-- =============================================================================
-- ~/.config/nvim/init.lua
-- Neovim-only config using lazy.nvim + coc.nvim for completion/diagnostics
-- No nvim-lsp, no YCM
-- Languages: C/C++, Python, TypeScript/JavaScript, Lua, Bash, Markdown
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
-- Core options
-- ---------------------------------------------------------------------------
local opt = vim.opt

opt.compatible     = false
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
opt.inccommand     = "split"
opt.termguicolors  = true
opt.background     = "dark"
opt.clipboard      = "unnamed,unnamedplus"
opt.updatetime     = 300   -- recommended by coc.nvim for snappier diagnostics
opt.signcolumn     = "yes" -- always show; prevents text shift on diagnostics

-- ---------------------------------------------------------------------------
-- Filetype + syntax
-- ---------------------------------------------------------------------------
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")

-- ---------------------------------------------------------------------------
-- Global vars — set BEFORE plugins load
-- ---------------------------------------------------------------------------
vim.g.localvimrc_ask           = 0
vim.g.flake8_ignore            = "E501,E225"
vim.g.zenburn_old_Visual       = 1
vim.g.zenburn_alternate_Visual = 1
vim.g.zenburn_high_Contrast    = 1
vim.g.tex_flavor               = "latex"
vim.g.VeryLiteral              = 0

-- coc.nvim: extensions to auto-install on first launch.
-- After install you may also need: :CocCommand clangd.install
vim.g.coc_global_extensions = {
  "coc-clangd",        -- C / C++
  "coc-pyright",       -- Python
  "coc-tsserver",      -- TypeScript / JavaScript
  "coc-lua",           -- Lua  (uses lua-language-server internally)
  "coc-sh",            -- Bash / shell
  "coc-markdownlint",  -- Markdown linting
  "coc-snippets",      -- Snippets
  "coc-pairs",         -- Auto-pairs
  "coc-highlight",     -- Word highlight across buffer
}

-- Autoformat helper vars (used by conform.nvim formatters below)
vim.g.autoformat_autoindent             = 0
vim.g.autoformat_retab                  = 0
vim.g.autoformat_remove_trailing_spaces = 0

-- ---------------------------------------------------------------------------
-- Plugins
-- ---------------------------------------------------------------------------
require("lazy").setup({

  -- -------------------------------------------------------------------------
  -- Colorscheme
  -- -------------------------------------------------------------------------
  {
    "phha/zenburn.nvim",
    lazy     = false,
    priority = 1000,
    config   = function() vim.cmd("colorscheme zenburn") end,
  },

  -- -------------------------------------------------------------------------
  -- coc.nvim  — completion, diagnostics, snippets for all target languages
  --
  -- Prerequisites:
  --   • Node.js >= 16
  --   • After first launch: :CocInstall  (or let coc_global_extensions do it)
  --   • For C/C++: :CocCommand clangd.install  (if clangd not on PATH)
  --   • For Lua:   install lua-language-server via your OS package manager
  --   • Add .clangd at project root, e.g.:
  --       CompileFlags:
  --         CompilationDatabase: build/
  --
  -- Run :CocConfig to open coc-settings.json.  Suggested contents:
  --   {
  --     "suggest.noselect": true,
  --     "suggest.enablePreview": true,
  --     "diagnostic.errorSign": "✘",
  --     "diagnostic.warningSign": "▲",
  --     "diagnostic.infoSign": "●",
  --     "clangd.path": "clangd",
  --     "python.linting.enabled": true,
  --     "python.linting.flake8Enabled": true,
  --     "python.linting.flake8Args": ["--ignore=E501,E225"],
  --     "bashIde.shellcheckPath": "shellcheck"
  --   }
  -- -------------------------------------------------------------------------
  {
    "neoclide/coc.nvim",
    branch = "release",
    lazy   = false,   -- must load eagerly; hooks into VimEnter internally
  },

  -- -------------------------------------------------------------------------
  -- Git  (vim-fugitive — statusline + full git workflow)
  -- -------------------------------------------------------------------------
  {
    "tpope/vim-fugitive",
    lazy = false,   -- needed at startup for FugitiveStatusline()
  },

  -- -------------------------------------------------------------------------
  -- Repeat  (makes . work with plugin maps)
  -- -------------------------------------------------------------------------
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- -------------------------------------------------------------------------
  -- Surround  (Lua rewrite of vim-surround)
  -- -------------------------------------------------------------------------
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    config  = true,
  },

  -- -------------------------------------------------------------------------
  -- EasyMotion replacement  (flash.nvim)
  -- -------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = {},
    keys  = {
      { "s",     function() require("flash").jump() end,       mode = { "n", "x", "o" }, desc = "Flash jump" },
      { "S",     function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
      { "r",     function() require("flash").remote() end,     mode = "o",               desc = "Remote Flash" },
      { "<C-s>", function() require("flash").toggle() end,     mode = "c",               desc = "Toggle Flash Search" },
    },
  },

  -- -------------------------------------------------------------------------
  -- File tree  (neo-tree replaces NERDTree)
  -- -------------------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch       = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd  = "Neotree",
    keys = { { "<F8>", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" } },
    opts = { filesystem = { follow_current_file = { enabled = true } } },
  },

  -- -------------------------------------------------------------------------
  -- Tag browser  (Tagbar replaces TagList)
  -- -------------------------------------------------------------------------
  {
    "preservim/tagbar",
    cmd  = "TagbarToggle",
    keys = { { "<F9>", "<cmd>TagbarToggle<CR>", desc = "Toggle Tagbar" } },
  },

  -- -------------------------------------------------------------------------
  -- Rainbow delimiters  (replaces RainbowParenthesis)
  -- -------------------------------------------------------------------------
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufReadPost",
  },

  -- -------------------------------------------------------------------------
  -- Rainbow CSV
  -- -------------------------------------------------------------------------
  {
    "mechatroner/rainbow_csv",
    ft = "csv",
  },

  -- -------------------------------------------------------------------------
  -- Treesitter  (syntax + indent for all target languages)
  -- -------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp",
          "python",
          "typescript", "javascript",
          "lua",
          "bash",
          "markdown", "markdown_inline",
        },
        highlight = { enable = true },
        indent    = { enable = true },
      })
    end,
  },

  -- -------------------------------------------------------------------------
  -- Python indentation fallback  (treesitter handles most cases)
  -- -------------------------------------------------------------------------
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },

  -- -------------------------------------------------------------------------
  -- Formatting  (conform.nvim replaces vim-autoformat)
  --
  -- External tools needed on PATH:
  --   C/C++:      astyle
  --   Python:     black, isort
  --   TS/JS/MD:   prettierd  (or prettier)
  --   Lua:        stylua
  --   Bash:       shfmt
  -- -------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys  = {
      {
        "<F3>",
        function() require("conform").format({ async = true, lsp_fallback = false }) end,
        desc = "Format file",
      },
    },
    opts = {
      formatters_by_ft = {
        c          = { "astyle" },
        cpp        = { "astyle" },
        python     = { "black", "isort" },
        typescript = { "prettierd", "prettier" },
        javascript = { "prettierd", "prettier" },
        lua        = { "stylua" },
        sh         = { "shfmt" },
        markdown   = { "prettierd", "prettier" },
      },
      formatters = {
        astyle = {
          command = "astyle",
          args    = {
            "--mode=c", "--suffix=none",
            "--options=" .. vim.fn.expand("~/.mca.astylerc"),
            "$FILENAME",
          },
          stdin = false,
        },
      },
      format_on_save = {
        timeout_ms   = 2000,
        lsp_fallback = false,
      },
    },
  },

  -- -------------------------------------------------------------------------
  -- Auto-tags  (vim-gutentags replaces vim-autotag)
  -- -------------------------------------------------------------------------
  {
    "ludovicchabant/vim-gutentags",
    event = "BufReadPost",
    init  = function()
      vim.g.gutentags_cache_dir = vim.fn.expand("~/.cache/nvim/tags")
    end,
  },

  -- -------------------------------------------------------------------------
  -- Local vimrc  (nvim-config-local replaces vim-localvimrc)
  -- -------------------------------------------------------------------------
  {
    "klen/nvim-config-local",
    opts = {
      config_files   = { ".nvim.lua", ".lvimrc" },
      silent         = true,
      lookup_parents = true,
    },
  },

  -- -------------------------------------------------------------------------
  -- SLIME / REPL  (no better Lua replacement yet)
  -- -------------------------------------------------------------------------
  {
    "jpalardy/vim-slime",
    event = "VeryLazy",
    init  = function()
      vim.g.slime_target = "tmux"   -- change to "neovim", "kitty", etc. if needed
    end,
  },

  -- -------------------------------------------------------------------------
  -- Indent text objects  (ii / ai motions)
  -- -------------------------------------------------------------------------
  {
    "michaeljsmith/vim-indent-object",
    event = "VeryLazy",
  },

  -- -------------------------------------------------------------------------
  -- txtfmt  (no modern replacement)
  -- -------------------------------------------------------------------------
  {
    "bpstahlman/txtfmt",
    ft = "txtfmt",
  },

  -- -------------------------------------------------------------------------
  -- Avante.nvim  (AI assistant — Ask Sage / OpenAI-compatible)
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
      providers = {
        openai = {
          -- endpoint = "https://api.asksage.ai/server/openai/v1",
          endpoint = "https://api.civ.asksage.ai/server/anthropic",
          --api_key = os.getenv("ASK_SAGE_API_KEY"),  -- or hardcode if you prefer (not recommended)
          api_key = "7f8c0ce2538d5f245fbc207efe872f11a625130acd67bf74e041abd082c2a61b",
          model = "gpt-4-gov",  -- or any model available in your Ask Sage tenant (e.g. gpt4-gov, claude-3.5-sonnet, etc.)
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0,
            max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
            reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
          },
          -- temperature, max_tokens, etc. as needed
        },
        ollama = {
          endpoint = "http://127.0.0.1:11434",
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            options = {
              temperature = 0.75,
              num_ctx = 20480,
              keep_alive = "5m",
            },
          },
        },
      },
    },
    --opts  = {
      --provider = "openai",
      --openai   = {
        --api_key  = os.getenv("ASK_SAGE_API_KEY"),
        --endpoint = "https://api.asksage.ai/server/openai/v1",
        --model    = "gpt-4-gov",
      --},
    --},
  },

}, {
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-- =============================================================================
-- coc.nvim keymaps
-- These must use Vimscript <expr> maps because coc# functions return strings
-- that are fed back into the keymap machinery — Lua closures cannot do this.
-- =============================================================================

-- Helper visible to the <expr> maps below
vim.cmd([[
function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction
]])

-- <Tab>: next completion item / indent / trigger completion
vim.cmd([[
inoremap <silent><expr> <Tab>
  \ coc#pum#visible() ? coc#pum#next(1) :
  \ CheckBackSpace() ? "\<Tab>" :
  \ coc#refresh()
]])

-- <S-Tab>: previous completion item / un-indent
vim.cmd([[
inoremap <silent><expr> <S-Tab>
  \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
]])

-- <CR>: confirm selection or normal Enter
vim.cmd([[
inoremap <silent><expr> <CR>
  \ coc#pum#visible() ? coc#pum#confirm() :
  \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
]])

-- <C-Space>: manually trigger completion
vim.cmd([[inoremap <silent><expr> <C-Space> coc#refresh()]])

-- <Esc>: cancel pum or normal Esc
vim.cmd([[
inoremap <silent><expr> <Esc>
  \ coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"
]])

-- Snippet navigation (coc-snippets)
vim.cmd([[
let g:coc_snippet_next = '<C-j>'
let g:coc_snippet_prev = '<C-k>'
]])

-- Diagnostic navigation
local si = { silent = true }
vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)",  { silent = true, desc = "Prev diagnostic" })
vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)",  { silent = true, desc = "Next diagnostic" })

-- Go-to actions
vim.keymap.set("n", "gd", "<Plug>(coc-definition)",       { silent = true, desc = "Go to definition" })
vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)",  { silent = true, desc = "Go to type def" })
vim.keymap.set("n", "gi", "<Plug>(coc-implementation)",   { silent = true, desc = "Go to implementation" })
vim.keymap.set("n", "gr", "<Plug>(coc-references)",       { silent = true, desc = "Go to references" })

-- Hover documentation
vim.keymap.set("n", "K", function()
  if vim.fn.CocAction("hasProvider", "hover") then
    vim.fn.CocActionAsync("doHover")
  else
    vim.api.nvim_feedkeys("K", "in", false)
  end
end, { silent = true, desc = "Show hover docs" })

-- Rename symbol
vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)",
  { silent = true, desc = "Rename symbol" })

-- Code actions
vim.keymap.set({ "n", "x" }, "<leader>ca", "<Plug>(coc-codeaction-selected)",
  { silent = true, desc = "Code action" })
vim.keymap.set("n", "<leader>cl", "<Plug>(coc-codeaction-line)",
  { silent = true, desc = "Code action (line)" })

-- Format selection via coc
vim.keymap.set("x", "<leader>f", "<Plug>(coc-format-selected)",
  { silent = true, desc = "Format selection" })

-- CocList shortcuts
vim.keymap.set("n", "<leader>co", "<cmd>CocList outline<CR>",
  { silent = true, desc = "Symbol outline" })
vim.keymap.set("n", "<leader>cs", "<cmd>CocList -I symbols<CR>",
  { silent = true, desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>cd", "<cmd>CocList diagnostics<CR>",
  { silent = true, desc = "Diagnostics list" })

-- =============================================================================
-- General keymaps
-- =============================================================================

local map  = vim.keymap.set
local opts = { silent = true }

-- Terminal escape
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- jj → Esc in insert mode
map("i", "jj", "<Esc>", opts)

-- Clear search highlight
-- NOTE: <C-l> doubles as window-right in some configs; window nav uses
-- <C-Right> / Ctrl-arrow below to avoid the conflict.
-- map("n", "<C-l>", "<cmd>nohlsearch<CR><C-l>", opts)

-- Window navigation (Ctrl-hjkl for up/down/left; Ctrl-Right for right)
map("n", "<C-j>",     "<C-w>j", opts)
map("n", "<C-k>",     "<C-w>k", opts)
map("n", "<C-h>",     "<C-w>h", opts)
map("n", "<C-l>",     "<C-w>l", opts)
map("n", "<C-Down>",  function() _G.win_move("j") end, opts)
map("n", "<C-Up>",    function() _G.win_move("k") end, opts)
map("n", "<C-Left>",  function() _G.win_move("h") end, opts)
map("n", "<C-Right>", function() _G.win_move("l") end, opts)
map("n", "<C-F12>",   function() _G.win_close()   end, opts)

-- Tab / Shift-Tab cycle buffers in normal mode
map("n", "<Tab>",   "<cmd>bn<CR>", opts)
map("n", "<S-Tab>", "<cmd>bp<CR>", opts)

-- Reselect visual block after indent
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Tag navigation
map("n", "<C-\\>", "<cmd>tab split<CR><cmd>exec('tag ' .. expand('<cword>'))<CR>", opts)
map("n", "<A-]>",  "<cmd>vsp<CR><cmd>exec('tag ' .. expand('<cword>'))<CR>", opts)

-- Sudo write
vim.cmd("cmap w!! %!sudo tee > /dev/null %")

-- change-paste: replace word with yank register
map("n", "cp", '"_cw<C-R>"<Esc>', opts)

-- Visual paste that preserves yank register
map("x", "p", 'p:let @"=@0<CR>', opts)

-- vimgrep current word
map("n", "<F6>", function()
  vim.cmd('execute "vimgrep /" . expand("<cword>") . "/j **" | cw')
end, opts)

-- =============================================================================
-- Window move / close helpers
-- =============================================================================

function _G.win_move(key)
  local cur = vim.fn.winnr()
  vim.cmd("wincmd " .. key)
  if vim.fn.winnr() == cur then
    if key:match("[jk]") then vim.cmd("wincmd v")
    else                       vim.cmd("wincmd s")
    end
    vim.cmd("wincmd " .. key)
  end
end

function _G.win_close()
  if vim.bo.filetype == "man" then vim.cmd("bd!")
  else                              vim.cmd("bd")
  end
end

-- =============================================================================
-- Enum-to-map helper
-- =============================================================================

local function enum_to_map_with_prefix()
  local prefix = vim.fn.input("Enum class prefix: ")
  local first  = vim.fn.line("v")
  local last   = vim.fn.line(".")
  if prefix ~= "" then
    vim.cmd(first .. "," .. last ..
      's/\\s*\\(\\w\\+\\),*/    {"\\1", ' .. prefix .. '::\\1},/')
  else
    vim.cmd(first .. "," .. last ..
      's/\\s*\\(\\w\\+\\),*/    {"\\1", \\1},/')
  end
end
map("v", "<leader>em", enum_to_map_with_prefix, opts)

-- =============================================================================
-- Multi-word highlight helpers
-- =============================================================================

local function set_highlight(n, colour)
  if colour and #colour > 0 then
    vim.cmd(string.format(
      "highlight hl%d term=bold ctermfg=%s guifg=%s", n, colour, colour))
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
  if #term > 0 then vim.fn.matchadd("hl" .. n, term, -1) end
end

for i, c in ipairs({ "darkred","darkgreen","darkblue","darkcyan","darkmagenta",
                     "red","green","blue","cyan" }) do
  set_highlight(i, c)
end

map("n", "<Leader>ma", function() do_highlight(vim.v.count1, vim.fn.expand("<cword>")) end, opts)
map("n", "<Leader>md", function() undo_highlight(vim.v.count1) end, opts)
map("n", "<Leader>mc", function()
  set_highlight(vim.v.count1, vim.fn.input("Enter colour: "))
end, opts)

-- =============================================================================
-- Visual * / # search
-- =============================================================================

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

map("v", "*", function() vset_search("/") vim.cmd("/" .. vim.fn.getreg("/")) end, opts)
map("v", "#", function() vset_search("?") vim.cmd("?" .. vim.fn.getreg("/")) end, opts)

map("n", "<leader>vl", function()
  vim.g.VeryLiteral = vim.g.VeryLiteral == 1 and 0 or 1
  print("VeryLiteral " .. (vim.g.VeryLiteral == 1 and "On" or "Off"))
end, opts)

-- =============================================================================
-- SLIME: send Python class/function to REPL
-- =============================================================================

local function select_class_or_function()
  local line  = vim.fn.getline(".")
  local cur   = vim.fn.line(".")
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
  if last == 0 then last = vim.fn.line("$")
  else              last = last - 1
  end

  vim.cmd(first .. "," .. last .. "y r")
  vim.fn["Send_to_Screen"](vim.fn.getreg("r"))
end
map("n", "<C-c><C-c>", select_class_or_function, opts)

-- =============================================================================
-- Autocommands
-- =============================================================================

local au = vim.api.nvim_create_autocmd

-- Close preview window when completion popup closes
au({ "CursorMovedI", "InsertLeave" }, {
  callback = function()
    if vim.fn.pumvisible() == 0 then pcall(vim.cmd, "pclose") end
  end,
})

-- Terminal: enter insert mode automatically
au("TermOpen",                    { command = "startinsert" })
au({ "BufWinEnter", "WinEnter" }, { pattern = "term://*", command = "startinsert" })

-- Filetype associations
au({ "BufNewFile", "BufRead" }, { pattern = "*.doxygen", command = "setfiletype doxygen" })
au({ "BufNewFile", "BufRead" }, { pattern = "*.md",      command = "set filetype=markdown" })

-- C/C++ formatting options
au("FileType", {
  pattern = { "c", "cpp", "cc", "h", "hpp" },
  command = "setlocal formatoptions=croqln"
         .. " formatlistpat=^\\\\s*\\\\*\\\\s*@"
         .. " comments=sr:/*,mb:*,el:*/,://"
         .. " nojoinspaces cindent",
})

-- LaTeX
au("FileType", {
  pattern = { "tex", "sty" },
  command = "setlocal formatoptions=tcqwa textwidth=78 nojoinspaces spell",
})

-- Dynamic textwidth: narrower inside C-style block comments
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

-- .clangd project root: lcd to the file's directory when .clangd found above
au("BufEnter", {
  pattern  = { "*.cpp", "*.h", "*.c", "*.hpp" },
  callback = function()
    local file_dir    = vim.fn.expand("%:p:h")
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

-- Highlight symbol under cursor via coc (on CursorHold)
au("CursorHold", {
  callback = function()
    if vim.fn.exists("*CocActionAsync") == 1 then
      vim.fn.CocActionAsync("highlight")
    end
  end,
})

-- Cscope quickfix integration
if vim.fn.has("cscope") == 1 then
  opt.cscopetag     = true
  opt.cscopeverbose = true
  if vim.fn.has("quickfix") == 1 then
    opt.cscopequickfix = "s-,c-,d-,i-,t-,e-"
  end
end

-- =============================================================================
-- Statusline  (fugitive integration preserved)
-- =============================================================================
opt.statusline = "%t [%{strlen(&fenc)?&fenc:'none'},%{&ff}] %h%m%r%y"
              .. " %{FugitiveStatusline()}%=%c,%l/%L %P"

-- =============================================================================
-- Commands
-- =============================================================================
vim.api.nvim_create_user_command("Sudow",
  "silent write !sudo tee % >/dev/null | silent edit!", { bar = true, nargs = 0 })

-- Cscope abbreviations
for abbr, expansion in pairs({
  csa = "cs add",  csf = "cs find", csk = "cs kill",
  csr = "cs reset", css = "cs show", csh = "cs help",
}) do
  vim.cmd("cnoreabbrev " .. abbr .. " " .. expansion)
end

