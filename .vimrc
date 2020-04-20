" ----------------------------------------------------------------------------
"  .vimrc                                                               {{{
" ----------------------------------------------------------------------------

" Allow vim to break compatibility with vi
set nocompatible " This must be first, because it changes other options

" }}}-------------------------------------------------------------------------
"  Plugin                                                               {{{
" ----------------------------------------------------------------------------

" Installing the Plug plugin manager, and all the plugins are included in this
" other file.
source $HOME/.vimrc.bundles

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

" }}}-------------------------------------------------------------------------
"  Base Options                                                         {{{
" ----------------------------------------------------------------------------

" Set the leader key to , instead of \ because it's easier to reach
let maplocalleader = ","
let mapleader  	   = ","
let g:mapleader    = ","

set nohidden 		" Dont allow buffers to exist in the background
set ttyfast 		" Indicates a fast terminal connection
set shortmess+=I 	" No welcome screen
set shortmess+=A 	" No .swap warning
set history=1000 	" Remember the last 1000 :ex commands
set secure 		" disable unsafe commands in local .vimrc files

" }}}-------------------------------------------------------------------------
"  Visuals                                                              {{{
" ----------------------------------------------------------------------------

" Control Area (May be superseded by vim-airline)
set showcmd                             " Show (partial) command in the last line of the screen
set wildmenu                            " Command completion
set wildmode=list:longest,list:full     " List all matches and complete till longest common string
" Ignore compiled files
set wildignore=*.o,*~,*.pyc
" Ignore VCS directories
set wildignore+=.hg,.git,.svn
" Ignore LaTeX intermediate files
set wildignore+=*.aux,*.out,*.toc
" Ignore binary images
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg
" Ignore compiled object files
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest
" Ignore Python byte code
set wildignore+=*.pyc
" Ignore compiled spelling lists
set wildignore+=*.spl
" Ignore backup, auto save, swap, undo and view files
set wildignore+=*~,#*#,*.sw?,%*,*=
" Ignore Mac OS
set wildignore+=*.DS_Store
set laststatus=2                " The last window will have a status line always
set noshowmode                  " Don't show the mode in the last line of the screen, vim-airline takes care of it
set ruler                       " Show the line and column number of the cursor position, separated by a comma.
set lazyredraw                  " Don't update the screen while executing macros/commands
autocmd VimEnter * redrawstatus!

" My command line autocomplete is case insensitive. Keep vim consistent with
" that. It's a recent feature to vim, test to make sure it's supported first.
if exists("&wildignorecase")
    set wildignorecase
endif

" Buffer Area Visuals
set scrolloff=7             " Minimal number of screen lines to keep above and below the cursor
set sidescrolloff=7         " Minimal number of screen lines to keep left and right of the cursor
set novisualbell            " Disable visual bell
set noerrorbells            " Disable all bells
set t_vb=                   " Disable all bells
set timeoutlen=500
set ttimeoutlen=10
" set cursorline              " Highlight the current line
" set number                  " Show line numbers
set nowrap                  " Don't wrap lines
set linebreak               " Break the line on words
set textwidth=79            " Break lines at just under 80 characters
set numberwidth=4       " Width of the line number column

" show fold column, fold by markers
set foldcolumn=0        " Don't show the folding gutter/column
set foldmethod=marker   " Fold on {{{ }}}
set foldlevelstart=20   " Open 20 levels of folding when I open a file

" Open folds unter the following conditions
set foldopen=block,hor,mark,percent,quickfix,search,tag,undo,jump

" Prevents inserting two spaces after punctuation on a join
set nojoinspaces

" Splits
set splitbelow      " Open new splits below
set splitright      " Open new vertical splits to the right

" Function to trim trailing white space
" Make your own mappings
function! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfunction

" Highlight VCS conflict markers
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" Character meaning when present in 'formatoptions'
" ------ ---------------------------------------
" c Auto-wrap comments using textwidth, inserting the current comment leader automatically.
" q Allow formatting of comments with "gq".
" r Automatically insert the current comment leader after hitting <Enter> in Insert mode.
" t Auto-wrap text using textwidth (does not apply to comments)
" n Recognize numbered lists
" 1 Don't break line after one-letter words
" a Automatically format paragraphs
set formatoptions=cqrn1

" Colors
syntax enable       " This has to come after colorcolumn in order to draw it.
set t_Co=256        " enable 256 colors

" When completing, fill with the longest common string
" Auto select the first option
set completeopt=longest,menuone

" }}}-------------------------------------------------------------------------
"  Style for terminal vim                                               {{{
" ----------------------------------------------------------------------------

set mouse=      " Disable mouse support

" set title of screen/tmux correctly
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)
if &term =~ "screen*"
    set t_ts=k
    set t_fs=\
endif
if &term =~ "screen*" || &term =~ "xterm*"
    set title
endif

" }}}-------------------------------------------------------------------------
"  Search                                                               {{{
" ----------------------------------------------------------------------------

set incsearch       " Show search results as we type
set showmatch       " Show matching brackets
set hlsearch        " Highlight search results

set ignorecase      " Ignore case when searching
set smartcase       " Don't ignore case if we have a capital letter
set magic           " Use some magic for regular expressions

" }}}-------------------------------------------------------------------------
"  Tabs                                                                 {{{
" ----------------------------------------------------------------------------

set tabstop=4               " Show a tab as four spaces
set shiftwidth=4            " Reindent is also four spaces
set softtabstop=4           " When hit <tab> use four columns
set expandtab               " Create spaces when I type <tab>
set smarttab                " Uses shiftwidth instead of tabstop at start of lines
set shiftround              " Round indent to multiple of 'shiftwidth'
set autoindent              " Put my cursor in the right place when I start a new line
set smartindent             " Indent according to my editing
filetype plugin indent on   " Rely on file plugins to handle indenting

" }}}-------------------------------------------------------------------------
"  Custom commands                                                      {{{
" ----------------------------------------------------------------------------

" Trim trailing white space
nmap <silent> <Leader>t :call StripTrailingWhitespaces()<CR>

" Clear search highlights
nnoremap <leader>n :nohlsearch<cr>

function! RunWith(command)
    execute "w"
    execute "!time " . a:command . " " . expand("%")
endfunction

command! -range=% -nargs=* Tidy <line1>,<line2>!perltidy

function! DoTidy()
    let l = line(".")
    let c = col(".")
    :Tidy
    call cursor(l,c)
endfunction

" }}}-------------------------------------------------------------------------
"   Configure My Plugins                                                  {{{
" ----------------------------------------------------------------------------

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'sh': ['shfmt'],
\   'perl': ['perltidy'],
\   'python': ['reorder-python-imports'],
\   'terraform': ['terraform'],
\}
let g:ale_linters = {
\   'perl': ['perl','perlcritic'],
\}
let g:ale_sh_language_server_use_global = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'normal'
let g:ale_perl_perlcritic_showrules = 1
let g:ale_perl_perl_options = '-c Mwarnings -Ilocal/lib/perl5'
noremap <F2> <ESC>:ALEFix<C-M>:ALELint<C-M>

" perl
let perl_sub_signatures = 1

" Ctrl-P
let g:ctrlp_working_path_mode = 'rw'
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|sass-cache|pip_download_cache|wheel_cache)$',
    \ 'file': '\v\.(png|jpg|jpeg|gif|DS_Store|pyc)$',
    \ 'link': '',
    \ }
let g:ctrlp_show_hidden = 1
let g:ctrlp_clear_cache_on_exit = 0
" Wait to update results (This should fix the fact that backspace is so slow)
let g:ctrlp_lazy_update = 1
" Show as many results as our screen will allow
let g:ctrlp_match_window = 'max:1000'

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag -l --nocolor --hidden -g "" %s'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
else
  " Fall back to using git ls-files if Ag is not available
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']
endif

" Session
" If you don't want help windows to be restored:
set sessionoptions-=help
" Don't save hidden and unloaded buffers in sessions.
set sessionoptions-=buffers

" Templates
let g:templates_directory = '~/.vim/templates'
let g:email = 'ben@unpatched.de'
let g:username = 'Benjamin Stier'
let g:templates_no_builtin_templates = 1

" avoid the possibility of trojaned text files:
" this needs the securemodeline plugin
let secure_modelines_verbose=1
let secure_modelines_modelines=5
let secure_modelines_leave_modeline=1

" Don't change cursor shape
let g:TerminusCursorShape = 0
" Don't enable mouse
let g:TerminusMouse = 0

" Preview docstring in fold text
let g:SimpylFold_docstring_preview = 1

" tt2 syntax
let b:tt2_syn_tags = '<% %>'

nnoremap <Leader>f :NERDTreeToggle<CR>
nnoremap <silent> <Leader>v :NERDTreeFind<CR>
let NERDTreeQuitOnOpen = 1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1


" }}}-------------------------------------------------------------------------
"   Custom filetypes                                                      {{{
" ----------------------------------------------------------------------------

augroup vimrcEx
    autocmd!

    autocmd BufRead,BufNewFile *.dsc setlocal textwidth=0
    autocmd FileType gitcommit setlocal textwidth=72
    autocmd FileType json,html,powershell setlocal shiftwidth=2 tabstop=2
    autocmd FileType xml setlocal foldmethod=syntax
    autocmd BufRead,BufNewFile *.md,*.markdown set filetype=markdown
    autocmd BufRead,BufNewFile *.git/config,.gitconfig,.gitmodules,gitconfig set ft=gitconfig
    autocmd BufRead,BufNewFile *.py setlocal foldmethod=indent
    autocmd BufRead,BufNewFile *.yml setlocal shiftwidth=2
    autocmd BufRead,BufNewFile *.tt setlocal ft=tt2html

    " Tidy perl files
    autocmd FileType perl nmap _ :call DoTidy()<CR>
    autocmd FileType perl vmap _ :Tidy()<CR>
    autocmd FileType perl PerlLocalLibPath


    " Execute files with &
    autocmd FileType perl vmap & :call RunWith("perl")<CR>
    autocmd FileType sh,bash,zsh nmap & :call RunWith("sh")<CR>
    autocmd FileType powershell nmap & :call RunWith("pwsh")<CR>
    autocmd FileType python nmap & :term python3 %<CR>

    " Open quickfix-windows for fugitive
    autocmd QuickFixCmdPost *grep* cwindow
augroup END

" }}}-------------------------------------------------------------------------
"   Custom mappings                                                       {{{
" ----------------------------------------------------------------------------

" Nobody ever uses "Ex" mode, and it's annoying to leave
noremap Q <nop>

" Easier window movement
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Disable help button
nmap <silent> <F1> <nop>
imap <silent> <F1> <nop>

" }}}-------------------------------------------------------------------------
"   Undo, Backup and Swap file locations                                  {{{
" ----------------------------------------------------------------------------

" Don't leave .swp files everywhere. Put them in a central place
set directory=$HOME/.vim/swapdir/
set nobackup 		" don't save backup files

if exists('+undodir')
    if !isdirectory($HOME . '/.vim/undodir')
        mkdir($HOME . "/.vim/undodir")
    endif
    set undodir=$HOME/.vim/undodir
    set undofile
    set undolevels=1000
    set undoreload=10000
endif

" Don't sync swapfile after every write
set swapsync=""

" }}}-------------------------------------------------------------------------
"   If there is a per-machine local .vimrc, source it here at the end     {{{
" ----------------------------------------------------------------------------

if filereadable(glob("$HOME/.vimrc.local"))
    source $HOME/.vimrc.local
endif

set exrc
