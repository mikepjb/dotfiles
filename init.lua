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
vim.opt.textwidth = 0
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
vim.filetype.add({ extension = { tmpl = "gotmpl" } })
vim.filetype.add({ extension = { templ = "templ" } })

vim.opt.termguicolors = os.getenv("COLORTERM") == 'truecolor'

vim.api.nvim_create_autocmd("FileType", {
    group = base,
    pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
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
vim.keymap.set("n", "U", function() vim.diagnostic.open_float(0, { scope = "line" }) end)
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "<C-l>", " => ")
vim.keymap.set("i", "<C-u>", " -> ")
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>")
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "S", "<C-^>")
vim.keymap.set("n", "gh", ":Explore<CR>")
vim.keymap.set("n", "gn", ":tabnew ~/.notes/index.md<CR>")
vim.keymap.set("n", "go", ":tabnew ~/.notes/areas/ops.md<CR>")
vim.keymap.set("n", "gw", ":tabnew ~/.notes/areas/work.md<CR>")
vim.keymap.set("n", "gs", ":tabnew ~/.notes/areas/special-ops.md<CR>")
vim.keymap.set("n", "g0", ":LspRestart<CR>")
vim.keymap.set("n", "gL", ":set rnu!<CR>") -- toggle relative line number
vim.keymap.set("n", "gR", ":Grep ")
vim.keymap.set("n", "g?", ":Dots<CR>")
vim.keymap.set("n", "gi", ":tabnew ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>")
vim.keymap.set("n", "gP", set_path_to_git_root) -- backup, shouldn't need to do this manually.
-- vim.keymap.set("n", "gr", ":call feedkeys(':grep<space>', 't')<CR>")
vim.keymap.set("n", "g*", function() vim.cmd(":grep " .. vim.fn.expand("<cword>")) end)
vim.keymap.set("n", ",", "/TODO\\|NEXT\\|XXX<CR>")
vim.keymap.set("n", "-", "za")
vim.keymap.set("n", "_", ":set foldlevel=1<CR>")
-- vim.keymap.set('n', 'gw', function()
--   local current_tw = vim.opt.textwidth
--   vim.opt.textwidth = 99
--   vim.cmd('normal! gw')
--   vim.opt.textwidth = current_tw
-- end, {noremap = true, expr = true})
vim.keymap.set('n', 'ge', function()
    local current_dir = vim.fn.expand('%:p:h')
    local input_cmd = ':e ' .. current_dir .. '/'

    -- Enable auto-creation of parent directories
    vim.opt.backupskip:append('*') -- Avoid backup file issues
    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function()
            local dir = vim.fn.expand('<afile>:p:h')
            if vim.fn.isdirectory(dir) == 0 then
                vim.fn.mkdir(dir, 'p')
            end
        end
    })

    vim.api.nvim_feedkeys(input_cmd, 'n', true)
end, { desc = 'Create/edit file relative to current buffer' })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.keymap.set("n", "j", "j<CR><C-w>p", { buffer = true })
        vim.keymap.set("n", "k", "k<CR><C-w>p", { buffer = true })
    end
})

vim.api.nvim_create_user_command('Grep', function(opts)
    vim.cmd('silent grep! ' .. opts.args)
    local qflist = vim.fn.getqflist()
    if #qflist > 0 then
        vim.cmd('copen')
        vim.cmd('cfirst')
        vim.cmd('wincmd j')
    else
        print("No matches found")
    end
end, { nargs = '+' })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "S", "<C-^>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "n", "Q", ":b#<bar>bd #<CR>", { noremap = true, silent = true })
    end
})

local debounce_time = 300 -- milliseconds, adjust as needed

local last_j_time = 0
local function debounced_j()
    local current_time = vim.loop.now()
    if current_time - last_j_time < debounce_time then
        vim.api.nvim_echo({ { 'Try using different motions instead of repeated j', 'WarningMsg' } }, false, {})
        last_j_time = current_time
        return
    end
    last_j_time = current_time
    return 'j'
end

local last_k_time = 0
local function debounced_k()
    local current_time = vim.loop.now()
    if current_time - last_k_time < debounce_time then
        vim.api.nvim_echo({ { 'Try using different motions instead of repeated k', 'WarningMsg' } }, false, {})
        last_k_time = current_time
        return
    end
    last_k_time = current_time
    return 'k'
end

for _, mode in ipairs({ 'n', 'x' }) do
    vim.keymap.set(mode, 'j', debounced_j, { expr = true })
    vim.keymap.set(mode, 'k', debounced_k, { expr = true })
end

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
    vim.keymap.set('n', '<space>', function()
        builtin.find_files({
            hidden = true,
            file_ignore_patterns = { "^.git/" }
        })
    end, {})
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
            { name = 'path' },   -- for path
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
            "html",
            "tailwindcss",
            "htmx",
            "jdtls",
        },
    })

    local on_attach = function(_, bufnr)
        -- Keymaps
        local opts = { noremap = true, silent = true, buffer = bufnr }
        -- remove 'gr' prefix bindings to avoid conflict with my 'gr' switch buffer binding
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gli", vim.lsp.buf.implementation)
        vim.keymap.set("n", "glr", vim.lsp.buf.references)
        vim.keymap.set("n", "gla", vim.lsp.buf.code_action)
        vim.keymap.set("n", "gln", vim.lsp.buf.rename)
    end

    -- More minimal capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

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
        filetypes = { "go", "gomod", "gowork" },
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true, -- Enable stricter formatting
                buildFlags = { "-tags=integration,e2e" },
            },
        },
        flags = {
            debounce_text_changes = 150,
        },
    })

    local servers = { "pyright", "ts_ls", "rust_analyzer" }
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })
    end

    local function jdk_source()
        local java_home = os.getenv('JAVA_HOME')
        local jdk_src = java_home .. '/lib/src.zip'

        if vim.fn.filereadable(jdk_src) == 1 then
            return jdk_src
        else
            -- Try to find source.zip or src.zip in various locations
            local possible_paths = {
                java_home .. '/src.zip',
                java_home .. '/lib/src.zip',
                java_home .. '/jre/lib/src.zip',
                -- macOS-specific paths
                java_home .. '/../src.zip',
                '/Library/Java/JavaVirtualMachines/adoptopenjdk-*/Contents/Home/src.zip',
            }

            for _, path in ipairs(possible_paths) do
                local expanded_path = vim.fn.glob(path)
                if expanded_path ~= '' and vim.fn.filereadable(expanded_path) == 1 then
                    return expanded_path
                end
            end
        end

        return nil
    end

    local jdtls_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

    local function get_mason_launcher_jar()
        local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')

        if launcher_jar == '' then
            error('Could not find launcher jar in Mason. Please install JDTLS properly.')
            return nil
        end

        return launcher_jar
    end

    local os_config
    if vim.fn.has('mac') == 1 then
        os_config = 'config_mac'
    elseif vim.fn.has('unix') == 1 then
        os_config = 'config_linux'
    elseif vim.fn.has('win32') == 1 then
        os_config = 'config_win'
    end

    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name



    if os.getenv('JAVA_HOME') then
        lspconfig.jdtls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { "java" },
            cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xmx1G',
                '--add-modules=ALL-SYSTEM',
                '--add-opens', 'java.base/java.util=ALL-UNNAMED',
                '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
                '-jar', get_mason_launcher_jar(),
                '-configuration', jdtls_path .. '/' .. os_config,
                '-javaagent:' .. jdtls_path .. '/lombok.jar',  -- Important for Lombok and Spring Boot annotation processing
                '--add-opens=java.base/java.lang=ALL-UNNAMED', -- This is critical for Spring Boot '@' annotations
                '-data', workspace_dir,
            },
            settings = {
                java = {
                    signatureHelp = { enabled = true },
                    contentProvider = { preferred = 'fernflower' },
                    completion = {
                        importOrder = {
                            "java",
                            "javax",
                            "com",
                            "org",
                            "io",
                            ""
                        },
                    },
                    maven = { downloadSources = true },
                    gradle = { downloadSources = true },
                    implementationsCodeLens = { enabled = true },
                    referencesCodeLens = { enabled = true },
                    references = { includeDecompiledSources = true },
                    inlayHints = { parameterNames = { enabled = "all" } },
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999,
                        },
                    },
                    codeGeneration = {
                        toString = {
                            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
                        },
                        useBlocks = true,
                    },
                    configuration = {
                        updateBuildConfiguration = "interactive",
                        runtimes = {
                            {
                                name = "JavaSE-21",
                                sources = jdk_source(),
                                javaHome = os.getenv('JAVA_HOME'),
                                path = os.getenv("HOME") .. "/.sdkman/candidates/java/current",

                            },
                        },
                    },
                }
            },
        })
    end

    lspconfig.html.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "gotmpl", "templ" },
    })

    lspconfig.htmx.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "gotmpl", "templ" },
    })

    lspconfig.tailwindcss.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "astro", "javascript", "typescript", "react", "gotmpl", "templ" },
        settings = {
            tailwindCSS = {
                includeLanguages = {
                    gotmpl = "html",
                },
            },
        },
    })

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

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.html", "*.tmpl", "*.templ", "*.lua" },
        callback = function()
            if vim.bo.filetype == "templ" then
                local bufnr = vim.api.nvim_get_current_buf()
                local filename = vim.api.nvim_buf_get_name(bufnr)
                local cmd = "templ fmt " .. vim.fn.shellescape(filename)

                vim.fn.jobstart(cmd, {
                    on_exit = function()
                        -- Reload the buffer only if it's still the current buffer
                        if vim.api.nvim_get_current_buf() == bufnr then
                            vim.cmd('e!')
                        end
                    end,
                })
            else
                vim.lsp.buf.format()
            end
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
            "tsx",
            "html",
            "gotmpl",
            "templ",
        },

        highlight = {
            enable = true,
            disable = { "gitcommit", "xml", "html" },
        },

        indent = {
            enable = true,
            disable = {
                "markdown", -- we like properly indented bullet points for notes thanks.
            },
        }
    }

    vim.treesitter.language.register('gotmpl', 'tmpl')
end

local lint = maybe_require('lint') -- nvim-lint
if lint then
    lint.linters_by_ft = {
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        go = { 'golangcilint' },
    }

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        group = base,
        callback = function()
            lint.try_lint()
        end,
    })
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
            },
        }
    )

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = base,
        pattern = "*",
        callback = function(args)
            -- Only format files under a certain size
            if vim.api.nvim_buf_line_count(args.buf) < 2000 then
                require("conform").format({ bufnr = args.buf })
            end
        end,
    })
end

vim.keymap.set("n", "gB", ":G blame<CR>")

local trouble = maybe_require('trouble')
if trouble then
    if not vim.g.trouble_setup_done then
        trouble.setup({
            mode = "document_diagnostics", -- Default to document diagnostics
        })
        vim.g.trouble_setup_done = true
    end

    vim.keymap.set("n", "gk", ":Trouble diagnostics toggle<CR>")
end

local replica = maybe_require('replica')
if replica then
    replica.setup({
        auto_connect = true,
        debug = false
    })
end
