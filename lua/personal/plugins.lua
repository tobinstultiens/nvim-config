 -- Install package manager
 local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
 if not vim.loop.fs_stat(lazypath) then
   vim.fn.system {
     'git',
     'clone',
     '--filter=blob:none',
     'https://github.com/folke/lazy.nvim.git',
     '--branch=stable', -- latest stable release
     lazypath,
   }
 end
 vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
 -- Git related plugins
 {
   "NeogitOrg/neogit",
   dependencies = {
     "nvim-lua/plenary.nvim",         -- required
     "nvim-telescope/telescope.nvim", -- optional
     "sindrets/diffview.nvim",        -- optional
     "ibhagwan/fzf-lua",              -- optional
   },
   config = true
 },

 -- Detect tabstop and shiftwidth automatically
 'tpope/vim-sleuth',

 -- NOTE: This is where your plugins related to LSP can be installed.
 --  The configuration is done below. Search for lspconfig to find it below.
 {
   -- LSP Configuration & Plugins
   'neovim/nvim-lspconfig',
   dependencies = {
     -- Automatically install LSPs to stdpath for neovim
     { 'williamboman/mason.nvim', config = true },
     'williamboman/mason-lspconfig.nvim',
     'WhoIsSethDaniel/mason-tool-installer.nvim',

     -- Useful status updates for LSP
     -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
     { 'j-hui/fidget.nvim', opts = {} },

     -- Additional lua configuration, makes nvim stuff amazing!
     'folke/neodev.nvim',
   },
 },

 {
   -- Autocompletion
   'hrsh7th/nvim-cmp',
   dependencies = {
     -- Snippet Engine & its associated nvim-cmp source
     'L3MON4D3/LuaSnip',
     'saadparwaiz1/cmp_luasnip',

     -- Adds LSP completion capabilities
     'hrsh7th/cmp-nvim-lsp',
     'hrsh7th/cmp-path',
     'hrsh7th/cmp-buffer',
     'hrsh7th/cmp-cmdline',

     -- Adds a number of user-friendly snippets
     'rafamadriz/friendly-snippets',
   },
 },

 -- Useful plugin to show you pending keybinds.
 { 'folke/which-key.nvim', opts = {} },
 {
   -- Adds git related signs to the gutter, as well as utilities for managing changes
   'lewis6991/gitsigns.nvim',
   opts = {
     -- See `:help gitsigns.txt`
     signs = {
       add = { text = '+' },
       change = { text = '~' },
       delete = { text = '_' },
       topdelete = { text = '‾' },
       changedelete = { text = '~' },
     },
     on_attach = function(bufnr)
       local gs = package.loaded.gitsigns

       local function map(mode, l, r, opts)
         opts = opts or {}
         opts.buffer = bufnr
         vim.keymap.set(mode, l, r, opts)
       end

       -- Navigation
       map({ 'n', 'v' }, ']c', function()
         if vim.wo.diff then
           return ']c'
         end
         vim.schedule(function()
           gs.next_hunk()
         end)
         return '<Ignore>'
       end, { expr = true, desc = 'Jump to next hunk' })

       map({ 'n', 'v' }, '[c', function()
         if vim.wo.diff then
           return '[c'
         end
         vim.schedule(function()
           gs.prev_hunk()
         end)
         return '<Ignore>'
       end, { expr = true, desc = 'Jump to previous hunk' })

       -- Actions
       -- visual mode
       map('v', '<leader>hs', function()
         gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
       end, { desc = 'stage git hunk' })
       map('v', '<leader>hr', function()
         gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
       end, { desc = 'reset git hunk' })
       -- normal mode
       map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
       map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
       map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
       map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
       map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
       map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
       map('n', '<leader>hb', function()
         gs.blame_line { full = false }
       end, { desc = 'git blame line' })
       map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
       map('n', '<leader>hD', function()
         gs.diffthis '~'
       end, { desc = 'git diff against last commit' })

       -- Toggles
       map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
       map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

       -- Text object
       map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
     end,
   },
 },

 { "catppuccin/nvim",      name = "catppuccin", priority = 1000 },

 {
   -- Set lualine as statusline
   'nvim-lualine/lualine.nvim',
   -- See `:help lualine.txt`
   opts = {
     options = {
       icons_enabled = false,
       theme = 'catppuccin',
       component_separators = '|',
       section_separators = '',
      },
      sections = {
        lualine_b = {
          {
          'macro',
            fmt = function(name, context)
              local reg = vim.fn.reg_recording()
              if reg ~= "" then
                return "Recording @" .. reg
              end
              return nil
            end,
            draw_empty = false,
          },
        }
      }
   },
 },

 {
   -- Add indentation guides even on blank lines
   'lukas-reineke/indent-blankline.nvim',
   -- Enable `lukas-reineke/indent-blankline.nvim`
   -- See `:help indent_blankline.txt`
   main = "ibl",
   opts = {},
 },

 -- "gc" to comment visual regions/lines
 { 'numToStr/Comment.nvim',  opts = {} },

 -- Fuzzy Finder (files, lsp, etc)
 {
   'nvim-telescope/telescope.nvim',
   branch = '0.1.x',
   dependencies = {
     'nvim-lua/plenary.nvim',
     -- Fuzzy Finder Algorithm which requires local dependencies to be built.
     -- Only load if `make` is available. Make sure you have the system
     -- requirements installed.
     {
       'nvim-telescope/telescope-fzf-native.nvim',
       -- NOTE: If you are having trouble with this installation,
       --       refer to the README for telescope-fzf-native for more instructions.
       build = 'make',
       cond = function()
         return vim.fn.executable 'make' == 1
       end,
     },
     { 'nvim-telescope/telescope-ui-select.nvim' },

     -- Useful for getting pretty icons, but requires a Nerd Font.
     { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
   },
 },

 {
   -- Highlight, edit, and navigate code
   'nvim-treesitter/nvim-treesitter',
   dependencies = {
     'nvim-treesitter/nvim-treesitter-textobjects',
   },
   build = ':TSUpdate',
 },
  {
    'jmbuhr/otter.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
    },
 {
   "folke/noice.nvim",
   event = "VeryLazy",
   opts = {
     -- add any options here
   },
   dependencies = {
     -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
     "MunifTanjim/nui.nvim",
     -- OPTIONAL:
     --   `nvim-notify` is only needed, if you want to use the notification view.
     --   If not available, we use `mini` as the fallback
     "rcarriga/nvim-notify",
   }
 },

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        ocaml = { 'ocamlformat' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    },
  },

 { import = 'custom.plugins' },
}, {})