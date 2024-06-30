-- Editor Configuration
-- optional plugins: plenary + nvim-telescope/telescope.nvim ------------------
-- clone the plugins here: ~/.config/nvim/pack/base/start/ --------------------

local base = vim.api.nvim_create_augroup('Base', {})

-- basic configuration --------------------------------------------------------
vim.opt.guicursor = ""        -- a. visual config
vim.opt.cursorline = true
vim.opt.textwidth = 79
vim.opt.colorcolumn = '80'
vim.opt.nu = true
vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

vim.opt.tabstop = 4            -- b. indentation
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false       -- c. backups
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true

vim.opt.gdefault = true        -- d. search/replacment
vim.opt.hlsearch = false
vim.opt.incsearch = true

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

vim.keymap.set("n", "gr", function ()
    if vim.g.loaded_telescope == 1 then
        return ":Telescope live_grep<CR>"
    else
        return ":grep "
    end
end, { expr = true })

vim.keymap.set("n", "<space>", function ()
    if vim.g.loaded_telescope == 1 then
        return ":Telescope find_files<CR>"
    else
        return ":find "
    end
end, { expr = true })

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

-- the rest? ------------------------------------------------------------------
local ok, _ = pcall(vim.cmd, 'colorscheme retrobox')
if not ok then
  vim.cmd 'colorscheme default' -- if the above fails, then use default
end

-- TODO include tmux too!
local bashrc = [[
export EDITOR=nvim CDPATH=".:$HOME/src" PAGER='less -S' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=$HOME/.cargo/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export RUST_SRC=$(rustc --print sysroot)/lib/rustlib/src/rust/library/
alias vi='nvim' gr='cd $(git rev-parse --shot-toplevel || echo \".\")'
PS1='\W($(git branch --show-current 2>/dev/null || echo "!")) \$ '
]]

local git_config = {
    ["core.editor"] = "nvim",
    ["core.autocrlf"] = "false",
    ["init.defaultBranch"] = "main",
    ["alias.aa"] = "add --all",
    ["alias.br"] = "branch --sort=committerdate",
    ["alias.st"] = "status",
    ["alias.up"] = "pull --rebase",
    ["alias.co"] = "checkout",
    ["alias.ci"] = "commit --verbose",
    ["alias.di"] = "diff",
    ["alias.push-new"] = "push -u origin HEAD",
    ["alias.ra"] = "log --pretty=format:" ..
    "\"%C(yellow)%h%Creset %<(7,trunc)%ae%C(auto)%d %Creset%s %Cgreen(%cr)\""
}

function dots()
    vim.fn.writefile({". ~/.bashrc"}, vim.fn.expand("$HOME/.bash_profile"))
    vim.fn.writefile(vim.fn.split(bashrc, "\n"), vim.fn.expand("$HOME/.bashrc"))
    if vim.fn.executable("git") == 1 then
        for k, v in pairs(git_config) do
            vim.fn.system("git config --global --replace-all " .. k .. " '" .. v .. "'")
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
