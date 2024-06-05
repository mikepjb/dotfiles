" Editor Configuration for both Vim (pref. 9.1+) & Neovim (pref. 0.10+)

autocmd! | set nocompatible encoding=UTF-8 notgc t_Co=256
syntax on | filetype plugin indent on " see `:help filetype-overview`
runtime macros/matchit.vim
set path+=** wildmenu wildignore=*.jpg,*.png,*.gif,*.pdf " -- behaviour settings
set mouse=a clipboard=unnamed,unnamedplus nobackup noswapfile gdefault
set shiftwidth=4 tabstop=4 softtabstop=4 smarttab autoindent
set wrap hidden visualbell autowrite textwidth=79 colorcolumn=80 scrolloff=3
set incsearch hlsearch ignorecase " search preferences
set spell showmode showcmd history=1000 undodir=~/.vim/backup undofile ur=10000
set splitbelow splitright " open new splits (e.g help) at the bottom
set cursorline number showmatch laststatus=2 showtabline=2 " -- visual settings
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
let g:omni_sql_no_default_maps = 1 | let g:sh_noisk = 1 " prevent remaps
let g:netrw_banner = 0 | let g:netrw_liststyle = 3 " netrw config

augroup Base " <CR> mappings + :make filetype configs
	autocmd!
	autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
	autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
	autocmd QuickFixCmdPost [^l]* nested cwindow
	autocmd QuickFixCmdPost    l* nested lwindow
	autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC/rusty-tags.vi
	autocmd FileType rust setlocal makeprg=cargo\ build
augroup END

let mapleader = " " " -- keybindings
nnoremap <leader>e :E<CR>|nnoremap <leader>r :E %:h<CR>
nnoremap <leader>f :find<space>
nnoremap <leader>t :!ctags -R .<space>
nnoremap <Leader>n :tabnew ~/.notes/content/_index.md<CR>
nnoremap gp :silent %!prettier --stdin-filepath %<CR>
nnoremap <C-j> <C-w><C-j>|nnoremap <C-k> <C-w><C-k>
nnoremap <C-h> <C-w><C-h>|nnoremap <C-l> <C-w><C-l>
nnoremap <Tab> <C-^>|nnoremap <C-g> :noh<CR><C-g>|nnoremap <C-q> :q<CR>
inoremap <C-c> <Esc>|nnoremap <CR> :make<CR>|nnoremap Q @q
inoremap <C-l> <Space>=><Space>|inoremap <C-u> <Space>-><Space>

if v:version < 901 | finish | endif

colorscheme retrobox

let s:bashrc =<<EOD
[[ -f /etc/bash_completion ]] && . /etc/bash_completion
[[ hB =~ i ]] && stty -ixoff -ixon # Disable CTRL-S and CTRL-Q
export EDITOR=vim CDPATH=".:$HOME/src" PAGER='less -S'
export TERM='xterm-256color' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=$HOME/.cargo/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export RUST_SRC=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
alias vi='vim' x='tmux attach -t x || tmux new -s x'
alias gr='cd $(git rev-parse --shot-toplevel || echo \".\")'
PS1='\W($(git branch --show-current 2>/dev/null || echo "!")) \$ '
EOD

fun! Dots() abort " create basic dotfiles
	call writefile([". ~/.bashrc"], expand('$HOME/.bash_profile'))
	call writefile(s:bashrc, expand('$HOME/.bashrc'))
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
endfun | command! Dots :call Dots()
