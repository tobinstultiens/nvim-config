-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

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
        vim.keymap.set('n', '<leader>hp', require('gitsigns').preview_hunk,
          { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
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

  { import = 'custom.plugins' },
}, {})

-- Set the Theme
vim.cmd.colorscheme "catppuccin-mocha"

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require "telescope.actions"
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<Esc>'] = actions.close,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim',
    'elixir', 'heex' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach_lsp = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>cr', vim.lsp.buf.rename, '[Code] [R]ename')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>cf', vim.lsp.buf.format(), '[C]ode [F]ormat')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- tsserver = {},
  ansiblels = {
    filetypes = {
      "yaml.ansible",
      "yaml",
    }
  },
  hls = {},
  html = { filetypes = { 'html', 'twig', 'hbs', 'heex', "elixir" } },
  tailwindcss = {
    init_options = { elixir = "phoenix-heex", eruby = "erb", heex = "phoenix=heex", svelte = "html" },
    handlers = {
      ["tailwindcss/getConfiguration"] = function(_, _, params, _, bufnr, _)
        vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", { _id = params._id })
      end,
    },
    settings = {
      includeLanguages = {
        typescript = "javascript",
        typescriptreact = "javascript",
        ["html-eex"] = "html",
        ["phoenix-heex"] = "html",
        heex = "html",
        eelixir = "html",
        elm = "html",
        erb = "html",
        svelte = "html",
      },
      tailwindCSS = {
        lint = {
          cssConflict = "warning",
          invalidApply = "error",
          invalidConfigPath = "error",
          invalidScreen = "error",
          invalidTailwindDirective = "error",
          invalidVariant = "error",
          recommendedVariantOrder = "warning",
        },
        experimental = {
          classRegex = {
            [[class= "([^"]*)]],
            [[class: "([^"]*)]],
            '~H""".*class="([^"]*)".*"""',
          },
        },
        validate = true,
      },
    },
    filetypes = {
      "css",
      "scss",
      "sass",
      "html",
      "heex",
      "elixir",
      "eruby",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "svelte",
    },
  },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach_lsp,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- Function to check if an array contains an object with a certain key pair if the array is non-empty
local function containsObjectWithKey(arr, key)
  if arr == nil then
    return false
  end
  for _, obj in ipairs(arr) do
    if obj[key] ~= nil then
      return true
    end
  end
  return false
end

-- Set description of object defined for commander using the commander objects
local function setDescription (item)
  if item.keys == nil then
    return
  end
  if containsObjectWithKey(item.keys[3], "noremap") and containsObjectWithKey(item.keys[3], "silent") then
    vim.keymap.set(item.keys[1], item.keys[2], item.cmd, {desc = item.desc, noremap = item.keys[3].noremap, silent = item.keys[3].silent})
  elseif containsObjectWithKey(item.keys[3], "noremap") then
    vim.keymap.set(item.keys[1], item.keys[2], item.cmd, {desc = item.desc, noremap = item.keys[3].noremap})
  elseif containsObjectWithKey(item.keys[3], "silent") then
    vim.keymap.set(item.keys[1], item.keys[2], item.cmd, {desc = item.desc, silent = item.keys[3].silent})
  else
    vim.keymap.set(item.keys[1], item.keys[2], item.cmd, {desc = item.desc})
  end
end

-- Implementation of concatenating 2 lists since lua does not have a proper implementation of concatenation.
local function conList(l1, l2)
  local combinedList = {}
  for _, v in ipairs(l1) do
    table.insert(combinedList, v)
  end
  for _, v in ipairs(l2) do
    table.insert(combinedList, v)
  end
  return combinedList
end

-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- See `:help telescope.builtin`
local telescopeKeymap = {
  {
    desc = '[?] Find recently opened files',
    cmd = require('telescope.builtin').oldfiles,
    keys = {'n','<leader>?' } },
  {
    keys = {'n', '<leader><space>'},
    cmd = require('telescope.builtin').buffers,
    desc = '[ ] Find existing buffers' },
  {
    keys = {'n', '<leader>/'},
    cmd = function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
    end,
    desc = '[/] Fuzzily search in current buffer' },

  { keys = {'n', '<leader>gf'}, cmd = require('telescope.builtin').git_files, desc = 'Search [G]it [F]iles' },
  { keys = {'n', '<leader>sf'}, cmd = require('telescope.builtin').find_files, desc = '[S]earch [F]iles' },
  { keys = {'n', '<leader>sh'}, cmd = require('telescope.builtin').help_tags, desc = '[S]earch [H]elp' },
  { keys = {'n', '<leader>sw'}, cmd = require('telescope.builtin').grep_string, desc = '[S]earch current [W]ord' },
  { keys = {'n', '<leader>sg'}, cmd = require('telescope.builtin').live_grep, desc = '[S]earch by [G]rep' },
  { keys = {'n', '<leader>sd'}, cmd = require('telescope.builtin').diagnostics, desc = '[S]earch [D]iagnostics' },
  { keys = {'n', '<leader>sr'}, cmd = require('telescope.builtin').resume, desc = '[S]earch [R]esume' },
}

local floatingTerminalKeymap = {
  { keys = {'n', "t"}, cmd = ":FloatermToggle myfloat<CR>"},
  { keys = {'t', "<Esc>"}, cmd = "<C-\\><C-n>:q<CR>"},
}

local fileManagerKeymap = {
  { keys = {'n', "<leader>f"}, cmd = "<cmd>Neotree<CR>", desc = "File tree"}
}

local diagnosticKeymap = {
  { keys = {'n', '[d'}, cmd = vim.diagnostic.goto_prev, desc = 'Go to previous diagnostic message' },
  { keys = {'n', ']d'}, cmd = vim.diagnostic.goto_next, desc = 'Go to next diagnostic message' },
  { keys = {'n', '<leader>e'}, cmd = vim.diagnostic.open_float, desc = 'Open floating diagnostic message' },
  { keys = {'n', '<leader>q'}, cmd = vim.diagnostic.setloclist, desc = 'Open diagnostics list' },
}

local gitKeymap = {
  { keys = {"n", "<leader>gg"}, cmd = require('neogit').open, desc = "Open neogit"},
}

local masonKeymap = {
 { keys = {"n", "<leader>m"}, cmd = "<cmd>Mason<CR>", desc = "Open Mason"},
}

require('which-key').register({
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>f'] = { name = '[F]iles', _ = 'which_key_ignore' },
  ['<leader>n'] = { name = '[N]eorg', _ = 'which_key_ignore' },
})

local neorgKeymap = { 
  {
    desc = "Run neorg toc",
    cmd = "<CMD>Neorg toc<CR>",
  }, {
    desc = "Run tangle on current file",
    cmd = "<CMD>Neorg tangle current-file<CR>"
  }
}

vim.keymap.set("n", "<leader>sc", "<CMD>Telescope commander<CR>", { desc = "[S]earch [C]ommands"})

local commander = require("commander")

-- Combine all keymaps into one big list
local commanderKeymapList = conList(conList(conList(conList(conList(conList(telescopeKeymap, neorgKeymap), gitKeymap), floatingTerminalKeymap), fileManagerKeymap), diagnosticKeymap), masonKeymap)

-- Add it to commander
commander.add(commanderKeymapList)

-- This will convert all added commands to commander to also be descriptive for which-key
for _, obj in ipairs(commanderKeymapList) do
  setDescription(obj)
end

-- See `:help vim.o`
-- Set highlight on search
-- vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Set relativenumber on
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'neorg' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et