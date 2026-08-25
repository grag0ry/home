use std::process::ExitCode;

fn usage() -> ExitCode {
    eprintln!("usage: sshseal encrypt|decrypt");
    ExitCode::FAILURE
}

fn main() -> ExitCode {
    match std::env::args().nth(1).as_deref() {
        Some("encrypt") => todo!(),
        Some("decrypt") => todo!(),
        _ => usage(),
    }
}
