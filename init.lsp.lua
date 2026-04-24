-- =============================================================================
-- ~/.config/nvim/init.lua
-- Neovim-only config using lazy.nvim
-- Converted from .vimrc, this is using LSP but probably not configured correctly
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Bootstrap lazy.nvim
-- ---------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ---------------------------------------------------------------------------
-- Core options  (set before plugins so plugins can read them)
-- ---------------------------------------------------------------------------
local opt = vim.opt

opt.compatible     = false          -- always false in Neovim, but harmless
opt.backup         = false
opt.directory      = vim.fn.expand("~/.local/share/nvim/swp") .. ",."
opt.shiftwidth     = 4
opt.softtabstop    = 4
opt.expandtab      = true
opt.smarttab       = true
opt.modelines      = 2
opt.modeline       = true
opt.number         = true
opt.incsearch      = true
opt.hlsearch       = true
opt.history        = 150
opt.backspace      = { "indent", "eol", "start" }
opt.laststatus     = 2
opt.ruler          = false
opt.wildmenu       = true
opt.wildmode       = { "longest", "list" }
opt.wildignore:append({ "*.a", "*.o", "*.bmp", "*.gif", "*.ico", "*.jpg", "*.png",
                         ".DS_Store", ".git", ".hg", ".svn", "*~", "*.swp", "*.tmp" })
opt.wildignorecase = true
opt.tags:append({ "./tags;/", "/usr/include/tags" })
opt.path:append("/usr/include/c++/**")
opt.grepprg        = "grep -nH $*"
opt.colorcolumn    = "100"
opt.textwidth      = 100
opt.cinoptions     = ":0.5s,g0.5s,h0.5s,t0,(0,+0,u0"
opt.inccommand     = "split"        -- live substitution preview (nvim-only)

-- 256-color + true-color
opt.termguicolors  = true
opt.background     = "dark"

-- Clipboard: sync with system clipboard
opt.clipboard      = "unnamed,unnamedplus"

-- Cscope
if vim.fn.has("cscope") == 1 then
  opt.cscopetag     = true
  opt.cscopeverbose = true
  -- quickfix integration handled below in autocmds
end

-- ---------------------------------------------------------------------------
-- Filetype detection  (replaces the has("autocmd") block)
-- ---------------------------------------------------------------------------
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-- ---------------------------------------------------------------------------
-- Colorscheme  (zenburn — installed as a plugin below)
-- ---------------------------------------------------------------------------
-- Applied after plugins load; see the colorscheme plugin spec.

-- ---------------------------------------------------------------------------
-- Global vars (plugin config that must be set before the plugin loads)
-- ---------------------------------------------------------------------------
vim.g.localvimrc_ask          = 0
vim.g.flake8_ignore           = "E501,E225"
vim.g.zenburn_old_Visual      = 1
vim.g.zenburn_alternate_Visual = 1
vim.g.zenburn_high_Contrast   = 1
vim.g.tex_flavor              = "latex"
vim.g.VeryLiteral             = 0

-- coc.nvim diagnostics (kept for coc; remove if switching to nvim-lsp fully)
vim.g.ycm_always_populate_location_list = 1   -- legacy; remove when YCM is gone

-- Autoformat (vim-autoformat replacement handled by conform.nvim below)
vim.g.formatdef_my_c_cpp_astyle = '"astyle --mode=c --suffix=none --options=' ..
                                   vim.fn.expand("~/.mca.astylerc") .. '"'
vim.g.formatters_cpp                       = { "my_c_cpp_astyle" }
vim.g.formatters_c                         = { "my_c_cpp_astyle" }
vim.g.autoformat_autoindent                = 0
vim.g.autoformat_retab                     = 0
vim.g.autoformat_remove_trailing_spaces    = 0

-- ---------------------------------------------------------------------------
-- Plugin specs
-- ---------------------------------------------------------------------------
require("lazy").setup({

  -- -------------------------------------------------------------------------
  -- Colorscheme
  -- -------------------------------------------------------------------------
  {
    "phha/zenburn.nvim",          -- Lua port of classic zenburn
    -- Alternative: "jnurmine/Zenburn" (original VimL, also works)
    lazy = false,
    priority = 1000,              -- load first so other plugins see the colors
    config = function()
      vim.cmd("colorscheme zenburn")
    end,
  },

  -- -------------------------------------------------------------------------
  -- Git integration  (replaces vim-fugitive from bundle/)
  -- -------------------------------------------------------------------------
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gstatus", "Gdiff", "Gblame", "Glog" },
    -- Statusline helper still needed synchronously, so we lazy-load on cmd
    -- but also load on VimEnter to populate fugitive#statusline()
    event = "VimEnter",
  },

  -- -------------------------------------------------------------------------
  -- Repeat  (replaces repeat/ from bundle/)
  -- tpope/vim-repeat — makes . work with plugin maps
  -- -------------------------------------------------------------------------
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- -------------------------------------------------------------------------
  -- Surround  (replaces surround/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "kylechui/nvim-surround",     -- Lua rewrite of vim-surround
    version = "*",
    event = "VeryLazy",
    config = true,
  },

  -- -------------------------------------------------------------------------
  -- EasyMotion  (replaces easymotion/ from bundle/)
  -- flash.nvim is the modern Lua replacement
  -- -------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "S",     function() require("flash").treesitter() end,        mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
      { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote Flash" },
      { "<C-s>", function() require("flash").toggle() end,            mode = "c",               desc = "Toggle Flash Search" },
    },
  },

  -- -------------------------------------------------------------------------
  -- File tree  (replaces nerdtree/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<F8>", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
    },
    opts = {
      filesystem = { follow_current_file = { enabled = true } },
    },
  },

  -- -------------------------------------------------------------------------
  -- Tag browser  (replaces taglist/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "preservim/tagbar",           -- drop-in spiritual successor to TagList
    cmd = "TagbarToggle",
    -- F8 is used for Neo-tree above; remap tagbar to <F9> or choose your own
    keys = { { "<F9>", "<cmd>TagbarToggle<CR>", desc = "Toggle Tagbar" } },
  },

  -- -------------------------------------------------------------------------
  -- Rainbow parentheses  (replaces RainbowParenthsis/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
  },

  -- -------------------------------------------------------------------------
  -- Rainbow CSV  (same plugin, just ported to lazy spec)
  -- -------------------------------------------------------------------------
  {
    "mechatroner/rainbow_csv",
    ft = "csv",
  },

  -- -------------------------------------------------------------------------
  -- Python indentation  (replaces vim-python-pep8-indent)
  -- Treesitter handles indentation now, but keep as fallback
  -- -------------------------------------------------------------------------
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },

  -- -------------------------------------------------------------------------
  -- Treesitter  (replaces vim-cpp/ from bundle/ and handles most syntax)
  -- -------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "python", "lua", "bash", "markdown", "latex" },
        highlight        = { enable = true },
        indent           = { enable = true },
      })
    end,
  },

  -- -------------------------------------------------------------------------
  -- LSP + Completion  (replaces coc.nvim)
  -- -------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",          -- installs LSP servers
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",                 -- completion engine
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",                 -- snippet engine
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    event = "BufReadPre",
    config = function()
      -- Mason setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "pyright" },
        automatic_installation = true,
      })

      -- nvim-cmp setup
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"]    = cmp.mapping.confirm({ select = false }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Esc>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.abort() else fallback() end
          end, { "i" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- LSP server configs
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("lspconfig").clangd.setup({ capabilities = capabilities })
      require("lspconfig").pyright.setup({ capabilities = capabilities })

      -- Global LSP keymaps (applied when an LSP attaches)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufopts = { buffer = ev.buf }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,     bufopts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,          bufopts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,         bufopts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,    bufopts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,     bufopts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,   bufopts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,   bufopts)
        end,
      })
    end,
  },

  -- -------------------------------------------------------------------------
  -- Formatting  (replaces vim-autoformat/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      {
        "<F3>",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format file",
      },
    },
    opts = {
      formatters_by_ft = {
        c   = { "astyle" },
        cpp = { "astyle" },
        python = { "black", "isort" },
      },
      formatters = {
        astyle = {
          command = "astyle",
          args    = { "--mode=c", "--suffix=none",
                      "--options=" .. vim.fn.expand("~/.mca.astylerc"), "$FILENAME" },
          stdin   = false,
        },
      },
    },
  },

  -- -------------------------------------------------------------------------
  -- Auto-tags  (replaces vim-autotag/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "ludovicchabant/vim-gutentags",
    event = "BufReadPost",
    init = function()
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/nvim/tags")
    end,
  },

  -- -------------------------------------------------------------------------
  -- Local vimrc  (replaces vim-localvimrc/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "klen/nvim-config-local",
    opts = {
      config_files = { ".nvim.lua", ".lvimrc" },
      silent       = true,
      lookup_parents = true,
    },
  },

  -- -------------------------------------------------------------------------
  -- SLIME / REPL  (replaces slime/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "jpalardy/vim-slime",
    event = "VeryLazy",
    init = function()
      vim.g.slime_target = "tmux"   -- or "neovim", "kitty", etc.
    end,
  },

  -- -------------------------------------------------------------------------
  -- Indent text objects  (replaces indentTabObjects/ from bundle/)
  -- -------------------------------------------------------------------------
  {
    "michaeljsmith/vim-indent-object",
    event = "VeryLazy",
  },

  -- -------------------------------------------------------------------------
  -- txtfmt  (replaces txtfmt/ from bundle/)
  -- This plugin has no modern equivalent; keeping the original.
  -- -------------------------------------------------------------------------
  {
    "bpstahlman/txtfmt",
    ft = "txtfmt",
  },

  -- -------------------------------------------------------------------------
  -- Avante.nvim  (AI coding assistant — from previous discussion)
  -- -------------------------------------------------------------------------
  {
    "yetone/avante.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    build = "make",
    event = "VeryLazy",
    opts = {
      provider = "openai",
      openai = {
        api_key  = os.getenv("ASK_SAGE_API_KEY"),
        endpoint = "https://api.asksage.ai/server/openai/v1",
        model    = "gpt-4-gov",
      },
    },
  },

}, {
  -- lazy.nvim options
  ui = { border = "rounded" },
  performance = {
    rtp = {
      -- Disable built-ins you don't need to speed up startup
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- =============================================================================
-- Keymaps
-- =============================================================================

local map  = vim.keymap.set
local opts = { silent = true }

-- Escape from terminal mode
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- jj → Escape in insert mode
map("i", "jj", "<Esc>", opts)

-- Ctrl-L clears search highlight
map("n", "<C-l>", "<cmd>nohlsearch<CR><C-l>", opts)
map("i", "<C-l>", "<Esc><cmd>nohlsearch<CR><C-l>", opts)

-- Window navigation (Ctrl-hjkl)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Tab/Shift-Tab cycle buffers in normal mode
map("n", "<Tab>",   "<cmd>bn<CR>", opts)
map("n", "<S-Tab>", "<cmd>bp<CR>", opts)

-- Reselect visual block after indent
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Open tag definition in new tab
map("n", "<C-\\>", "<cmd>tab split<CR><cmd>exec('tag ' .. expand('<cword>'))<CR>", opts)

-- Open tag definition in vertical split
map("n", "<A-]>", "<cmd>vsp<CR><cmd>exec('tag ' .. expand('<cword>'))<CR>", opts)

-- Sudo write
vim.cmd("cmap w!! %!sudo tee > /dev/null %")

-- change-paste: replace current word with yanked register
map("n", "cp", '"_cw<C-R>"<Esc>', { silent = true })

-- Visual paste that preserves yank register
map("x", "p", 'p:let @"=@0<CR>', opts)

-- vimgrep current word across all files
map("n", "<F6>", function()
  vim.cmd('execute "vimgrep /" . expand("<cword>") . "/j **" | cw')
end, opts)

-- ---------------------------------------------------------------------------
-- WinMove / WinClose helpers  (GVim-style window nav rewritten in Lua)
-- ---------------------------------------------------------------------------
local function win_move(key)
  local cur = vim.fn.winnr()
  vim.cmd("wincmd " .. key)
  if vim.fn.winnr() == cur then
    if key:match("[jk]") then
      vim.cmd("wincmd v")
    else
      vim.cmd("wincmd s")
    end
    vim.cmd("wincmd " .. key)
  end
end

local function win_close()
  if vim.bo.filetype == "man" then
    vim.cmd("bd!")
  else
    vim.cmd("bd")
  end
end

map("n", "<C-Down>",  function() win_move("j") end, opts)
map("n", "<C-Up>",    function() win_move("k") end, opts)
map("n", "<C-Left>",  function() win_move("h") end, opts)
map("n", "<C-Right>", function() win_move("l") end, opts)
map("n", "<C-F12>",   win_close,                    opts)

-- ---------------------------------------------------------------------------
-- Enum-to-map helper  (converted from VimL function)
-- ---------------------------------------------------------------------------
local function enum_to_map_with_prefix()
  local prefix = vim.fn.input("Enum class prefix: ")
  local first  = vim.fn.line("v")
  local last   = vim.fn.line(".")
  if prefix ~= "" then
    vim.cmd(first .. "," .. last .. 's/\\s*\\(\\w\\+\\),*/    {"\\1", ' .. prefix .. '::\\1},/')
  else
    vim.cmd(first .. "," .. last .. 's/\\s*\\(\\w\\+\\),*/    {"\\1", \\1},/')
  end
end
map("v", "<leader>em", enum_to_map_with_prefix, opts)

-- ---------------------------------------------------------------------------
-- Multi-word highlight helpers  (ported from VimL)
-- ---------------------------------------------------------------------------
local function set_highlight(n, colour)
  if colour and #colour > 0 then
    vim.cmd(string.format("highlight hl%d term=bold ctermfg=%s guifg=%s", n, colour, colour))
  end
end

local function get_highlight_id(n)
  for _, m in ipairs(vim.fn.getmatches()) do
    if m.group == "hl" .. n then return m.id end
  end
  return 0
end

local function undo_highlight(n)
  pcall(vim.fn.matchdelete, get_highlight_id(n))
end

local function do_highlight(n, term)
  undo_highlight(n)
  if #term > 0 then
    vim.fn.matchadd("hl" .. n, term, -1)
  end
end

-- Set up initial colors
local hl_colors = { "darkred","darkgreen","darkblue","darkcyan","darkmagenta",
                    "red","green","blue","cyan" }
for i, c in ipairs(hl_colors) do set_highlight(i, c) end

map("n", "<Leader>ma", function() do_highlight(vim.v.count1, vim.fn.expand("<cword>")) end, opts)
map("n", "<Leader>md", function() undo_highlight(vim.v.count1) end, opts)
map("n", "<Leader>mc", function()
  set_highlight(vim.v.count1, vim.fn.input("Enter colour: "))
end, opts)

-- ---------------------------------------------------------------------------
-- Visual * / # search  (ported from VimL VSetSearch)
-- ---------------------------------------------------------------------------
local function vset_search(cmd)
  local old_reg     = vim.fn.getreg('"')
  local old_regtype = vim.fn.getregtype('"')
  vim.cmd("normal! gvy")
  local text = vim.fn.getreg('"')
  local pat
  if text:match("^[0-9a-z,_ ]*$") then
    pat = text
  else
    pat = vim.fn.escape(text, cmd .. "\\")
    if vim.g.VeryLiteral == 1 then
      pat = pat:gsub("\n", "\\n")
    else
      pat = pat:gsub("^%_%s+", "\\s\\+")
      pat = pat:gsub("%_%s+$", "\\s\\*")
      pat = pat:gsub("%_%s+",  "\\_s\\+")
    end
    pat = "\\V" .. pat
  end
  vim.fn.setreg("/", pat)
  vim.cmd("normal! gV")
  vim.fn.setreg('"', old_reg, old_regtype)
end

map("v", "*", function() vset_search("/")  vim.cmd("/" .. vim.fn.getreg("/")) end, opts)
map("v", "#", function() vset_search("?")  vim.cmd("?" .. vim.fn.getreg("/")) end, opts)

map("n", "<leader>vl", function()
  vim.g.VeryLiteral = vim.g.VeryLiteral == 1 and 0 or 1
  print("VeryLiteral " .. (vim.g.VeryLiteral == 1 and "On" or "Off"))
end, opts)

-- ---------------------------------------------------------------------------
-- SLIME send class/function  (replicates SelectClassOrFunction)
-- ---------------------------------------------------------------------------
local function select_class_or_function()
  local line    = vim.fn.getline(".")
  local cur     = vim.fn.line(".")
  local first, last

  if line:match("^def") or line:match("^class") then
    first = cur
  elseif line:match("^[a-zA-Z]") then
    first = cur
    last  = cur
    vim.cmd(first .. "," .. last .. "y r")
    vim.fn["Send_to_Screen"](vim.fn.getreg("r"))
    return
  else
    first = vim.fn.search("^def\\|^class", "bnW")
    if first == 0 then first = 1 end
  end

  last = vim.fn.search("^[a-zA-Z@]", "nW")
  if last == 0 then
    last = vim.fn.line("$")
  else
    last = last - 1
  end

  vim.cmd(first .. "," .. last .. "y r")
  vim.fn["Send_to_Screen"](vim.fn.getreg("r"))
end
map("n", "<C-c><C-c>", select_class_or_function, opts)

-- =============================================================================
-- Autocommands
-- =============================================================================

local au = vim.api.nvim_create_autocmd

-- Auto-close preview window after completion
au({ "CursorMovedI", "InsertLeave" }, {
  callback = function()
    if vim.fn.pumvisible() == 0 then
      pcall(vim.cmd, "pclose")
    end
  end,
})

-- Terminal: start in insert mode
au("TermOpen", { command = "startinsert" })
au({ "BufWinEnter", "WinEnter" }, {
  pattern = "term://*",
  command = "startinsert",
})

-- Filetype associations
au({ "BufNewFile", "BufRead" }, { pattern = "*.doxygen", command = "setfiletype doxygen" })
au({ "BufNewFile", "BufRead" }, { pattern = "*.md",      command = "set filetype=markdown" })

-- C/C++ formatting options
au("FileType", {
  pattern = { "c", "cpp", "cc", "h", "hpp" },
  command  = "setlocal formatoptions=croqln formatlistpat=^\\\\s*\\\\*\\\\s*@ comments=sr:/*,mb:*,el:*/,://  nojoinspaces cindent",
})

-- LaTeX
au("FileType", {
  pattern = { "tex", "sty" },
  command  = "setlocal formatoptions=tcqwa textwidth=78 nojoinspaces spell",
})

-- Dynamic textwidth for C++ style comments
if vim.fn.hostname() ~= "CDM" then
  au({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      local line = vim.fn.getline(vim.fn.line("."))
      if line:match("^%s*/%*") or line:match("^%s*%*") or line:match("^%s*//") then
        vim.opt_local.textwidth = 95
      else
        vim.opt_local.textwidth = 100
      end
    end,
  })
end

-- .clangd project root detection
au("BufEnter", {
  pattern  = { "*.cpp", "*.h", "*.c", "*.hpp" },
  callback = function()
    local file_dir   = vim.fn.expand("%:p:h")
    local clangd_file = vim.fn.findfile(".clangd", file_dir .. ";")
    if clangd_file ~= "" then
      local clangd_dir = vim.fn.fnamemodify(clangd_file, ":p:h")
      local cwd        = vim.fn.getcwd()
      if not cwd:find(clangd_dir, 1, true) and clangd_dir ~= file_dir then
        vim.cmd("lcd " .. vim.fn.fnameescape(file_dir))
      end
    end
  end,
})

-- Cscope quickfix
if vim.fn.has("cscope") == 1 and vim.fn.has("quickfix") == 1 then
  vim.opt.cscopequickfix = "s-,c-,d-,i-,t-,e-"
end

-- =============================================================================
-- Statusline  (retains fugitive integration)
-- =============================================================================
opt.statusline = "%t [%{strlen(&fenc)?&fenc:'none'},%{&ff}] %h%m%r%y %{FugitiveStatusline()}%=%c,%l/%L %P"

-- =============================================================================
-- Commands
-- =============================================================================
vim.api.nvim_create_user_command("Sudow",
  "silent write !sudo tee % >/dev/null | silent edit!",
  { bar = true, nargs = 0 })

-- Cscope abbreviations
for abbr, expand in pairs({
  csa = "cs add",  csf = "cs find", csk = "cs kill",
  csr = "cs reset", css = "cs show", csh = "cs help",
}) do
  vim.cmd("cnoreabbrev " .. abbr .. " " .. expand)
end

