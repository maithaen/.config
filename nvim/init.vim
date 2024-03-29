" Set options
set number
set relativenumber
set autoindent
set smarttab
set mouse=a
set tabstop=4
set shiftwidth=4
set softtabstop=4
set encoding=UTF-8


" Plugin manager
call plug#begin()

" Plugins
Plug 'tpope/vim-surround' " Surrounding ysw
Plug 'preservim/nerdtree' " NerdTree
Plug 'tpope/vim-commentary' " Commenting gcc & gc
Plug 'vim-airline/vim-airline' " Status bar 
Plug 'lifepillar/pgsql.vim' " PSQL plugin
Plug 'ap/vim-css-color' " CSS Color Preview
Plug 'rafi/awesome-vim-colorschemes' " Retro Scheme
Plug 'neoclide/coc.nvim' " Auto Completion
Plug 'ryanoasis/vim-devicons' " Developer Icons
Plug 'tc50cal/vim-terminal' " Vim Terminal
Plug 'preservim/tagbar' " Tagbar 
Plug 'terryma/vim-multiple-cursors' " Multiple cursors
Plug 'rstacruz/vim-closer' " Bracket autocompletion
Plug 'jiangmiao/auto-pairs' 

Plug 'tpope/vim-commentary' " Commentary

" CoC extensions
let g:coc_global_extensions = [
  \ 'coc-python',
  \ 'coc-tsserver',
  \ 'coc-css',
  \ 'coc-html',
  \ ]

call plug#end()

" Key mappings
nmap <leader>c :Commentary<CR> 
xmap <leader>c :Commentary<CR>
nmap <F2> :Commentary<CR>
xmap <F2> :Commentary<CR>

nmap <C-t> :NERDTreeToggle<CR>
nmap <F3> :NERDTreeToggle<CR>

nmap <F8> :TagbarToggle<CR>

nmap <F4> :q!<CR> 

nmap <F5> :wq<CR>

nmap <space>n :set relativenumber!<CR>:set number!<CR>
nmap <space>m :set relativenumber<CR>:set number<CR> 

nmap <A-up> :m-2<CR> 
nmap <A-down> :m+1<CR>

nmap <C-S> :w<CR>
vmap <C-S> <esc>:w<CR>
imap <C-S> <esc>:w<CR>

nmap <C-Q> :q<CR>
vmap <C-Q> <esc>:q<CR>
imap <C-Q> <esc>:q<CR>

nmap <C-c> yy
nmap <C-x> dd
nmap <C-v> p

nmap <C-z> :undo<CR>
nmap <C-u> :redo<CR>

colorscheme jellybeans

let g:NERDTreeDirArrowExpandable = "+"
let g:NERDTreeDirArrowCollapsible = "~"

inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
