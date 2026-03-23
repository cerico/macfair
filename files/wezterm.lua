local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.term = 'xterm-256color'
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Monaco',
}
config.font_size = 15.0
config.line_height = 1.2
config.font_rules = {
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font('JetBrains Mono', { weight = 'Bold' }),
  },
  {
    intensity = 'Normal',
    italic = true,
    font = wezterm.font('JetBrains Mono', { style = 'Italic' }),
  },
  {
    intensity = 'Half',
    italic = false,
    font = wezterm.font('JetBrains Mono', { weight = 'Light' }),
  },
}
config.color_schemes = {
  coffee = {
    foreground = '#ffca28',
    background = '#23262e',
    cursor_fg = '#23262e',
    cursor_bg = '#ee5d43',
    selection_fg = '#00e8c6',
    selection_bg = '#292e38',
    ansi = { '#23262e', '#f0266f', '#8fd46d', '#ffe66d', '#0321d7', '#ee5d43', '#03d6b8', '#c74ded' },
    brights = { '#292e38', '#f92672', '#8fd46d', '#ffe66d', '#03d6b8', '#ee5d43', '#03d6b8', '#c74ded' },
  },
  daegu = {
    foreground = '#fdfdfd',
    background = '#1d1f28',
    cursor_fg = '#1d1f28',
    cursor_bg = '#c574dd',
    selection_fg = '#000000',
    selection_bg = '#c1deff',
    ansi = { '#282a36', '#f37f97', '#5adecd', '#f2a272', '#8897f4', '#c574dd', '#79e6f3', '#fdfdfd' },
    brights = { '#414458', '#ff4971', '#18e3c8', '#ff8037', '#556fff', '#b043d1', '#3fdcee', '#bebec1' },
  },
  liege = {
    foreground = '#ffffff',
    background = '#334789',
    cursor_fg = '#334789',
    cursor_bg = '#fad000',
    selection_fg = '#c2c2c2',
    selection_bg = '#b362ff',
    ansi = { '#000000', '#d90429', '#3ad900', '#ffe700', '#6943ff', '#ff2c70', '#00c5c7', '#c7c7c7' },
    brights = { '#686868', '#f92a1c', '#43d426', '#f1d000', '#6871ff', '#ff77ff', '#79e8fb', '#ffffff' },
  },
  sea = {
    foreground = '#deb88d',
    background = '#09141b',
    cursor_fg = '#09141b',
    cursor_bg = '#fca02f',
    selection_fg = '#fee4ce',
    selection_bg = '#1e4962',
    ansi = { '#17384c', '#d15123', '#027c9b', '#fca02f', '#1e4950', '#68d4f1', '#50a3b5', '#deb88d' },
    brights = { '#434b53', '#d48678', '#628d98', '#fdd39f', '#1bbcdd', '#bbe3ee', '#87acb4', '#fee4ce' },
  },
  kawa = {
    foreground = '#ffffff',
    background = '#b70d4b',
    cursor_fg = '#b70d4b',
    cursor_bg = '#fad000',
    selection_fg = '#c2c2c2',
    selection_bg = '#b362ff',
    ansi = { '#000000', '#d90429', '#3ad900', '#ffe700', '#6943ff', '#ff2c70', '#00c5c7', '#c7c7c7' },
    brights = { '#686868', '#f92a1c', '#43d426', '#f1d000', '#6871ff', '#ff77ff', '#79e8fb', '#ffffff' },
  },
  asda = {
    foreground = '#ffffff',
    background = '#2f2d76',
    cursor_fg = '#2f2d76',
    cursor_bg = '#fad000',
    selection_fg = '#c2c2c2',
    selection_bg = '#b362ff',
    ansi = { '#000000', '#ff757d', '#3dd605', '#ffe700', '#6943ff', '#f02d6c', '#00c5c7', '#c7c7c7' },
    brights = { '#686868', '#ff757d', '#75ff8a', '#f1d000', '#6871ff', '#ff77ff', '#75ffe9', '#ffffff' },
  },
  forest = {
    foreground = '#d6e7d6',
    background = '#161e16',
    cursor_fg = '#161e16',
    cursor_bg = '#7cbd7c',
    selection_fg = '#161e16',
    selection_bg = '#334c33',
    ansi = { '#223122', '#d45f5f', '#7cbd7c', '#caca6e', '#6e95b1', '#b195b1', '#6eb195', '#d6e7d6' },
    brights = { '#293b29', '#fe7272', '#95e383', '#f2f284', '#6e95b1', '#b195b1', '#6eb195', '#ffffff' },
  },
  gruvbox = {
    foreground = '#d5c4a1',
    background = '#282828',
    cursor_fg = '#282828',
    cursor_bg = '#d5c4a1',
    selection_fg = '#282828',
    selection_bg = '#504945',
    ansi = { '#282828', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#d5c4a1' },
    brights = { '#665c54', '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#fbf1c7' },
  },
  peacock = {
    foreground = '#bbc2cf',
    background = '#1c1f24',
    cursor_fg = '#1c1f24',
    cursor_bg = '#bbc2cf',
    selection_fg = '#1c1f24',
    selection_bg = '#3f444a',
    ansi = { '#1c1f24', '#ff6c6b', '#98be65', '#ecbe7b', '#51afef', '#c678dd', '#46d9ff', '#bbc2cf' },
    brights = { '#5b6268', '#da8548', '#4db5bd', '#ecbe7b', '#2257a0', '#a9a1e1', '#00b8d4', '#dfdfdf' },
  },
  sunset = {
    foreground = '#ffdead',
    background = '#291217',
    cursor_fg = '#291217',
    cursor_bg = '#ff9966',
    selection_fg = '#291217',
    selection_bg = '#663333',
    ansi = { '#492028', '#ff6666', '#f4d03f', '#ffc107', '#b080a7', '#ff94b1', '#f2be69', '#ffdead' },
    brights = { '#572630', '#ff7a7a', '#fffa4b', '#ffe808', '#d39ac8', '#ffb1d4', '#f2be69', '#ffffd0' },
  },
  midnight = {
    foreground = '#c0d1e9',
    background = '#0a0a14',
    cursor_fg = '#0a0a14',
    cursor_bg = '#6699ff',
    selection_fg = '#0a0a14',
    selection_bg = '#1a1a4c',
    ansi = { '#141428', '#dc322f', '#27ae60', '#f3c227', '#2877f0', '#9370db', '#3498db', '#c0d1e9' },
    brights = { '#181830', '#ff3c38', '#2ed173', '#ffe92e', '#308fff', '#b086ff', '#3498db', '#e7fbff' },
  },
  mocha = {
    foreground = '#cdd6f4',
    background = '#1e1e2e',
    cursor_fg = '#1e1e2e',
    cursor_bg = '#f5e0dc',
    selection_fg = '#cdd6f4',
    selection_bg = '#585b70',
    ansi = { '#45475a', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#f5c2e7', '#94e2d5', '#bac2de' },
    brights = { '#585b70', '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#f5c2e7', '#94e2d5', '#a6adc8' },
  },
  cherry = {
    foreground = '#ffe0f0',
    background = '#1e0f14',
    cursor_fg = '#1e0f14',
    cursor_bg = '#f080a8',
    selection_fg = '#1e0f14',
    selection_bg = '#4c2633',
    ansi = { '#3c1e28', '#db6193', '#add69e', '#f5deb3', '#ad81a8', '#db7093', '#8fbcbb', '#ffe0f0' },
    brights = { '#482430', '#ff86b0', '#d0ffbe', '#ffffd7', '#d09bca', '#ff86b0', '#8fbcbb', '#ffffff' },
  },
}
config.color_scheme = 'coffee'
config.window_background_opacity = 0.80
config.macos_window_background_blur = 20
config.inactive_pane_hsb = { saturation = 0.8, brightness = 0.7 }
config.window_decorations = 'TITLE | RESIZE'
config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.colors = {
  split = '#ffffff',
  tab_bar = {
    background = '#1a1a1a',
    active_tab = {
      bg_color = '#ffca28',
      fg_color = '#000000',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#1a1a1a',
      fg_color = '#666666',
    },
    inactive_tab_hover = {
      bg_color = '#2a2a2a',
      fg_color = '#aaaaaa',
    },
    new_tab = {
      bg_color = '#1a1a1a',
      fg_color = '#666666',
    },
    new_tab_hover = {
      bg_color = '#2a2a2a',
      fg_color = '#aaaaaa',
    },
  },
}

config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'PrimarySelection',
  },
}

config.keys = {
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString '\x1b[13;2u' },
  { key = '|', mods = 'LEADER|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = 'n', mods = 'SUPER', action = wezterm.action.SpawnCommandInNewWindow { cwd = wezterm.home_dir } },
  { key = ' ', mods = 'SUPER', action = wezterm.action_callback(function(window, pane)
    local home = wezterm.home_dir
    local history_file = home .. '/.dir_history'
    local f = io.open(history_file, 'r')
    if not f then return end
    local choices = {}
    for line in f:lines() do
      local label = line:gsub('^' .. home, '~')
      table.insert(choices, { id = line, label = label })
    end
    f:close()
    window:perform_action(wezterm.action.InputSelector {
      title = 'Jump to directory',
      fuzzy = true,
      choices = choices,
      action = wezterm.action_callback(function(_, _, id, label)
        if id then
          pane:send_text('cd ' .. id .. '\n')
        end
      end),
    }, pane)
  end) },
}

local function get_pane_info(pane)
  local process = pane.foreground_process_name or ''
  local proc = process:match('[^/]+$') or 'shell'
  local cwd = ''
  local url = pane.current_working_dir
  if url then
    local dir = type(url) == 'userdata' and url.file_path or tostring(url)
    dir = dir:gsub('^file://[^/]*', ''):gsub('/$', '')
    local home = os.getenv('HOME') or ''
    if dir == home then
      cwd = '~'
    else
      cwd = dir:match('[^/]+$') or dir
    end
  end
  return proc, cwd
end

wezterm.on('format-window-title', function(tab)
  local proc, cwd = get_pane_info(tab.active_pane)
  return cwd ~= '' and cwd or proc
end)

wezterm.on('format-tab-title', function(tab)
  local proc, cwd = get_pane_info(tab.active_pane)
  local index = tab.tab_index + 1
  return string.format(' %d %s %s ', index, proc, cwd)
end)

wezterm.on('user-var-changed', function(window, _, name, _)
  if name == 'focus' then
    window:focus()
  end
end)

return config
