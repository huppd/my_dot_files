#!/usr/bin/env bash
# ~/.vim/storage_size.sh
# "What is eating my quota?" — list every top-level entry of a directory
# (files *and* directories, hidden ones included) with its size, sorted
# largest first, then print the total.
#
# Usage:
#   storage_size.sh [DIR]      # DIR defaults to the current directory
#   storage_size.sh -h         # help
#
# Sizes are actual disk usage (like plain `du`), not apparent size, so
# sparse files and filesystem overhead are reflected.

set -uo pipefail

PROG="$(basename "${BASH_SOURCE[0]}")"

usage() {
  cat <<EOF
Usage: $PROG [OPTION]... [DIR]

List the size of every entry directly inside DIR (default: the current
directory), including hidden files and hidden directories, sorted from
largest to smallest, followed by the total size of DIR itself.

Options:
  -h, --help    show this help and exit

Examples:
  $PROG                 # current directory
  $PROG ~/scratch       # somewhere else
  $PROG / 2>/dev/null   # ignore unreadable entries
EOF
}

# --- 1. arguments ----------------------------------------------------------
root=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) printf '%s: unknown option: %s\n' "$PROG" "$1" >&2
        printf "Try '%s --help'.\n" "$PROG" >&2
        exit 2 ;;
    *)  if [ -n "$root" ]; then
          printf '%s: too many arguments\n' "$PROG" >&2; exit 2
        fi
        root="$1" ;;
  esac
  shift
done
if [ $# -gt 0 ]; then                 # leftovers after a literal `--`
  if [ -n "$root" ] || [ $# -gt 1 ]; then
    printf '%s: too many arguments\n' "$PROG" >&2; exit 2
  fi
  root="$1"
fi
root="${root:-.}"

if [ ! -d "$root" ]; then
  printf '%s: not a directory: %s\n' "$PROG" "$root" >&2
  exit 1
fi

# --- 2. size formatting ----------------------------------------------------
if command -v numfmt >/dev/null 2>&1; then
  human() {
    if [ "$1" -lt 1024 ] 2>/dev/null; then
      printf '%dB' "$1"                       # plain bytes, no "0.0"
    else
      numfmt --to=iec --format='%.1f' -- "$1"
    fi
  }
else
  human() {
    awk -v b="$1" 'BEGIN {
      split("B K M G T P", u, " ")
      i = 1
      while (b >= 1024 && i < 6) { b /= 1024; i++ }
      printf (i == 1 ? "%d%s" : "%.1f%s"), b, u[i]
    }'
  }
fi

# --- 3. collect sizes ------------------------------------------------------
# find -mindepth 1 -maxdepth 1 gives every top-level entry, dotfiles
# included and `.`/`..` excluded, with no glob/dotglob trickery needed.
# Everything is NUL-delimited so names with spaces, tabs or newlines
# survive intact.
if du --help 2>/dev/null | grep -q -- '--files0-from'; then
  sizes() {
    find "$root" -mindepth 1 -maxdepth 1 -print0 \
      | du -s --block-size=1 --null --files0-from=- \
      | sort -z -k1,1rn
  }
else
  # Portable fallback (BSD/macOS du): one du per entry, KiB granularity.
  sizes() {
    find "$root" -mindepth 1 -maxdepth 1 -print0 \
      | while IFS= read -r -d '' entry; do
          kb="$(du -sk -- "$entry" 2>/dev/null | awk '{print $1; exit}')"
          [ -n "${kb:-}" ] || continue
          printf '%s\t%s\0' "$((kb * 1024))" "$entry"
        done \
      | sort -z -k1,1rn
  }
fi

count=0
while IFS=$'\t' read -r -d '' bytes name; do
  [ -n "${bytes:-}" ] || continue
  printf '%8s  %s\n' "$(human "$bytes")" "$name"
  count=$((count + 1))
done < <(sizes)

# --- 4. total --------------------------------------------------------------
total="$(du -s --block-size=1 -- "$root" 2>/dev/null | awk '{print $1; exit}')"
if [ -z "${total:-}" ]; then
  total="$(du -sk -- "$root" 2>/dev/null | awk '{print $1 * 1024; exit}')"
fi

printf '%s\n' "--------"
if [ -n "${total:-}" ]; then
  printf '%8s  TOTAL (%s, %d entr%s)\n' \
    "$(human "$total")" "$root" "$count" "$([ "$count" -eq 1 ] && echo y || echo ies)"
else
  printf '   ?  TOTAL (%s, %d entries)\n' "$root" "$count"
fi
