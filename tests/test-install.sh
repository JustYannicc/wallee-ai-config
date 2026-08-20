#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
assert_contains() { rg -F -- "$2" "$1" >/dev/null || fail "$1 does not contain $2"; }

mkdir -p "$test_root/bin" "$test_root/home" "$test_root/remote-script"
cp "$repo_dir/tests/fixtures/brew" "$test_root/bin/brew"
cp "$repo_dir/tests/fixtures/git" "$test_root/bin/git"
cp "$repo_dir/tests/fixtures/uname" "$test_root/bin/uname"
cp "$repo_dir/install.sh" "$test_root/remote-script/install.sh"
chmod +x "$test_root/bin/brew" "$test_root/bin/git" "$test_root/bin/uname"
: > "$test_root/commands.log"

PATH="$test_root/bin:$PATH" \
HOME="$test_root/home" \
TAILORBIRD_BREW_BIN="$test_root/bin/brew" \
TAILORBIRD_INSTALL_DIR="$test_root/checkout" \
TAILORBIRD_TEST_LOG="$test_root/commands.log" \
TAILORBIRD_TEST_REPO="$repo_dir" \
  "$test_root/remote-script/install.sh" \
  --safe --without-zendesk --skip-skills --yes

[[ -d "$test_root/checkout/.git" ]] || fail "bootstrap did not create the checkout"
[[ -L "$test_root/home/.codex/AGENTS.md" ]] || fail "bootstrap did not link AGENTS.md"
[[ -L "$test_root/home/.codex/config.toml" ]] || fail "bootstrap did not link config.toml"
assert_contains "$test_root/commands.log" "brew install git"
assert_contains "$test_root/commands.log" "git clone --depth 1 https://github.com/JustYannicc/wallee-ai-config.git $test_root/checkout"
assert_contains "$test_root/commands.log" "brew bundle install --no-upgrade --file $test_root/checkout/Brewfile"

printf 'PASS: remote one-command bootstrap reaches the safe configured state\n'
