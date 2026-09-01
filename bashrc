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

# --- git branch in prompt ---------------------------------------------------
# Vendored git-prompt.sh (upstream, GPLv2) defines __git_ps1; without it
# some machines won't have it available at all.
BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$BASHRC_DIR/git-prompt.sh" ] && . "$BASHRC_DIR/git-prompt.sh"
unset BASHRC_DIR

# user@host, cwd (cropped to the last ~20 chars if long), git branch in red
export PS1='\u@\h \[\e[32m\]$(echo "${PWD}" | awk -F/ '\''{if(length($0) > 23) {n=length($0); printf "...%s",substr($0,n-20,n)} else {print $0}}'\'') \[\e[91m\]$(__git_ps1)\[\e[00m\]$ '

# --- default editor ----------------------------------------------------
# also makes `spack edit` use VS Code
export VISUAL=code
export EDITOR=code
export SPACK_EDITOR=code
