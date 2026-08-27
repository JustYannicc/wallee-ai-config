<p align="center">
  <img src="assets/tailorbird-mark.svg" width="112" height="112" alt="Tailorbird">
</p>

<p align="center">
  <img src="assets/wallee-ai-config-wordmark.svg" width="920" alt="Wallee AI Config">
</p>

<p align="center">One command for a public, rerunnable Wallee AI setup on macOS.</p>

## Install

Run this in Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JustYannicc/wallee-ai-config/main/install.sh)"
```

The installer asks two separate questions:

1. Use the safe Codex profile or Yannic's full-trust profile. Safe is the fallback when input is unavailable.
2. Add Zendesk. The default is no. Only choose yes after the team has agreed to it.

Rerun the same command to update the checkout and repair the setup. Existing Codex instruction and config files move to timestamped backups before Tailorbird links its files.

## What it installs

Homebrew is installed first when it is missing. The checked-in `Brewfile` then installs:

- Codex
- ChatGPT for macOS
- Node.js
- pnpm
- Git

Tailorbird checks out to `~/.local/share/wallee-ai-config`, installs global Codex instructions, and links one of these project-free configurations:

- `config/codex-safe.toml` keeps approvals and sandboxing on.
- `config/codex-full-trust.toml` matches Yannic's autonomous settings. It disables approvals, grants full filesystem access, and allows destructive and open-world app tools.

Neither profile contains credentials, private URLs, provider proxies, local project paths, trust entries, hooks, histories, or caches.

## Skills

The installer uses the public [skills.sh CLI](https://skills.sh/) and installs every skill from [JustYannicc/skills](https://github.com/JustYannicc/skills):

- `thinking-in-systems`, `domain-modeling`, `framing-decisions`, and `choosing-interventions`
- `representing-systems`, `designing-interfaces`, `implementing-systems`, and `automating-systems`
- `operating-a-system`, `evaluating-systems`, `changing-systems`, and `governing-systems`
- `wayfinder`, `prototype`, `to-spec`, `to-tickets`, and `review`
- `setup-system-thinking` and `creating-skills`

It also installs the standard suite dependencies `grilling` and `research`, plus `writing-for-agents` from [mattpocock/skills](https://github.com/mattpocock/skills), and `unslop` from [cursor/plugins](https://github.com/cursor/plugins).

## Zendesk is opt-in

The default setup skips Zendesk. After approval, install everything with Zendesk in one command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JustYannicc/wallee-ai-config/main/install.sh)" -- --with-zendesk
```

Or add Zendesk to an existing setup:

```bash
~/.local/share/wallee-ai-config/scripts/configure.sh --with-zendesk
```

That runs:

```bash
codex mcp add zendesk -- \
  npx -y @fruggr/zendesk-mcp-server wallee \
  --namespace tickets \
  --mode single
```

## Explicit profiles

From a checkout, bypass the profile question with one of these:

```bash
./scripts/configure.sh --safe
./scripts/configure.sh --full-trust
```

Adding `--yes` keeps the safe profile and still skips Zendesk unless `--with-zendesk` is also present.

## Verify

```bash
bash -n install.sh scripts/configure.sh tests/test-configure.sh tests/test-install.sh tests/fixtures/*
shellcheck install.sh scripts/configure.sh tests/test-configure.sh tests/test-install.sh tests/fixtures/*
tests/test-configure.sh
tests/test-install.sh
```

The common tailorbird mark and ANSI Shadow wordmark are generated from `tools/generate-brand.mjs`. Regenerate them with `node tools/generate-brand.mjs`.

## License

MIT
