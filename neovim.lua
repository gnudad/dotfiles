vim.g.mapleader = " "

vim.o.cmdheight = 0
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.formatoptions = "cro/qnlj"
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.pumheight = 7
vim.o.scrolloff = 5
vim.o.shiftwidth = 2
vim.o.sidescrolloff = 5
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.textwidth = 88
vim.o.title = true
vim.o.titlestring = "%{fnamemodify(getcwd(), ':t')}"
vim.o.wrap = false

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "https://github.com/folke/lazy.nvim.git",
    "--filter=blob:none", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { "sainnhe/gruvbox-material", priority = 1000,
    config = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_foreground = "mix"
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
      vim.g.gruvbox_material_better_performance = 1
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "@function.builtin", { link = "YellowBold" })
          vim.api.nvim_set_hl(0, "@property", { link = "Fg" })
          vim.api.nvim_set_hl(0, "@variable.builtin", { italic = true })
          vim.api.nvim_set_hl(0, "@variable.member", { link = "Fg" })
          vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { link = "DiagnosticUnderlineHint" })
          vim.api.nvim_set_hl(0, "MatchParen", { link = "FloatTitle" })
          vim.api.nvim_set_hl(0, "NeogitHunkHeaderCursor", { link = "TabLine" })
          vim.api.nvim_set_hl(0, "TabLineFill", { link = "PmenuExtra" })
        end,
      })
      vim.cmd.colorscheme("gruvbox-material")
    end,
  },
  { "nvim-lualine/lualine.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_b = { "branch", "diff" },
        lualine_x = {
          { "macro-recording",
            fmt = function()
              if vim.fn.reg_recording() == "" then return "" end
              return "Recording @" .. vim.fn.reg_recording()
            end,
          },
          "selectioncount", "searchcount", "diagnostics", "filetype",
        },
      },
    },
  },
  { "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({
        notification = { override_vim_notify = true },
      })
      vim.keymap.set("n", "<leader>h", [[<cmd>Fidget history<cr>]])
    end,
  },
  { "stevearc/oil.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "ojroques/nvim-osc52",
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = vim.schedule_wrap(function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if vim.fn.isdirectory(bufname) == 1 then
            vim.cmd("Oil " .. bufname)
          end
        end),
      })
    end,
    config = function()
      require("oil").setup({
        skip_confirm_for_simple_edits = true,
        columns = {
          { "mtime", highlight = "Comment" },
          { "size", highlight = "Blue" },
          { "icon", add_padding = true },
        },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-p>"] = "actions.preview",
          ["<C-r>"] = "actions.refresh",
          ["<A-y>"] = function() require("osc52").copy(
            require("oil").get_current_dir() .. require("oil").get_cursor_entry().name
          ) end,
          ["Q"] = function()
            local file = io.open("/tmp/.oil.nvim.cd", "w")
            if file ~= nil then
              file:write(require("oil").get_current_dir())
              file:close()
            end
            vim.cmd("qa!")
          end,
        },
        win_options = { winbar = "%{v:lua.require('oil').get_current_dir()}" },
      })
      vim.api.nvim_set_hl(0, "WinBar", { link = "Title" })
    end,
    cmd = "Oil",
    keys = {{"-", [[<cmd>Oil<cr>]] }},
  },
  { "aymericbeaumet/vim-symlink" },
  { "LunarVim/bigfile.nvim" },
  { "tpope/vim-sleuth",
    config = function()
      for _, ft in pairs({ "go", "php", "python" }) do
        vim.g["sleuth_" .. ft .. "_defaults"] = "shiftwidth=4"
      end
    end,
  },
  { "lewis6991/gitsigns.nvim", event = "BufReadPost",
    config = function()
      local gs = require("gitsigns")
      gs.setup({})
      local function get_range() return { vim.fn.line("."), vim.fn.line("v") } end
      vim.keymap.set({"n", "x", "o"}, "[g", gs.prev_hunk)
      vim.keymap.set({"n", "x", "o"}, "]g", gs.next_hunk)
      vim.keymap.set("n", "<leader>gl", function() gs.blame_line({ full = true }) end)
      vim.keymap.set("n", "<leader>gp", gs.preview_hunk)
      vim.keymap.set("n", "<leader>gr", gs.reset_hunk)
      vim.keymap.set("x", "<leader>gr", function() gs.reset_hunk(get_range()) end)
      vim.keymap.set("n", "<leader>gs", gs.stage_hunk)
      vim.keymap.set("x", "<leader>gs", function() gs.stage_hunk(get_range()) end)
      vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk)
      vim.keymap.set("n", "<leader>gd", gs.toggle_deleted)
    end,
  },
  { "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    init = function()
      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          if vim.bo.filetype == "NeogitCommitMessage" or vim.bo.filetype == "gitcommit" then
            vim.opt_local.spell = true
          end
        end,
      })
    end,
    config = function()
      require("neogit").setup({
        disable_hint = true,
        disable_insert_on_commit = true,
        console_timeout = 5000,
        graph_style = "kitty",
        sections = {
          untracked = { folded = true, hidden = false },
        },
      })
    end,
    keys = {{ "<leader>gg", [[<cmd>silent wa<cr><cmd>Neogit kind=replace<cr>]] }},
  },
  { "tpope/vim-fugitive", keys = {{ "<leader>gb", [[<cmd>Git blame<cr>]] }} },
  { "sindrets/diffview.nvim",
    keys = {
      { "<leader>gf", [[<cmd>DiffviewFileHistory %<cr>]] },
      { "<leader>gh", [[<cmd>DiffviewFileHistory<cr>]] },
      { "<leader>go", [[<cmd>DiffviewOpen<cr>]] },
      { "<leader>gc", [[<cmd>DiffviewClose<cr>]] },
    },
  },
  { "ahmedkhalf/project.nvim", name = "project_nvim", config = true },
  { "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "jvgrootveld/telescope-zoxide" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { ".DS_Store", ".git/", ".venv/" },
          layout_strategy = "vertical",
          mappings = {
            i = {
              ["<C-t>"] = require("trouble.sources.telescope").open,
              ["<esc>"] = require("telescope.actions").close,
            },
          },
        },
        extensions = {
          zoxide = {
            mappings = {
              default = {
                after_action = function(selection)
                  vim.cmd.edit(selection.path)
                end,
              },
            },
          },
        },
      })
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("projects")
      require("telescope").load_extension("zoxide")
      require("telescope").load_extension("yank_history")
    end,
    keys = {
      { "<leader>p", [[<cmd>Telescope projects<cr>]] },
      { "<leader>f", [[<cmd>Telescope find_files hidden=true<cr>]] },
      { "<leader>F", [[<cmd>Telescope find_files hidden=true no_ignore=true<cr>]] },
      { "<leader><tab>", [[<cmd>Telescope buffers sort_lastused=true<cr>]] },
      { "<leader>*", [[<cmd>Telescope grep_string<cr>]] },
      { "<leader>/", [[<cmd>Telescope live_grep<cr>]] },
      { "<leader>lo", [[<cmd>Telescope lsp_document_symbols<cr>]] },
      { "<leader>lw", [[<cmd>Telescope lsp_dynamic_workspace_symbols<cr>]] },
      { "<leader>r", [[<cmd>Telescope resume<cr>]] },
      { "<leader>z", [[<cmd>Telescope zoxide list<cr>]] },
      { "<leader>y", [[<cmd>Telescope yank_history<cr>]] },
      { "z=", [[<cmd>Telescope spell_suggest<cr>]] },
    },
  },
  { "folke/trouble.nvim",
    config = function()
      require("trouble").setup({
        auto_jump = true,
        focus = true,
        keys = { ["<tab>"] = "fold_toggle" },
      })
      vim.api.nvim_set_hl(0, "TroubleNormal", { link = "Normal" })
      vim.api.nvim_set_hl(0, "TroubleNormalNC", { link = "Normal" })
    end,
    cmd = "Trouble",
    keys = {
      { "gd", [[<cmd>Trouble lsp_definitions<cr>]] },
      { "gr", [[<cmd>Trouble lsp_references<cr>]] },
      { "<leader>dd", [[<cmd>Trouble diagnostics toggle<cr>]] },
      { "<leader>q", [[<cmd>Trouble quickfix toggle<cr>]] },
      { "<leader>o", [[<cmd>Trouble symbols toggle focus=true<cr>]] },
    },
  },
  { "williamboman/mason.nvim", config = true,
    keys = {{ "<leader>M", [[<cmd>Mason<cr>]] }},
  },
  { "neovim/nvim-lspconfig",
    dependencies = "williamboman/mason-lspconfig.nvim",
    ft = { "go", "html", "javascript", "lua", "php", "python" },
    config = function()
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              ---@diagnostic disable-next-line: unused-local
              on_attach = function(client, bufnr)
                client.server_capabilities.semanticTokensProvider = nil
              end,
            })
          end,
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              settings = { python = { pythonPath = ".venv/bin/python" } },
            })
          end,
          ["ruff"] = function()
            require("lspconfig").ruff.setup({
              ---@diagnostic disable-next-line: unused-local
              on_attach = function(client, bufnr)
                -- Prevent "No information available" from ruff on vim.lsp.buf.hover()
                client.server_capabilities.hoverProvider = false
              end,
            })
          end,
        },
      })
      vim.keymap.set("n", "ge", vim.diagnostic.open_float)
      vim.keymap.set("n", "<leader>li", [[<cmd>LspInfo<cr>]])
      vim.keymap.set("n", "<leader>lr", [[<cmd>LspRestart<cr>]])
      local function update_severity(s)
        if s ~= false then s = { severity = { min = vim.diagnostic.severity[s] } } end
        vim.diagnostic.config({
          signs = false,
          underline = s,
          virtual_text = s,
          severity_sort = true,
        })
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev(s) end)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next(s) end)
      end
      vim.keymap.set("n", "<leader>de", function() update_severity("ERROR") end)
      vim.keymap.set("n", "<leader>da", function() update_severity("HINT") end)
      vim.keymap.set("n", "<leader>do", function() update_severity(false) end)
      update_severity("HINT")
    end,
  },
  { "folke/lazydev.nvim", ft = "lua",
    dependencies = "Bilal2453/luvit-meta",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        { path = "~/.config/hammerspoon/Spoons/EmmyLua.spoon/annotations" },
      },
    },
  },
  { "rachartier/tiny-code-action.nvim", config = true,
    dependencies = "nvim-telescope/telescope.nvim",
    keys = {{ "ga", function() require("tiny-code-action").code_action() end }},
  },
  { "smjonas/inc-rename.nvim", event = "LspAttach",
    config = function()
      require("inc_rename").setup({})
      vim.keymap.set("n", "gR", function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end, { expr = true })
    end,
  },
  { "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {
        formatters_by_ft = {
          css = { "prettier" },
          go = { "gofmt" },
          html = { "prettier" },
          javascript = { "prettier" },
          json = { "jq" },
          python = { "ruff_format" },
        },
    },
    keys = {{ "<leader>=", mode = { "n", "x" }, function()
      require("conform").format({ lsp_format = "fallback" })
    end }},
  },
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "folke/lazydev.nvim",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "nvim-autopairs",
      "gitaarik/nvim-cmp-toggle",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.abort()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "lazydev" },
          { name = "buffer", max_item_count = 5,
            option = { get_bufnrs = function() return vim.api.nvim_list_bufs() end } },
          { name = "path", option = { get_cwd = function() return vim.fn.getcwd() end } },
          { name = "calc" },
          { name = "luasnip" },
        }),
        ---@diagnostic disable-next-line: missing-fields
        matching = { disallow_fuzzy_matching = true, },
      })
      -- Insert `(` after select function or method item
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
    keys = {{ "<leader>c", [[<cmd>NvimCmpToggle<cr>]] }}
  },
  { "ray-x/lsp_signature.nvim", event = "LspAttach",
    config = function()
      require("lsp_signature").setup({
        hint_enable = false,
        handler_opts = { border = "none" },
        toggle_key = "<C-s>",
      })
      vim.keymap.set("n", "<C-s>", function() vim.lsp.buf.signature_help() end)
    end,
  },
  { "gbprod/yanky.nvim",
    dependencies = "kkharji/sqlite.lua",
    opts = { ring = { storage = "sqlite" } },
    keys = {
      { "y", mode = {"n", "x"}, [[<Plug>(YankyYank)]] },
      { "p", mode = {"n", "x"}, [[<Plug>(YankyPutAfter)]] },
      { "P", mode = {"n", "x"}, [[<Plug>(YankyPutBefore)]] },
      { "=p", mode = {"n", "x"}, [[<Plug>(YankyPutAfterFilter)]] },
      { "=P", mode = {"n", "x"}, [[<Plug>(YankyPutBeforeFilter)]] },
      { "[p", [[<Plug>(YankyCycleForward)]] },
      { "]p", [[<Plug>(YankyCycleBackward)]] },
    },
  },
  { "ojroques/nvim-osc52",
    dependencies = "gbprod/yanky.nvim",
    config = function()
      require("osc52").setup({ silent = true })
      vim.keymap.set("n", "<A-y>", require("osc52").copy_operator, { expr = true })
      vim.keymap.set("n", "<A-y><A-y>", "<A-y>i_", { remap = true })
      vim.keymap.set("v", "<A-y>", require("osc52").copy_visual)
    end,
    keys = {{ "<A-y>", mode = { "n", "v" } }},
  },
  { "ggandor/leap.nvim",
    config = function()
      vim.keymap.set({ "n", "x", "o" }, "s", [[<Plug>(leap)]])
      vim.keymap.set({ "n",          }, "S", [[<Plug>(leap-from-window)]])
      require("leap.user").set_repeat_keys("<enter>", "<backspace>")
    end,
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            node_incremental = "v",
            node_decremental = "<backspace>",
          },
        },
      })
      -- Use bash treesitter syntax for zsh files
      vim.treesitter.language.register("bash", "zsh")
      -- Fix sql @function.call highlights
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "sql",
        callback = function()
          local path = vim.fn.stdpath("config") .. "/queries/sql"
          local f = io.open(path .. "/highlights.scm")
          if f ~= nil then f:close() else
            os.execute("mkdir -p " .. path)
            f = io.open(path .. "/highlights.scm", "w")
            if f ~= nil then
              f:write(";; extends\n")
              f:write("(invocation (object_reference name: (identifier) @function.call))")
              f:close()
            end
          end
        end,
      })
      vim.keymap.set("n", "<leader>i", [[<cmd>Inspect<cr>]])
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({ enable = false })
      vim.keymap.set("n", "<leader>`", [[<cmd>TSContextToggle<cr>]])
      vim.keymap.set("n", "[`", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end)
    end,
  },
  { "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["aa"] = "@parameter.outer",   ["ia"] = "@parameter.inner",
              ["aC"] = "@class.outer",       ["iC"] = "@class.inner",
              ["ac"] = "@conditional.outer", ["ic"] = "@conditional.inner",
              ["af"] = "@function.outer",    ["if"] = "@function.inner",
              ["aL"] = "@loop.outer",        ["iL"] = "@loop.inner",
              ["a;"] = "@comment.outer",     ["i;"] = "@comment.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = false,
            goto_next_start = {
              ["]a"] = "@parameter.inner",
              ["]C"] = "@class.outer",
              ["]c"] = "@conditional.outer",
              ["]f"] = "@function.outer",
              ["]l"] = "@loop.outer",
              ["];"] = "@comment.outer",
            },
            goto_previous_start = {
              ["[a"] ="@parameter.inner",
              ["[C"] ="@class.outer",
              ["[c"] ="@conditional.outer",
              ["[f"] ="@function.outer",
              ["[l"] ="@loop.outer",
              ["[;"] ="@comment.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>al"] = "@parameter.inner" },
            swap_previous = { ["<leader>ah"] = "@parameter.inner" },
          },
        },
      })
      local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
    end,
  },
  { "chrisgrieser/nvim-various-textobjs", opts = {
    useDefaultKeymaps = true,
    disabledKeymaps = { "gw", "r" },
  }},
  { "wellle/targets.vim" },
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "windwp/nvim-ts-autotag", config = true },
  { "utilyre/sentiment.nvim", event = "VeryLazy", config = true },
  { "kylechui/nvim-surround", config = true, keys = {
      "ys", "ds", "cs", { "S", mode = { "x" } },
  }},
  { "Wansmer/treesj",
    opts = { use_default_keymaps = false },
    keys = {{ "<leader>j", [[<cmd>TSJSplit<cr>]] },
            { "<leader>J", [[<cmd>TSJJoin<cr>]] }},
  },
  { "chrishrb/gx.nvim", submodules = false, config = true,
    keys = {{ "gx", mode = { "n", "x" }, [[<cmd>Browse<cr>1<cr><cr>]] }},
  },
  { "tzachar/highlight-undo.nvim", config = true },
  { "utilyre/sentiment.nvim", config = true },
  { "junegunn/vim-easy-align", keys = {{ "gA", mode = { "x" }, [[<Plug>(EasyAlign)]] }} },
  { "johmsalas/text-case.nvim",
    opts = { default_keymappings_enabled = false },
    keys = {{ "gt", mode = { "x" }, function()
      require("textcase").visual("to_title_case")
    end }},
  },
  { "brenoprata10/nvim-highlight-colors", config = true },
  { "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("ufo").setup({
        provider_selector = function() return { "treesitter", "indent" } end,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
      vim.api.nvim_set_hl(0, "Folded", {})
      vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { link = "FloatTitle" })
    end,
  },
  { "nvim-pack/nvim-spectre",
    opts = {
      replace_engine = {
        ["sed"] = { cmd = "sed", args = { "-i", "", "-E" } },
      },
    },
    keys = {{ "<leader>?", [[<cmd>Spectre<cr>]] }},
  },
  { "mistweaverco/kulala.nvim", ft = "http",
    init = function()
      vim.filetype.add({ extension = { http = "http" } })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "http",
        callback = function()
          vim.keymap.set("n", "<leader><cr>", require("kulala").run, { buffer = 0 })
          vim.keymap.set("n", "<leader>v", require("kulala").toggle_view, { buffer = 0 })
        end
      })
    end,
    opts = {
      default_view = "headers_body",
      additional_curl_options = { "-L" },
    },
  },
  { "iamcco/markdown-preview.nvim", ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.wrap = true
        end,
      })
    end,
    keys = {{ "<leader>m", [[<cmd>MarkdownPreviewToggle<cr>]] }},
  },
  { "Robitx/gp.nvim",
    config = function()
      require("gp").setup({
        providers = {
          anthropic = {
            disable = false,
            secret = { "cat", vim.fn.expand("~/.dotfiles/anthropic.key") },
          },
          openai = {
            disable = false,
            secret = { "cat", vim.fn.expand("~/.dotfiles/openai.key") },
          },
        },
        agents = {
          { name = "ChatClaude-3-5-Sonnet", provider = "anthropic",
            chat = true, command = false,
            model = { model = "claude-3-5-sonnet-latest", temperature = 0.8, top_p = 1 },
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
          { name = "CodeClaude-3-5-Sonnet", provider = "anthropic",
            chat = false, command = true,
            model = { model = "claude-3-5-sonnet-latest", temperature = 0.8, top_p = 1 },
            system_prompt = require("gp.defaults").code_system_prompt,
          },
          { name = "ChatClaude-3-Haiku", disable = true },
          { name = "CodeClaude-3-Haiku", disable = true },
          { name = "ChatGPT4o-mini", disable = true },
          { name = "CodeGPT4o-mini", disable = true },
        },
      })
    end,
    keys = {
      { "\\c", mode = { "n" }, [[:GpChatNew<cr>]] },
      { "\\c", mode = { "x" }, [[:<C-u>'<,'>GpChatNew<cr>]] },
      { "\\v", mode = { "n" }, [[:GpChatToggle<cr>]] },
      { "\\v", mode = { "x" }, [[:<C-u>'<,'>GpChatToggle<cr>]] },
      { "\\p", mode = { "x" }, [[:<C-u>'<,'>GpChatPaste<cr>]] },
      { "\\r", mode = { "x" }, [[:<C-u>'<,'>GpRewrite<cr>]] },
      { "\\i", mode = { "x" }, [[:<C-u>'<,'>GpImplement<cr>]] },
      { "\\a", mode = { "x" }, [[:<C-u>'<,'>GpAppend<cr>]] },
      { "\\b", mode = { "x" }, [[:<C-u>'<,'>GpPrepend<cr>]] },
      { "\\n", mode = { "n", "x" }, [[:GpNextAgent<cr>]] },
      { "\\g", mode = { "n", "x" }, [[:GpChatRespond<cr>]] },
      { "\\s", mode = { "n", "x" }, [[:GpStop<cr>]] },
    },
  },
  { "gnudad/hackernews.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = "HackerNews",
    keys = {{ "<leader>H", [[<cmd>HackerNews<cr>]] }},
  },
  { "fladson/vim-kitty", ft = "kitty" },
  { "mrjones2014/smart-splits.nvim", build = "./kitty/install-kittens.bash",
    config = function()
      require("smart-splits").setup({ at_edge = "stop" })
      local modes = { "n", "i", "x", "c" }
      vim.keymap.set(modes, "<C-h>", require("smart-splits").move_cursor_left)
      vim.keymap.set(modes, "<C-j>", require("smart-splits").move_cursor_down)
      vim.keymap.set(modes, "<C-k>", require("smart-splits").move_cursor_up)
      vim.keymap.set(modes, "<C-l>", require("smart-splits").move_cursor_right)
      vim.keymap.set(modes, "<C-A-h>", require("smart-splits").resize_left)
      vim.keymap.set(modes, "<C-A-j>", require("smart-splits").resize_down)
      vim.keymap.set(modes, "<C-A-k>", require("smart-splits").resize_up)
      vim.keymap.set(modes, "<C-A-l>", require("smart-splits").resize_right)
    end,
  },
  { "mikesmithgh/kitty-scrollback.nvim", config = true,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    event = { "User KittyScrollbackLaunch" },
  },
})
vim.keymap.set("n", "<leader>L", [[<cmd>Lazy<cr>]])

-- Exit insert mode
vim.keymap.set("i", "jk", "<esc>")

-- Clear search highlights
vim.keymap.set("n", "<esc>", [[<cmd>nohlsearch<cr>]])

-- Search in visual selection
vim.keymap.set("x", "/", "<Esc>/\\%V")

-- Select last changed or pasted region
vim.keymap.set("n", "gp", [[ "`[" . getregtype() . "`]" ]], { expr = true })

-- Lazy motions
vim.keymap.set({ "o", "x" }, "ag", "gG", { remap = true })
vim.keymap.set({ "o", "x" }, "q", "iq", { remap = true })
vim.keymap.set({ "o", "x" }, "w", "iw", { remap = true })

-- Fix j/k movements in wrapped lines
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Use Cmd+j/k in command completion popups
vim.keymap.set("c", "<up>",   "<C-p>")
vim.keymap.set("c", "<down>", "<C-n>")

-- Delete buffer without saving/prompt
vim.keymap.set("n", "<leader>k", [[<cmd>bw!<cr>]])
vim.keymap.set("n", "<leader>K", [[<cmd>b#|bw! #<cr>]])

-- Send to terminal
vim.keymap.set({ "n", "x" }, "<leader><cr>", function()
  if vim.fn.mode() == "n" then vim.cmd([[normal V]]) end
  vim.cmd([[normal "vy]])
  local data = vim.fn.shellescape("\x1b[200~" .. vim.fn.getreg("v") .. "\x1b[201~\n")
  os.execute("printf '%s' " .. data .. " | kitty @ send-text --match recent:1 --stdin")
end)

-- Exit quickly without prompts
vim.keymap.set({ "n", "x" }, "Q", [[<cmd>qa!<cr>]]) -- Without saving
vim.keymap.set({ "n", "x" }, "Z", [[<cmd>xa!<cr>]]) -- Save if modified

-- Edit Neovim config
vim.keymap.set("n", "<leader>.", [[<cmd>edit $HOME/.dotfiles/neovim.lua<cr>]])
