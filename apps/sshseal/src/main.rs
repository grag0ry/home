mod agent;

use std::process::ExitCode;

fn usage() -> ExitCode {
    eprintln!("usage: sshseal encrypt|decrypt|identities");
    ExitCode::FAILURE
}

fn identities() -> ExitCode {
    let mut client = match agent::Client::connect() {
        Ok(c) => c,
        Err(e) => {
            eprintln!("sshseal: {e}");
            return ExitCode::FAILURE;
        }
    };
    match client.list_identities() {
        Ok(identities) => {
            for id in identities {
                println!("{} {}", id.fingerprint(), id.comment);
            }
            ExitCode::SUCCESS
        }
        Err(e) => {
            eprintln!("sshseal: {e}");
            ExitCode::FAILURE
        }
    }
}

fn main() -> ExitCode {
    match std::env::args().nth(1).as_deref() {
        Some("encrypt") => todo!(),
        Some("decrypt") => todo!(),
        Some("identities") => identities(),
        _ => usage(),
    }
}
