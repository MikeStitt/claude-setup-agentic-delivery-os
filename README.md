# claude-setup-agentic-delivery-os

Bash-first tooling that installs and adjusts
[Agentic Delivery OS (ADOS)](https://github.com/juliusz-cwiakalski/agentic-delivery-os)
onto a project and wires it to a **hybrid model runtime**: local
[Ollama](https://ollama.com)-served **Gemma** for the high-volume agents, **cloud**
models for the high-stakes agents, with the ADOS/OpenCode agents running inside an
isolated **Docker (Linux microVM) sandbox**. Tuned for a local machine like a
MacBook Pro — Gemma inference runs natively on the Mac GPU; only command/build
execution runs in the VM.

See the full walkthrough in
[`.docs/user-experience-elephant.md`](.docs/user-experience-elephant.md), and the
development rules in [`.specify/memory/constitution.md`](.specify/memory/constitution.md).

## Prerequisites (host)

Homebrew · modern `bash` (≥5) · Docker Desktop (with `docker sandbox`) · Ollama
(+ a tool-capable Gemma model) · OpenCode. Run `tools/ados-ollama-doctor` to see
what's missing. For host Ollama to be reachable from the sandbox, start it with
`OLLAMA_HOST=0.0.0.0:11434`.

## Quick start

```bash
# one-time: dev tools for working ON this toolkit
./scripts/setup-dev.sh
tools/ados-ollama-doctor

# install ADOS-on-Ollama into a target project (idempotent; preview with --dry-run)
tools/ados-ollama all --target /path/to/project --model gemma3:27b

# launch OpenCode for the project inside the Docker sandbox
tools/ados-sandbox --target /path/to/project
```

## Commands

| Command | Role |
| --- | --- |
| `tools/ados-ollama` | orchestrator: doctor / install / setup / configure / sandbox / all |
| `tools/ados-ollama-doctor` | read-only preflight (host deps) |
| `scripts/setup-ollama.sh` | ensure Ollama + pull/verify a Gemma model |
| `scripts/install-ados.sh` | ADOS install + project-local agent/command defs + provenance |
| `tools/gen-opencode-config` | write the hybrid `.opencode/opencode.jsonc` |
| `tools/ados-sandbox` | run OpenCode in an isolated Docker sandbox |
| `tools/ados-sandbox-macos` | experimental Seatbelt write-confinement (macOS-native work) |

Every mutating script supports `--dry-run` and is idempotent.

## Development

```bash
make check     # shellcheck + shfmt -d + bats (the quality gate)
make fmt-fix   # apply shfmt formatting
make test      # bats suites only
make help      # list verbs
```

Standards live in the constitution and its per-work-type parts under
`.specify/memory/parts/`. Live plan + progress:
[`.docs/plan-ados-ollama-tooling.md`](.docs/plan-ados-ollama-tooling.md).

## License

MIT — see [`LICENSE`](LICENSE).
