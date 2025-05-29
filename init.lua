-- Focused neovim configuration
if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --vimgrep"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

-- potential optimisation
local settings = {
    guicursor = "", textwidth = 80, nu = true,
}

for k, v in pairs(settings) do vim.opt[k] = v end

vim.opt.guicursor = "" -- always use a block cursor
vim.opt.textwidth = 80 -- limit ourselves to human readable line lengths
vim.opt.spell = false -- not when editing, include during build if you must
vim.opt.nu = true -- but not for writing? e.g not in markdown files?
vim.opt.scrolloff = 8 -- keep a little text ahead of the cursor to read ahead
vim.opt.clipboard:append({ "unnamedplus" }) -- integrate with system clipboard
vim.opt.autoread = true -- update buffers when the file changes elsewhere
vim.opt.lazyredraw = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.undofile = true -- keep undo history between nvim instances
vim.opt.expandtab = true -- use spaces > tabs instead of inserting <Tab>
vim.opt.smartindent = true -- autoindent when going onto newlines
vim.opt.wrap = false -- don't wrap long lines to fit inside the buffer
vim.opt.gdefault = true -- search/replace by line > first instance
vim.opt.incsearch = true -- show search results as you type
vim.opt.inccommand = "split" -- show substitute command results as you type
vim.opt.ignorecase = true
vim.opt.smartcase = true -- case sensitive search only when you use uppercase
vim.opt.wildmode = "list:longest,list:full" -- completion mode in Ex

vim.opt.tabstop = 4 -- <Tab> == 4 spaces
vim.opt.softtabstop = 4 -- same as above for editing operations
vim.opt.shiftwidth = 4 -- how far >>/<< shifts your text
vim.opt.termguicolors = os.getenv("COLORTERM") == 'truecolor'

vim.g.markdown_fenced_languages = { 'typescript', 'javascript', 'bash', 'go' }
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.

local base = vim.api.nvim_create_augroup('Base', { clear = true })

local function au(event, pattern, callback) -- not used in lieu of table approach currently
    vim.api.nvim_create_autocmd(event, { group = base, pattern = pattern, callback = callback })
end

local vol = vim.opt_local

local condensed_langs = {
    "clojure",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "json" 
}

local autocmds = {
    {"FileType", condensed_langs, function()
        vol.shiftwidth, vol.tabstop, vol.softtabstop = 2, 2 ,2
    end},
}

for _, ac in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(ac[1], {group = base, pattern = ac[2], callback = ac[3]})
end

vim.api.nvim_create_autocmd("QuickFixCmdPost", { -- open quickfix if there are results
    group = vim.api.nvim_create_augroup("AutoOpenQuickfix", { clear = true }),
    pattern = { "[^l]*" },
    command = "cwindow"
})

vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-g>", ":noh<CR><C-g>")
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("i", "<C-l>", " => ")
vim.keymap.set("i", "<C-u>", " -> ")
vim.keymap.set("n", "S", "<C-^>")
vim.keymap.set("n", "gh", ":Explore<CR>")
vim.keymap.set("n", "gn", ":tabnew ~/.notes/index.md<CR>")
vim.keymap.set("n", "gi", ":tabnew ~/.config/nvim/init.lua<CR>")
vim.keymap.set("n", "gr", ":Grep ")
vim.keymap.set("n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>")
-- doesn't work for netrw.. want to sometimes set the pwd for fuzzy searching,
-- maybe overkill
vim.keymap.set("n", "gh", ":cd %:h")
vim.keymap.set("n", "gs", function() vim.cmd(":Grep -w " .. vim.fn.expand("<cword>")) end)
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

-- jump to quickfix targets automatically
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.keymap.set("n", "j", "j<CR><C-w>p", { buffer = true })
        vim.keymap.set("n", "k", "k<CR><C-w>p", { buffer = true })
    end
})

vim.api.nvim_create_user_command('Grep', function(opts)
    vim.cmd('silent! grep!' .. opts.args)
    vim.cmd('redraw!')  -- clear any lingering output
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

vim.api.nvim_create_user_command('TrimWhitespace', function()
    vim.cmd '%s/\\s\\+$//e'
end, {})

pcall(vim.cmd, 'colorscheme quiet') -- Try colorscheme, fallback to default
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NonText", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusFill", { fg = "#6c6c6c", bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
vim.api.nvim_set_hl(0, "VertSplit", { fg = "#6c6c6c", bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#6c6c6c", bg = "none" })
vim.opt.statusline = " %f%m%r%h%w %#StatusFill#%=%#StatusLine# %l•%c :: %p%% "
vim.opt.fillchars = { stl = '─', stlnc = '─' } -- Subtle separator for statusline

vim.api.nvim_create_autocmd("BufWritePre", {
    group = base,
    pattern = "*.go",
    callback = function()
        if vim.fn.executable("goimports") == 1 then
            local file = vim.fn.expand("%:p")
            vim.system({"goimports", "-w", file}, {}, function()
                vim.schedule(function()
                    vim.cmd("e!")
                end)
            end)
        end
    end,
})

-- Templ file formatting
vim.api.nvim_create_autocmd("BufWritePre", {
    group = base,
    pattern = "*.templ",
    callback = function()
        if vim.fn.executable("templ") == 1 then
            vim.cmd("silent !templ fmt %")
            vim.cmd("edit!")
        end
    end,
})

local function maybe_require(module_name)
    local ok, module = pcall(require, module_name)
    if ok then
        return module
    end
    return nil
end

maybe_require('plenary') -- dep for telescope
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

-- also, how do we align by chracters or generally for things like maps that we
-- want on multiple lines it would be nice to have a way to align by column
--
-- vim.keymap.set("n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>")
-- doesn't work for netrw.. want to sometimes set the pwd for fuzzy searching,
-- maybe overkill
