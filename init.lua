-- Editor Configuration
-- optional plugins: plenary + nvim-telescope/telescope.nvim ------------------

local base = vim.api.nvim_create_augroup('Base', {})

-- basic configuration --------------------------------------------------------
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

-- keybindings ----------------------------------------------------------------
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

-- TODO include inside nvim grepping function?

vim.keymap.set("n", "<space>", function ()
    -- if nvim-telescope/telescope.nvim & plenary.nvim are installed
    -- clone the plugins here: ~/.config/nvim/pack/base/start/
    if vim.g.loaded_telescope == 1 then
        vim.cmd('Telescope find_files')
        -- TODO can we do this directly without .cmd?
    else
        print('no telescope')
        -- we want :find
    end
end)


-- LSP ------------------------------------------------------------------------
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

-- LspAttach!

-- vim.fn.colorscheme('retrobox')

-- TODO include tmux too!
local bashrc = [[
export EDITOR=vim CDPATH=".:$HOME/src" PAGER='less -S' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=$HOME/.cargo/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export RUST_SRC=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
alias vi='vim' gr='cd $(git rev-parse --shot-toplevel || echo \".\")'
PS1='\W($(git branch --show-current 2>/dev/null || echo "!")) \$ '
]]

local git_config = {
    ["core.editor"] = "nvim",
    ["core.autocrlf"] = "false",
}

function dots()
    vim.fn.writefile({". ~/.bashrc"}, vim.fn.expand("$HOME/.bash_profile"))
    vim.fn.writefile(vim.fn.split(bashrc, "\n"), vim.fn.expand("$HOME/.bashrc"))
    if vim.fn.executable("git") == 1 then
        for k, v in pairs(git_config) do
            print("git config --global --replace-all " .. k .. " '" .. v .. "'")
        end
    end
end

vim.api.nvim_create_user_command('Dots', dots, {})

local css_reset = [[
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0;}
body { line-height: 1.5; font-size: 100%; -webkit-font-smoothing: antialiased; }
img, picture, video, canvas, svg { display: block; max-width: 100%; }
input, button, textarea, select { font: inherit; }
p, h1, h2, h3, h4, h5, h6 { overflow-wrap: break-word; }
html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }
]]
vim.fn.setreg("r", css_reset)
