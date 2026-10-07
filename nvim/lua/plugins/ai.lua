return {
  -- ── GitHub Copilot auth ───────────────────────────────────────────────
  -- Avante's copilot provider reads the token that copilot.lua writes to
  -- ~/.config/github-copilot/hosts.json. Declaring it as an avante
  -- dependency is not enough on its own -- something has to call setup(),
  -- otherwise :Copilot auth does not exist.
  --
  -- Run :Copilot auth once after installing.
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    -- VeryLazy so setup() runs before avante's own copilot check at its
    -- VeryLazy load; a cmd-only dep does not reliably configure in time,
    -- which surfaced as "You must setup copilot with either copilot.lua
    -- or copilot.vim".
    event = "VeryLazy",
    config = function()
      require("copilot").setup {
        -- v2 defaults auto_trigger to false; without it copilot never
        -- suggests. hide_during_completion keeps ghost away while the
        -- blink menu is open (default, stated for clarity).
        suggestion = {
          auto_trigger = true,
          hide_during_completion = true,
        },
        server_opts_overrides = {
          settings = {
            ["github"] = { endpoint = "https://api.githubcopilot.com" },
          },
        },
      }

      -- avante's copilot provider reads only hosts.json, but copilot.lua
      -- v2 stores the OAuth token in sqlite auth.db. Re-export it so the
      -- avante provider keeps working; autocomplete is unaffected (it uses
      -- copilot's own LSP). Skips when hosts.json is current; failures
      -- surface as a notification with the sqlite3 error.
      local function export_hosts_for_avante()
        -- Must match avante's get_oauth_token(): it joins <config>/github-copilot
        -- where <config> is $XDG_CONFIG_HOME, else ~/.config. stdpath("config")
        -- is wrong here -- it is ~/.config/nvim, so the bridge was writing to
        -- a path the provider never reads.
        local config_dir = vim.env.XDG_CONFIG_HOME
        if not config_dir or vim.fn.isdirectory(config_dir) == 0 then config_dir = vim.fn.expand "~/.config" end
        local copilot_dir = config_dir .. "/github-copilot"
        local db, hosts = copilot_dir .. "/auth.db", copilot_dir .. "/hosts.json"

        if vim.fn.filereadable(db) == 0 then
          vim.notify("avante bridge: no auth.db at " .. db, vim.log.levels.WARN, { title = "copilot" })
          return
        end
        -- Token refreshes land in the WAL, so auth.db's own mtime stays stale.
        -- The WAL is the real freshness signal.
        local newest = math.max(vim.fn.getftime(db), vim.fn.getftime(db .. "-wal"))
        if vim.fn.filereadable(hosts) == 1 and vim.fn.getftime(hosts) >= newest then return end
        if vim.fn.executable("sqlite3") == 0 then
          vim.notify("avante bridge: sqlite3 not on PATH", vim.log.levels.WARN, { title = "copilot" })
          return
        end

        -- copilot.lua v2 has no `auth` table; the token lives in
        -- oauth_tokens.token_ciphertext (plaintext here, not encrypted).
        local sql = table.concat({
          "SELECT json_object('github.com', json_object(",
          "'user', user_login,",
          "'oauth_token', CAST(token_ciphertext AS TEXT)",
          ")) FROM oauth_tokens",
          "WHERE auth_authority = 'github.com'",
          "ORDER BY updated_at DESC LIMIT 1;",
        }, " ")
        local cmd = "sqlite3 " .. vim.fn.shellescape(db) .. " " .. vim.fn.shellescape(sql) .. " 2>&1"
        local out = vim.fn.system(cmd)

        if vim.v.shell_error ~= 0 then
          vim.notify("avante bridge failed: " .. out, vim.log.levels.WARN, { title = "copilot" })
          return
        end
        if vim.trim(out) == "" then
          vim.notify("avante bridge: no github.com row in oauth_tokens", vim.log.levels.WARN, { title = "copilot" })
          return
        end

        vim.fn.mkdir(copilot_dir, "p")
        local f = io.open(hosts, "w")
        if f then
          f:write(out)
          f:close()
          vim.notify("avante bridge: hosts.json exported from auth.db", vim.log.levels.INFO, { title = "copilot" })
        end
      end
      export_hosts_for_avante()
    end,
  },

  -- ── Avante ────────────────────────────────────────────────────────────
  -- Chat sidebar, diff-based edits, repo-map context. Registers its
  -- @-mention completion sources through cmp's API; blink.compat bridges
  -- those (see configs/blink.lua).
  --
  -- build = false, not `build = "make"`: lazy prefers a luarocks rockspec
  -- when no build is given, and that rockspec shells out to cargo. rustc on
  -- this box is broken (librustc_driver: undefined symbol, version LLVM_23.1),
  -- so the rock build dies and the plugin never lands.
  --
  -- The Rust build only produces avante_tokenizers, which
  -- lua/avante/tokenizers.lua loads via pcall and treats as optional
  -- (`if not ok then return nil end`). Skipping it costs nothing.
  {
    "yetone/avante.nvim",
    build = false,
    event = "VeryLazy",
    opts = {
      provider = "copilot",
      mode = "agentic",
      auto_suggestions_provider = "copilot",
      behaviour = {
        auto_apply_diff_after_generation = false,
        auto_focus_sidebar = true,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_suggestions = false,
        enable_cursor_planning_mode = true,
        jump_result_buffer_on_finish = false,
        minimize_diff = true,
        support_paste_from_clipboard = true,
      },
      hints = { enabled = true },
      providers = {
        copilot = {
          model = "claude-opus-4.5",
          disable_tools = false,
        },
      },
    },
    -- pcall'd because a missing/invalid Copilot login makes setup throw,
    -- and an unhandled error in a VeryLazy plugin breaks the rest of the
    -- startup sequence.
    config = function(_, opts)
      local ok, err = pcall(require("avante").setup, opts)
      if not ok then
        vim.schedule(function()
          vim.notify("avante: " .. tostring(err), vim.log.levels.WARN, { title = "avante" })
        end)
      end
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      { "HakonHarnes/img-clip.nvim", event = "VeryLazy" },
      "MeanderingProgrammer/render-markdown.nvim",
      -- Required since avante switched its command parser; if cmdparse is
      -- missing the plugin/avante.lua source fails with
      -- "module 'mega.cmdparse' not found".
      { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
    },
  },

  -- sudo-tee fork, not nickjvandyke's: this one has ask()/select(), the
  -- :Opencode command and the per-session keymaps. Both repos name their
  -- plugin dir "opencode.nvim", so only one can be installed.
  --
  -- Detects blink (completion) and telescope (picker) on its own, so
  -- snacks.nvim is not required.
  {
    "sudo-tee/opencode.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "Avante", "opencode_output" },
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
      },
    },
    config = function()
      require("opencode").setup {
        keymap = {
          editor = {
            ["<leader>og"] = { "toggle" }, -- Open opencode. Close if opened
          },
        },
      }
    end,
  },
}
