# Global Claude Code instructions

## Available CLI tools

Besides standard GNU/coreutils, the following modern Rust-based utilities are installed:

- `fd` — fast alternative to `find`
- `rg` (ripgrep) — fast grep (also used internally by the Grep tool)
- `bat` — `cat` with syntax highlighting, useful in pipelines
- `delta` — syntax-highlighted git diff pager
- `dos2unix` / `unix2dos` — CRLF<->LF conversion; prefer these over ad-hoc
  `sed` one-liners whenever a file's line endings need converting (e.g. when
  moving a patch between an LF checkout and a CRLF one)

Not on `PATH`, call by full path (dir: `~/projects/vimdevpack/devenv/bin/`):

- `ty` — Python type checker (Astral)
- `shellcheck` — shell script linter

Use these in `Bash` tool calls when they offer a cleaner solution than standard
coreutils. Still prefer dedicated tools (Grep, Glob, Read) over Bash for
standard file search and reading operations.

## Language

Always respond in Russian.

## Engineering Principles

- **Keep it simple** - prefer the simplest solution that correctly solves the problem. Follow KISS. Avoid unnecessary abstractions, indirection, generalization, and speculative complexity.

- **Complexity must pay for itself** - every abstraction, validation layer, optimization, or special case should solve a concrete problem. Do not add complexity for hypothetical future needs.

- **Do one thing well** - follow the UNIX philosophy. Keep components focused, composable, and loosely coupled. Prefer small, clear interfaces and mechanisms that can be combined over monolithic or overly generic designs.

- **Readability matters** - code should be easy to understand, reason about, debug, and maintain. Prefer explicit and straightforward code over clever constructs. Optimize for the reader, not for showing sophistication.

- **Performance matters** - avoid unnecessary work, allocations, copies, synchronization, syscalls, and algorithmic overhead. Do not introduce meaningful performance regressions without a concrete and justified reason.

- **Optimize for real-world use** - prioritize actual and common usage patterns over theoretical edge cases. Do not complicate the implementation for scenarios with no demonstrated practical impact.

- **Do not over-defend against misuse** - avoid checks, safeguards, wrappers, and defensive complexity whose primary purpose is protecting callers from deliberately violating documented contracts or preconditions. Trust callers to use an API correctly unless there is a concrete reason not to. The caller is responsible for knowingly performing destructive operations.

- **Fail clearly rather than hide errors** - do not silently recover from programming errors, broken invariants, or invalid states when recovery can hide bugs. Prefer explicit failures and clear error propagation over surprising fallback behavior.

- **Preserve compatibility by default** - treat existing behavior, APIs, ABIs, data formats, protocols, and other compatibility guarantees as constraints. Breaking compatibility is acceptable only when there is a strong reason. If a proposed change breaks compatibility, explicitly identify the breakage, explain why it is justified and what it affects, and ask the user before proceeding.

- **Prefer mechanisms over policy** - where practical, provide simple, predictable primitives and let callers decide how to combine and use them. Avoid embedding unnecessary policy or assumptions into low-level components.

- **Be pragmatic** - solve the problem that actually exists. Prefer proven, boring, maintainable solutions over theoretically elegant designs that add complexity without proportional practical benefit.

## Code comments

- A comment must add knowledge the code cannot express: why, an invariant,
  a non-obvious constraint, the shape of a data structure.
- Do not retell the code. Do not repeat another comment, the README, the PR
  description or the tests. No long justifications or references the code
  does not need.
- For simple code, one line on what and one on why is usually enough.
- Length follows the complexity of what the code cannot show, not a limit.
  A non-trivial data structure or algorithm deserves a detailed comment:
  memory layout, invariants, state before and after an operation, ASCII
  diagrams.
- Match the comment density of the surrounding file.
- In a shared component, do not name a specific product or caller.

@~/.claude/CLAUDE-private.md
