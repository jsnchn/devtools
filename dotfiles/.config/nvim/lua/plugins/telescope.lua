return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    -- Ensure hidden files show by default in file picker
    opts.pickers = opts.pickers or {}
    opts.pickers.find_files = vim.tbl_deep_extend("force",
      opts.pickers.find_files or {},
      {
        hidden = true,
      }
    )

    -- Always search hidden files with live_grep, but ignore .git/
    opts.defaults = opts.defaults or {}
    opts.defaults.vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",        -- Include hidden files
      "--glob", "!.git/",-- Exclude .git folder
    }

    -- Optional: Custom mappings in Telescope prompt
    opts.defaults.mappings = opts.defaults.mappings or {}
    opts.defaults.mappings.i = opts.defaults.mappings.i or {}
    opts.defaults.mappings.i["<S-h>"] = function(prompt_bufnr)
      local action_state = require("telescope.actions.state")
      local line = action_state.get_current_line()
      require("telescope.builtin").find_files({ hidden = true, default_text = line })
    end

    return opts
  end,
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
  },
}
