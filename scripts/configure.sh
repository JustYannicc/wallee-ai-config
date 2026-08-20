#!/usr/bin/env bash

set -Eeuo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_home="${TAILORBIRD_HOME:-$HOME}"
codex_home="${TAILORBIRD_CODEX_HOME:-${target_home}/.codex}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
profile="${TAILORBIRD_PROFILE:-ask}"
zendesk="${TAILORBIRD_WITH_ZENDESK:-ask}"
skip_skills=false
assume_yes=false

say() { printf '  %s\n' "$1"; }
warn() { printf '  warning: %s\n' "$1" >&2; }
fail() { printf 'error: %s\n' "$1" >&2; exit 1; }

confirm() {
  local prompt="$1" reply=""
  [[ "$assume_yes" == false && -t 0 ]] || return 1
  printf '  %s [y/N] ' "$prompt"
  read -r reply || true
  [[ "$reply" =~ ^[Yy]$ ]]
}

backup_and_link() {
  local source="$1" target="$2" backup_base backup suffix=1
  [[ -r "$source" ]] || fail "Missing source: ${source}"

  if [[ -L "$target" && -r "$target" && "$target" -ef "$source" ]]; then
    say "ok      ${target}"
    return
  fi

  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    backup_base="${target}.backup-${timestamp}"
    backup="$backup_base"
    while [[ -e "$backup" || -L "$backup" ]]; do
      backup="${backup_base}-${suffix}"
      suffix=$((suffix + 1))
    done
    mv "$target" "$backup"
    say "backup  ${backup}"
  fi
  ln -s "$source" "$target"
  say "linked  ${target} -> ${source}"
}

install_skills() {
  command -v npx >/dev/null 2>&1 || fail "npx is unavailable after installing Node.js."
  say "Installing every public skill from JustYannicc/skills."
  npx --yes skills add JustYannicc/skills --skill '*' --global --agent codex --yes
  say "Installing the suite dependencies and writing-for-agents."
  npx --yes skills add mattpocock/skills \
    --skill grilling research writing-for-agents \
    --global --agent codex --yes
  say "Installing unslop."
  npx --yes skills add cursor/plugins --skill unslop --global --agent codex --yes
}

install_zendesk() {
  command -v codex >/dev/null 2>&1 || fail "Codex is unavailable after installation."
  if codex mcp get zendesk >/dev/null 2>&1; then
    say "ok      Zendesk MCP is already configured"
    return
  fi
  codex mcp add zendesk -- \
    npx -y @fruggr/zendesk-mcp-server wallee \
    --namespace tickets \
    --mode single
  say "added   Zendesk MCP"
}

while (($#)); do
  case "$1" in
    --safe) profile="safe" ;;
    --full-trust) profile="full-trust" ;;
    --with-zendesk) zendesk="yes" ;;
    --without-zendesk) zendesk="no" ;;
    --skip-skills) skip_skills=true ;;
    --yes) assume_yes=true ;;
    -h|--help)
      printf '%s\n' \
        "Usage: scripts/configure.sh [--safe|--full-trust] [--with-zendesk|--without-zendesk] [--yes]" \
        "" \
        "The safe profile is used when input is unavailable. Zendesk is never installed without a separate opt-in."
      exit 0
      ;;
    *) fail "Unknown option: $1" ;;
  esac
  shift
done

if [[ "$profile" == "ask" ]]; then
  warn "The full-trust profile disables approvals and grants full filesystem access."
  if confirm "Install Yannic's full-trust Codex profile?"; then
    profile="full-trust"
  else
    profile="safe"
  fi
fi
[[ "$profile" == "safe" || "$profile" == "full-trust" ]] || fail "Invalid profile: ${profile}"

say "Installing the ${profile} Codex profile."
backup_and_link "${repo_dir}/config/AGENTS.md" "${codex_home}/AGENTS.md"
backup_and_link "${repo_dir}/config/codex-${profile}.toml" "${codex_home}/config.toml"

if [[ "$skip_skills" == false ]]; then
  install_skills
fi

if [[ "$zendesk" == "ask" ]]; then
  if confirm "Install the Zendesk MCP server? This requires separate team approval."; then
    zendesk="yes"
  else
    zendesk="no"
  fi
fi

if [[ "$zendesk" == "yes" ]]; then
  install_zendesk
else
  say "skipped Zendesk MCP"
fi

say "Codex configuration is ready in ${codex_home}."
