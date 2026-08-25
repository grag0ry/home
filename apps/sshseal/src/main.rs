mod agent;
mod crypto;

use std::io::{self, Read, Write};
use std::process::ExitCode;

use agent::{Client, Identity};

fn cmd_identities() -> io::Result<()> {
    let mut client = Client::connect()?;
    for id in client.list_identities()? {
        println!("{} {} ({})", id.fingerprint(), id.comment, id.algorithm());
    }
    Ok(())
}

fn select_identity(client: &mut Client, requested: Option<&str>) -> io::Result<Identity> {
    let identities = client.list_identities()?;
    match requested {
        Some(fp) => {
            let id = identities
                .into_iter()
                .find(|id| id.fingerprint() == fp)
                .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, format!("no identity {fp} loaded in ssh-agent")))?;
            if !id.is_ed25519() {
                return Err(io::Error::new(
                    io::ErrorKind::InvalidInput,
                    format!(
                        "{fp} is {}, sshseal only supports ed25519 (needs reproducible signatures)",
                        id.algorithm()
                    ),
                ));
            }
            Ok(id)
        }
        None => {
            let mut ed25519: Vec<_> = identities.into_iter().filter(Identity::is_ed25519).collect();
            match ed25519.len() {
                0 => Err(io::Error::new(io::ErrorKind::NotFound, "no ed25519 identities loaded in ssh-agent")),
                1 => Ok(ed25519.remove(0)),
                _ => {
                    let list = ed25519
                        .iter()
                        .map(|id| format!("  {} {}", id.fingerprint(), id.comment))
                        .collect::<Vec<_>>()
                        .join("\n");
                    Err(io::Error::new(
                        io::ErrorKind::InvalidInput,
                        format!("multiple ed25519 identities loaded, pick one with --identity:\n{list}"),
                    ))
                }
            }
        }
    }
}

fn cmd_encrypt(requested: Option<&str>) -> io::Result<()> {
    let mut client = Client::connect()?;
    let identity = select_identity(&mut client, requested)?;

    let mut plaintext = Vec::new();
    io::stdin().read_to_end(&mut plaintext)?;

    let mut nonce = [0u8; crypto::NONCE_LEN];
    getrandom::getrandom(&mut nonce).map_err(|e| io::Error::other(e.to_string()))?;

    let signature = client.sign(&identity.key_blob, &nonce)?;
    let ciphertext = crypto::seal(&plaintext, &signature);

    let mut blob = Vec::new();
    crypto::Header {
        fingerprint: identity.fingerprint_digest(),
        nonce,
    }
    .write(&mut blob);
    blob.extend_from_slice(&ciphertext);

    io::stdout().write_all(&blob)
}

fn cmd_decrypt() -> io::Result<()> {
    let mut input = Vec::new();
    io::stdin().read_to_end(&mut input)?;
    let (header, ciphertext) = crypto::Header::parse(&input)?;

    let mut client = Client::connect()?;
    let identity = client
        .list_identities()?
        .into_iter()
        .find(|id| id.fingerprint_digest() == header.fingerprint)
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "required key is not loaded in ssh-agent"))?;

    let signature = client.sign(&identity.key_blob, &header.nonce)?;
    let plaintext = crypto::unseal(ciphertext, &signature)?;
    io::stdout().write_all(&plaintext)
}

fn parse_identity_flag(mut args: impl Iterator<Item = String>) -> io::Result<Option<String>> {
    match args.next().as_deref() {
        None => Ok(None),
        Some("--identity") => Ok(Some(
            args.next()
                .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidInput, "--identity requires a value"))?,
        )),
        Some(other) => Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            format!("unknown argument: {other}"),
        )),
    }
}

fn main() -> ExitCode {
    let mut args = std::env::args().skip(1);
    let result = match args.next().as_deref() {
        Some("identities") => cmd_identities(),
        Some("encrypt") => parse_identity_flag(args)
            .map(|id| id.or_else(|| std::env::var("SSHSEAL_IDENTITY").ok()))
            .and_then(|id| cmd_encrypt(id.as_deref())),
        Some("decrypt") => cmd_decrypt(),
        _ => {
            eprintln!("usage: sshseal encrypt [--identity <fingerprint>] | decrypt | identities");
            eprintln!("       --identity defaults to $SSHSEAL_IDENTITY if set");
            return ExitCode::FAILURE;
        }
    };
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("sshseal: {e}");
            ExitCode::FAILURE
        }
    }
}
