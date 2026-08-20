#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
assert_file() { [[ -e "$1" || -L "$1" ]] || fail "missing $1"; }
assert_contains() {
  if command -v rg >/dev/null 2>&1; then
    rg -F -- "$2" "$1" >/dev/null
  else
    grep -F -- "$2" "$1" >/dev/null
  fi || fail "$1 does not contain $2"
}

mkdir -p "$test_root/home/.codex"
printf 'legacy = true\n' > "$test_root/home/.codex/config.toml"

TAILORBIRD_HOME="$test_root/home" \
TAILORBIRD_CODEX_HOME="$test_root/home/.codex" \
  "$repo_dir/scripts/configure.sh" --safe --without-zendesk --skip-skills --yes

assert_file "$test_root/home/.codex/AGENTS.md"
assert_file "$test_root/home/.codex/config.toml"
assert_contains "$test_root/home/.codex/config.toml" 'sandbox_mode = "workspace-write"'
backup_count="$(find "$test_root/home/.codex" -name 'config.toml.backup-*' | wc -l | tr -d ' ')"
[[ "$backup_count" == 1 ]] || fail "expected one config backup, got $backup_count"

TAILORBIRD_HOME="$test_root/home" \
TAILORBIRD_CODEX_HOME="$test_root/home/.codex" \
  "$repo_dir/scripts/configure.sh" --safe --without-zendesk --skip-skills --yes

backup_count="$(find "$test_root/home/.codex" -name 'config.toml.backup-*' | wc -l | tr -d ' ')"
[[ "$backup_count" == 1 ]] || fail "rerun created another backup"

mkdir -p "$test_root/bin" "$test_root/skill-home"
cp "$repo_dir/tests/fixtures/npx" "$test_root/bin/npx"
cp "$repo_dir/tests/fixtures/codex" "$test_root/bin/codex"
chmod +x "$test_root/bin/npx" "$test_root/bin/codex"
: > "$test_root/commands.log"

PATH="$test_root/bin:$PATH" \
TAILORBIRD_TEST_LOG="$test_root/commands.log" \
TAILORBIRD_HOME="$test_root/skill-home" \
TAILORBIRD_CODEX_HOME="$test_root/skill-home/.codex" \
  "$repo_dir/scripts/configure.sh" --safe --with-zendesk --yes

assert_contains "$test_root/commands.log" "skills add JustYannicc/skills --skill * --global --agent codex --yes"
assert_contains "$test_root/commands.log" "skills add mattpocock/skills --skill grilling research writing-for-agents --global --agent codex --yes"
assert_contains "$test_root/commands.log" "skills add cursor/plugins --skill unslop --global --agent codex --yes"
assert_contains "$test_root/commands.log" "codex mcp add zendesk -- npx -y @fruggr/zendesk-mcp-server wallee --namespace tickets --mode single"

node "$repo_dir/tools/generate-brand.mjs" --check
printf 'PASS: configure script is idempotent and Zendesk stays opt-in\n'
