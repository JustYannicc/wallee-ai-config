#!/usr/bin/env bash

set -Eeuo pipefail

readonly REPOSITORY_URL="https://github.com/JustYannicc/wallee-ai-config.git"
readonly DEFAULT_INSTALL_DIR="${HOME}/.local/share/wallee-ai-config"
brew_command="${TAILORBIRD_BREW_BIN:-}"

say() { printf '  %s\n' "$1"; }
stage() { printf '\n==> %s\n' "$1"; }
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }

[[ "$(uname -s)" == "Darwin" ]] || fail "Wallee AI Config currently supports macOS only."

ensure_homebrew() {
  if [[ -n "$brew_command" ]]; then
    [[ -x "$brew_command" ]] || fail "TAILORBIRD_BREW_BIN is not executable: ${brew_command}"
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_command="/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_command="/usr/local/bin/brew"
  elif command -v brew >/dev/null 2>&1; then
    brew_command="$(command -v brew)"
  else
    stage "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -x /opt/homebrew/bin/brew ]]; then
      brew_command="/opt/homebrew/bin/brew"
    elif [[ -x /usr/local/bin/brew ]]; then
      brew_command="/usr/local/bin/brew"
    fi
  fi
  [[ -x "$brew_command" ]] || fail "Homebrew installed but its executable could not be found."
}

resolve_checkout() {
  local script_dir install_dir
  script_dir=""
  if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || script_dir=""
  fi
  if [[ -f "${script_dir}/.tailorbird-root" ]]; then
    printf '%s' "$script_dir"
    return
  fi

  install_dir="${TAILORBIRD_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
  if [[ -d "${install_dir}/.git" ]]; then
    stage "Updating Wallee AI Config" >&2
    git -C "$install_dir" pull --ff-only >&2
  elif [[ -e "$install_dir" ]]; then
    fail "${install_dir} exists and is not a Git checkout. Move it, then rerun."
  else
    stage "Downloading Wallee AI Config" >&2
    mkdir -p "$(dirname "$install_dir")"
    git clone --depth 1 "$REPOSITORY_URL" "$install_dir" >&2
  fi
  printf '%s' "$install_dir"
}

printf '\nWallee AI Config · Tailorbird\n'
say "Installs the Mac tools, public Codex defaults, and public skills."

ensure_homebrew

if ! "$brew_command" list --formula git >/dev/null 2>&1; then
  stage "Installing Git"
  "$brew_command" install git
fi

repo_dir="$(resolve_checkout)"

stage "Installing Codex, ChatGPT, Node.js, pnpm, and Git"
HOMEBREW_NO_AUTO_UPDATE=1 "$brew_command" bundle install --no-upgrade --file "${repo_dir}/Brewfile"

stage "Configuring Codex and skills"
"${repo_dir}/scripts/configure.sh" "$@"

printf '\n%s\n' "Setup complete. Open ChatGPT and run 'codex login' if this Mac is not signed in yet."
