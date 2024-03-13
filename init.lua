-- TODO treesitter is not enabled but is available..

-- visual/editor behaviour
vim.opt.termguicolors = true -- enable 24-bit RGB color
vim.opt.guicursor = "" -- always block cursor, as nature intended
vim.opt.showtabline = 2 -- always show tabline
vim.opt.nu = true
vim.opt.mouse = "a"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "number"
vim.opt.textwidth = 79
vim.opt.colorcolumn = "80"
vim.opt.updatetime = 50
vim.opt.autowrite = true -- autosaves before ! and other commands
vim.opt.errorbells = false
vim.opt.foldenable = false
vim.opt.gdefault = true
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menu" -- no 'preview' in the scratch buffer please.
vim.g.sh_noisk = 1 -- stop vim messing with iskeyword when opening a shell file
vim.g.ftplugin_sql_omni_key = "<Nop>" -- stop sql filetype stealing <C-c>

-- indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- backups/undo history
vim.opt.swapfile = false
vim.opt.backup = false
local undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir)
end
vim.opt.undodir = undodir
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.mapleader = " "
vim.keymap.set("n", "<Tab>", "<C-^>")
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set('n', '<C-g>', ':noh<CR><C-g>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-d>', '<Delete>')
vim.keymap.set('i', '<C-d>', '<Delete>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-l>', ' => ')
vim.keymap.set('n', '<C-q>', ':q<CR>')
vim.keymap.set('n', 'Q', '@q')
vim.keymap.set('n', '<Leader>i', ':tabnew ~/.config/nvim/init.lua<CR>')
vim.keymap.set('n', '<Leader>n', ':tabnew ~/.notes/content/_index.md<CR>')
vim.keymap.set('n', '<Leader>c', ':copen<CR>') -- current list
vim.keymap.set('n', '<Leader>e', ':Explore<CR>')
vim.keymap.set('n', '<BS>', '<C-w><C-h>', { noremap = true }) -- compatability
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { noremap = true })

function tab()
  local col = vim.fn.col('.') - 1
  if col == 0 then
    return "<Tab>"
  end

  local char = string.sub(vim.fn.getline('.'), col, col)
  if string.match(char, "%S+") then
    return "<C-p>"
  else
    return "<Tab>"
  end
end

vim.keymap.set('i', '<Tab>', tab, { expr = true })
vim.keymap.set('i', '<S-Tab>', '<C-n>')

function runFile()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand('%:t')
  if filetype == 'clojure' then
    vim.cmd('Require') -- replica command
  elseif filetype == 'markdown' then
    vim.cmd("normal za")
  elseif filetype == 'lua' then
    -- vim.fn.source(vim.fn.expand('%'))
    if string.find(filename, "_spec.lua") then
      vim.cmd("terminal make test")
    else
      vim.cmd('so %')
      print('loaded lua file')
    end
  else
    print('what filetype is this?')
  end
end
function mapRunFile()
  vim.keymap.set('n', '<CR>', ':lua runFile()<CR>')
end
mapRunFile()

local tags = [[
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- <link rel="stylesheet" href="/css/style.css" type="text/css" media="all" />  -->
<meta property="og:title" content="My New Page" />
<meta property="og:description" content="A brand new page" />
<meta property="og:image" content="https://example.com/preview-image.png" />
<title>New Page</title>
]]

function htmlTags()
    local splitContent = {}
    for i in string.gmatch(tags, "[^\r\n]+") do
        table.insert(splitContent, i)
    end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_lines(0, row - 1, row, true, splitContent)
end

vim.api.nvim_create_user_command('Tags', htmlTags, { desc = 'Insert default webpage head tags' })



local languageGroup = vim.api.nvim_create_augroup("language", { clear = true })
vim.api.nvim_create_autocmd("CmdwinEnter", { command = ":unmap <CR>", group = languageGroup })
vim.api.nvim_create_autocmd("CmdwinLeave", { command = ":lua mapRunFile<CR>", group = languageGroup })
vim.api.nvim_create_autocmd("BufReadPost", {
    command = "nnoremap <buffer> <CR> <CR>",
    pattern = "quickfix",
    group = languageGroup
})

if vim.fn.isdirectory(vim.fn.expand('~/.config/nvim/pack/base')) ~= 0 then
    vim.cmd.packadd("plenary.nvim")
    vim.cmd.packadd("telescope.nvim")
    vim.cmd.packadd("nvim-treesitter")
    vim.cmd.packadd("trouble.nvim")
    vim.cmd.packadd("nvim-lspconfig")
    vim.cmd.packadd("vim-fugitive")
    vim.cmd.packadd("lotus.nvim")

    vim.cmd[[colorscheme lotus]]

    require('telescope').setup({
        defaults = { file_ignore_patterns = {"node_modules", ".git", "public"} }
    })

    require('trouble').setup {
        icons = false
    }

    require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
            "typescript", "javascript", "lua", "sql", "tsx", "go"
        }
    })

    -- Use an on_attach function to only map the following keys
    -- after the language server attaches to the current buffer
    local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', 'gj', vim.diagnostic.goto_next, bufopts)
        vim.keymap.set('n', 'gk', vim.diagnostic.goto_prev, bufopts)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setqflist, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    end

    local lspconfig = require('lspconfig')
    lspconfig['gopls'].setup({
        on_attach = on_attach,
        flags = flags,
        settings = {
            gopls = {
                analyses = {
                    unusedparams = true,
                },
                staticcheck = true,
                gofumpt = true,
            },
        },
    })
    lspconfig['clojure_lsp'].setup({ on_attach = on_attach })
    -- lspconfig['tsserver'].setup({ on_attach = on_attach })
    lspconfig['rust_analyzer'].setup({ on_attach = on_attach })

-- run goimports (from gopls) on save
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

  vim.keymap.set("n", "<leader>f", ":Telescope find_files<cr>")
  vim.keymap.set("n", "<leader>b", ":Telescope buffers<cr>")
  vim.keymap.set("n", "<leader>t", ":Trouble<cr>")
  vim.keymap.set('n', 'gb', ':Git blame<CR>')
end
