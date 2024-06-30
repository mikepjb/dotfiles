-- Editor Configuration
-- optional plugins: plenary + nvim-telescope/telescope.nvim

-- editor config goes here

-- keybindings go here

-- LSP setup goes here

-- optional plugin stuff goes here

vim.fn.colorscheme('retrobox')

function dots()
	vim.fn.writefile({'. ~/.bashrc'}, vim.fn.expand('$HOME/.bash_profile'))
end
