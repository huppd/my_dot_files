" ~/.vim/vimrc
" Plugins managed with vim-plug (https://github.com/junegunn/vim-plug).
" plug.vim is vendored in autoload/; plugins install into ~/.vim/plugged/
" (gitignored) via: vim +PlugInstall +qall

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-commentary'    " gc/gcc comment toggling; minimal, low-maintenance replacement for nerdcommenter

call plug#end()

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
