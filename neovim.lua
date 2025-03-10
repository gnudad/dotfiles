---@diagnostic disable: missing-fields, unused-local
vim.g.mapleader = " "

vim.o.cmdheight = 0
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.formatoptions = "crqnlj"
vim.o.ignorecase = true
vim.o.laststatus = 3
vim.o.linebreak = true
vim.o.pumheight = 7
vim.o.scrolloff = 5
vim.o.shiftwidth = 4
vim.o.sidescrolloff = 5
vim.o.signcolumn = "yes"
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 4
vim.o.textwidth = 88
vim.o.title = true
vim.o.titlestring = "(%{hostname()}) %{fnamemodify(getcwd(), ':t')}"
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
  { "LunarVim/bigfile.nvim" },
  { "tpope/vim-sleuth",
    config = function()
      for _, ft in pairs({ "css", "html", "javascript", "lua" }) do
        vim.g["sleuth_" .. ft .. "_defaults"] = "shiftwidth=2 tabstop=2"
      end
      for _, ft in pairs({ "go", "php" }) do
        vim.g["sleuth_" .. ft .. "_defaults"] = "noexpandtab"
      end
    end,
  },
  { "lewis6991/gitsigns.nvim", event = "BufReadPost",
    config = function()
      local gs = require("gitsigns")
      gs.setup({})
      local function get_range() return { vim.fn.line("."), vim.fn.line("v") } end
      vim.keymap.set({ "n", "x", "o" }, "[g", function() gs.nav_hunk("prev") end)
      vim.keymap.set({ "n", "x", "o" }, "]g", function() gs.nav_hunk("next") end)
      vim.keymap.set({ "o", "x" }, "ig", [[:<C-u>Gitsigns select_hunk<cr>]])
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
    cmd = "Neogit",
    keys = {{ "<leader>gg", [[<cmd>silent! wa<cr><cmd>Neogit kind=replace<cr>]] }},
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
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "jvgrootveld/telescope-zoxide" },
    },
    config = function()
      local actions = require("telescope.actions")
      local state = require("telescope.actions.state")
      local no_ignore = false
      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          file_ignore_patterns = { ".DS_Store", ".git/", ".venv/" },
          mappings = {
            i = {
              ["<esc>"] = require("telescope.actions").close,
              ["<C-.>"] = function(prompt_bufnr)
                no_ignore = not no_ignore
                actions.close(prompt_bufnr)
                require("telescope.builtin").find_files({
                  default_text=state.get_current_line(),
                  hidden=true, no_ignore=no_ignore,
                })
              end,
              ["<C-->"] = function(prompt_bufnr) -- Open Oil directory listing
                actions.close(prompt_bufnr)
                local dir = state.get_selected_entry().value
                if vim.fn.isdirectory(dir) == 0 then
                  dir = vim.fn.fnamemodify(dir, ":h")
                end
                vim.api.nvim_set_current_dir(dir)
                vim.cmd("Oil " .. dir)
              end,
              ["<C-g>"] = function(prompt_bufnr) -- Open Neogit status
                actions.close(prompt_bufnr)
                local dir = state.get_selected_entry().value
                if vim.fn.isdirectory(dir) == 0 then
                  dir = vim.fn.fnamemodify(dir, ":h")
                end
                vim.api.nvim_set_current_dir(dir)
                vim.cmd("Neogit kind=replace cwd=" .. dir)
              end,
              ["<C-t>"] = require("trouble.sources.telescope").open,
            },
          },
        },
        pickers = {
          buffers = {
            mappings = {
              i = {
                ["<C-d>"] = require("telescope.actions").delete_buffer,
              },
            },
          },
        },
        extensions = {
          fzf = { fuzzy = false },
          zoxide = {
            mappings = {
              default = { action = function(selection) vim.cmd.edit(selection.path) end },
              ["<C-d>"] = {
                action = function(selection) vim.fn.system("zoxide remove " .. selection.path) end,
                after_action = function() vim.cmd([[Telescope zoxide list]]) end,
              },
            },
          },
        },
      })
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("projects")
      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("yank_history")
      require("telescope").load_extension("zoxide")
    end,
    keys = {
      { "<leader>p", [[<cmd>Telescope projects<cr>]] },
      { "<leader>f", [[<cmd>Telescope find_files hidden=true<cr>]] },
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
    ft = { "go", "html", "javascript", "json", "lua", "php", "python", "yaml" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "golangci_lint_ls", -- +"golangci-lint"
          "gopls",
          "intelephense",
          "jsonls",
          "lua_ls",
          "pyright",
          "ruff",
          "yamlls",
        },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
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
              on_attach = function(client, bufnr)
                -- Prevent "No information available" from ruff on vim.lsp.buf.hover()
                client.server_capabilities.hoverProvider = false
              end,
            })
          end,
        },
      })
      vim.keymap.set("n", "ge", vim.diagnostic.open_float)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
      vim.keymap.set("n", "<leader>li", [[<cmd>silent check lspconfig<cr>]])
      vim.keymap.set("n", "<leader>lr", [[<cmd>LspRestart<cr>]])
      vim.keymap.set("n", "<leader>dt", function()
        vim.diagnostic.config({
          virtual_text = not vim.diagnostic.config().virtual_text,
        })
      end)
      vim.diagnostic.config({ severity_sort = true, signs = false })
      vim.keymap.set({ "n", "i" }, "<C-s>", function() vim.lsp.buf.signature_help() end)
    end
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
    keys = {{ "ga", function() require("tiny-code-action").code_action({}) end }},
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
    ft = { "go" },
    opts = {
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype ~= "go" then return end
        return { timeout_ms = 500, lsp_format = "fallback" }
      end,
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
  { "saghen/blink.cmp", version = 'v0.*', event = "InsertEnter",
    config = function()
      require("blink-cmp").setup({
        keymap = { preset = "super-tab" },
        sources = {
          providers = {
            buffer = { score_offset = -7 },
            lsp = { fallbacks = {} }, -- Always show buffer items
          },
        },
        completion = {
          accept = {
            auto_brackets = {
              enabled = true,
              semantic_token_resolution = { enabled = false },
            },
          },
          documentation = { auto_show = true },
        },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "normal",
        },
        signature = { enabled = true },
      })
    end,
  },
  { "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    opts = {
      jsonFormatter = "jq",
      backdrop = { enabled = false },
    },
    keys = {
      { "<leader>sa", mode = { "n", "x" }, [[<cmd>ScissorsAddNewSnippet<cr>]] },
      { "<leader>se", [[<cmd>silent ScissorsEditSnippet<cr>]] },
    },
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
      require("leap.user").set_repeat_keys("<enter>", "<backspace>")
    end,
    keys = {
      { "s", [[<Plug>(leap)]], mode = { "n", "x", "o" } },
      { "S", [[<Plug(leap-from-window)]] },
    },
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
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
    ft = function() return require("nvim-treesitter.parsers").available_parsers() end,
    config = function()
      require("treesitter-context").setup({ enable = false })
      vim.keymap.set("n", "<leader>`", [[<cmd>TSContextToggle<cr>]])
      vim.keymap.set("n", "[`", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end)
    end,
  },
  { "nvim-treesitter/nvim-treesitter-textobjects",
    ft = function() return require("nvim-treesitter.parsers").available_parsers() end,
    config = function()
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
  { "chrisgrieser/nvim-various-textobjs",
    config = function()
      require("various-textobjs").setup({
        keymaps = {
          useDefaults = true,
          disabledDefaults = { "g", "n", "r" },
        },
      })
      vim.keymap.set({ "o", "x" }, "ag", "gG", { remap = true })
    end,
  },
  { "wellle/targets.vim" },
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "windwp/nvim-ts-autotag", config = true, ft = { "html", "php", "phtml", "xml" } },
  { "utilyre/sentiment.nvim", event = "VeryLazy", config = true },
  { "folke/todo-comments.nvim", event = "BufReadPost",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup({})
      vim.keymap.set("n", "[t", require("todo-comments").jump_prev)
      vim.keymap.set("n", "]t", require("todo-comments").jump_next)
    end,
    keys = {
      { "<leader>tt", [[<cmd>TodoTrouble<cr>]] },
      { "<leader>tT", [[<cmd>TodoTelescope<cr>]] },
    },
  },
  { "kylechui/nvim-surround", config = true, keys = {
      "ys", "ds", "cs", { "S", mode = { "x" } },
  }},
  { "Wansmer/treesj",
    opts = { use_default_keymaps = false },
    keys = {{ "<leader>j", [[<cmd>TSJSplit<cr>]] },
            { "<leader>J", [[<cmd>TSJJoin<cr>]] }},
  },
  { "chrishrb/gx.nvim", submodules = false, config = true,
    keys = {{ "gx", mode = { "n", "x" }, [[<cmd>Browse<cr>]] }},
  },
  { "tzachar/highlight-undo.nvim", config = true, keys = {{ "u" }} },
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
      require("ufo").setup({
        provider_selector = function() return { "treesitter", "indent" } end,
      })
      vim.schedule(function()
        vim.keymap.del("n", "zc")
        vim.keymap.set("n", "zm", require("ufo").closeFoldsWith)
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
        vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
        vim.keymap.set("n", "zR", require("ufo").openAllFolds)

      end)
      vim.api.nvim_set_hl(0, "Folded", {})
      vim.api.nvim_set_hl(0, "UfoFoldedEllipsis", { link = "FloatTitle" })
    end,
    keys = {
      { "zc", function() vim.defer_fn(function() vim.cmd([[normal zc]]) end, 100) end },
      { "zm", function()
          local vcount = vim.v.count
          vim.defer_fn(function() require("ufo").closeFoldsWith(vcount) end, 100)
        end
      },
    },
  },
  { "cdmill/focus.nvim",
    config = true,
    keys = {
      { "<leader>n", [[:Narrow<cr>]], mode = { "n" } },
      { "<leader>n", [[:'<,'>Narrow<cr>]], mode = { "x" } },
      { "<leader>Z", [[:Zen<cr>]] },
    },
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
    build = [[cd app && npm install && git restore .]],
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
  { "frankroeder/parrot.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("parrot").setup({
        chat_free_cursor = true,
        chat_user_prefix = "💬:",
        llm_prefix = "🤖:",
        providers = {
          anthropic = { api_key = { "cat", vim.fn.expand("~/.dotfiles/anthropic.key") } },
          gemini = { api_key = { "cat", vim.fn.expand("~/.dotfiles/gemini.key") } },
          openai = { api_key = { "cat", vim.fn.expand("~/.dotfiles/openai.key") } },
          deepseek = {
            style = "openai",
            api_key = { "cat", vim.fn.expand("~/.dotfiles/deepseek.key") },
            endpoint = "https://api.deepseek.com/v1/chat/completions",
            models = {
              "deepseek-chat",
              "deepseek-reasoner",
            },
            params = {
              chat = { temperature = 0.3, top_p = 0.7 },
              command = { temperature = 0.3, top_p = 0.7 },
            },
            topic_prompt = "You only respond with 3 to 4 words to summarize the past conversation.",
            topic = {
              name = "deepseek",
              model = "deepseek-chat",
              params = { max_completion_tokens = 64 },
            },
          },
        },
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*/parrot/chats/*.md",
        callback = function()
          vim.schedule(function()
            vim.keymap.set("n", "<cr>", [[<cmd>PrtChatResponde<cr>]], { buffer = true })
            vim.keymap.set("n", "<esc>", [[<cmd>PrtChatStop<cr>]], { buffer = true })
            vim.keymap.set({ "n", "x", "o" }, "[[", [[?^\(💬:\|🤖:\)<cr>]], { buffer = true })
            vim.keymap.set({ "n", "x", "o" }, "]]", [[/^\(💬:\|🤖:\)<cr>]], { buffer = true })
          end)
        end,
      })
    end,
    keys = {
      { "<leader>an", mode = { "n" }, [[:PrtChatNew<cr>]] },
      { "<leader>an", mode = { "x" }, [[:<C-u>'<,'>PrtChatNew<cr>]] },
      { "<leader>av", mode = { "n" }, [[:PrtChatToggle<cr>]] },
      { "<leader>av", mode = { "x" }, [[:<C-u>'<,'>PrtChatToggle<cr>]] },
      { "<leader>ap", mode = { "x" }, [[:<C-u>'<,'>PrtChatPaste<cr>]] },
      { "<leader>am", mode = { "n", "x" }, [[:PrtProvider<cr>]] },
      { "<leader>aM", mode = { "n", "x" }, [[:PrtModel<cr>]] },
      { "<leader>as", mode = { "n", "x" }, [[:PrtStatus<cr>]] },
      { "<leader>ar", mode = { "x" }, [[:<C-u>'<,'>PrtRewrite<cr>]] },
      { "<leader>ae", mode = { "n", "x" }, [[:<C-u>'<,'>PrtEdit<cr>]] },
      { "<leader>aa", mode = { "n" }, [[:PrtAppend<cr>]] },
      { "<leader>aa", mode = { "x" }, [[:<C-u>'<,'>PrtAppend<cr>]] },
      { "<leader>ab", mode = { "n" }, [[:PrtPrepend<cr>]] },
      { "<leader>ab", mode = {  "x" }, [[:<C-u>'<,'>PrtPrepend<cr>]] },
      { "<leader>aR", mode = { "n", "x" }, [[:<C-u>'<,'>PrtRetry<cr>]] },
      { "<leader>ai", mode = { "x" }, [[:<C-u>'<,'>PrtImplement<cr>]] },
    },
  },
  { "gnudad/hackernews.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = "HackerNews",
    keys = {{ "<leader>H", [[<cmd>HackerNews<cr>]] }},
  },
  { "tadaa/vimade", event = "VeryLazy",
    opts = { ncmode = "windows", fadelevel = 0.7 },
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
vim.keymap.set("x", "//", "<Esc>/\\%V")

-- Select last changed or pasted region
vim.keymap.set("n", "gp", [[ "`[" . getregtype() . "`]" ]], { expr = true })

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
