# Tailorbird repository instructions

- Keep the public installer macOS-only and safe to rerun.
- Keep `config/codex-safe.toml` as the default. Full filesystem access requires an explicit choice.
- Keep Zendesk behind its own explicit opt-in. Never add it through the default path.
- Treat `tools/generate-brand.mjs` as the source of truth for generated SVG assets. Run it with `--check` before handoff.
- Run `tests/test-configure.sh`, `bash -n install.sh scripts/configure.sh`, and ShellCheck when it is available.
- Keep secrets, authentication, private URLs, machine-specific paths, and project-specific configuration out of the repository.
- Apply `unslop` to prose. Use `writing-for-agents` when changing this file or `config/AGENTS.md`.
