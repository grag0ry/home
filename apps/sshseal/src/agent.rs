use std::io::{self, Read, Write};
use std::os::unix::net::UnixStream;

use base64::Engine;
use sha2::{Digest, Sha256};

const SSH_AGENTC_REQUEST_IDENTITIES: u8 = 11;
const SSH_AGENT_IDENTITIES_ANSWER: u8 = 12;
const SSH_AGENTC_SIGN_REQUEST: u8 = 13;
const SSH_AGENT_SIGN_RESPONSE: u8 = 14;
const SSH_AGENT_FAILURE: u8 = 5;

pub struct Identity {
    pub key_blob: Vec<u8>,
    pub comment: String,
}

impl Identity {
    pub fn fingerprint_digest(&self) -> [u8; 32] {
        Sha256::digest(&self.key_blob).into()
    }

    pub fn fingerprint(&self) -> String {
        format!(
            "SHA256:{}",
            base64::engine::general_purpose::STANDARD_NO_PAD.encode(self.fingerprint_digest())
        )
    }

    /// The key's algorithm name (e.g. "ssh-ed25519", "ssh-rsa"), read from the
    /// wire-format key blob's first field.
    pub fn algorithm(&self) -> &str {
        Reader::new(&self.key_blob)
            .string()
            .ok()
            .and_then(|s| std::str::from_utf8(s).ok())
            .unwrap_or("")
    }

    /// sshseal only works with ed25519 keys: agent signatures over the same
    /// message must be reproducible, and only EdDSA guarantees that (RSA/ECDSA
    /// signatures here are randomized).
    pub fn is_ed25519(&self) -> bool {
        self.algorithm() == "ssh-ed25519"
    }
}

pub struct Client {
    stream: UnixStream,
}

impl Client {
    pub fn connect() -> io::Result<Self> {
        let path = std::env::var_os("SSH_AUTH_SOCK")
            .ok_or_else(|| io::Error::other("SSH_AUTH_SOCK is not set - is ssh-agent running?"))?;
        Self::connect_to(path)
    }

    pub fn connect_to(path: impl AsRef<std::path::Path>) -> io::Result<Self> {
        let path = path.as_ref();
        let stream = UnixStream::connect(path).map_err(|e| {
            io::Error::new(
                e.kind(),
                format!("can't connect to ssh-agent at {} ({e}) - is SSH_AUTH_SOCK stale?", path.display()),
            )
        })?;
        Ok(Self { stream })
    }

    pub fn list_identities(&mut self) -> io::Result<Vec<Identity>> {
        let reply = self.roundtrip(&[SSH_AGENTC_REQUEST_IDENTITIES])?;
        let mut r = Reader::new(&reply);
        match r.u8()? {
            SSH_AGENT_IDENTITIES_ANSWER => {}
            SSH_AGENT_FAILURE => return Err(agent_failure()),
            other => return Err(unexpected_reply(other)),
        }
        let count = r.u32()?;
        (0..count)
            .map(|_| {
                let key_blob = r.string()?.to_vec();
                let comment = String::from_utf8_lossy(r.string()?).into_owned();
                Ok(Identity { key_blob, comment })
            })
            .collect()
    }

    /// Signs `data` with the key identified by `key_blob` (as returned by `list_identities`).
    /// Returns the raw signature bytes, without the algorithm-name wrapper the wire format adds.
    pub fn sign(&mut self, key_blob: &[u8], data: &[u8]) -> io::Result<Vec<u8>> {
        let mut body = vec![SSH_AGENTC_SIGN_REQUEST];
        write_string(&mut body, key_blob);
        write_string(&mut body, data);
        body.extend_from_slice(&0u32.to_be_bytes()); // flags: none (ed25519 has no signature variants)

        let reply = self.roundtrip(&body)?;
        let mut r = Reader::new(&reply);
        match r.u8()? {
            SSH_AGENT_SIGN_RESPONSE => {}
            SSH_AGENT_FAILURE => return Err(agent_failure()),
            other => return Err(unexpected_reply(other)),
        }
        let mut sig = Reader::new(r.string()?);
        let _algo = sig.string()?;
        Ok(sig.string()?.to_vec())
    }

    fn roundtrip(&mut self, body: &[u8]) -> io::Result<Vec<u8>> {
        self.stream.write_all(&(body.len() as u32).to_be_bytes())?;
        self.stream.write_all(body)?;

        let mut len = [0u8; 4];
        self.stream.read_exact(&mut len)?;
        let mut reply = vec![0u8; u32::from_be_bytes(len) as usize];
        self.stream.read_exact(&mut reply)?;
        Ok(reply)
    }
}

fn write_string(buf: &mut Vec<u8>, s: &[u8]) {
    buf.extend_from_slice(&(s.len() as u32).to_be_bytes());
    buf.extend_from_slice(s);
}

struct Reader<'a> {
    data: &'a [u8],
    pos: usize,
}

impl<'a> Reader<'a> {
    fn new(data: &'a [u8]) -> Self {
        Self { data, pos: 0 }
    }

    fn u8(&mut self) -> io::Result<u8> {
        let b = *self.data.get(self.pos).ok_or_else(truncated)?;
        self.pos += 1;
        Ok(b)
    }

    fn u32(&mut self) -> io::Result<u32> {
        let bytes: [u8; 4] = self
            .data
            .get(self.pos..self.pos + 4)
            .ok_or_else(truncated)?
            .try_into()
            .unwrap();
        self.pos += 4;
        Ok(u32::from_be_bytes(bytes))
    }

    fn string(&mut self) -> io::Result<&'a [u8]> {
        let len = self.u32()? as usize;
        let s = self.data.get(self.pos..self.pos + len).ok_or_else(truncated)?;
        self.pos += len;
        Ok(s)
    }
}

fn truncated() -> io::Error {
    io::Error::new(io::ErrorKind::UnexpectedEof, "truncated ssh-agent reply")
}

fn agent_failure() -> io::Error {
    io::Error::other("ssh-agent returned SSH_AGENT_FAILURE")
}

fn unexpected_reply(kind: u8) -> io::Error {
    io::Error::new(
        io::ErrorKind::InvalidData,
        format!("unexpected ssh-agent reply type {kind}"),
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use ed25519_dalek::{Signature, Verifier, VerifyingKey};
    use std::process::Command;

    /// Spawns a throwaway ssh-agent + ed25519 key and exercises list_identities/sign
    /// against it, verifying the signature with ed25519-dalek as an independent check.
    #[test]
    fn sign_and_list_identities_roundtrip() {
        let dir = std::env::temp_dir().join(format!("sshseal-agent-test-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&dir);
        std::fs::create_dir_all(&dir).unwrap();
        let key_path = dir.join("testkey");

        let status = Command::new("ssh-keygen")
            .args(["-t", "ed25519", "-N", "", "-C", "test"])
            .arg("-f")
            .arg(&key_path)
            .status()
            .unwrap();
        assert!(status.success());

        let agent_out = Command::new("ssh-agent").arg("-s").output().unwrap();
        let agent_out = String::from_utf8(agent_out.stdout).unwrap();
        let field = |name: &str| {
            agent_out
                .lines()
                .find_map(|l| l.strip_prefix(name)?.split(';').next())
                .unwrap_or_else(|| panic!("no {name} in ssh-agent output"))
                .to_string()
        };
        let sock = field("SSH_AUTH_SOCK=");
        let pid = field("SSH_AGENT_PID=");

        let result = std::panic::catch_unwind(|| {
            let status = Command::new("ssh-add")
                .arg(&key_path)
                .env("SSH_AUTH_SOCK", &sock)
                .status()
                .unwrap();
            assert!(status.success());

            let mut client = Client::connect_to(&sock).unwrap();
            let identities = client.list_identities().unwrap();
            assert_eq!(identities.len(), 1);
            let id = &identities[0];
            assert_eq!(id.comment, "test");

            let data = b"sshseal-test-nonce";
            let sig1 = client.sign(&id.key_blob, data).unwrap();
            let sig2 = client.sign(&id.key_blob, data).unwrap();
            assert_eq!(sig1, sig2, "ed25519 agent signatures must be deterministic");

            let mut key_reader = Reader::new(&id.key_blob);
            let _algo = key_reader.string().unwrap();
            let pubkey: [u8; 32] = key_reader.string().unwrap().try_into().unwrap();
            let verifying_key = VerifyingKey::from_bytes(&pubkey).unwrap();
            let signature = Signature::from_bytes(sig1.as_slice().try_into().unwrap());
            verifying_key
                .verify(data, &signature)
                .expect("agent signature must verify against its own public key");
        });

        let _ = Command::new("kill").arg(&pid).status();
        let _ = std::fs::remove_dir_all(&dir);
        result.unwrap();
    }
}
