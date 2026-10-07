" ~/.vim/vimrc
" Plugins managed with vim-plug (https://github.com/junegunn/vim-plug).
" plug.vim is vendored in autoload/; plugins install into ~/.vim/plugged/
" (gitignored) via: vim +PlugInstall +qall

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-commentary'    " gc/gcc comment toggling; minimal, low-maintenance replacement for nerdcommenter
Plug 'tpope/vim-fugitive'       " :Git blame / :Gdiffsplit / :Git log; standard git integration
Plug 'airblade/vim-gitgutter'   " +/~/- signs for uncommitted changes; ]c/[c jump, <leader>hp preview

call plug#end()

" inline git blame for the cursor line comes from plugin/blameline.vim;
" it appears after the cursor rests for 'updatetime' ms (default 4000)
set updatetime=500

" color whole changed lines, not just the sign column (:GitGutterLineHighlightsToggle)
let g:gitgutter_highlight_lines = 1

" Ctrl+/ toggles a comment, matching VS Code's default keybinding. Terminals
" deliver Ctrl+/ as the control code 0x1F, which Vim sees as <C-_>.
nmap <C-_> gcc
xmap <C-_> gc

syntax on
filetype plugin indent on

set number
set tw=90

" indentation
set expandtab
set shiftwidth=2
set tabstop=2
set cindent            " C-style auto-indent; supersedes autoindent/smartindent (see :help ai)
set cinoptions+=l1      " align case labels with switch
set cinoptions+=N-s     " no extra indent inside namespaces
set cinoptions+=g-1     " access modifiers in classes indented one level less

" spell checker
set spell spelllang=en_us,de_ch

" minimal statusline (no plugin)
set laststatus=2
set statusline=%f\ %m%r%h%w%=%y\ [%{&fileencoding?&fileencoding:&encoding}]\ %l:%c\ %P

" search the word under the cursor across the project, into the quickfix list
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>

" fortran
let fortran_do_enddo=1
