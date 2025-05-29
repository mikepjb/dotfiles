-- Focused neovim configuration

-- TODO make sure to add tcd/netrw changes!
-- TODO can you center the buffer/add padding for an olivetti type writing mode
-- for markdown files?

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg, vim.opt.grepformat = "rg --vimgrep", "%f:%l:%c:%m"
end

local settings = {
    guicursor = "", -- always use a block cursor
    textwidth = 80, -- limit ourselves to human readable line lengths
    nu = true,
    swapfile = false, backup = false, undofile = true,
    undodir = os.getenv("HOME") .. "/.config/nvim/undodir",
    incsearch = true, inccommand = "split", -- show search/cmd results as typed
    gdefault = true, -- search/replace by line > first instance
    ignorecase = true, smartcase = true, -- ignore case for search unless input
    wrap = false, -- don't wrap long lines to fit inside the buffer
    tabstop = 4, -- <Tab> == 4 spaces
    softtabstop = 4, -- same as above for editing operations
    shiftwidth = 4, -- how far >>/<< shifts your text
    termguicolors = os.getenv("COLORTERM") == 'truecolor',
    spell = false, nu = true, scrolloff = 8,
}

for k, v in pairs(settings) do vim.opt[k] = v end
vim.opt.clipboard:append({ "unnamedplus" }) -- integrate with system clipboard

vim.opt.autoread = true -- update buffers when the file changes elsewhere
vim.opt.lazyredraw = false
vim.opt.expandtab = true -- use spaces > tabs instead of inserting <Tab>
vim.opt.smartindent = true -- autoindent when going onto newlines
vim.opt.wildmode = "list:longest,list:full" -- completion mode in Ex

vim.g.markdown_fenced_languages = { 'typescript', 'javascript', 'bash', 'go' }
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.

local base = vim.api.nvim_create_augroup('Base', { clear = true })

local function au(event, pattern, callback) -- not used in lieu of table approach currently
    vim.api.nvim_create_autocmd(event, { group = base, pattern = pattern, callback = callback })
end

local function fmt(fn, args)
    return function()
        if vim.fn.executable(fn) == 1 then
            local file = vim.fn.expand("%:p")
            vim.system({fn, args, file}, {}, function()
                vim.schedule(function()
                    vim.cmd("e!")
                end)
            end)
        else
            -- TODO won't be seen because the write message comes after!,
            -- verified it comes out with :messages to see history
            print(fn .. " not found, cannot format the buffer")
        end
    end
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
    {"FileType", "markdown", function()
        vol.nu = false
    end},
    {"BufWritePre", "*.go", fmt("goimports", "-w")},
    {"BufWritePre", "*.templ", fmt("templ", "fmt -w")},
    {"FileType", "qf", function() -- jump to quickfix targets automatically
        vim.keymap.set("n", "j", "j<CR><C-w>p", { buffer = true })
        vim.keymap.set("n", "k", "k<CR><C-w>p", { buffer = true })
    end},
    {"FileType", "netrw", function()
        vim.api.nvim_buf_set_keymap(0, "n", "S", "<C-^>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "n", "Q", ":b#<bar>bd #<CR>", { noremap = true, silent = true })
    end}
}

for _, ac in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(ac[1], {group = base, pattern = ac[2], callback = ac[3]})
end

vim.api.nvim_create_autocmd("QuickFixCmdPost", { -- open quickfix if there are results
    group = vim.api.nvim_create_augroup("AutoOpenQuickfix", { clear = true }),
    pattern = { "[^l]*" },
    command = "cwindow"
})

local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts or {})
end

vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-q>", ":q<CR>")
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
    -- TODO maybe this should just be a general autocmd?
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

local highlights = {
    Normal = { bg = "none"},
    NonText = { bg = "none"},
    SignColumn = { bg = "none"},
    EndOfBuffer = { bg = "none"},
    StatusLine = { bg = "none"},
    StatusFill = { fg = "#6c6c6c", bg = "none" },
    VertSplit = { fg = "#6c6c6c", bg = "none" },
    WinSeparator = { fg = "#6c6c6c", bg = "none" }
}

for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
end

vim.opt.statusline = " %f%m%r%h%w %#StatusFill#%=%#StatusLine# %l•%c :: %p%% "
vim.opt.fillchars = { stl = '─', stlnc = '─' } -- Subtle separator for statusline

local function maybe_require(module_name)
    local ok, module = pcall(require, module_name)
    if ok then
        return module
    end
    return nil
end

local ok, telescope = pcall(require, 'telescope')
if ok then
    telescope.setup({defaults = {path_display = {"truncate"}}})
    local builtin = require('telescope.builtin')
    map('n', '<space>', function()
        builtin.find_files({hidden = true, file_ignore_patterns = {"^.git/"}})
    end)
    map('n', 'gb', builtin.buffers)
end
