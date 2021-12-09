" NVim configuration file.
" Author: https://gralin.ski
" Created on: 20.10.2021
" Last modified: 01.12.2021
" License: CC0

set nocompatible
syntax on
filetype plugin on

""" SET orders: """
set background=dark

" Allows backspacing over everything in insert mode:
set backspace=eol,start,indent

""" Backup options - disable any and all backup files: """
set nobackup
set nowritebackup
set noswapfile

""" Bell options - disable all bells: """
set noerrorbells
set novisualbell

" Display a margin at 120th column
set colorcolumn=120

" Do not highlight the current line
set nocursorline

" Use Unicode:
set encoding=utf-8

set guifont=Iosevka\ Regular\ 14

set history=512

"! Indenting SETs:
set autoindent          " Apply the indentation of the current line to the next
set smartindent         " But also react to the syntax of the file. Requires autoindent.

set laststatus=2

" Redraw only if needed when executing macros:
set lazyredraw

" Displays the tab character at all times:
set list
set listchars=tab:▶─,trail:·

" Number of lines to read from file's head & tail for file-specific variables:
set modelines=0

" Disable mouse support
set mouse=""

" Display line numbers
set number

" Perform recursive search from $CWD (e.g. tab completion for filenames):
set path+=**

set ruler

" !Searching SETs:
" Perform case-sensitive search when capital letters are present, case-insensitive otherwise
set hlsearch
set incsearch
set ignorecase
set smartcase

" Do not blink the matching parens, braces etc. This is confusing.
set noshowmatch

" Open new split panes to the right and below:
set splitbelow
set splitright

set noswapfile          " Disable creating of a swap file

" Try to show at least 7 lines before/after the current line when entering or scrolling the text:
set scrolloff=7

" Tab key: expand to 4 spaces, backspace 1-level at a time.
set tabstop=4     " tab width is exactly 4 spaces when displaying
set shiftwidth=4  " tab width is exactly 4 spaces when shifting
set expandtab     " expand tabs to spaces
set softtabstop=0 " Backspace one space at a time in trailing whitespace.
                  " However, for indentation, <BS> still deletes across levels, not individual chars.
set noshiftround

set textwidth=120

" List all matches without completing, then each full match (like Bash):
set wildmode=longest,list

" Display lines longer than window width as multiple lines:
set wrap

""" Highlight options: """
highlight ColorColumn ctermbg=DarkGray ctermfg=Yellow
                      \ guibg=DarkGray guifg=Yellow
highlight LineNr ctermbg=234 ctermfg=242
highlight MatchParen cterm=underline ctermbg=None ctermfg=Blue
                    \ gui=underline guibg=None guifg=Blue
highlight Search cterm=underline ctermbg=None ctermfg=Yellow
                    \ gui=underline guibg=None guifg=Yellow
highlight TrailingWhitespace cterm=Underline ctermbg=Red ctermfg=Yellow
                    \ gui=underline guibg=Red guifg=Yellow

""" Key mappings: """
" Map <Space> as leader key
let mapleader="\<Space>"
let g:mapleader="\<Space>"

" Remap j -> gj, k -> gk to navigate across splitted lines more intuitively:
nnoremap j gj
nnoremap k gk

" Disable ex-mode:
nnoremap Q <nop>

" Remap ; to : in normal mode:
nnoremap ; :

" Easier reindenting of a visually-selected block: reselects a block after indent/dedent:
vnoremap < <gv
vnoremap > >gv

nnoremap <Space><Space> V

" Switch off search highlighting temporarily:
nnoremap <Leader>h :nohlsearch<CR>
nnoremap <Leader>w :w<CR>

" Quick $MYVIMRC editing: <Leader>ve for edit, <Leader>vs for sourcing.
nnoremap <Leader>ve :vsplit $MYVIMRC<CR>
nnoremap <Leader>vs :source $MYVIMRC<CR>

" Move a line of text using ALT+[jk]
nnoremap <M-j> mz:m+<cr>`z
vnoremap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
nnoremap <M-k> mz:m-2<cr>`z
vnoremap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

""" Functions: """
" Disables the annoying auto line-break insertion. This is caused by ftplugins
" being loaded after .vimrc / init.vim, which override formatoptions and textwidth (if set to 0).
" Fixes these settings by overriding them again after the buffer is loaded.
function! DisableAutoWrapping()
    set formatoptions-=ct
    echom "Disabled auto wrapping"
endfunction

" Removes all the trailing whitespace from the current buffer:
function! TrimTrailingWhitespace()
    let b:save = winsaveview()    " Saves the current view: cursor position, folds, etc.
    keeppatterns %s/\s\+$//e      " Trims the trailing whitespace using a regex.
    call winrestview(b:save)      " Restores the saved view.
endfunction
nnoremap <Leader>dw :call TrimTrailingWhitespace()<CR>
nnoremap <Leader>ds :call TrimTrailingWhitespace()<CR>

" Updates the `Last modified: dd.mm.yyyy` part of file's header:
function! UpdateLastModified()
    if ! &modifiable
        echom "[UpdateLastModified] Buffer is not modifiable. Skipping."
        return
    endif

    " Exit if the buffer has not been modified - there is no need to bump the modification date
    let b:bufmodified = getbufvar("%", "&mod")
    if ! b:bufmodified
        echom "[UpdateLastModified] No changes in buffer. Skipping."
    endif

    " Do not update the `Last modified:` part of snippet files - these are *not* to be altered.
    let b:filename_extension = expand("%:e")
    if b:filename_extension ==? "SNIPPETS"
        echom "[UpdateLastModified] Buffer is of SNIPPETS type. Skipping."
        return
    endif

    let b:pos = winsaveview()
    let b:begin_line = 0
    let b:end_line = 20
    let b:time_format = "%d.%m.%Y"
    let b:lastmodified_prefix = "Last modified:"

    " This prefix but converted to lowercase should be used when search() is called.
    " The reason for that is because search() assumes ignorecase+smartcase flags, so that
    " case-insensitive search will be performed when pattern is given in lowercase.
    " When substituting, the correct version of pattern will be used."
    " Note: remember that both `set ignorecase` and `set smartcase` need to be set in this .vimrc / init.vim .
    let b:lastmodified_prefix_lowercase = tolower(b:lastmodified_prefix)

    execute b:begin_line
    let b:line_num = search(b:lastmodified_prefix_lowercase, "", b:end_line)
    if b:line_num > 0
        echom "[UpdateLastModified] found in line " .. b:line_num
        let b:existing_line = getline(b:line_num)
        let b:new_line = substitute(b:existing_line, b:lastmodified_prefix . ".*$", b:lastmodified_prefix . " " . strftime(b:time_format), "")
        if b:existing_line ==# b:new_line
            echom "Last modified part is already up-to-date."
        else
            call setline(b:line_num, b:new_line)
        endif
    endif
    call winrestview(b:pos)
endfunction

""" Autogroups """
augroup anyfile
    autocmd!
    " For any file type: jump to the position edited the last time.
    autocmd BufReadPost *
                \ if line("'\"") > 0 && line("'\"") <= line("$") |:
                \ exe "normal g`\"" |
                \ endif

    " Makes the text copied from (N)Vim stay in the clipboard even after exiting.
    autocmd VimLeave * call system("xsel -ib", getreg("+"))
augroup end

augroup highlight_trailing_whitespace
    autocmd!
    autocmd BufWinEnter * match TrailingWhitespace /\s\+$/
    autocmd InsertEnter * match TrailingWhitespace /\s\+\%#\@<!$/
    autocmd InsertLeave * match TrailingWhitespace /\s\+$/
    autocmd BufWinLeave * call clearmatches()
augroup end

augroup filetype_st
    autocmd!
    " Makes (N)Vim treat any *.cls file (recognized as filetype=st) as if it were tex code:
    autocmd FileType st set filetype=tex
augroup end

augroup filetype_conky
    autocmd!
    " Makes (N)Vim treat any *.conky file as if it were Lua code,
    " as Conky utilizes Lua syntax since v1.10:
    autocmd BufNewFile,BufRead *.conky set filetype=lua
augroup end

augroup filetype_gitcommit
    autocmd!
    autocmd FileType gitcommit setlocal colorcolumn=73
    autocmd FileType gitcommit setlocal textwidth=72
augroup end

augroup filetype_make
    autocmd!
    autocmd FileType make setlocal noexpandtab
augroup end

augroup filetype_python
    autocmd!
    autocmd FileType python inoremap # X<C-h>#
    autocmd FileType python setlocal shiftwidth=4
    autocmd FileType python setlocal softtabstop=4
    autocmd FileType python setlocal expandtab
    autocmd FileType python setlocal colorcolumn=80
    autocmd FileType python setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class
augroup end

augroup filetype_shrc
    autocmd!
    autocmd BufNewFile,BufRead *.shrc set filetype=sh
augroup end

""" Plugins: handled by vimplug, which needs to be installed manually. """
" Run :PlugInstall to install plugins from the following list, :PlugUpdate to update
call plug#begin('~/.config/nvim/plugins')
    Plug 'vim-airline/vim-airline'
    Plug 'dense-analysis/ale'
    Plug 'SirVer/ultisnips'
call plug#end()

""" Plugin-specific configuration: """
""" Airline: """
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_alt_sep = ''

""" ALE / A.L.E. / Asynchronous Lint Engine: """
" Integrate A.L.E. with airline, as both plugins are installed:
let g:airline#extensions#ale#enabled = 1
" Do not lint asynchronously on every text change. Instead perform linting on every save.
let g:ale_lint_on_text_changed = "never"
let g:ale_lint_on_insert_leave = 0
" Linters used for specific filetypes:
let g:ale_linters = {
\  "cpp": ["clangtidy", "clang", "gcc"],
\  "tex": ["chktex"],
\  "python": ["pylint"],
\  "sh": ["shellcheck"],
\}
let g:ale_echo_msg_format = "[%linter%]: %s"

" A.L.E. mappings:
nnoremap <leader>ad :ALEDetail<cr>
nnoremap <leader>af :ALEFix<cr>
nnoremap <leader>agd :ALEGoToDefinition<cr>
nnoremap <leader>ai :ALEInfo<cr>
nnoremap <leader>an :ALENext<cr>
nnoremap <leader>ap :ALEPrevious<cr>
nnoremap <leader>at :ALEToggleBuffer<cr>

" A.L.E. -> C++ settings:
let g:ale_lint_on_enter = 1
let g:common_cpp_options = "-std=c++20 -Wall -Wextra"
let g:ale_cpp_clang_options = g:common_cpp_options
let g:ale_cpp_clangtidy_options = g:common_cpp_options
let g:ale_cpp_gcc_options = g:common_cpp_options

" A.L.E. -> Python (pylint) settings:
" Warnings disabled in pylint:
" * C0103 - variable name doesn't conform to snake_case naming style
let g:ale_python_pylint_options = "--disable=C0103"

""" Ultisnips: """
let g:UltiSnipsSnippetsDir="~/.vim/UltiSnips"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']
let g:UltiSnipsExpandTrigger="<C-j>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-k>"
" Makes UltiSnipsEdit open a new split instead of switching buffers:
let g:UltiSnipsEditSplit="vertical"

""" Commands for fast editing of snippet files: <Leader>s[_] """
" Edit snippets relevant to the current buffer type (e.g. cpp.snippets for filetype cpp)
nnoremap <Leader>se :UltiSnipsEdit<CR>
nnoremap <Leader>sE :vsp $HOME/.vim/UltiSnips/<CR>
nnoremap <Leader>ss :call UltiSnips#RefreshSnippets()<CR>

nnoremap <Leader>es :echo "\<Leader\>es deleted. Please use \<Leader\>se instead."<CR>
