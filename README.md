# my_dot_files

Personal Vim (and Claude Code CLI) config. Works on a plain box or over SSH
on a cluster — console-only, no GUI vim required.

## Install

```
git clone git@github.com:huppd/my_dot_files.git ~/.vim
~/.vim/setup.sh
```

That's it. Re-run `~/.vim/setup.sh` any time — it's safe to run repeatedly.

## What the setup script does

- Symlinks `~/.vimrc` -> `~/.vim/vimrc` (backs up any pre-existing real file
  first).
- Installs plugins via vim-plug (vendored in `autoload/plug.vim`) into
  `~/.vim/plugged/`.
- Syncs the portable keys (`editorMode`, `theme`) from `claude/settings.json`
  into `~/.claude/settings.json`, without touching any machine-local
  `permissions` already set there.
- Appends a one-line `source ~/.vim/bashrc` to `~/.bashrc` (guarded by a
  marker, added once), without touching anything else already there.
- Patches portable keys from `vscode/settings.json` into VS Code's and/or
  VSCodium's `settings.json` (whichever are installed), as a text edit
  rather than a JSON rewrite — that file is JSONC (comments, trailing
  commas), so anything already there is left exactly as-is.

## Plugins

- tpope/vim-commentary — `gc`/`gcc` to (un)comment

To add one: add a `Plug '...'` line in `vimrc`, then `vim +PlugInstall +qall`
(or re-run `setup.sh`).

## Limitations

- No internet on some HPC compute/login nodes: `PlugInstall` needs to run
  once from a machine/node that can reach GitHub. Everything already
  installed works fully offline.

## Manual bits

- `spell/` — spell-check word lists: `de.utf-8.spl` (stock German list,
  vendored so `en_us,de_ch` spell-check works with no network access) and
  `en.utf-8.add` (personal word additions; `:mkspell` regenerates
  `en.utf-8.add.spl` after editing it).
- `ftplugin/` — per-filetype tweaks (python, fortran).
- `bashrc` — portable bash customizations (extended history, git branch in
  the prompt), sourced from `~/.bashrc` by `setup.sh`. Kept separate from
  the real `~/.bashrc` so machine-specific bits (conda init, corporate
  profile sourcing, editor env vars, PATH tweaks, ...) never end up here.
- `git-prompt.sh` — vendored upstream (GPLv2) so `__git_ps1` works with no
  network access; used by `bashrc`.
- `vscode/settings.json` — portable VS Code/VSCodium settings, patched into
  the real `settings.json` by `setup.sh`.

## License

This repository is MIT licensed (see `LICENSE`), except for vendored
third-party files, which keep their original license:

- `git-prompt.sh` — Git project, GPLv2 (see file header).
