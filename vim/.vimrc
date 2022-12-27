"
" .vimrc File of technat (https://github.com/the-technat/WALl-E)
" Philosohpy: only enable what you really understand, use as few plugins as possible and as much default settings as possible
"

" General
set encoding=utf-8
set history=1000
set mouse=a
set shell=/usr/bin/zsh
set autoread

" Behaviour
set confirm
set linebreak
set wrap
set noerrorbells

" UI
set number
set title
set wildmenu
set cursorline
set background=dark
set termguicolors
syntax enable
colorscheme solarized

" Search
set hlsearch
set ignorecase
set incsearch
set smartcase

" Editor
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set shiftround
set smarttab

" ALE
let g:ale_fix_on_save = 1
let g:ale_lint_on_save=1
let g:ale_completion_enabled = 1
let g:ale_completion_autoimport = 1
let g:ale_default_navigation="vsplit"
let g:ale_sign_error = '●'
let g:ale_sign_warning = '.'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_set_balloons=1
let g:ale_hover_cursor=1
set omnifunc=ale#completion#OmniFunc " trigger completion using <C-x><C-o>
let g:ale_fixers = {
\  '*': ['remove_trailing_lines', 'trim_whitespace'],
\  'go': ['gofmt', 'gofumpt', 'goimports', 'golines'],
\  'terraform': ['terraform'],
\  'sh': ['shfmt'],
\}
let g:ale_linters = {
\ 'go': ['staticcheck', 'gobuild', 'govet', 'gopls'],
\}

" Other plugins
let g:system_copy_silent = 1

" Autocmd Magic
" Save the file if we switch to another window
autocmd FocusLost,WinLeave * :silent! w
" Jump back to previous position in file when you reopen a file
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Keybindings
let mapleader = ","
"----------- Windows -----------
nnoremap <silent> <C-j> <C-W>j
nnoremap <silent> <C-k> <C-W>k
nnoremap <silent> <C-l> <C-W>l
nnoremap <silent> <C-h> <C-W>h
" Scroll the window next to the current one
" (especially useful for two-window splits)
nnoremap <silent> <leader>jj <c-w>w<c-d><c-w>W
nnoremap <silent> <leader>kk <c-w>w<c-u><c-w>W
"----------- Editor -----------
noremap ,<space> :nohlsearch<CR>
noremap ,f :NERDTreeToggle<CR>
noremap ,r :NERDTreeRefreshRoot<CR>

" For Plugins
packloadall
silent! helptags ALL
