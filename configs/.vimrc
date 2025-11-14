"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible "Not compatible with the old-fashion vi mode
set bs=2 "allow backspacking over everything in insert mode

set ruler "show the cursor position all the time
set autoread "Set to auto read when a file is changed from the outside
set history=700 "Sets how many lines of history VIM has to remember

" Show file title in the console title bar
set title

" :W - saves the file using sudo
" (useful for handling the permission-denied error)
"command W w !sudo tee % > /dev/null

" auto reload vimrc when editing it
autocmd! bufwritepost .vimrc source ~/.vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256

" Enable syntax highlighting
syntax enable

try
"    colorscheme desert
    colorscheme default
catch
endtry

set background=dark

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editor related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set showmode " always show what mode we're currently editing in

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Line numbering, text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number "Set line number
set numberwidth=3 " number of columns for line numbers
set expandtab "Use spaces instead of tabs
set smarttab "enable smarttab

set linespace=2 " Set linespace

"set textwidth=0 " do not wrap words (insert)
"set nowrap " do not wrap words (view)

set showmatch " Show matching brackets

" 1 tab = 4 spaces
set tabstop=4 "a <TAB> is 4 spaces
set shiftwidth=4 "number of spaces to use for autoindenting
set softtabstop=4 "when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftround "use multiple of shitwidth when indenting with '<' & '>'

set ai "Auto indent
set si "Smart indent

" Highlight the current line
"set cursorline

" Switching filetype on so that auto-indent works for various languages
" auto-indent can be done using 'gg=G'
"
"   --> 'gg' go to top of file;
"   --> '=' turns on indent;
"   --> 'G' indents until the last line.
"
"   =, the indent command can take motions. So, gg to get the start of the
"   file, = to indent, G to the end of the file, gg=G.
filetype on
filetype plugin on
filetype indent on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Keep all temporary and backup files in one place.
" Taken from: http://stackoverflow.com/a/164867
" set backup
" set backupdir=~/.vim/backup
" set directory=~/.vim/tmp

if has("win16") || has("win32") || has("win64")
    set directory=$TMP
else
    set directory=~/.vim/tmp
end

" Turn backup off, if using version control
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Useful Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
