-- essentials
vim.g.mapleader = " "
vim.o.rnu = true
vim.o.shiftwidth = 4
vim.g.netrw_liststyle = 3

-- custom keymaps
vim.keymap.set('n', '<leader>e', vim.cmd.Ex)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
	"git",
	"clone",
	"--filter=blob:none",
	"https://github.com/folke/lazy.nvim.git",
	"--branch=stable", -- latest stable release
	lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
	'nvim-telescope/telescope.nvim', tag = '0.1.4',
	dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
	'VonHeikemen/lsp-zero.nvim',
	branch = 'v3.x',
	lazy = true,
	config = false,
	init = function()
	    -- Disable automatic setup, we are doing it manually
	    vim.g.lsp_zero_extend_cmp = 0
	    vim.g.lsp_zero_extend_lspconfig = 0
	end,
    },
    {
	'williamboman/mason.nvim',
	lazy = false,
	config = true,
    },

    -- Autocompletion
    {
	'hrsh7th/nvim-cmp',
	event = 'InsertEnter',
	dependencies = {
	    {'L3MON4D3/LuaSnip'},
	},
	config = function()
	    -- Here is where you configure the autocompletion settings.
	    local lsp_zero = require('lsp-zero')
	    lsp_zero.extend_cmp()

	    -- And you can configure cmp even more, if you want to.
	    local cmp = require('cmp')
	    local cmp_action = lsp_zero.cmp_action()

	    cmp.setup({
		formatting = lsp_zero.cmp_format(),
		mapping = cmp.mapping.preset.insert({
		    ['<C-Space>'] = cmp.mapping.complete(),
		    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
		    ['<C-d>'] = cmp.mapping.scroll_docs(4),
		    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
		    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
		})
	    })
	end
    },

    -- LSP
    {
	'neovim/nvim-lspconfig',
	cmd = {'LspInfo', 'LspInstall', 'LspStart'},
	event = {'BufReadPre', 'BufNewFile'},
	dependencies = {
	    {'hrsh7th/cmp-nvim-lsp'},
	    {'williamboman/mason-lspconfig.nvim'},
	},
	config = function()
	    local lsp_zero = require('lsp-zero')
	    lsp_zero.extend_lspconfig()

	    lsp_zero.on_attach(function(client, bufnr)
		lsp_zero.default_keymaps({buffer = bufnr})
	    end)

	    require('mason-lspconfig').setup({
		ensure_installed = {},
		handlers = {
		    lsp_zero.default_setup,
		}
	    })
	end
    }})

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>f', builtin.git_files, {})
    vim.keymap.set('n', '<leader>af', builtin.find_files, {})
    vim.keymap.set('n', '<leader>g', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ")})
    end)
    vim.keymap.set('n', '<leader>b', builtin.buffers, {})
    vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
