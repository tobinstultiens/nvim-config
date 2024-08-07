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
  { keys = {'n', '<leader>sc'}, cmd = "<CMD>Noice telescope<CR>", desc = '[S]earch [C]ommands' },
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

require('which-key').add{
  {
    {'<leader>c', group = '[C]ode'},
    {'<leader>d', group = '[D]ocument'},
    {'<leader>g', group = '[G]it'},
    {'<leader>h', group = 'Git [H]unk'},
    {'<leader>s', group = '[S]earch'},
    {'<leader>f', group = '[F]iles'},
    {'<leader>n', group = '[N]eorg', mode = {'n', 'v'}},
  },
}

local neorgKeymap = { 
  {
    desc = "Run neorg toc",
    cmd = "<CMD>Neorg toc<CR>",
  }, {
    desc = "Run tangle on current file",
    cmd = "<CMD>Neorg tangle current-file<CR>",
  }
}

vim.keymap.set("i", "<C-p>", "<CMD>Telescope commander<CR>", { desc = "[S]earch [C]ommands"})
vim.keymap.set("n", "<C-p>", "<CMD>Telescope commander<CR>", { desc = "[S]earch [C]ommands"})

local commander = require("commander")

-- Combine all keymaps into one big list
local commanderKeymapList = conList(conList(conList(conList(conList(conList(telescopeKeymap, neorgKeymap), gitKeymap), floatingTerminalKeymap), fileManagerKeymap), diagnosticKeymap), masonKeymap)

-- Add it to commander
commander.add(commanderKeymapList)