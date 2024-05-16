" Editor Configuration for both Vim & Neovim

autocmd! | set nocompatible encoding=UTF-8 notgc t_Co=256
syntax on | filetype plugin indent on " see `:help filetype-overview`
set path+=** wildmenu wildignore=*.jpg,*.png,*.gif,*.pdf " -- behaviour settings
set mouse=a clipboard=unnamed,unnamedplus nobackup gdefault autoindent
set shiftwidth=4 tabstop=4 softtabstop=4 smarttab
set wrap hidden visualbell autowrite textwidth=79 colorcolumn=80 scrolloff=3
set incsearch hlsearch ignorecase " search preferences
set spell showmode showcmd history=1000 undodir=~/.vim/backup undofile ur=10000
set splitbelow splitright " open new splits (e.g help) at the bottom
set omnifunc=syntaxcomplete#Complete
set completeopt=menu,menuone,noinsert complete+=k
set cursorline number showmatch laststatus=2 showtabline=2 " -- visual settings
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
let g:omni_sql_no_default_maps = 1 | let g:sh_noisk = 1 " prevent remaps
let g:netrw_banner = 0 | let g:netrw_liststyle = 3 " netrw config
let $COLORFGBG='7;0' " ensure terminal vim defaults to dark background with bg&

augroup Base " theme + <CR> mappings + :make filetype configs
	autocmd!
	autocmd ColorScheme default call BaseTheme()
	autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
	autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
	autocmd QuickFixCmdPost [^l]* nested cwindow
	autocmd QuickFixCmdPost    l* nested lwindow
	autocmd FileType rust setlocal makeprg=cargo\ build
augroup END

fun! BaseTheme() abort " mini theme inside a function
	hi! Normal ctermfg=253 ctermbg=234 cterm=NONE
	hi! NonText ctermfg=253 ctermbg=234 cterm=NONE
	hi! StatusLine ctermfg=253 ctermbg=235 cterm=bold
	hi! StatusLineNC ctermfg=250 ctermbg=235 cterm=NONE
	hi! TabLine ctermfg=250 ctermbg=235 cterm=NONE
	hi! TabLineFill ctermfg=250 ctermbg=235 cterm=NONE
	hi! TabLineSel ctermfg=252 ctermbg=233 cterm=bold
    hi! ColorColumn ctermfg=NONE ctermbg=233 cterm=NONE
    hi! Cursor ctermfg=NONE ctermbg=NONE cterm=reverse
    hi! CursorColumn ctermfg=NONE ctermbg=236 cterm=NONE
    hi! CursorLine ctermfg=NONE ctermbg=235 cterm=NONE
    hi! LineNr ctermfg=242 ctermbg=234 cterm=NONE
    hi! CursorLineNr ctermfg=253 ctermbg=236 cterm=NONE
	hi! SpellBad ctermfg=9 ctermbg=NONE cterm=underline
	hi! Comment ctermfg=245 | hi! link Number Keyword
	hi! link String Keyword | hi! link markdownH2 Keyword
	hi! link markdownH3 Function | hi! link markdownH4 Type
endfun | colorscheme default

let mapleader = " " " -- keybindings
nnoremap <leader>e :E<CR>|nnoremap <leader>r :E %:h<CR>
nnoremap <leader>f :find<space>
nnoremap <leader>t :!ctags -R .<space>
nnoremap <Leader>n :tabnew ~/.notes/content/_index.md<CR>
nnoremap <C-j> <C-w><C-j>|nnoremap <C-k> <C-w><C-k>
nnoremap <C-h> <C-w><C-h>|nnoremap <C-l> <C-w><C-l>
nnoremap <Tab> <C-^>|nnoremap <C-g> :noh<CR><C-g>|nnoremap <C-q> :q<CR>
inoremap <C-c> <Esc>|nnoremap <CR> :make<CR>|nnoremap Q @q
inoremap <C-l> <Space>=><Space>|inoremap <C-u> <Space>-><Space>

let s:bashrc = "[[ -f /etc/bash_completion ]] && . /etc/bash_completion"
	\."\n[[ hB =~ i ]] && stty -ixoff -ixon # Disable CTRL-S and CTRL-Q"
	\."\nexport EDITOR=vim CDPATH=\".:$HOME/src\" PAGER='less -S' COLORFGBG='7;0'"
	\."\nexport TERM='xterm-256color' NPM_CONFIG_PREFIX=$HOME/.npm"
	\."\nexport PATH=$HOME/.cargo/bin:$HOME/.npm/bin:/usr/local/bin:/usr/bin:/bin"
	\."\nalias vi='vim' x='tmux attach -t x || tmux new -s x'"
	\."\nalias gr='cd $(git rev-parse --shot-toplevel || echo \".\")'"
	\."\nPS1='\W($(git branch --show-current 2>/dev/null || echo \"!\")) \\$ '"

let s:tmux = "set -g history-limit 100000; set -g status off; set -g lock-after-time 0"
	\."\nset-window-option -g alternate-screen on"
	\."\nunbind C-b; set -g prefix C-q; unbind x; bind x kill-pane"
	\."\nset -gq utf-8 on; set -g mouse on; set -g set-clipboard external;"
	\."\nset -g default-terminal \"tmux-256color\"; set -ag terminal-overrides \",$TERM:RGB\""

fun! Dots() abort " create basic dotfiles
	call writefile([". ~/.bashrc"], expand('$HOME/.bash_profile'))
	call writefile(split(s:bashrc, '\n'), expand('$HOME/.bashrc'))
	call writefile(split(s:tmux, '\n'), expand('$HOME/.tmux.conf'))
	let s:gPre = ";git config --global --replace-all " | let s:git = ""
	let s:f = " %C(cyan)%<(12)%cr %Cgreen%<(14,trunc)%aN%C(auto)%d %Creset%s"

	for s in ["core.editor 'vim'",
			\"core.autocrlf false",  "init.defaultBranch 'main'",
			\"alias.aa 'add --all'", "alias.br 'branch --sort=committerdate'",
			\"alias.st 'status'",    "alias.up 'pull --rebase'",
			\"alias.co 'checkout'",  "alias.ci 'commit --verbose'",
			\"alias.di 'diff'",      "alias.amend 'commit --amend'",
			\"alias.push-new 'push -u origin HEAD'",
			\"alias.ra \"log --pretty=format:'%C(yellow)%h" . s:f . "'\""]
		let s:git = s:git . s:gPre . s
	endfor | call system("command -v git && $(" . s:git[1:] . ")")
endfun
