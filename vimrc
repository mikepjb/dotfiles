" Editor Configuration
"
" Designed to be used for both vim & neovim where the executables are
" available on the system I'm currently using.

" editor settings
autocmd!
set nocompatible encoding=UTF-8
syntax on
filetype plugin indent on " see filetype-overview
set hidden " keep buffers open in the background
set visualbell " no audible bell thanks
set spell " spelling
set autowrite " save changed buffers when using ':make'
set textwidth=79
set path+=** wildmenu wildignore=*.jpg,*.png,*.gif,*.pdf
" behaviour settings
set mouse=a clipboard=unnamed,unnamedplus nobackup gdefault
set shiftwidth=4 tabstop=4 softtabstop=4 smarttab
set wrap
set incsearch hlsearch ignorecase " search preferences
set showmatch  " show matching [{()}]
set showmode showcmd
set history=1000 " remember more commands and searches, default is 20
set splitbelow splitright " open new splits (e.g help) at the bottom
set omnifunc=syntaxcomplete#Complete
set completeopt=menu,menuone,noinsert complete+=k
set undodir=~/.vim/backup undofile undoreload=10000
" appearance settings
set cursorline number laststatus=2 showtabline=2
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

let g:omni_sql_no_default_maps = 1 " don't let SQL files take over <C-c>
let g:sh_noisk = 1 " stop vim messing with iskeyword when opening a shell file
let g:netrw_banner = 0 | let g:netrw_liststyle = 3

fun! BaseTheme() abort "mini theme inside a function
	set notermguicolors t_Co=256
	hi clear
	colorscheme default
	set background=dark
	hi! Normal ctermfg=253 ctermbg=234 cterm=NONE
	hi! NonText ctermfg=253 ctermbg=234 cterm=NONE
	hi! StatusLine ctermfg=253 ctermbg=235 cterm=bold
	hi! StatusLineNC ctermfg=250 ctermbg=235 cterm=NONE
	hi! TabLine ctermfg=250 ctermbg=235 cterm=NONE
	hi! TabLineFill ctermfg=250 ctermbg=235 cterm=NONE
	hi! TabLineSel ctermfg=253 ctermbg=233 cterm=bold
    hi! ColorColumn ctermfg=NONE ctermbg=233 cterm=NONE
    hi! Cursor ctermfg=NONE ctermbg=NONE cterm=reverse
    hi! CursorColumn ctermfg=NONE ctermbg=236 cterm=NONE
    hi! CursorLine ctermfg=NONE ctermbg=235 cterm=NONE
    hi! LineNr ctermfg=253 ctermbg=235 cterm=NONE
    hi! CursorLineNr ctermfg=253 ctermbg=236 cterm=NONE
	hi! SpellBad ctermfg=1 ctermbg=NONE cterm=underline
	hi! Comment ctermfg=245 | hi! link Number Keyword
	hi! link String Keyword | hi! link markdownH2 Keyword
	hi! link markdownH3 Function | hi! link markdownH4 Type
endfun

augroup Base
	autocmd! | autocmd ColorScheme default call BaseTheme()
augroup END

colorscheme default " will also invoke our base changes shown above.

" custom configuration

" Minimalist-Tab Complete
inoremap <expr> <Tab> TabComplete()
fun! TabComplete()
	if getline('.')[col('.') - 2] =~ '\K' || pumvisible()
		return "\<C-N>"
	else
		return "\<Tab>"
	endif
endfun

" keybindings
nnoremap <C-j> <C-w><C-j> | nnoremap <C-k> <C-w><C-k>
nnoremap <C-h> <C-w><C-h> | nnoremap <C-l> <C-w><C-l>
nnoremap <Tab> <C-^>
nnoremap <C-g> :noh<CR><C-g>
nnoremap <C-q> :q<CR>
inoremap <C-c> <Esc>
nnoremap <CR> :make<CR>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
inoremap <C-l> <Space>=><Space> | inoremap <C-u> <Space>-><Space>
nnoremap Q @q

augroup command
	autocmd!
	" make sure <CR>/enter remains unmapped on the command line
	autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
	autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
	autocmd QuickFixCmdPost [^l]* nested cwindow
	autocmd QuickFixCmdPost    l* nested lwindow
	autocmd FileType rust setlocal makeprg=cargo\ build
augroup END

let mapleader = " "

nnoremap <leader>e :E<CR>
nnoremap <leader>r :E %:h<CR>
nnoremap <leader>f :find<space>
nnoremap <leader>t :!ctags -R .<space>
nnoremap <Leader>i :tabnew ~/.vimrc<CR>
nnoremap <Leader>n :tabnew ~/.notes/content/_index.md<CR>

let s:bashrc =<< END
[[ -f /etc/bash_completion ]] && . /etc/bash_completion
[[ hB =~ i ]] && stty -ixoff -ixon # Disable CTRL-S and CTRL-Q
export EDITOR=vim CDPATH=".:$HOME/src" PAGER='less -S'
export TERM='xterm-256color' NPM_CONFIG_PREFIX=$HOME/.config/npm
export PATH=$HOME/.cargo/bin:$HOME/.config/npm/bin:/usr/local/bin:/usr/bin:/bin
alias vi='vim' x='tmux attach -t x || tmux new -s x'
alias gr='cd $(git rev-parse --shot-toplevel || echo ".")'
viw() { vi `which "$!"`; }
PS1='\W($(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "!")) \$ '
END

let s:tmux =<< END
set -g history-limit 100000
set-window-option -g alternate-screen on
set -g status off; set -g lock-after-time 0
unbind C-b; set -g prefix C-q
unbind x ; bind x kill-pane
set -gq utf-8 on; set -g mouse on; set -g set-clipboard external;
set -g default-terminal "tmux-256color"; set -ag terminal-overrides ",$TERM:RGB"
END

fun! Dots() abort
	call writefile(s:bashrc, expand('$HOME/.bashrc'))
	call writefile(s:tmux, expand('$HOME/.tmux.conf'))

	let s:gPre = ";git config --global --replace-all "
	let s:git = ""
	let s:f = " %C(cyan)%<(12)%cr %Cgreen%<(14,trunc)%aN%C(auto)%d %Creset%s"
	for s in ["core.editor 'vim'",
			\"core.autocrlf false",  "init.defaultBranch 'main'",
			\"alias.aa 'add --all'", "alias.br 'branch --sort=committerdate'",
			\"alias.st 'status'",    "alias.up 'pull --rebase'",
			\"alias.co 'checkout'",  "alias.ci 'commit --verbose'",
			\"alias.di 'diff'",      "alias.dc 'diff --cached'",
			\"alias.amend 'commit --amend'",
			\"alias.push-new 'push -u origin HEAD'",
			\"alias.ra \"log --pretty=format:'%C(yellow)%h" .. s:f .. "'\""]
		let s:git = s:git .. s:gPre .. s
	endfor

	call system(s:git[1:]) " remove the first ; before calling
endfun
