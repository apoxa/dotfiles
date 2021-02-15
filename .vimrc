" ----------------------------------------------------------------------------
"  .vimrc                                                               {{{
" ----------------------------------------------------------------------------

" Allow vim to break compatibility with vi
set nocompatible " This must be first, because it changes other options

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
"  Plugin                                                               {{{
" ----------------------------------------------------------------------------

" Install vim-plug if we don't already have it
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-git'
Plug 'pearofducks/ansible-vim'
Plug 'zigford/vim-powershell'
Plug 'vim-perl/vim-perl', { 'for': 'perl', 'do': 'make clean carp dancer highlight-all-pragmas moose test-more try-tiny' }
    let perl_sub_signatures = 1
Plug 'shmup/vim-sql-syntax'

Plug 'junegunn/vim-easy-align'
    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)

" Fuzzy file opener
Plug 'ctrlpvim/ctrlp.vim' | Plug 'sgur/ctrlp-extensions.vim' | Plug 'tacahiroy/ctrlp-funky'
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

" Linter
Plug 'dense-analysis/ale'
    let g:ale_fixers = {
    \   '*': ['remove_trailing_lines', 'trim_whitespace'],
    \   'sh': ['shfmt'],
    \   'perl': ['perltidy'],
    \   'python': ['reorder-python-imports', 'black'],
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

" Fugitive: A git wrapper so awesome, it should be illegal
Plug 'tpope/vim-fugitive'

" Change brackets and quotes
Plug 'tpope/vim-surround'
" Make vim-surround repeatable with .
Plug 'tpope/vim-repeat'
" End certain structures automatically.
Plug 'tpope/vim-endwise'
" Make commenting easier
Plug 'tpope/vim-commentary'

" UNIX helpers
Plug 'tpope/vim-eunuch'

" Fancy statusline
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='solarized'
let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 2
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
function! AirlineInit()
    let g:airline_section_z = airline#section#create([
        \ 'windowswap',
        \ '%3p%% ',
        \ 'linenr',
        \ ':%3v '
        \ ])
endfunction
autocmd VimEnter * call AirlineInit()

Plug 'edkolev/tmuxline.vim'

" A secure alternative to Vim modelines
Plug 'ciaranm/securemodelines'
    let secure_modelines_verbose=1
    let secure_modelines_modelines=5
    let secure_modelines_leave_modeline=1

" Call perldoc in vim buffer
Plug 'hotchpotch/perldoc-vim', { 'for': 'perl' }

" Intelligently reopen files at your last edit position
Plug 'farmergreg/vim-lastplace'

" Enhanced terminal support. Enables pasting etc
Plug 'wincent/terminus'
    " Don't change cursor shape
    let g:TerminusCursorShape = 0
    " Don't enable mouse
    let g:TerminusMouse = 0

" Templates for filetypes
Plug 'aperezdc/vim-template'
    let g:templates_directory = '~/.vim/templates'
    let g:email = 'ben@unpatched.de'
    let g:username = 'Benjamin Stier'
    let g:templates_no_builtin_templates = 1

" Handle swap files intelligently
Plug 'gioele/vim-autoswap'

" Use tab for completion needs
Plug 'ervandew/supertab'

" Colorizer: display color codes as their colors inline
Plug 'lilydjwg/colorizer'

" sessions
Plug 'thaerkh/vim-workspace'
    let g:workspace_session_directory = $HOME . '/.vim/sessions/'
    let g:workspace_autosave_always = 1
    let g:workspace_session_disable_on_args = 1
    " If you don't want help windows to be restored:
    set sessionoptions-=help
    " Don't save hidden and unloaded buffers in sessions.
    set sessionoptions-=buffers

" vim local lib helper
Plug 'yuuki/perl-local-lib-path.vim', { 'for': 'perl' }

Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
Plug 'jmcantrell/vim-virtualenv', { 'for': 'python' }
Plug 'davidhalter/jedi-vim', { 'for': 'python' }
    let g:jedi#usages_command = ""

Plug 'scrooloose/nerdtree', {'on': ['NERDTreeToggle', 'NERDTreeFind'] }| Plug 'Xuyuanp/nerdtree-git-plugin'
    nnoremap <Leader>f :NERDTreeToggle<CR>
    nnoremap <silent> <Leader>v :NERDTreeFind<CR>
    let NERDTreeQuitOnOpen = 1
    autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
    let NERDTreeAutoDeleteBuffer = 1
    let NERDTreeMinimalUI = 1
Plug 'ryanoasis/vim-devicons'

Plug 'mxw/vim-jsx'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
" Perl6/raku
Plug 'Raku/vim-raku'
" terraform
Plug 'hashivim/vim-terraform'

call plug#end()

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
"   Custom mappings                                                       {{{
" ----------------------------------------------------------------------------

" Trim trailing white space
nmap <silent> <Leader>t :call myfunctions#StripTrailingWhitespaces()<CR>

" Clear search highlights
nnoremap <leader>n :nohlsearch<cr>

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
