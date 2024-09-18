-- Editor Configuration
-- (plenary, telescope + nvim-lint) clone plugins here: ~/.config/nvim/pack/base/start/ --

local base = vim.api.nvim_create_augroup('Base', {})

-- basic configuration --------------------------------------------------------
vim.opt.guicursor = ""        -- a. visual config
vim.opt.cursorline = true
vim.opt.textwidth = 99
vim.opt.colorcolumn = '100'
vim.opt.nu = true
vim.opt.showtabline = 2
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.wildmode = "list:longest,list:full"
vim.opt.wildignore:append({"node_modules"})
vim.opt.suffixesadd:append({".rs"}) -- search for suffixes using gf
vim.opt.completeopt:remove("preview") -- no preview buffer during completion
vim.opt.clipboard:append({"unnamedplus"}) -- integrate with system clipboard

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
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.g.markdown_fenced_languages = {'typescript', 'javascript', 'bash', 'go'}

local ok, _ = pcall(vim.cmd, 'colorscheme retrobox')
if not ok then
  vim.cmd 'colorscheme default' -- if the above fails, then use default
end

-- keybindings ----------------------------------------------------------------
vim.keymap.set("n", "gn", ":tabnew ~/.notes/src/SUMMARY.md<CR>")
vim.keymap.set("n", "g0", function () vim.lsp.stop_client(vim.lsp.get_active_clients()) end)
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-g>", ":noh<CR><C-g>")
vim.keymap.set("n", "<Tab>", "<C-^>")
vim.keymap.set("n", "L", function () vim.diagnostic.open_float(0, {scope="line"}) end)
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
             'javascript,typescript,javascriptreact,typescriptreact',
             {'package.json'})
register_lsp({"gopls"}, "go", {"go.mod"})
-- register_lsp({"golangci-lint"}, "go", {"go.mod"})
--
vim.api.nvim_create_autocmd('LspAttach', {
    group = base,
    callback = function()
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    end
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({async = false})
  end
})

-- external config ------------------------------------------------------------
local bashrc = [[
export EDITOR=nvim CDPATH=".:$HOME/src" PAGER='less -S' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=$HOME/go/bin:$HOME/.cargo/bin:$HOME/.npm/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export HISTSIZE=10000 HISTCONTROL=erasedups
shopt -s histappend
alias vi='nvim' gr='cd $(git rev-parse --show-toplevel || echo \".\")'
alias x='tmux attach -t x || tmux new -s x' sk='eval $(ssh-agent -k)'
alias sa='pkill ssh-agent; eval $(ssh-agent -t 28800); ssh-add ~/.ssh/id_rsa'
PS1='\h:\W($(git branch --show-current 2>/dev/null || echo "!")) \$ '
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

local utilities = { "rg", "htop", "tmux", "go", "node" }

function dots()
    vim.fn.writefile({". ~/.bashrc"}, vim.fn.expand("$HOME/.bash_profile"))
    vim.fn.writefile(vim.fn.split(bashrc, "\n"), vim.fn.expand("$HOME/.bashrc"))
    if vim.fn.executable("git") == 1 then
        for k, v in pairs(git_config) do
            vim.fn.system("git config --global --replace-all " .. k .. " '" .. v .. "'")
        end
    end

    for _, u in ipairs(utilities) do
        if vim.fn.executable(u) == 0 then
            print("missing " .. u)
        end
    end
end

vim.api.nvim_create_user_command('Dots', dots, {})

-- snippets -------------------------------------------------------------------
local css_reset = [[
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0;}
body { line-height: 1.5; font-size: 100%; -webkit-font-smoothing: antialiased; }
img, picture, video, canvas, svg { display: block; max-width: 100%; }
input, button, textarea, select { font: inherit; }
p, h1, h2, h3, h4, h5, h6 { overflow-wrap: break-word; }
html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }
]]
vim.fn.setreg("r", css_reset)
