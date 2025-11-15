-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
function prepend_debug_lines_if_not_present()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local line1 = "require 'debug/session'"
  local line2 = "DEBUGGER__.open_tcp(port: 38_698, host: '127.0.0.1')"
  local firstlines = vim.api.nvim_buf_get_lines(current_bufnr, 0, 2, false)
  if firstlines[1] ~= line1 and firstlines[2] ~= line2 then
    vim.api.nvim_buf_set_lines(current_bufnr, 0, 0, false, { line1, line2, '' })
  end
end

function remove_debug_lines_if_present()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local line1 = "require 'debug/session'"
  local line2 = "DEBUGGER__.open_tcp(port: 38_698, host: '127.0.0.1')"
  local firstlines = vim.api.nvim_buf_get_lines(current_bufnr, 0, 2, false)
  if firstlines[1] == line1 and firstlines[2] == line2 then
    vim.api.nvim_buf_set_lines(current_bufnr, 0, 3, false, {})
  end
end

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
    'loverude/nvim-dap-ruby',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<leader>1',
      function()
        prepend_debug_lines_if_not_present()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<leader>1',
      function()
        require('dap').run_to_cursor()
      end,
      desc = 'Debug: Run to Cursor',
    },
    {
      '<leader>3',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<leader>4',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<leader>5',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>6',
      function()
        require('dap').step_back()
      end,
      desc = 'Debug: Step Back',
    },
    {
      '<leader>7',
      function()
        require('dap').terminate()
      end,
      desc = 'Debug: Terminate',
    },
    {
      '<leader>8',
      function()
        require('dap').disconnect()
      end,
      desc = 'Debug: Disconnect',
    },
    {
      '<leader>9',
      function()
        require('dap').close()
        remove_debug_lines_if_present()
      end,
      desc = 'Debug UI: Close UI',
    },
    {
      '<leader>0',
      function()
        require('dap').pause()
      end,
      desc = 'Debug: Pause',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
        prepend_debug_lines_if_not_present()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        prepend_debug_lines_if_not_present()
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<leader>=',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('dap-ruby').setup()

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    require('dapui').setup {
      layouts = {
        {
          elements = {
            { id = 'watches', size = 0.2 },
            { id = 'stacks', size = 0.2 },
            { id = 'breakpoints', size = 0.2 },
            { id = 'scopes', size = 0.4 },
          },
          size = 40, -- width of 40
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 15, -- height of 15
          position = 'bottom',
        },
      },

      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = ' ',
          play = ' ',
          step_into = ' ',
          step_over = ' ',
          step_out = ' ',
          step_back = ' ',
          run_last = ' ',
          terminate = ' ',
          disconnect = ' ',
        },
      },
    }

    -- Evaluate a past variable in the debugger just by mousing over it
    vim.keymap.set('n', '<leader>/', function()
      require('dapui').eval(nil, { enter = true })
    end)

    -- Reset debug UI
    vim.keymap.set('n', '<leader>dr', ":lua require('dapui').open({reset = true})<CR>", { noremap = true })

    vim.api.nvim_set_hl(0, 'DapUIPlayPauseNC', { fg = 'lightgreen' })
    vim.api.nvim_set_hl(0, 'DapUIStepIntoNC', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIStepOverNC', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIStepOutNC', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIStepBackNC', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIRestartNC', { fg = 'lightgreen' })
    vim.api.nvim_set_hl(0, 'DapUIStopNC', { fg = '#fa3f4c' })

    vim.api.nvim_set_hl(0, 'DapUIPlayPause', { fg = 'lightgreen' })
    vim.api.nvim_set_hl(0, 'DapUIStepInto', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIStepOver', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIStepOut', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIStepBack', { fg = '#3ea6ff' })
    vim.api.nvim_set_hl(0, 'DapUIRestart', { fg = 'lightgreen' })
    vim.api.nvim_set_hl(0, 'DapUIStop', { fg = '#fa3f4c' })

    vim.api.nvim_set_hl(0, 'winbarNC', { fg = '#333333' })
    vim.api.nvim_set_hl(0, 'winbar', { fg = '#333333' })

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#6ac44c', fg = '#333333' })

    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      if type == 'Stopped' then
        vim.fn.sign_define(tp, { text = icon, texthl = 'DapStop', linehl = 'DapStoppedLine', numhl = 'DapStop' })
      else
        vim.fn.sign_define(tp, { text = icon, texthl = 'DapBreak', numhl = 'DapBreak' })
      end
    end

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
