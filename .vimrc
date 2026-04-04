" =============================
" PLUGIN MANAGER (vim-plug)
" =============================
call plug#begin('~/.vim/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-fugitive'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-markdown'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
" Snippet engine (lightweight, no Python needed, vanilla Vim compatible)
Plug 'garbas/vim-snipmate'
Plug 'MarcWeber/vim-addon-mw-utils'   " snipmate dependency
Plug 'tomtom/tlib_vim'                " snipmate dependency
Plug 'honza/vim-snippets'             " community snippet library (C/C++ included)

call plug#end()

" =============================
" BASIC SETTINGS
" =============================
set nocompatible
filetype plugin indent on
syntax on
set encoding=utf-8
set number
set relativenumber
set cursorline
set showcmd
set showmatch
set wildmenu
set wildmode=longest:full,full
set hidden
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set wrap
set linebreak
set breakindent
set scrolloff=8
set sidescrolloff=8
set ignorecase
set smartcase
set incsearch
set hlsearch
set termguicolors
set mouse=a
set clipboard=unnamedplus
set lazyredraw

" Persistent undo
set undofile
set undodir=~/.vim/undodir
silent! call mkdir(expand('~/.vim/undodir'), 'p')

" =============================
" DRACULA & CURSOR
" =============================
colorscheme dracula
set background=dark

" =============================
" TRANSPARENCY FIX
" =============================
hi Normal guibg=NONE ctermbg=NONE
hi NormalNC guibg=NONE ctermbg=NONE

" =============================
" STATUSLINE (LIGHTLINE)
" =============================
set laststatus=2
set noshowmode

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

augroup LightlineBold
  autocmd!
  autocmd VimEnter,ColorScheme * call s:bold_lightline()
augroup END

function! s:bold_lightline()
  for l:mode in ['normal', 'insert', 'visual', 'replace', 'command', 'inactive']
    for l:side in ['Left', 'Right']
      for l:seg in ['0', '1', '2']
        silent! exec 'hi Lightline' . l:side . '_' . l:mode . '_' . l:seg
              \ . ' gui=bold cterm=bold'
      endfor
    endfor
    silent! exec 'hi LightlineMiddle_' . l:mode . ' gui=bold cterm=bold'
  endfor
endfunction

" =============================
" COMPLETION — fast & smart
" =============================
" Pull from: current buffer, other buffers, included files, tags
set complete=.,b,u,],i,t
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" Tab cycles through popup; Enter confirms
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"

" Trigger completion manually with <C-Space>
inoremap <C-Space> <C-n>

" Faster tag-based completion for C/C++ (needs ctags)
" Run: ctags -R . in your project root
set tags=./tags,tags;$HOME

" Auto-generate ctags on write for C/C++ files
augroup auto_ctags
  autocmd!
  autocmd BufWritePost *.c,*.cpp,*.h,*.hpp
        \ silent! execute '!ctags -R . &>/dev/null &'
augroup END

" =============================
" SNIPMATE SETTINGS
" =============================
" Use <Tab> to expand snippets (snipmate default)
" Tab in insert mode: expand snippet if cursor is on a trigger word,
" otherwise fall through to completion popup or literal tab.
let g:snipMate = { 'snippet_version' : 1 }

" =============================
" CUSTOM C/C++ SNIPPETS
" (drop-in, no plugin needed — lives in ~/.vim/snippets/cpp.snippets)
" The lines below create the file automatically on first run.
" =============================
function! s:WriteCustomSnippets()
  let l:dir  = expand('~/.vim/snippets')
  let l:file = l:dir . '/cpp.snippets'
  silent! call mkdir(l:dir, 'p')
  if filereadable(l:file) | return | endif

  let l:lines = [
    \ '# ---- C++ custom snippets ----',
    \ '',
    \ '# main — competitive / general',
    \ 'snippet main',
    \ '	#include <bits/stdc++.h>',
    \ '	using namespace std;',
    \ '	',
    \ '	int main() {',
    \ '	    ios_base::sync_with_stdio(false);',
    \ '	    cin.tie(NULL);',
    \ '	',
    \ '	    ${1:// code here}',
    \ '	',
    \ '	    return 0;',
    \ '	}',
    \ '',
    \ '# mainc — clean main (no competitive headers)',
    \ 'snippet mainc',
    \ '	#include <iostream>',
    \ '	#include <string>',
    \ '	',
    \ '	int main(int argc, char* argv[]) {',
    \ '	    ${1:// code here}',
    \ '	    return 0;',
    \ '	}',
    \ '',
    \ '# cls — class with constructor/destructor',
    \ 'snippet cls',
    \ '	class ${1:ClassName} {',
    \ '	public:',
    \ '	    ${1:ClassName}(${2});',
    \ '	    ~${1:ClassName}();',
    \ '	',
    \ '	private:',
    \ '	    ${3:// members}',
    \ '	};',
    \ '',
    \ '# st — struct',
    \ 'snippet st',
    \ '	struct ${1:Name} {',
    \ '	    ${2:// fields}',
    \ '	};',
    \ '',
    \ '# vec — vector loop',
    \ 'snippet vec',
    \ '	for (const auto& ${1:item} : ${2:container}) {',
    \ '	    ${3:// body}',
    \ '	}',
    \ '',
    \ '# fori — indexed for loop',
    \ 'snippet fori',
    \ '	for (int ${1:i} = 0; ${1:i} < ${2:n}; ++${1:i}) {',
    \ '	    ${3:// body}',
    \ '	}',
    \ '',
    \ '# guard — header guard',
    \ 'snippet guard',
    \ '	#ifndef ${1:HEADER_H}',
    \ '	#define ${1:HEADER_H}',
    \ '	',
    \ '	${2:// content}',
    \ '	',
    \ '	#endif // ${1:HEADER_H}',
    \ '',
    \ '# pr — printf',
    \ 'snippet pr',
    \ '	printf("${1:%s}\n"${2:, });',
    \ '',
    \ '# cout',
    \ 'snippet co',
    \ '	std::cout << ${1:val} << "\n";',
    \ '',
    \ '# ptr — smart pointer',
    \ 'snippet uptr',
    \ '	std::unique_ptr<${1:Type}> ${2:ptr} = std::make_unique<${1:Type}>(${3});',
    \ '',
    \ 'snippet sptr',
    \ '	std::shared_ptr<${1:Type}> ${2:ptr} = std::make_shared<${1:Type}>(${3});',
    \ '',
    \ '# lam — lambda',
    \ 'snippet lam',
    \ '	auto ${1:fn} = [${2:&}](${3}) {',
    \ '	    ${4:// body}',
    \ '	};',
    \ '',
    \ '# try/catch',
    \ 'snippet try',
    \ '	try {',
    \ '	    ${1:// code}',
    \ '	} catch (const std::exception& e) {',
    \ '	    std::cerr << e.what() << "\n";',
    \ '	}',
    \ ]

  call writefile(l:lines, l:file)
endfunction

call s:WriteCustomSnippets()

" =============================
" TERMINAL — persistent split on the right
" =============================
" Ctrl+`  → toggle terminal open/closed
" Shell session stays alive when hidden; reopening restores it.
" Works in vanilla Vim 8.1+ with :terminal

let g:term_buf = 0
let g:term_win = 0

function! s:TermWidth()
  " 20% of the total Vim window width, minimum 20 cols
  return max([20, float2nr(&columns * 0.40)])
endfunction

function! s:ToggleTerminal()
  " If we're currently IN the terminal window → close/hide it
  if win_getid() == g:term_win
    close
    return
  endif

  " If the terminal window is open elsewhere → close it (toggle off)
  if win_gotoid(g:term_win)
    close
    return
  endif

  " Window is hidden — reuse existing buffer if shell is still alive
  if g:term_buf && bufexists(g:term_buf)
    botright vertical split
    execute 'buffer ' . g:term_buf
    execute 'vertical resize ' . s:TermWidth()
    let g:term_win = win_getid()
    startinsert
    return
  endif

  " First open — spawn a new terminal
  botright vertical terminal
  execute 'vertical resize ' . s:TermWidth()
  let g:term_buf = bufnr('')
  let g:term_win = win_getid()
endfunction

" Ctrl+` in normal, insert, and terminal modes
nnoremap <C-`> :call <SID>ToggleTerminal()<CR>
inoremap <C-`> <Esc>:call <SID>ToggleTerminal()<CR>
tnoremap <C-`> <C-w>:call <SID>ToggleTerminal()<CR>

" Jump back to the last code window from inside the terminal
" Press <C-w>h from terminal normal mode, or use the split nav below
" In terminal-job mode, <C-w>N enters terminal normal mode first
tnoremap <C-h> <C-w>h
tnoremap <C-j> <C-w>j
tnoremap <C-k> <C-w>k
tnoremap <C-l> <C-w>l
tnoremap <Esc> <C-w>N   " Esc in terminal → terminal normal mode

" =============================
" MARKDOWN
" =============================
let g:markdown_fenced_languages = [
      \ 'html',
      \ 'python',
      \ 'cpp',
      \ 'javascript=js',
      \ 'bash=sh',
      \ 'json',
      \ 'css',
      \ ]

let g:vim_markdown_conceal = 0
set conceallevel=0

augroup markdown_settings
  autocmd!
  autocmd FileType markdown setlocal spell spelllang=en
augroup END

" =============================
" C / C++ SETTINGS
" =============================
autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4
autocmd FileType c,cpp match ErrorMsg /\s\+$/

" Switch between .h and .cpp
nnoremap <leader>s :call SwitchSourceHeader()<CR>
function! SwitchSourceHeader()
  let l:ext = expand('%:e')
  if l:ext ==# 'cpp' || l:ext ==# 'cc'
    let l:alt = expand('%:r') . '.h'
  elseif l:ext ==# 'h' || l:ext ==# 'hpp'
    let l:alt = expand('%:r') . '.cpp'
    if !filereadable(l:alt)
      let l:alt = expand('%:r') . '.cc'
    endif
  endif
  if filereadable(l:alt)
    execute 'edit ' . l:alt
  else
    echo "No matching file found: " . l:alt
  endif
endfunction

" =============================
" KEY MAPPINGS
" =============================
let mapleader = " "

nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
nnoremap <leader>h :nohlsearch<CR>
inoremap jk <Esc>
nnoremap <leader>e :Ex<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>

" fzf
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fb :Buffers<CR>

" Move selected lines up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" =============================
" PERFORMANCE
" =============================
set updatetime=300
set timeoutlen=500

" =============================
" FORMAT FILE
" =============================
function! FormatFile()
    let l:view = winsaveview()
    if &filetype ==# 'cpp' || &filetype ==# 'c'
        silent %!clang-format
    elseif &filetype ==# 'python'
        silent %!black -
    elseif &filetype ==# 'javascript'
        silent %!prettier --stdin-filepath %
    endif
    normal! gg=G
    call winrestview(l:view)
endfunction

nnoremap <C-f> :call FormatFile()<CR>

" =============================
" RUN CODE
" =============================
function! RunCode()
    update
    let l:out = '/tmp/' . expand('%:t:r')

    if &filetype ==# 'c'
        execute '!clear && gcc -Wall -Wextra ' . shellescape(@%)
              \ . ' -o ' . shellescape(l:out) . ' && ' . shellescape(l:out)

    elseif &filetype ==# 'cpp'
        execute '!clear && g++ -std=c++17 -Wall -Wextra ' . shellescape(@%)
              \ . ' -o ' . shellescape(l:out) . ' && ' . shellescape(l:out)

    elseif &filetype ==# 'python'
        execute '!clear && python3 ' . shellescape(@%)

    elseif &filetype ==# 'javascript'
        execute '!clear && node ' . shellescape(@%)

    elseif &filetype ==# 'sh'
        execute '!clear && bash ' . shellescape(@%)

    else
        echo "No runner configured for this filetype"
    endif
endfunction

nnoremap <C-b> :call RunCode()<CR>
