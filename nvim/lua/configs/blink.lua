-- Overrides layered on top of `nvchad.blink.config` (see plugins/init.lua).
-- The lazyspec declares opts_extend = { "sources.default" }, so the list
-- below is unioned with nvChad's { lsp, snippets, buffer, path } rather
-- than replacing it.

return {
  -- Ghost text was on in EcoVim. Comment out if it gets noisy.
  ghost_text = { enabled = true },

  -- Avante registers these through nvim-cmp's source API during setup;
  -- blink.compat forwards the registrations to blink. High score_offset so
  -- @-mentions outrank ordinary LSP completions.
  --
  -- NOTE: avante also lists an "avante_files" source in its own
  -- cmp.setup.filetype call but never registers it, so it is not wired up
  -- here -- blink errors on unknown source names.
  --
  -- If @-completion misbehaves, set debug = true on the blink.compat spec
  -- in plugins/init.lua to see which source failed to register.
  sources = {
    default = { "avante_mentions", "avante_commands" },
    providers = {
      avante_mentions = {
        name = "avante_mentions",
        module = "blink.compat.source",
        score_offset = 1000,
        opts = {},
      },
      avante_commands = {
        name = "avante_commands",
        module = "blink.compat.source",
        score_offset = 90,
        opts = {},
      },
    },
  },

  completion = {
    -- nvChad's kind icons are double-width, which throws the menu columns
    -- out of alignment. Right-side-only padding fixes it.
    -- https://github.com/NvChad/NvChad/discussions/3244
    menu = { draw = { padding = { 0, 1 } } },
  },
}
