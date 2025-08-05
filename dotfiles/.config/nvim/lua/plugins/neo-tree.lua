return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,           -- Show filtered (hidden) items as dimmed
        show_hidden_count = true, -- (optional) shows hidden counts
        hide_dotfiles = false,    -- Don't actually hide dotfiles
        hide_gitignored = true,   -- Optionally hide gitignored files (can set to false)
        hide_by_name = {},        -- Explicitly list files/folders to hide
        never_show = {},          -- Never show these files/folders
      },
    },
  },
}
