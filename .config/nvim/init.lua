-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "

plugins = {
  "nvim-treesitter/nvim-treesitter",
  -- "alaviss/nim.nvim", -- REMOVED
  "nvim-tree/nvim-web-devicons",
  "ms-jpq/coq_nvim",
  "mrcjkb/rustaceanvim",
  "navarasu/onedark.nvim",
  "nvimtools/none-ls.nvim",
  "neovim/nvim-lspconfig",
 "andweeb/presence.nvim", 
{
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {},
    version = '^1.0.0',
  },
  "lukas-reineke/indent-blankline.nvim",
  "nvim-lua/plenary.nvim",
  "akinsho/ToggleTerm.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "j-morano/buffer_manager.nvim",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/nvim-cmp",
  "nvim-lualine/lualine.nvim",
  "tpope/vim-fugitive",
  "folke/todo-comments.nvim",
  "echasnovski/mini.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  -- "xiyaowong/transparent.nvim", -- Already removed
  "NvChad/nvterm",
"nvimdev/dashboard-nvim"
  }
 	
-- Initialize lazy
require("lazy").setup(plugins, {})

vim.opt.termguicolors = true
require("onedark").load({ style = "darker" })

-- Telescope mappings
local builtin = require('telescope.builtin')
vim.keymap.set('n', 'ff', builtin.find_files, {})
vim.keymap.set('n', 'fg', builtin.live_grep, {})
vim.keymap.set('n', 'fb', builtin.buffers, {})
vim.keymap.set('n', 'fh', builtin.help_tags, {})

-- Todo-comments
require("todo-comments").setup()
vim.keymap.set('n', 'tn', function() require("todo-comments").jump_next() end)
vim.keymap.set('n', 'tp', function() require("todo-comments").jump_prev() end)

local function fileExists(path)
  return vim.fn.filereadable(path) == 1
end

vim.cmd("set clipboard=unnamedplus")

-- Mini align
require("mini.align").setup({
  mappings = {
    start = "sa",
    start_with_preview = "sA"
  },
  options = {
    justify_side = "left"
  },
  silent = false
})

-- Mini notify
local notify = require("mini.notify")
notify.setup({
  lsp_progress = {
    enable = true,
    duration_last = 1000
  },
  window = {
    max_width_share = 0.382,
    winblend = 25,
  }
})
vim.notify = notify.make_notify({
  ERROR = { duration = 5000 },
  WARN = { duration = 4000 },
  INFO = { duration = 3000 }
})

require("ibl").setup {}

-- Buffer manager
local buffctl = require("buffer_manager.ui")

-- Removed: Nim-specific null-ls registration

-- Barbar setup
local barbar = require("barbar.api")
local state = require("barbar.state")
require("barbar").setup({
  animation = true,
  auto_hide = true,
  sidebar_filetypes = {
    NvimTree = true,
    undotree = { text = "undotree" },
    ["neo-tree"] = { event = "BufWipeout" },
    Outline = { event = "BufWinLeave", text = "symbols-outline" },
  },
})

vim.keymap.set('n', 'bc', function() barbar.close_all_but_current() end)
vim.keymap.set('n', 'br', function() barbar.restore_buffer() end)
vim.keymap.set('n', 'bn', function() vim.cmd("BufferNext") end)
vim.keymap.set('n', 'bp', function() vim.cmd("BufferPrevious") end)

vim.keymap.set('n', 'df', function()
  local file = vim.api.nvim_buf_get_name(0)
  if fileExists(file) then
    local answer = vim.fn.input("Do you want to delete this file? [y/n] ")
    if answer == "y" then
      os.remove(file)
      vim.notify("Deleted file \"" .. file .. "\" successfully.")
    end
  end
end)

-- NvTerm setup
require("nvterm").setup({
  terminals = {
    shell = vim.o.shell,
    list = {},
    type_opts = {
      float = {
        relative = "editor",
        row = 0.3,
        col = 0.25,
        width = 0.5,
        height = 0.4,
        border = "single",
      },
      horizontal = { location = "rightbelow", split_ratio = 0.3 },
      vertical = { location = "rightbelow", split_ratio = 0.5 },
    },
  },
  behavior = {
    autoclose_on_quit = {
      enabled = false,
      confirm = true,
    },
    close_on_exit = true,
    auto_insert = true,
  },
})

vim.keymap.set('n', 'tt', function() require("nvterm.terminal").toggle("float") end)



-- Lualine
require("lualine").setup({
  options = {
    theme = "codedark",
  },
  disabled_filetypes = {
    "NvimTree",
    statusline = {},
    winbar = {},
  },
  offsets = {
    { filetype = "NvimTree", text = "File Explorer", padding = 0 }
  }
})

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "cpp", "json", "toml", "glsl", "rust", "javascript", "markdown" },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local max_filesize = 102400
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then return true end
    end,
    additional_vim_regex_highlighting = false,
  },
})

-- Presence (Discord RPC)
local quotes = {
  "Those who can, do. Those who cannot, complain.",
  "Any sufficiently advanced technology is indistinguishable from magic.",
  "The only way of discovering the limits of the possible is to venture a little way past them into the impossible.",
  "Premature optimization is the root of all evil.",
  "A primary cause of complexity is that software vendors uncritically adopt almost any feature that users want.",
  "Expected a quote here? Tough luck."
}

math.randomseed(os.clock())
local qIdx = math.floor(math.random() * #quotes) + 1
local rpcKillSwitch = "/home/" .. os.getenv("USER") .. "/.neovim-no-rpc"

local presence = require("presence")
presence.setup({
  auto_update = true,
  neovim_image_text = quotes[qIdx],
  debounce_timeout = 10,
  enable_line_number = true,
  blacklist = {},
  buttons = true,
  file_assets = {},
  show_time = true,
  editing_text = "Editing %s",
  file_explorer_text = "Browsing",
  git_commit_text = "Committing changes",
  plugin_manager_text = "Managing plugins",
  reading_text = "Reading %s",
  workspace_text = "Working on %s",
  line_number_text = "Line %s out of %s"
})

vim.keymap.set('n', 'rd', function()
  if fileExists(rpcKillSwitch) ~= true then
    local f = io.open(rpcKillSwitch, "w")
    assert(f, "Can't open: " .. rpcKillSwitch)
    f:write("sneak 100")
    presence.cancel()
    vim.notify("Discord RPC has been disabled.")
  else
    os.remove(rpcKillSwitch)
    presence.connect()
    vim.notify("Discord RPC has been enabled.")
  end
end)

-- Completion (cmp + lspconfig)
local cmp = require("cmp")
cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp" }
  })
})
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local nvim_lsp = require("lspconfig")


-- Lua
nvim_lsp.lua_ls.setup({
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME },
          },
        },
      })
      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end,
})

-- C/C++
nvim_lsp["clangd"].setup({
  cmd = { "clangd" },
  capabilities = capabilities,
  init_options = {
    usePlaceholders = true,
  },
})

-- Arduino
nvim_lsp["arduino_language_server"].setup({})

vim.keymap.set('n', 'qq', function() vim.cmd(":bdelete") end)

