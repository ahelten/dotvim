" START TEMPLATE FOR UPDATING 'path' variable using directory of .local.vimrc
" " what is the name of the directory containing this file?
" let s:et_dir = expand('<sfile>:p:h')
" " add the directory to 'path'
" let &path = printf('%s,%s/**', &path, s:et_dir)
" END TEMPLATE FOR UPDATING 'path' variable using directory of .local.vimrc

let g:syntastic_python_python_exec = 'python3'
set nocompatible
call pathogen#infect()
call pathogen#helptags()
se nobackup
se directory=~/.vim/swp,.
se shiftwidth=4
se sts=4
se modelines=2
se modeline
se nocp
set number
" ttymouse is set at the end because it apparently gets overwritten somewhere between
if !has("gui_running")
   "set mouse=a
   set clipboard=unnamed
else
   set go+=a
endif

" It isn't setup yet, so complains on startup
set runtimepath-=~/.vim/bundle/YouCompleteMe

if has("win32unix") " i.e. cygwin
   " This plugin doesn't work on cygwin/windows (opening a file just hangs vim)
   set runtimepath-=~/.vim/bundle/vim-localrc
"   set runtimepath-=~/.vim/bundle/a
"   set runtimepath-=~/.vim/bundle/clang_complete
"   set runtimepath-=~/.vim/bundle/easymotion
"   set runtimepath-=~/.vim/bundle/flake8
"   set runtimepath-=~/.vim/bundle/indentTabObjects
"   set runtimepath-=~/.vim/bundle/nerdtree
"   set runtimepath-=~/.vim/bundle/RainbowParenthsis
"   set runtimepath-=~/.vim/bundle/repeat
"   set runtimepath-=~/.vim/bundle/slime
"   set runtimepath-=~/.vim/bundle/surround
"   set runtimepath-=~/.vim/bundle/taglist
"   set runtimepath-=~/.vim/bundle/ultisnips
"   set runtimepath-=~/.vim/bundle/ultisnips/after
endif

set runtimepath-=~/.vim/bundle/clang_complete
if (! executable('astyle'))
   set runtimepath-=~/.vim/bundle/vim-autoformat
endif

if has("autocmd")
    filetype on
    filetype indent on
    filetype plugin on
endif

" Don't prompt when loading local .lvimrc
let g:localvimrc_ask = 0

"
" YCM setup/config
"
if has("win32unix")
   let g:ycm_show_diagnostics_ui = 0
endif
let g:ycm_always_populate_location_list = 1

"
" Add git branch to statusline as well as other status info
"
set noruler
set laststatus=2
set statusline=%t\ [%{strlen(&fenc)?&fenc:'none'},%{&ff}]\ %h%m%r%y\ %{fugitive#statusline()}%=%c,%l/%L\ %P

"
" Search path for 'gf' command (e.g. open #include-d files)
"
"set path+=.**
set path+=/usr/include/c++/**


"
" Tags
"
" If I ever need to generate tags on the fly, I uncomment this:
" noremap <C-F11> :!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>


" This will look in current directory for "tags", and work up the tree towards root until one is found.
set tags+=./tags;/
set tags+=/usr/include/tags

" For GTRI JPALS development
"set tags+=/cygdrive/c/amh_devel/anp/gtri-jpals/tags
"set path+=/cygdrive/c/amh_devel/anp/gtri-jpals/**
"set path+=~/GTRI-JPALS-inyer-FACE/amh_devel/gtri-jpals/**

" For ACM development
set path+=/opt/ACM-INSTALL/include/**
set tags+=/opt/ACM-INSTALL/include/tags

"set tags+=~/amh_devel/sw/MudbucketCxx/tags


" C-\ - Open the definition in a new tab (using tags)
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
" A-] - Open the definition in a vertical split (using tags)
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>


" se autoindent
" se undofile
" se undodir=~/.vimundo
"noremap <ESC>OP <F1>

" Remap rapid 'jj' sequence to Escape
inoremap jj <Esc>


"
" necessary for using libclang, comment out if libclang.so is missing
"
if has("python")
    let g:clang_complete_auto = 1
endif

if has("win32unix") " i.e. cygwin
    " let g:clang_library_path='/usr/local/clang-llvm/lib'
    "AHelten: Use g:clang_user_options='|| exit 0' with cygwin clang
    " let g:clang_exec = '/bin/clang'
    " let g:clang_user_options='|| exit 0'
    " let g:clang_exec = '/usr/local/clang-llvm/bin/clang'
    "AHelten: clang_frontend is a perl script front-end to MinGW clang
    let g:clang_use_library = 1
    "let g:clang_exec = '~/.vim/clang_frontend'
    "let g:clang_exec = '/usr/bin/clang'
    let g:clang_library_path='~/.vim/libclang.so'
    "let g:clang_library_path='/usr/local/lib'
    "let g:clang_library_path='/usr/lib64/llvm'
    "let g:clang_exec = '/usr/bin/clang'
"    let g:clang_library_path='/home/andy.helten/.vim'
else
    let g:clang_use_library = 1
    let g:clang_library_path='/usr/lib/x86_64-linux-gnu'
endif

" AHelten: enable copen when debugging 'pattern not found' or other problems
"let g:clang_complete_copen = 1

let g:clang_complete_macros=1
let g:clang_complete_patterns=0

" let g:clang_user_options = '-include-pch'
" Remove -std=c++11 if you don't use C++ for everything like I do.
"let g:clang_user_options=' -std=c++11 || exit 0'
"let g:clang_user_options='|| exit 0'
" Set this to 0 if you don't want autoselect, 1 if you want autohighlight,
" and 2 if you want autoselect. 0 will make you arrow down to select the first
" option, 1 will select the first option for you, but won't insert it unless you
" press enter. 2 will automatically insert what it thinks is right. 1 is the most
" convenient IMO, and it defaults to 0.
let g:clang_auto_select=1

let g:clang_snippets = 1
let g:clang_snippets_engine = 'ultisnips'
"let g:clang_snippets_engine = 'clang_complete'


" auto-closes preview window after you select what to auto-complete with
autocmd CursorMovedI * if pumvisible() == 0|silent! pclose|endif
autocmd InsertLeave * if pumvisible() == 0|silent! pclose|endif


"
" maps NERDTree to F10
"
noremap <silent> <F10> :NERDTreeToggle<CR>
noremap! <silent> <F10> <ESC>:NERDTreeToggle<CR>


"
" tells NERDTree to use ASCII chars
"
let g:NERDTreeDirArrows=0


"
" Better TAB completion for files (like the shell)
"
if has("wildmenu")
    set wildmenu
    set wildmode=longest,list
    " Ignore stuff (for TAB autocompletion)
    set wildignore+=*.a,*.o
    set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
    set wildignore+=.DS_Store,.git,.hg,.svn
    set wildignore+=*~,*.swp,*.tmp
    if exists("&wildignorecase")
        set wildignorecase
    endif
endif

"
" Python stuff
"
" obsolete, replaced by flake8
" PEP8
"let g:pep8_map='<leader>8'


" flake8: ignore 'too long lines'
let g:flake8_ignore="E501,E225"


"
" My attempt at easy navigation/creation of windows:
"   Ctrl-Cursor keys to navigate open windows
"   Ctrl-F12 to close current window
"
function! WinMove(key)
  let t:curwin = winnr()
  exec "wincmd ".a:key
  if (t:curwin == winnr()) "we havent moved
    if (match(a:key,'[jk]')) "were we going up/down
      wincmd v
    else
      wincmd s
    endif
    exec "wincmd ".a:key
  endif
endfunction
function! WinClose()
  if &filetype == "man"
    bd!
  else
    bd
  endif
endfunction
if !has("gui_running")
    " XTerm
    noremap <silent> [1;5B :call WinMove('j')<CR>
    noremap <silent> [1;5A :call WinMove('k')<CR>
    noremap <silent> [1;5D :call WinMove('h')<CR>
    noremap <silent> [1;5C :call WinMove('l')<CR>
    noremap <silent> [24;5~ :call WinClose()<CR>
    noremap! <silent> [1;5B <ESC>:call WinMove('j')<CR>
    noremap! <silent> [1;5A <ESC>:call WinMove('k')<CR>
    noremap! <silent> [1;5D <ESC>:call WinMove('h')<CR>
    noremap! <silent> [1;5C <ESC>:call WinMove('l')<CR>
    noremap! <silent> [24;5~ <ESC>:call WinClose()<CR>

    " Putty-ing from Windows 
    "
    if has("unix")
      let myosuname = system("uname")
      if myosuname =~ "OpenBSD"
	" Putty-ing from Windows into OpenBSD
"	noremap <silent> [B :call WinMove('j')<CR>
"	noremap <silent> [A :call WinMove('k')<CR>
"	noremap <silent> [D :call WinMove('h')<CR>
"	noremap <silent> [C :call WinMove('l')<CR>
"	noremap <silent> [24~ :call WinClose()<CR>
"	noremap! <silent> [B <ESC>:call WinMove('j')<CR>
"	noremap! <silent> [A <ESC>:call WinMove('k')<CR>
"	noremap! <silent> [D <ESC>:call WinMove('h')<CR>
"	noremap! <silent> [C <ESC>:call WinMove('l')<CR>
"	noremap! <silent> [24~ <ESC>:call WinClose()<CR>
      elseif &term == "xterm-color"
	" Putty-ing from Windows into Linux
"	noremap <silent> OB :call WinMove('j')<CR>
"	noremap <silent> OA :call WinMove('k')<CR>
"	noremap <silent> OD :call WinMove('h')<CR>
"	noremap <silent> OC :call WinMove('l')<CR>
"	noremap <silent> [24~ :call WinClose()<CR>
"	noremap! <silent> OB <ESC>:call WinMove('j')<CR>
"	noremap! <silent> OA <ESC>:call WinMove('k')<CR>
"	noremap! <silent> OD <ESC>:call WinMove('h')<CR>
"	noremap! <silent> OC <ESC>:call WinMove('l')<CR>
"	noremap! <silent> [24~ <ESC>:call WinClose()<CR>
      endif
    endif
else
    " GVim
    noremap <silent> <C-Down>  :call WinMove('j')<CR>
    noremap <silent> <C-Up>    :call WinMove('k')<CR>
    noremap <silent> <C-Left>  :call WinMove('h')<CR>
    noremap <silent> <C-Right> :call WinMove('l')<CR>
    noremap <silent> <C-F12>   :call WinClose()<CR>
    noremap! <silent> <C-Down>  <ESC>:call WinMove('j')<CR>
    noremap! <silent> <C-Up>    <ESC>:call WinMove('k')<CR>
    noremap! <silent> <C-Left>  <ESC>:call WinMove('h')<CR>
    noremap! <silent> <C-Right> <ESC>:call WinMove('l')<CR>
    noremap! <silent> <C-F12>   <ESC>:call WinClose()<CR>
endif


"
" incremental search that highlights results
"
se incsearch
se hlsearch
" Ctrl-L clears the highlight from the last search
noremap <C-l> :nohlsearch<CR><C-l>
noremap! <C-l> <ESC>:nohlsearch<CR><C-l>


"
" Smart in-line manpages with 'K' in command mode
"
if 0 " amh: Just use built-in :Man <func>  -- or built-in K mapping
fun! ReadMan()
  " Assign current word under cursor to a script variable:
  let s:man_word = expand('<cword>')
  " Open a new window:
  :wincmd n
  " Read in the manpage for man_word (col -b is for formatting):
  :exe ":r!man " . s:man_word . " | col -b"
  " Goto first line...
  :goto
  " and delete it:
  :delete
  " finally set file type to 'man':
  :set filetype=man
  " lines set to 20
  :resize 20
endfun
" Map the K key to the ReadMan function:
noremap K :call ReadMan()<CR>
else
runtime ftplugin/man.vim
endif


"
" Toggle TagList window with F8
"
noremap <silent> <F8> :TlistToggle<CR>
noremap! <silent> <F8> <ESC>:TlistToggle<CR>


"
" Fix insert-mode cursor keys in FreeBSD
"
if has("unix")
  let myosuname = system("uname")
  if myosuname =~ "FreeBSD"
    set term=cons25
  elseif myosuname =~ "Linux"
    set term=linux
  endif
endif


"
" Reselect visual block after indenting
"
vnoremap < <gv
vnoremap > >gv


"
" Keep search pattern at the center of the screen
"
"nnoremap <silent> n nzz
"nnoremap <silent> N Nzz
"nnoremap <silent> * *zz
"nnoremap <silent> # #zz


"
" Function that sends individual Python classes or Python functions 
" to active screen (SLIME emulation)
" 
function! SelectClassOrFunction ()

    let s:currLine = getline(line('.'))
    if s:currLine =~ '^def\|^class' 
	" If the cursor line is a function/class start line, 
	" save its number
	let s:beginLineNumber = line('.')
    elseif s:currLine =~ '^[a-zA-Z]'
	" If the cursor line begins with something else, 
	" we must be on something like a global assignment
	let s:beginLineNumber = line('.')
	let s:endLineNumber = line('.')
	:exe ":" . s:beginLineNumber . "," . s:endLineNumber . "y r"
	:call Send_to_Screen(@r)
	return
    else
	" we are inside something, so search backwards 
	" for function/class beginning, and save its number
	let s:beginLineNumber = search('^def\|^class', 'bnW')
	if !s:beginLineNumber 
	    let s:beginLineNumber = 1
	endif
    endif

    " Now search for the first line that starts with something
    " (function, class, global, etc) and save it
    let s:endLineNumber = search('^[a-zA-Z@]', 'nW')
    if !s:endLineNumber
	let s:endLineNumber = line('$')
    else
	let s:endLineNumber = s:endLineNumber-1
    endif

    " Finally pass the range to the screen session running a REPL
    :exe ":" . s:beginLineNumber . "," . s:endLineNumber . "y r"
    :call Send_to_Screen(@r)
endfunction
nmap <silent> <C-c><C-c> :call SelectClassOrFunction()<CR><CR>


"
" Make Y behave like other capitals
"
"noremap Y y$


"
" Force Saving Files that Require Root Permission
"
cmap w!! %!sudo tee > /dev/null %


"
" Syntastic - Ignore 'too long lines' from flake8 report
"
"let g:syntastic_python_checker_args = "--ignore=E501,E225"


"
"when the vim window is resized resize the vsplit panes as well
"
au VimResized * exe "normal! \<c-w>="


"
" TAB and Shift-TAB in normal mode cycle buffers
"
:nmap <Tab> :bn<CR>
:nmap <S-Tab> :bp<CR>


"
" Syntax-coloring of files
if &t_Co > 2 || has("gui_running")
  syntax on
endif

" Begin AMH customizations
"
set background=dark
" Some "linux" VGA console terminals will blink the file text if only 8 colors
" are support by the terminal. Enable the 'if/endif' when that happens.
" if $TERM != "linux"
  set t_Co=256    " set to 256 colors
" endif
" Both of the Visual parameters must be '1' to get brighter Visual highlighting
let g:zenburn_old_Visual = 1
let g:zenburn_alternate_Visual = 1
let g:zenburn_high_Contrast = 1
colorscheme zenburn

if has("win32") " i.e. native windows
  " Microsoft Windows key mappings, like Ctrl-X/C/V for cut/copy/paste
  " Only enable this on the GUI (which I currently only run on Windows)
  source $VIMRUNTIME/mswin.vim
endif

set expandtab
set smarttab
if has("win32unix") " i.e. cygwin
    set pastetoggle=<F2>
else
    " This is <F2>
    set pastetoggle=OQ
endif

" mostly left this as an example of how to customize for a specific host
if hostname() == 'CDM'
    set textwidth=100
else
    " Set textwidth smaller for C/C++ style comments
    autocmd CursorMoved,CursorMovedI * if match(getline(line('.')), '^\s*\/*[\*\/]') == 0 | setlocal textwidth=95 | else | setlocal textwidth=100 | endif
endif
set colorcolumn=100
set shiftwidth=4
set cinoptions=:0.5s,g0.5s,h0.5s,t0,(0,+0,u0

au BufNewFile,BufRead *.doxygen setfiletype doxygen
au BufNewFile,BufRead *.md set filetype=markdown

set history=150		" keep 150 lines of command line history

set backspace=indent,eol,start " Allow deleting backward past starting point

if 0 " Don't know yet whether these are needed
 set nojoinspaces 
 setlocal isfname+=:  " actually belongs in ftplugin/perl.vim?
endif


" Sudow = sudo-write of a file without restarting vim, see also ':w!!'
command! -bar -nargs=0 Sudow   :silent exe "write !sudo tee % >/dev/null"|silent edit!

" cp = (change-paste) replace current word with default copy/yank register
nmap <silent> cp "_cw<C-R>"<Esc>
" Make p in Visual mode replace the selected text with the "" register.
"vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" From https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text:
" if you want to paste the same text a second time, you must use the "0 register, as in viw"0p. A
" workaround is to remap the p command in visual mode so that it first deletes to the black hole
" register like so:
xnoremap p "_dP
" However, the above remapping prevents you from pasting from other registers in visual mode. So
" viw"ap to paste from the "a register is now broken. There might be workarounds, like
" <leader_char>p for the paste command (e.g. 'tp') but I don't paste from other registers in visual
" mode so I can tolerate that broken feature.

" These do grep searches of the current word and display the results
if has("win32unix") " i.e. cygwin
    map <F5> [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
    map <F6> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
else
    " These are F5 and F6 respectively
    map [15~ [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
    map [17~ :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>
endif

"set tags+=~/.commontags

" ----------------------- Begin Latex-Suite Additions -----------------------
" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*


if has("autocmd")

  " OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
  " 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
  " The following changes the default filetype back to 'tex':
  let g:tex_flavor='latex'
  autocmd FileType tex,sty  set formatoptions=tcqwa textwidth=78 formatlistpat='^\\s*\\' nojoinspaces spell
  " ----------------------- End Latex-Suite Additions -----------------------

  " In text files, always limit the width of text to 78 characters
  "autocmd BufRead *.txt set tw=78

  " Remove all cprog autocommands
  "au!

  " When starting to edit a file:
  "   For C and C++ files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  "   This formatlist is not quite right:  formatlistpat=^\\s*\\*\\s*@
  "   This formatlist is not quite right:  formatlistpat="^\s*\*\s*\d*[\]:.)}\t@ ].*"
  "  
  "autocmd FileType c,cpp,h,idl  set formatoptions=croqlna cindent comments=sr:/*,mb:*,el:*/,:// nojoinspaces
  "autocmd FileType cc,c,cpp,h,hpp  set formatoptions=croqln formatlistpat=^\\s*\\*\\s*@ cindent comments=sr:/*,mb:*,el:*/,:// nojoinspaces
  autocmd FileType cc,c,cpp,h,hpp  set formatoptions=croqln formatlistpat=^\\s*\\*\\s*@ comments=sr:/*,mb:*,el:*/,:// nojoinspaces cindent
  
  if (executable('astyle'))
     " The following FileType settings will use astyle to dynamically (as-you-type) do formatting...
     " but it doesn't appear to use my astylerc so it does the wrong thing. I also think it would be
     " too restrictive in preventing me from breaking the astyle-imposed format when I really want to:
     "autocmd FileType cc,c,cpp,h,hpp  set formatoptions=roqlnaj formatlistpat=^\\s*\\*\\s*@ comments=sr:/*,mb:*,el:*/,:// nojoinspaces formatprg=astyle\ --options=/home/ahelten/.mca.astylerc

     " This FileType setting uses astyle for '=' reformatting, such as, 'gg=G' or '==':
     "autocmd FileType cc,c,cpp,h,hpp  set equalprg=astyle\ --options=/home/ahelten/.mca.astylerc

     let g:formatdef_my_c_cpp_astyle='"astyle --mode=c --suffix=none --options=/home/ahelten/.mca.astylerc"'
     let g:formatters_cpp = ['my_c_cpp_astyle']
     let g:formatters_c = ['my_c_cpp_astyle']
     let g:autoformat_autoindent = 0
     let g:autoformat_retab = 0
     let g:autoformat_remove_trailing_spaces = 0

     " This for the auto-format plugin and allows using <F3> to reformat an entire file using my
     " astylerc:
     if has("win32unix") " i.e. cygwin
        noremap <F3>   :Autoformat<CR>
     else
        " This is <F3>
        noremap OR   :Autoformat<CR>
     endif
  endif

  " This is disabled, because it changes the jumplist.  Can't use CTRL-O to go
  " back to positions in previous files more than once.
  if 0
    " When editing a file, always jump to the last cursor position.
    " This must be after the uncompress commands.
    autocmd BufReadPost * if line("'\"") && line("'\"") <= line("$") | exe "normal `\"" | endif
  endif

endif " has("autocmd")



" This is Method2 from http://vim.wikia.com/wiki/Talk:Highlight_multiple_words
" Use \ma to highlight with color 1, 2\ma to highlight with color 2, 3\ma for color 3, etc
" Use n\mc to change a color mapping (or just edit the mapping below)
"
function! DoHighlight(hlnum, search_term)
  call UndoHighlight(a:hlnum)
  if len(a:search_term) > 0
    let id = matchadd('hl'.a:hlnum, a:search_term, -1)
  endif
endfunction

function! UndoHighlight(hlnum)
  silent! call matchdelete(GetId(a:hlnum))
endfunction

function! GetId(hlnum)
  for m in getmatches()
    if m['group'] == 'hl'.a:hlnum
      return m['id']
    endif
  endfor
  return 0
endfunction

function! SetHighlight(hlnum, colour)
  if len(a:colour) > 0
    exe "highlight hl".a:hlnum." term=bold ctermfg=".a:colour." guifg=".a:colour
  endif
endfunction

call SetHighlight(1, 'darkred')
call SetHighlight(2, 'darkgreen')
call SetHighlight(3, 'darkblue')
call SetHighlight(4, 'darkcyan')
call SetHighlight(5, 'darkmagenta')
call SetHighlight(6, 'red')
call SetHighlight(7, 'green')
call SetHighlight(8, 'blue')
call SetHighlight(9, 'cyan')
nnoremap <Leader>ma :<C-u>call DoHighlight(v:count1, expand("<cword>"))<CR>
nnoremap <Leader>md :<C-u>call UndoHighlight(v:count1)<CR>
nnoremap <Leader>mc :<C-u>call SetHighlight(v:count1, input("Enter colour: "))<CR>


" Search for selected text (e.g. select words using 'vww' and then '*' as always)
" http://vim.wikia.com/wiki/VimTip171
" - A global variable (g:VeryLiteral) controls whether selected whitespace
"   matches any whitespace (by default, VeryLiteral is off, so any whitespace is
"   found).
" - Type \vl to toggle VeryLiteral to turn whitespace matching off/on
"   (assuming the default backslash leader key).
" - When VeryLiteral is off, any selected leading or trailing whitespace will
"   not match newlines, which is more convenient, and avoids false search hits.
"
let s:save_cpo = &cpo | set cpo&vim
if !exists('g:VeryLiteral')
  let g:VeryLiteral = 0
endif

function! s:VSetSearch(cmd)
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')
  normal! gvy
  if @@ =~? '^[0-9a-z,_]*$' || @@ =~? '^[0-9a-z ,_]*$' && g:VeryLiteral
    let @/ = @@
  else
    let pat = escape(@@, a:cmd.'\')
    if g:VeryLiteral
      let pat = substitute(pat, '\n', '\\n', 'g')
    else
      let pat = substitute(pat, '^\_s\+', '\\s\\+', '')
      let pat = substitute(pat, '\_s\+$', '\\s\\*', '')
      let pat = substitute(pat, '\_s\+', '\\_s\\+', 'g')
    endif
    let @/ = '\V'.pat
  endif
  normal! gV
  call setreg('"', old_reg, old_regtype)
endfunction

vnoremap <silent> * :<C-U>call <SID>VSetSearch('/')<CR>/<C-R>/<CR>
vnoremap <silent> # :<C-U>call <SID>VSetSearch('?')<CR>?<C-R>/<CR>
vmap <kMultiply> *

nmap <silent> <Plug>VLToggle :let g:VeryLiteral = !g:VeryLiteral
  \\| echo "VeryLiteral " . (g:VeryLiteral ? "On" : "Off")<CR>
if !hasmapto("<Plug>VLToggle")
  nmap <unique> <Leader>vl <Plug>VLToggle
endif
let &cpo = s:save_cpo | unlet s:save_cpo


" Moving between windows with Ctrl-j, etc. Also note that <C-w><C-p> goes to 'previous' window
:noremap <C-j> <C-w>j
:noremap <C-k> <C-w>k
:noremap <C-h> <C-w>h
:noremap <C-l> <C-w>l

" Restores console screen when exiting or Ctrl-Z-ing from vim
" (http://vimdoc.sourceforge.net/htmldoc/tips.html#xterm-screens)
set t_ti=[?47h t_te=[?47l
" Restores console screen when exiting or Ctrl-Z-ing from vim (but this version jumps cursor to top
" without clearing screen so not good when the screen contains stuff):
"set t_ti=7[r[?47h t_te=[?47l8

" This enables some mouse actions like moving the cursor and visual selection in rxvt
if !has("gui_running")
   set ttymouse=xterm
   let &t_ti.="\e[1 q"
   let &t_SI.="\e[5 q"
   let &t_EI.="\e[1 q"
   let &t_te.="\e[0 q"
endif


if has('cscope')
    set cscopetag cscopeverbose

    if has('quickfix')
        set cscopequickfix=s-,c-,d-,i-,t-,e-
    endif

    cnoreabbrev csa cs add
    cnoreabbrev csf cs find
    cnoreabbrev csk cs kill
    cnoreabbrev csr cs reset
    cnoreabbrev css cs show
    cnoreabbrev csh cs help

    command! -nargs=0 Cscope cs add $VIMSRC/src/cscope.out $VIMSRC/src
endif
