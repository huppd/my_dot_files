# ~/.vim/bashrc
# Portable bash customizations, sourced from ~/.bashrc by setup.sh.
# Kept separate from the real ~/.bashrc so machine-specific bits (conda
# init, corporate profile sourcing, PATH tweaks, ...) never end up in this
# repo.

# --- extended history ------------------------------------------------------
HISTCONTROL=ignoreboth   # no dupes, no lines starting with a space
shopt -s histappend      # append to the history file, don't overwrite it
HISTSIZE=100000
HISTFILESIZE=200000

BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- git branch in prompt ---------------------------------------------------
# Vendored git-prompt.sh (upstream, GPLv2) defines __git_ps1; without it
# some machines won't have it available at all.
[ -f "$BASHRC_DIR/git-prompt.sh" ] && . "$BASHRC_DIR/git-prompt.sh"

# user@host, cwd (cropped to the last ~20 chars if long), git branch in red
export PS1='\u@\h \[\e[32m\]$(echo "${PWD}" | awk -F/ '\''{if(length($0) > 23) {n=length($0); printf "...%s",substr($0,n-20,n)} else {print $0}}'\'') \[\e[91m\]$(__git_ps1)\[\e[00m\]$ '

# --- default editor ----------------------------------------------------
# also makes `spack edit` use VS Code
export VISUAL=code
export EDITOR=code
export SPACK_EDITOR=code

# --- uv cache on CSCS scratch --------------------------------------------
# Home quotas on these clusters are small; keep uv's cache on scratch instead.
case "$(hostname -s 2>/dev/null)" in
    balfrin*|santis*|linard*)
        export UV_CACHE_DIR="/scratch/mch/$USER/.cache/uv"
        ;;
esac

# --- manual dotfiles refresh -------------------------------------------
# Deliberately manual, not automatic: on offline HPC nodes a pull/PlugInstall
# on every shell startup would just hang, and auto-running whatever's in the
# repo on every new shell is more blast radius than we want unattended.
alias my_dot_up="git -C '$BASHRC_DIR' pull --ff-only && '$BASHRC_DIR/setup.sh' && exec bash"

# --- storage usage helper -----------------------------------------------
alias storage_size="'$BASHRC_DIR/storage_size.sh'"

# --- tmux session per folder ----------------------------------------------
# `t` attaches to the tmux session named after the current folder, creating
# it if needed; `t name` uses an explicit name. tmux forbids '.' and ':' in
# session names, so they become '_'. Inside tmux it switches instead of nesting.
t() {
    local name="${1:-$(basename "$PWD")}"
    name="${name//[.:]/_}"
    if [ -n "$TMUX" ]; then
        tmux has-session -t "=$name" 2>/dev/null || tmux new-session -d -s "$name"
        tmux switch-client -t "=$name"
    else
        tmux new-session -A -s "$name"
    fi
}

unset BASHRC_DIR
