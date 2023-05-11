
:set number
:set relativenumber
:set autoindent
:set smarttab
:set mouse=a
:set tabstop=4
:set shiftwidth=4
:set softtabstop=4
:set encoding=UTF-8

 " Make sure you use single quotes
call plug#begin()
Plug 'http://github.com/tpope/vim-surround' " Surrounding ysw)
Plug 'https://github.com/preservim/nerdtree' " NerdTree
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/vim-airline/vim-airline' " Status bar
Plug 'https://github.com/lifepillar/pgsql.vim' " PSQL Pluging needs :SQLSetType pgsql.vim
Plug 'https://github.com/ap/vim-css-color' " CSS Color Preview
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Retro Scheme
Plug 'https://github.com/neoclide/coc.nvim'  " Auto Completion
Plug 'https://github.com/ryanoasis/vim-devicons' " Developer Icons
Plug 'https://github.com/tc50cal/vim-terminal' " Vim Terminal
Plug 'https://github.com/preservim/tagbar' " Tagbar for code navigation
Plug 'https://github.com/terryma/vim-multiple-cursors' " CTRL + N for multiple cursors
Plug 'https://github.com/rstacruz/vim-closer' " For brackets autocompletion
Plug 'https://github.com/jiangmiao/auto-pairs'


" Auto-completion  For Javascript
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'} " this is for auto complete, prettier and tslinting

let g:coc_global_extensions = ['coc-tslint-plugin', 'coc-python', 'coc-tsserver', 'coc-css', 'coc-html', 'coc-json', 'coc-clangd', 'coc-lua']  " list of CoC extensions needed

Plug 'jiangmiao/auto-pairs' "this will auto close ( [ {

" these two plugins will add highlighting and indenting to JSX and TSX files.
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'



call plug#end()


" F keys


" Toggle display NERDTree
map <C-t> :NERDTreeToggle<CR>
map <F3> :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>

" Exit Don't Save
map <F4> <esc>:q!<CR>

" Exit and save
map <F5> <esc>:wq<CR>


" Toggle Line number Space+m or Space+n
map <space>n <esc>:set relativenumber<CR>:set number<CR>
map <space>m <esc>:set relativenumber!<CR>:set number!<CR>


" Move Line Alt+up or Alt+down
map <A-up> <esc>:m-2<CR>
map <A-down> <esc>:m+1<CR>


" Control-S Save
nmap <C-S> :w<cr>
vmap <C-S> <esc>:w<cr>
imap <C-S> <esc>:w<cr>
" Save + back into insert
" imap <C-S> <esc>:w<cr>a

" Control-Q exit
nmap <C-Q> :q<cr>
vmap <C-Q> <esc>:q<cr>
imap <C-Q> <esc>:q<cr>
" force exit

" Control-C Copy 
map <C-c> <esc>yy

" Control-x cut line
map <C-x> <esc>dd


" Control-V Paste in insert and command mode
map <C-v> <esc>p

" Undu and Redu You can use Control+R for redu
map <C-z> <esc>:undo<CR>
map <C-u> <esc>:redo<CR>



:colorscheme jellybeans

let g:NERDTreeDirArrowExpandable="+"
let g:NERDTreeDirArrowCollapsible="~"

" --- Just Some Notes ---
" :PlugClean :PlugInstall :UpdateRemotePlugins
"
" :CocInstall coc-python
" :CocInstall coc-clangd
" :CocInstall coc-snippets
" :CocCommand snippets.edit... FOR EACH FILE TYPE

" air-line
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" airline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
