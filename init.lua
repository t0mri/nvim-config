-- essentials
vim.g.mapleader = " "
vim.o.nu = true
vim.o.rnu = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.g.netrw_liststyle = 3
vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true
vim.o.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.o.hlsearch = false
vim.o.scrolloff = 8
vim.o.wrap = false
vim.loader.enable()
vim.opt.clipboard = "unnamedplus"
vim.api.nvim_set_keymap("v", "<leader>y", ":%w !clip.exe<CR><CR>", { noremap = true })

-- custom keymaps
--vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

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
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
		config = function()
			local telescope = require("telescope")

			telescope.setup({
				pickers = {
					find_files = {
						find_command = {
							"rg",
							"--no-ignore",
							"--hidden",
							"--files",
							"-g",
							"!**/node_modules/*",
							"-g",
							"!**/.git/*",
						},
					},
				},
				extensions = {
					file_browser = {
						hidden = { file_browser = true, folder_browser = true },
						prompt_path = true,
					},
				},
			})

			local builtin = require("telescope.builtin")
			-- vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
			vim.keymap.set("n", "<leader>f", builtin.find_files, {})
			vim.keymap.set("n", "<leader>g", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>b", builtin.buffers, {})
			vim.keymap.set("n", "<leader>h", builtin.help_tags, {})

			telescope.load_extension("file_browser")
			vim.api.nvim_set_keymap(
				"n",
				"<space>e",
				":Telescope file_browser path=%:p:h select_buffer=true<CR>",
				{ noremap = true }
			)
		end,
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		config = false,
		init = function()
			-- Disable automatic setup, we are doing it manually
			vim.g.lsp_zero_extend_cmp = 0
			vim.g.lsp_zero_extend_lspconfig = 0
		end,
	},
	{
		"williamboman/mason.nvim",
		config = true,
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
		config = function()
			local lsp_zero = require("lsp-zero")
			lsp_zero.extend_cmp()
			local cmp = require("cmp")
			local cmp_action = lsp_zero.cmp_action()
			require("luasnip.loaders.from_vscode").lazy_load()
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-f>"] = cmp_action.luasnip_jump_forward(),
					["<C-b>"] = cmp_action.luasnip_jump_backward(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		config = function()
			local lsp_zero = require("lsp-zero")
			lsp_zero.extend_lspconfig()
			lsp_zero.on_attach(function(client, bufnr)
				lsp_zero.default_keymaps({ buffer = bufnr })
			end)
			require("mason-lspconfig").setup({
				handlers = {
					lsp_zero.default_setup,
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				ignore_install = { "html", "css" },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = true,
				},
			})
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{
		"christoomey/vim-tmux-navigator",
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				format_on_save = { async = true },
				formatters_by_ft = {
					lua = { "stylua" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					typescriptreact = { "prettierd" },
					css = { "prettierd" },
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({})
		end,
	},
	{ "jiangmiao/auto-pairs" },
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
			local ufo = require("ufo")
			ufo.setup()
			vim.keymap.set("n", "ua", ufo.openAllFolds)
			vim.keymap.set("n", "fa", ufo.closeAllFolds)
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Lua
			vim.keymap.set("n", "<leader>xx", function()
				require("trouble").toggle()
			end)
			vim.keymap.set("n", "<leader>xw", function()
				require("trouble").toggle("workspace_diagnostics")
			end)
			vim.keymap.set("n", "<leader>xd", function()
				require("trouble").toggle("document_diagnostics")
			end)
			vim.keymap.set("n", "<leader>xq", function()
				require("trouble").toggle("quickfix")
			end)
			vim.keymap.set("n", "<leader>xl", function()
				require("trouble").toggle("loclist")
			end)
			vim.keymap.set("n", "gR", function()
				require("trouble").toggle("lsp_references")
			end)
		end,
	},
	{
		"crispgm/nvim-tabline",
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional
		config = true,
	},
})

-- tabline keymaps
vim.keymap.set("n", "<leader>l", ":tabn<CR>")
vim.keymap.set("n", "<leader>h", ":tabp<CR>")
vim.keymap.set("n", "<leader>n", ":tabnew<CR>")
vim.keymap.set("n", "<leader>w", ":tabc<CR>")
