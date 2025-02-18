-- Editor Configuration

-- Environment ------------------------------------------------------------------------------------

local function maybe_require(module_name)
    local ok, module = pcall(require, module_name)
    if ok then
        return module
    end
    return nil
end

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --vimgrep"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Appearance -------------------------------------------------------------------------------------
local tokyonight = maybe_require('tokyonight')
if tokyonight then
    tokyonight.setup({
        transparent = true, -- Enable transparency
        styles = {
            sidebars = 'transparent',
            floats = 'transparent',
        },
    })

    vim.cmd([[colorscheme tokyonight]])
end

local base = vim.api.nvim_create_augroup('Base', { clear = true })

-- Editor Behaviour -------------------------------------------------------------------------------
vim.opt.guicursor = "" -- a. visual config
vim.opt.cursorline = true
vim.opt.textwidth = 99
vim.opt.colorcolumn = '100'
vim.opt.spell = false -- no spell, can we enable for just markdown + comments?
vim.opt.nu = true
vim.opt.rnu = false   -- maybe default true in future?
vim.opt.showtabline = 2
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.wildmode = "list:longest,list:full"
vim.opt.wildignore:append({ "node_modules" })
vim.opt.suffixesadd:append({ ".rs" })       -- search for suffixes using gf
vim.opt.completeopt:remove("preview")       -- no preview buffer during completion
vim.opt.clipboard:append({ "unnamedplus" }) -- integrate with system clipboard
vim.opt.autoread = true
vim.opt.foldlevel = 1                       -- by default, only show top level fold/heading
vim.opt.lazyredraw = false                  -- make sure we always redraw

vim.opt.tabstop = 4                         -- b. indentation
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false -- c. backups
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true

vim.opt.gdefault = true -- d. search/replacment
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.g.markdown_fenced_languages = { 'typescript', 'javascript', 'bash', 'go' }
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.

vim.opt.termguicolors = os.getenv("COLORTERM") == 'truecolor'

vim.api.nvim_create_autocmd("FileType", {
    group = base,
    pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact", "json"},
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
    end,
})

local function set_path_to_git_root(filepath) -- or do nothing if not in git.
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

vim.api.nvim_create_autocmd("TabNewEntered", {
    group = base,
    callback = function(_)
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

-- Keybindings & Commands -------------------------------------------------------------------------

vim.keymap.set("n", "<C-q>", ":q<CR>")
vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-g>", ":noh<CR><C-g>")
vim.keymap.set("n", "<Tab>", "<C-^>")
vim.keymap.set("n", "L", function() vim.diagnostic.open_float(0, { scope = "line" }) end)
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "<C-l>", " => ")
vim.keymap.set("i", "<C-u>", " -> ")
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>")
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "gh", ":Explore<CR>")
vim.keymap.set("n", "gn", ":tabnew ~/.notes/index.md<CR>")
vim.keymap.set("n", "go", ":tabnew ~/.notes/areas/ops.md<CR>")
vim.keymap.set("n", "gw", ":tabnew ~/.notes/areas/work.md<CR>")
vim.keymap.set("n", "gs", ":tabnew ~/.notes/areas/special-ops.md<CR>")
vim.keymap.set("n", "g0", function() vim.lsp.stop_client(vim.lsp.get_active_clients()) end)
vim.keymap.set("n", "gl", ":set rnu!<CR>") -- toggle relative line number
vim.keymap.set("n", "g?", ":Dots<CR>")
vim.keymap.set("n", "gi", ":tabnew ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>")
vim.keymap.set("n", "gP", set_path_to_git_root) -- backup, shouldn't need to do this manually.
-- vim.keymap.set("n", "gr", ":call feedkeys(':grep<space>', 't')<CR>")
vim.keymap.set("n", "g*", function() vim.cmd(":grep " .. vim.fn.expand("<cword>")) end)
vim.keymap.set("n", ",", "/TODO\\|NEXT\\|XXX<CR>")
vim.keymap.set("n", "-", "za")
vim.keymap.set("n", "_", ":set foldlevel=1<CR>")

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

-- take single line stacktraces from logs and expand them
vim.api.nvim_create_user_command('Destack', function()
    vim.cmd [[silent! %s/\\t/	/]]
    vim.cmd [[silent! %s/\\n/\r/]]
end, {})

-- same for json
vim.api.nvim_create_user_command('Prettify', function()
    vim.cmd [[silent! %s/\\//]]
    vim.cmd [[:. !jq .]]
end, {})

vim.api.nvim_create_user_command('TrimWhitespace', function()
    vim.cmd '%s/\\s\\+$//e'
end, {})

-- Packages & Configuration ------------------------------------------

maybe_require('plenary') -- dep for telescope
-- maybe_require('nvim-web-devicons') -- dep for telescope, think it gets loaded automatically
local telescope = maybe_require('telescope')
if telescope then
    telescope.setup({
        defaults = {
            path_display = { "truncate" }
        }
    })
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<space>', builtin.find_files, {})
    vim.keymap.set('n', 'gr', builtin.live_grep, {})
    vim.keymap.set('n', 'gb', builtin.buffers, {})
end

local cmp = maybe_require('cmp')
if cmp then
    cmp.setup({
        mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'buffer' }, -- for buffer words
            { name = 'path' }, -- for path
        }),
        window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },
    })
end

local mason = maybe_require('mason')
local mason_lspconfig = maybe_require('mason-lspconfig')
local lspconfig = maybe_require('lspconfig')
if lspconfig and mason and mason_lspconfig then
    mason.setup()
    mason_lspconfig.setup({
        automatic_installation = true,
        ensure_installed = {
            "lua_ls",
            "gopls",
            "pyright",
            "ts_ls",
            "rust_analyzer",
            "jdtls",
        },
    })

    local on_attach = function(client, bufnr)
        -- Keymaps
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        -- vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
        -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    end

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = {
                    ignoreDir = { "undodir" }
                },
            },
        },
    })

    lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true, -- Enable stricter formatting
                buildFlags = { "-tags=integration" },
            },
        },
        flags = {
            debounce_text_changes = 150,
        },
    })

    local servers = { "pyright", "ts_ls", "rust_analyzer", "jdtls" }
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
    end

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.go" },
        callback = function()
            vim.lsp.buf.format()

            vim.lsp.buf.code_action({
                context = {
                    only = { "source.organizeImports" }
                },
                apply = true
            })
        end
    })
end

local treesitter = maybe_require('nvim-treesitter')
if treesitter then
    require('nvim-treesitter.configs').setup {
        modules = {},
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        ensure_installed = {
            "markdown",
            "java",
            "go",
            "lua",
            "bash",
            "javascript",
            "typescript",
            "tsx"
        },

        highlight = {
            enable = true,
            disable = { "gitcommit" }, -- for some reason treesitter doesn't highlight diffs
        },

        indent = {
            enable = true,
        }
    }
end

local lint = maybe_require('nvim-lint')
if lint then
    lint.linters_by_ft = {
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        golang = { 'golangci-lint' },
    }
end

local conform = maybe_require('conform')
if conform then
    conform.setup(
        {
            formatters_by_ft = {
                typescript = { "prettier" },
                typescriptreact = { "prettier" },
                javascript = { "prettier" },
                javascriptreact = { "prettier" },
            }
        }
    )

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
            require("conform").format({ bufnr = args.buf })
        end,
    })
end

vim.keymap.set("n", "gB", ":G blame<CR>")

-- TODO nvim-lint?
-- TODO maybe git fugitive too?
-- TODO lsp-zero can do eslint? have a look and see how!
