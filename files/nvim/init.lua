vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.confirm = true

vim.schedule(function() vim.opt.clipboard = "unnamedplus" end)

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = { float = true },
}

vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Diagnostic quickfix" })

vim.keymap.set("n", "<leader>gd", function()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.85)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("git diff", {
    on_exit = function(_, code)
      if code == 0 and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Git diff in floating window" })

vim.keymap.set("n", "<leader>gm", function()
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.85)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("git diff main", {
    on_exit = function(_, code)
      if code == 0 and vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Git diff main in floating window" })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath }
  if vim.v.shell_error ~= 0 then error("Error cloning lazy.nvim:\n" .. out) end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "NMAC427/guess-indent.nvim", opts = {} },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      delay = 0,
      spec = {
        { "<leader>s", group = "Search", mode = { "n", "v" } },
        { "<leader>t", group = "Toggle" },
        { "<leader>h", group = "Git Hunk", mode = { "n", "v" } },
        { "gr", group = "LSP Actions", mode = { "n" } },
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("telescope").setup {
        extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
      }
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search Grep" })
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
      vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "Search Select Telescope" })
      vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "Search Word" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search Resume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "Search Recent Files" })
      vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search Commands" })
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown { winblend = 10, previewer = false })
      end, { desc = "Fuzzy search in buffer" })
      vim.keymap.set("n", "<leader>sn", function() builtin.find_files { cwd = vim.fn.stdpath("config") } end, { desc = "Search Neovim files" })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "Goto References" })
          vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "Goto Implementation" })
          vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "Goto Definition" })
          vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Document Symbols" })
          vim.keymap.set("n", "gW", builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = "Workspace Symbols" })
          vim.keymap.set("n", "grt", builtin.lsp_type_definitions, { buffer = buf, desc = "Goto Type Definition" })
        end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("grn", vim.lsp.buf.rename, "Rename")
          map("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
          map("grD", vim.lsp.buf.declaration, "Goto Declaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight", event.buf) then
            local hl_group = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf, group = hl_group, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf, group = hl_group, callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(e)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "lsp-highlight", buffer = e.buf }
              end,
            })
          end

          if client and client:supports_method("textDocument/inlayHint", event.buf) then
            map("<leader>th", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, "Toggle Inlay Hints")
          end
        end,
      })

      local extra_tools = { "stylua" }
      local servers = {
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath("config") and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc")) then return end
            end
            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
              runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
              workspace = {
                checkThirdParty = false,
                library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), { "${3rd}/luv/library", "${3rd}/busted/library" }),
              },
            })
          end,
          settings = { Lua = {} },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, extra_tools)
      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>f", function() require("conform").format { async = true, lsp_format = "fallback" } end, mode = "", desc = "Format buffer" },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then return nil end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
      formatters_by_ft = { lua = { "stylua" } },
    },
  },

  {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "2.*", build = (vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0) and nil or "make install_jsregexp", opts = {} },
    },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
      sources = { default = { "lsp", "path", "snippets" } },
      snippets = { preset = "luasnip" },
      fuzzy = { implementation = "lua" },
      signature = { enabled = true },
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup {}
      vim.cmd.colorscheme("catppuccin-mocha")
      vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    end,
  },

  { "folke/todo-comments.nvim", event = "VimEnter", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },

  {
    "nvim-mini/mini.nvim",
    config = function()
      require("mini.ai").setup { n_lines = 500 }
      require("mini.surround").setup()
      local statusline = require("mini.statusline")
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function() return "%2l:%-2v" end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    branch = "main",
    config = function()
      require("nvim-treesitter").install({ "bash", "c", "diff", "html", "lua", "luadoc", "markdown", "markdown_inline", "query", "vim", "vimdoc", "javascript", "typescript", "tsx", "json", "yaml" })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)
          if not language then return end
          if not vim.treesitter.language.add(language) then return end
          vim.treesitter.start(args.buf, language)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      { "rcarriga/nvim-notify", opts = { background_colour = "#000000" } },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },

  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    opts = {},
  },
})
