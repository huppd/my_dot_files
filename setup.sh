#!/usr/bin/env bash
# ~/.vim/setup.sh
# Idempotent "fresh clone -> fully configured" bootstrap.
# Never overwrites a real (non-symlink) file without backing it up first.

set -uo pipefail

VIM_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%dT%H%M%S)"

log()  { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }

# --- 1. ~/.vimrc symlink ---------------------------------------------------
link_dotfile() {
  local target="$1" src="$2"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
    log "$target already -> $src, skipping"; return
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup="${target}.bak.${TS}"
    log "$target exists and differs, backing up to $backup"
    mv "$target" "$backup"
  fi
  ln -s "$src" "$target"
  log "linked $target -> $src"
}
link_dotfile "$HOME/.vimrc" "$VIM_DIR/vimrc"

# --- 2. vim-plug itself (vendored; download only as a fallback) ----------
PLUG_VIM="$VIM_DIR/autoload/plug.vim"
if [ ! -f "$PLUG_VIM" ]; then
  log "autoload/plug.vim missing, attempting to download it"
  mkdir -p "$VIM_DIR/autoload"
  if command -v curl >/dev/null 2>&1; then
    curl -fLo "$PLUG_VIM" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
      || warn "download failed (offline?); vim-plug unavailable this run"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$PLUG_VIM" \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
      || warn "download failed (offline?); vim-plug unavailable this run"
  else
    warn "no curl/wget and plug.vim not vendored; skipping plugin manager setup"
  fi
else
  log "vim-plug already vendored at autoload/plug.vim"
fi

# --- 3. install plugins headlessly ---------------------------------------
if [ -f "$PLUG_VIM" ] && command -v vim >/dev/null 2>&1; then
  log "running PlugInstall (needs network access to GitHub)"
  if ! vim -es -u "$VIM_DIR/vimrc" -c "PlugInstall --sync" -c "qa!"; then
    warn "PlugInstall reported errors (no network from this node?)"
    warn "re-run this script later from a machine that can reach GitHub"
  fi
else
  warn "vim or plug.vim not available; skipped plugin install"
fi

# --- 4. ~/.claude/settings.json sync (merge, never blind-overwrite) ------
CLAUDE_DIR="$HOME/.claude"
CLAUDE_TARGET="$CLAUDE_DIR/settings.json"
CLAUDE_REPO_FILE="$VIM_DIR/claude/settings.json"

if [ -f "$CLAUDE_REPO_FILE" ]; then
  mkdir -p "$CLAUDE_DIR"
  if [ ! -e "$CLAUDE_TARGET" ]; then
    log "no existing $CLAUDE_TARGET, creating it from repo defaults"
    cp "$CLAUDE_REPO_FILE" "$CLAUDE_TARGET"
  else
    log "merging repo keys (editorMode, theme) into existing $CLAUDE_TARGET"
    cp "$CLAUDE_TARGET" "$CLAUDE_TARGET.bak.${TS}"
    if command -v python3 >/dev/null 2>&1; then
      if python3 - "$CLAUDE_REPO_FILE" "$CLAUDE_TARGET" <<'PYEOF'
import json, sys
repo_path, target_path = sys.argv[1], sys.argv[2]
with open(repo_path) as f:
    repo = json.load(f)
with open(target_path) as f:
    local = json.load(f)
local.update(repo)   # repo values win for the synced keys only
with open(target_path, "w") as f:
    json.dump(local, f, indent=2)
    f.write("\n")
PYEOF
      then
        log "merged; backup kept at $CLAUDE_TARGET.bak.${TS}"
      else
        warn "merge failed; restoring original from backup"
        mv "$CLAUDE_TARGET.bak.${TS}" "$CLAUDE_TARGET"
      fi
    else
      warn "python3 not found; leaving $CLAUDE_TARGET untouched"
      warn "manually merge $CLAUDE_REPO_FILE into $CLAUDE_TARGET"
    fi
  fi
else
  warn "no $CLAUDE_REPO_FILE in repo; skipping Claude settings sync"
fi

# --- 5. ~/.bashrc: source portable bash customizations --------------------
BASHRC_TARGET="$HOME/.bashrc"
BASHRC_SRC="$VIM_DIR/bashrc"
BASHRC_MARKER="# >>> my_dot_files bashrc >>>"

if [ -f "$BASHRC_SRC" ]; then
  if [ -f "$BASHRC_TARGET" ] && grep -qF "$BASHRC_MARKER" "$BASHRC_TARGET"; then
    log "$BASHRC_TARGET already sources $BASHRC_SRC, skipping"
  else
    log "appending source line for $BASHRC_SRC to $BASHRC_TARGET"
    {
      printf '\n%s\n' "$BASHRC_MARKER"
      printf '[ -f "%s" ] && . "%s"\n' "$BASHRC_SRC" "$BASHRC_SRC"
      printf '# <<< my_dot_files bashrc <<<\n'
    } >> "$BASHRC_TARGET"
  fi
else
  warn "no $BASHRC_SRC in repo; skipping bashrc sourcing"
fi

log "done."
