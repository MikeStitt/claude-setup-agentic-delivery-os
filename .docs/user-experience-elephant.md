# User experience: ADOS-on-Ollama on a project ("elephant")

This is the end-to-end story of taking a brand-new, nearly-empty GitHub repo and
putting it under the Agentic Delivery OS (ADOS) — running **mostly on your own Mac**
(local Gemma via Ollama), using **cloud models only for the heavy-reasoning
agents**, with all agent work happening inside an **isolated Linux sandbox** so a
runaway build or command can't touch the rest of your machine.

## The cast

- **elephant** — your new, largely-empty project on GitHub.
- **ADOS** — the delivery framework (19 agents, 10-phase lifecycle) that runs in
  **OpenCode**.
- **This toolkit** (`claude-setup-agentic-delivery-os`) — installs and wires ADOS
  onto elephant with the local-Gemma + cloud hybrid and the Docker sandbox.

## 0. One-time machine setup (only ever the first time)

Install the host tools. Everything here is idempotent — already-present tools are
skipped.

```bash
git clone https://github.com/MikeStitt/claude-setup-agentic-delivery-os.git
cd claude-setup-agentic-delivery-os
./scripts/setup-dev.sh         # Homebrew packages for the toolkit itself
tools/ados-ollama-doctor       # reports what's installed vs missing, with fixes
```

`doctor` is read-only and tells you exactly what (if anything) is missing and how
to fix it. See **What gets installed** below.

## 1. Clone elephant

```bash
cd ~/projects
git clone https://github.com/<you>/elephant.git
cd elephant
```

## 2. Install ADOS-on-Ollama into elephant — one command

Preview first (changes nothing):

```bash
~/projects/claude-setup-agentic-delivery-os/tools/ados-ollama all --target . --dry-run
```

Then do it:

```bash
~/projects/claude-setup-agentic-delivery-os/tools/ados-ollama all --target .
```

In one pass this:

1. Runs preflight (`doctor`).
2. Installs/updates ADOS globally (`~/.ados`) and **into elephant**
   (`.opencode/agent`, `.opencode/command`, `doc/`, `.ai/`) so the sandbox can see
   the agents.
3. Ensures Ollama is running and the **Gemma** model is pulled.
4. Writes elephant's **`.opencode/opencode.jsonc`**: the Ollama provider + the
   per-agent hybrid model map (local Gemma for the cheap/high-volume agents, cloud
   for the heavy-reasoning ones). No secrets are written — API keys stay as
   `{env:...}` references.

Re-running `ados-ollama all` later is safe: it converges and leaves your hand-edits
alone. Commit the result — elephant now carries its own ADOS + model config.

## 3. Start the agentic delivery system (inside the sandbox)

```bash
~/projects/claude-setup-agentic-delivery-os/tools/ados-sandbox --target .
```

This boots a generously-sized **Linux microVM**, mounts elephant inside it, points
the local agents at **Ollama running on your Mac** (over the host gateway), allows
the cloud-model + GitHub endpoints, and drops you into **OpenCode** with `@pm`
ready.

From there, drive ADOS as usual — autopilot:

```text
@pm deliver change GH-1
```

…or step by step: `/plan-change` → `/write-spec` → `/write-test-plan` →
`/write-plan` → `/run-plan` → `/review` → `/check` → `/pr`.

Under the hood: the high-volume agents (`committer`, `runner`, …) think on **Gemma
on your Mac's GPU**; the heavy-reasoning agents (`architect`, `reviewer`, `coder`)
use the cloud; **every command, build, and test runs in the isolated VM**, not on
your host.

## What gets installed on your Mac (high level)

| Tool | Role | Often already present? |
|------|------|------------------------|
| **Homebrew** | installs the rest | usually yes |
| **bash 5** (brew) | the toolkit needs ≥4; macOS ships 3.2 | no (macOS has 3.2) |
| **Docker Desktop** (+ `docker sandbox`) | the isolated Linux microVM for agents | sometimes |
| **Ollama** + a **Gemma** model | local model inference on the Mac GPU | sometimes |
| **OpenCode** | the agent runtime ADOS runs in | sometimes |
| **ADOS** (`~/.ados`) | the delivery framework | no |
| **shellcheck / shfmt / bats** | dev-only, for building the toolkit | no |
| **this toolkit** | installs + wires everything above | no |

Inference (Gemma) runs **natively on the Mac** for full GPU/memory; only the
agents' command/build execution runs in the Linux VM.

## Why this is better than doing it by hand

- **One idempotent command** instead of a dozen fiddly, order-dependent steps you
  have to remember and repeat per project.
- **The wiring that's easy to get wrong is done for you** — the Ollama provider,
  the raised `num_ctx` that local tool-calling needs, the host-gateway URL so the
  VM can reach your Mac's Ollama, and the per-agent local-vs-cloud tiers.
- **Isolation by default** — agents can't touch anything outside the project; a bad
  build or injected instruction is contained in the VM.
- **Reproducible & version-controlled** — the config lives in elephant's git, so
  every clone and every teammate gets the identical setup; no "works on my machine."
- **Provenance & safe updates** — the installed ADOS version is recorded, and
  re-running updates cleanly while preserving your project-specific files.
- **Preflight catches problems early** — `doctor` tells you what's missing before
  you're mid-task wondering why an agent can't reach a model.
