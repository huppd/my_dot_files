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
- `ftplugin/` — per-filetype tweaks (python, fortran, xml).
