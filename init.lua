-- Focused neovim configuration

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
    autoread = true, -- update buffers when the file changes elsewhere
    spell = false, nu = true, scrolloff = 8,
    lazyredraw = false, wildmode = "list:longest,list:full",
    expandtab = true, -- use spaces > tabs instead of inserting <Tab>
    smartindent = true, -- autoindent when going onto newlines

} for k, v in pairs(settings) do vim.opt[k] = v end

vim.opt.clipboard:append({ "unnamedplus" }) -- integrate with system clipboard
vim.g.markdown_fenced_languages = { 'typescript', 'javascript', 'bash', 'go' }
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.

if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg, vim.opt.grepformat = "rg --vimgrep", "%f:%l:%c:%m"
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
            vim.notify(fn .. " not found, cannot format the buffer")
        end
    end
end

local base = vim.api.nvim_create_augroup('Base', { clear = true })
local vol = vim.opt_local

local autocmds = {
    {"FileType", {
        "clojure", "javascript", "typescript",
        "json", "javascriptreact", "typescriptreact",
    }, function() vol.shiftwidth, vol.tabstop, vol.softtabstop = 2, 2, 2 end},
    {"FileType", "markdown", function()
        vol.nu, vol.wrap, vol.linebreak, vol.textwidth = false, true, true, 65
        -- Better centering: use sidescrolloff and window width calculation
        local width = vim.api.nvim_win_get_width(0)
        local padding = math.max(0, (width - 65) / 2)
        -- TODO still won't work because foldcolumn can't be more than 9
        -- there must be some other way to set padding (both horizontally and
        -- vertically.
        -- vim.cmd("setlocal foldcolumn=" .. math.min(padding, 12))
    end},
    {"BufWritePre", "*.go", fmt("goimports", "-w")},
    {"BufWritePre", "*.templ", fmt("templ", "fmt -w")},
    {"FileType", "qf", function() -- jump to quickfix targets automatically
        vim.keymap.set("n", "j", "j<CR><C-w>p", { buffer = true })
        vim.keymap.set("n", "k", "k<CR><C-w>p", { buffer = true })
    end},
    {"FileType", "netrw", function()
        vim.keymap.set("n", "S", "<C-^>", { noremap = true })
        vim.keymap.set("n", "Q", ":b#<bar>bd #<CR>", { noremap = true, silent = true })
        -- TODO gp doesn't work inside netrw, also not sure how to go back from
        -- netrw to the previous vim buffer, also not sure what the above Q
        -- binding is supposed to do?

        if vim.b.netrw_curdir then
            vim.cmd('tcd ' .. vim.fn.fnameescape(vim.b.netrw_curdir))
        end
    end},
    {'BufWritePre', '*', function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, 'p') end
    end},
}

for _, ac in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(ac[1], {group = base, pattern = ac[2], callback = ac[3]})
end

vim.api.nvim_create_autocmd("QuickFixCmdPost", { -- open quickfix if there are results
    group = base, pattern = { "[^l]*" }, command = "cwindow"
})

local keymaps = {
    {"n", "<C-h>", "<C-w><C-h>"}, {"n", "<C-j>", "<C-w><C-j>"},
    {"n", "<C-k>", "<C-w><C-k>"}, {"n", "<C-l>", "<C-w><C-l>"},
    {"n", "<C-q>", ":q<CR>"},     {"n", "<C-g>", ":noh<CR><C-g>"},
    {"i", "<C-l>", " => "},       {"i", "<C-u>", " -> "},
    {"i", "<C-c>", "<Esc>"},      {"n", "S", "<C-^>"},
    {"n", "gh", ":Explore<CR>"},  {"n", "gr", ":Grep "},
    {"n", "gn", ":tabnew ~/.notes/index.md<CR>"},
    {"n", "gi", ":tabnew ~/.config/nvim/init.lua<CR>"},
    {"n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>"},
    {"n", "gs", function() vim.cmd(":Grep -w " .. vim.fn.expand("<cword>")) end},
    {'n', 'ge', function()
        local current_dir = vim.fn.expand('%:p:h')
        local input_cmd = ':e ' .. current_dir .. '/'
        vim.opt.backupskip:append('*') -- Avoid backup file issues
        vim.api.nvim_feedkeys(input_cmd, 'n', true)
    end, { desc = 'Create/edit file relative to current buffer' }},
} for _, km in ipairs(keymaps) do vim.keymap.set(km[1], km[2], km[3]) end

vim.api.nvim_create_user_command('Grep', function(opts)
    vim.cmd('silent! grep!' .. opts.args)
    vim.cmd('redraw!')  -- clear any lingering output
    local qflist = vim.fn.getqflist()
    if #qflist > 0 then vim.cmd('copen | cfirst | wincmd j')
    else print("No matches found") end
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

local hls = {
    Normal = { bg = "none"},     NonText = { bg = "none"},
    SignColumn = { bg = "none"}, EndOfBuffer = { bg = "none"},
    StatusLine = { bg = "none"}, StatusLineNC = { fg = "#6c6c6c", bg = "none"},
    StatusFill = { fg = "#6c6c6c", bg = "none" },
    VertSplit = { fg = "#6c6c6c", bg = "none" },
    WinSeparator = { fg = "#6c6c6c", bg = "none" }
} for group, opts in pairs(hls) do vim.api.nvim_set_hl(0, group, opts) end

vim.opt.statusline = " %f%m%r%h%w %#StatusFill#%=%#StatusLine# %l•%c :: %p%% "
vim.opt.fillchars = { stl = '─', stlnc = '─' } -- Subtle separator for statusline

local ok, telescope = pcall(require, 'telescope')
if ok then
    telescope.setup({defaults = {path_display = {"truncate"}}})
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<space>', function()
        builtin.find_files({hidden = true, file_ignore_patterns = {"^.git/"}})
    end)
    vim.keymap.set('n', 'gb', builtin.buffers)
end
