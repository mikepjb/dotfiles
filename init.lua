-- Editor Configuration
-- optional plugins: plenary + nvim-telescope/telescope.nvim

local base = vim.api.nvim_create_augroup('Base', {})

-- editor config goes here
vim.opt.guicursor = ""

vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.cursorline = true
vim.opt.colorcolumn = '80'
vim.opt.smartindent = true
vim.opt.gdefault = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50

-- keybindings go here
vim.keymap.set("n", "gn", ":tabnew ~/.notes/src/SUMMARY.md<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-g>", ":noh<CR><C-g>")
vim.keymap.set("n", "<Tab>", "<C-^>")
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "<C-l>", " => ")
vim.keymap.set("i", "<C-u>", " -> ")

-- LSP setup goes here


-- optional plugin stuff goes here
function register_lsp(cmd, pattern, root_files)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = pattern,
        callback = function()
            local root_dir = vim.fs.dirname(
                vim.fs.find(root_files, { upward = true })[1]
            )
            local client = vim.lsp.start({
                name = cmd[0], cmd = cmd, root_dir = root_dir,
            })
            vim.lsp.buf_attach_client(0, client)
        end
    })
end

register_lsp({'rust-analyzer'}, 'rust', {'Cargo.toml'})
register_lsp({'typescript-language-server', '--stdio'},
             'javascript,typescript,javascriptreact, typescriptreact',
             {'package.json'})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        local root_dir = vim.fs.dirname(
            vim.fs.find({ 'go.mod', 'go.work', '.git' }, { upward = true })[1]
        )
        local client = vim.lsp.start({
            name = 'gopls',
            cmd = { 'gopls' },
            root_dir = root_dir,
        })
        vim.lsp.buf_attach_client(0, client)
    end
})

-- vim.fn.colorscheme('retrobox')

local bashrc = [[
export EDITOR=vim CDPATH=".:$HOME/src" PAGER='less -S' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=$HOME/.cargo/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export RUST_SRC=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
alias vi='vim' gr='cd $(git rev-parse --shot-toplevel || echo \".\")'
PS1='\W($(git branch --show-current 2>/dev/null || echo "!")) \$ '
]]

function dots()
	vim.fn.writefile({". ~/.bashrc"}, vim.fn.expand("$HOME/.bash_profile"))
	vim.fn.writefile(vim.fn.split(bashrc, "\n"), vim.fn.expand("$HOME/.bashrc"))
end

vim.api.nvim_create_user_command('Dots', dots, {})
