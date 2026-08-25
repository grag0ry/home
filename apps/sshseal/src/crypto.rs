use std::io;

use aes_gcm::aead::{Aead, KeyInit};
use aes_gcm::{Aes256Gcm, Nonce};
use hkdf::Hkdf;
use sha2::Sha256;

const MAGIC: [u8; 4] = *b"SSE1";
pub const NONCE_LEN: usize = 32;
const FINGERPRINT_LEN: usize = 32; // raw SHA256 digest, not the "SHA256:base64" display form
const HEADER_LEN: usize = MAGIC.len() + FINGERPRINT_LEN + NONCE_LEN;

pub struct Header {
    pub fingerprint: [u8; FINGERPRINT_LEN],
    pub nonce: [u8; NONCE_LEN],
}

impl Header {
    pub fn parse(data: &[u8]) -> io::Result<(Header, &[u8])> {
        if data.len() < HEADER_LEN || data[..4] != MAGIC {
            return Err(io::Error::new(io::ErrorKind::InvalidData, "not an sshseal blob"));
        }
        let fingerprint = data[4..4 + FINGERPRINT_LEN].try_into().unwrap();
        let nonce = data[4 + FINGERPRINT_LEN..HEADER_LEN].try_into().unwrap();
        Ok((Header { fingerprint, nonce }, &data[HEADER_LEN..]))
    }

    pub fn write(&self, out: &mut Vec<u8>) {
        out.extend_from_slice(&MAGIC);
        out.extend_from_slice(&self.fingerprint);
        out.extend_from_slice(&self.nonce);
    }
}

/// Derives the AES-256-GCM key+nonce from an ed25519 agent signature over the
/// blob's nonce. The nonce and fingerprint are stored in the clear right next
/// to the ciphertext; the only thing standing between them and the key is
/// whether an agent holding the matching private key is willing to sign.
fn derive(signature: &[u8]) -> (Aes256Gcm, [u8; 12]) {
    let hkdf = Hkdf::<Sha256>::new(None, signature);
    let mut okm = [0u8; 44];
    hkdf.expand(b"sshseal-v1", &mut okm)
        .expect("44 bytes is within HKDF-SHA256's output limit");
    let cipher = Aes256Gcm::new_from_slice(&okm[..32]).expect("okm[..32] is exactly 32 bytes");
    (cipher, okm[32..].try_into().unwrap())
}

pub fn seal(plaintext: &[u8], signature: &[u8]) -> Vec<u8> {
    let (cipher, iv) = derive(signature);
    cipher
        .encrypt(Nonce::from_slice(&iv), plaintext)
        .expect("AES-256-GCM encryption of an in-memory buffer does not fail")
}

pub fn unseal(ciphertext: &[u8], signature: &[u8]) -> io::Result<Vec<u8>> {
    let (cipher, iv) = derive(signature);
    cipher
        .decrypt(Nonce::from_slice(&iv), ciphertext)
        .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "decryption failed (wrong key or corrupted data)"))
}
