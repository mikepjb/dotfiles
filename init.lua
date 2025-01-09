-- Editor Configuration
-- (plenary, telescope + nvim-lint) clone plugins here: ~/.config/nvim/pack/base/start/ --
-- TODO maybe git fugitive too?
-- TODO lsp-zero can do eslint? have a look and see how!

-- local function maybe_require(module_name)
--     local ok, module = pcall(require, module_name)
--     if ok then
--         return module
--     end
--     return nil
-- end
-- 
-- local telescope = maybe_require("telescope.builtin")
-- if telescope then
--     vim.keymap.set('n', '<space>', builtin.find_files, {})
-- end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key before lazy
-- vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

-- TODO do not use lazy.nvim since you can't resource :so your config
-- Initialize lazy with plugins
require("lazy").setup({
  {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.5',
    dependencies = { 
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    config = function()
      -- Basic Telescope keymaps
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<space>', builtin.find_files, {})
      -- vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      -- vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      -- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            transparent = true,  -- Enable transparency
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
})

local base = vim.api.nvim_create_augroup('Base', { clear = true })

-- editor configuration ---------------------------------------------------------------------------
vim.opt.guicursor = ""        -- a. visual config
vim.opt.cursorline = true
vim.opt.textwidth = 99
vim.opt.colorcolumn = '100'
vim.opt.spell = false -- no spell, can we enable for just markdown + comments?
vim.opt.nu = true
vim.opt.rnu = false -- maybe default true in future?
vim.opt.showtabline = 2
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.wildmode = "list:longest,list:full"
vim.opt.wildignore:append({"node_modules"})
vim.opt.suffixesadd:append({".rs"}) -- search for suffixes using gf
vim.opt.completeopt:remove("preview") -- no preview buffer during completion
vim.opt.clipboard:append({"unnamedplus"}) -- integrate with system clipboard
vim.opt.autoread = true
vim.opt.foldlevel = 1 -- by default, only show top level fold/heading

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
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.g.markdown_fenced_languages = {'typescript', 'javascript', 'bash', 'go'}
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.

vim.opt.termguicolors = os.getenv("COLORTERM") == 'truecolor'

-- local ok, _ = pcall(vim.cmd, 'colorscheme retrobox')
-- if not ok then
--     -- can use vim.cmd.colorscheme(input)
--     vim.cmd 'colorscheme default' -- if the above fails, then use default
-- end

-- keymap configuration ---------------------------------------------------------------------------

function set_path_to_git_root(filepath) -- or do nothing if not in git.
    if not filepath then
        filepath = vim.fn.expand("%:p:h")
    end
    local pwd_cmd = string.format(
        "cd %s && echo -n \"$(git rev-parse --show-toplevel 2>/dev/null || echo $PWD)\"",
        filepath
    )
    local new_pwd = vim.fn.system(pwd_cmd)
    print(string.format("tcd set as '%s'", new_pwd))
    vim.cmd(string.format(":tcd  %s", new_pwd))
end

vim.keymap.set("n", "<C-q>", ":q<CR>")
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
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>")
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "gn", ":tabnew ~/notes/src/index.md<CR>")
vim.keymap.set("n", "go", ":tabnew ~/notes/src/ops.md<CR>")
vim.keymap.set("n", "g0", function () vim.lsp.stop_client(vim.lsp.get_active_clients()) end)
vim.keymap.set("n", "gl", ":set rnu!<CR>") -- toggle relative line number
vim.keymap.set("n", "g?", ":Dots<CR>")
vim.keymap.set("n", "gi", ":tabnew ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>")
vim.keymap.set("n", "gP", set_path_to_git_root) -- backup, shouldn't need to do this manually.
vim.keymap.set("n", "gr", ":call feedkeys(':grep<space>', 't')<CR>")
vim.keymap.set("n", "g*", function () vim.cmd(":grep " .. vim.fn.expand("<cword>")) end)
vim.keymap.set("n", ",", "/TODO\\|NEXT\\|XXX<CR>")
vim.keymap.set("n", "-", "za")
vim.keymap.set("n", "_", ":set foldlevel=1<CR>")

vim.api.nvim_create_autocmd("TabNewEntered", {
    group = base, callback = function(ev)
        vim.schedule(function()
            local netrw_dir = vim.b.netrw_curdir
            if netrw_dir then
                set_path_to_git_root(netrw_dir)
            end
        end)
    end
})

-- always open quickfix window automatically.
-- this uses cwindows which will open it only if there are entries.
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = vim.api.nvim_create_augroup("AutoOpenQuickfix", { clear = true }),
  pattern = { "[^l]*" },
  command = "cwindow"
})

local css_reset = [[
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0;}
body { line-height: 1.5; font-size: 100%; -webkit-font-smoothing: antialiased; }
img, picture, video, canvas, svg { display: block; max-width: 100%; }
input, button, textarea, select { font: inherit; }
p, h1, h2, h3, h4, h5, h6 { overflow-wrap: break-word; }
html { -moz-text-size-adjust: none; -webkit-text-size-adjust: none; text-size-adjust: none; }
]]
vim.fn.setreg("r", css_reset)

local html_template = [[
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link rel="stylesheet" href="/style.css" type="text/css" media="all" />
	</head>
</html>
]]
vim.fn.setreg("h", html_template)

-- environment configuration ----------------------------------------------------------------------

if vim.fn.executable("rg") == 1 then
    -- works slightly differently, use :grep foo, open results with copen
    vim.opt.grepprg = "rg --vimgrep"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

-- vim.keymap.set("n", "<space>", function ()
--     if vim.g.loaded_telescope == 1 then
--         return ":Telescope find_files<CR>"
--     else
--         return ":find "
--     end
-- end, { expr = true })

function register_lsp(cmd, pattern, root_files)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = pattern,
        callback = function()
            local root_dir = vim.fs.dirname(
                vim.fs.find(root_files, { upward = true })[1]
            )
            local client = vim.lsp.start({
                name = cmd[1], cmd = cmd, root_dir = root_dir,
            })
            if vim.fn.executable(cmd[1]) == 1 then
                vim.lsp.buf_attach_client(0, client)
            else
               print("Could not register lsp, '" .. cmd[0] .. "' couldn't be found.") 
            end
        end
    })
end

register_lsp({'rust-analyzer'}, 'rust', {'Cargo.toml'})
-- register_lsp({'jdtls'}, 'java', {'gradlew'})

if vim.fn.executable("typescript-language-server") == 1 and
    vim.fn.isdirectory("./node_modules/typescript") == 1 then
    register_lsp(
        {'typescript-language-server', '--stdio'},
        'javascript,typescript,javascriptreact,typescriptreact',
        {'package.json'}
    )
end

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

local bashrc = [=[
[[ -f /etc/bash_completion ]] && . /etc/bash_completion
export BASH_SILENCE_DEPRECATION_WARNING=1 # Mac OS likes to think bash is going out of fashion.
export EDITOR=nvim CDPATH=".:$HOME/src" PAGER='less -S' NPM_CONFIG_PREFIX=$HOME/.npm
export PATH=/usr/local/go/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.npm/bin:/opt/homebrew/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin
export HISTSIZE=100000 HISTCONTROL=erasedups
shopt -s histappend
alias vi='nvim' gr='cd $(git rev-parse --show-toplevel || echo \".\")'
alias x='tmux attach -t x || tmux new -s x' sk='eval $(ssh-agent -k)'
alias sa='pkill ssh-agent; eval $(ssh-agent -t 28800); ssh-add ~/.ssh/id_rsa'
alias new-pass="head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | echo"
[[ -f $HOME/.bashrc.local ]] && . $HOME/.bashrc.local
jobs_signal() { [[ $(jobs) != "" ]] && echo -e "\x01\033[0;36m\x02\$\x01\033[0m\x02" || echo -e "\$"; }
PS1='\h:\W($(git branch --show-current 2>/dev/null || echo "!")) $(jobs_signal) '
]=]

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
    ["alias.count"] = "shortlog -sn",
    ["alias.push-new"] = "push -u origin HEAD",
    ["alias.ra"] = "log --pretty=format:" ..
    "\"%C(yellow)%h%Creset %<(7,trunc)%ae%C(auto)%d %Creset%s %Cgreen(%cr)\""
}

function dots()
    vim.fn.writefile({". ~/.bashrc"}, vim.fn.expand("$HOME/.bash_profile"))
    vim.fn.writefile(vim.fn.split(bashrc, "\n"), vim.fn.expand("$HOME/.bashrc"))
    vim.fn.writefile(vim.fn.split(tmux_conf, "\n"), vim.fn.expand("$HOME/.config/tmux/tmux.conf"))
    if vim.fn.executable("git") == 1 then
        for k, v in pairs(git_config) do
            vim.fn.system("git config --global --replace-all " .. k .. " '" .. v .. "'")
        end
    end
end

vim.api.nvim_create_user_command('Dots', dots, {})
vim.api.nvim_create_user_command('Prettify', function()
    vim.cmd '%!jq .'
end, {})
vim.api.nvim_create_user_command('TrimWhitespace', function()
    vim.cmd '%s/\\s\\+$//e'
end, {})

-- Extra Highlighting
--
-- TODO.. TODO/NEXT etc highlighting, maybe for markdown only?
-- TODO extra whitespace /\s\+$/
-- :highlight ExtraWhitespace ctermbg=red guibg=red
-- :match ExtraWhitespace /\s\+$/
-- ..alternatively set listchars https://vim.fandom.com/wiki/Highlight_unwanted_spaces#Using_the_list_and_listchars_options

-- external stuff/packages ------------------
-- Linting --------------------------------------------------------------------
-- require('lint').linters_by_ft = {
--   go = {'golangcilint',}
-- }

-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--   callback = function()
--     require("lint").try_lint()
--   end,
-- })

-- TODO write a function that will try to download your dependencies and optionally takes an
-- argument to prefix so you can use artifactory etc? or overkill?
-- TODO pushd on cd, allow selecta style cli to pick from previous stack (deduped)
