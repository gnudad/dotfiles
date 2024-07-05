-- Download Spoons, if required
local f = io.open("Spoons/EmmyLua.spoon/annotations/hs.lua")
if f ~= nil then io.close(f) else
  hs.alert("Downloading Spoons")
  os.execute([[
    mkdir -p Spoons && cd Spoons &&
    git clone https://github.com/jasonrudolph/ControlEscape.spoon.git
    git clone https://github.com/gnudad/Rectangle.spoon.git
    git clone https://github.com/gnudad/Rcmd.spoon.git
    curl -LO https://github.com/Hammerspoon/Spoons/raw/master/Spoons/EmmyLua.spoon.zip &&
    unzip ~/.config/hammerspoon/Spoons/EmmyLua.spoon.zip &&
    rm ~/.config/hammerspoon/Spoons/EmmyLua.spoon.zip && cd -
  ]])
  -- Hammerspoon annotations for lua language server
  hs.loadSpoon("EmmyLua")
end

-- Caps Lock acts as Esc when tapped, Ctrl when held
---@diagnostic disable-next-line: undefined-field
hs.loadSpoon("ControlEscape"):start()

-- Move and resize windows
local mods = { "ctrl", "cmd" }
---@diagnostic disable-next-line: undefined-field
hs.loadSpoon("Rectangle"):bindHotkeys({
  top_left    = { mods, "q" },  top_half    = { mods, "w" },  top_right    = { mods, "e" },
  left_half   = { mods, "a" },  center_half = { mods, "s" },  right_half   = { mods, "d" },
  bottom_left = { mods, "z" },  bottom_half = { mods, "x" },  bottom_right = { mods, "c" },
  maximize    = { mods, "f" },  almost_max  = { mods, "g" },
  center      = { mods, "0" },  smaller     = { mods, "-" },  larger       = { mods, "=" },
})

-- Switch apps using the right command key
---@diagnostic disable-next-line: undefined-field
hs.loadSpoon("Rcmd"):bindHotkeys({
  a = "Mail",
  A = function() -- Copy Mail.app message link to clipboard
    local script = [[
      tell application "Mail"
        set emails to selection
        set email to item 1 of emails
        set msgid to message id of email
        set subj to subject of email
        set the clipboard to "✉️ " & subj & "\nmessage://%3c" & msgid & "%3e"
      end tell
    ]]
    hs.osascript.applescript(script)
    hs.alert("Copied email link to clipboard")
  end,
  c = "Calendar",
  d = "Things3",
  e = "Microsoft Excel",
  f = "Finder",
  g = "Google Chrome",
  h = "Hammerspoon",
  k = function() hs.application.frontmostApplication():hide() end,
  m = "Music",
  n = "Notion",
  o = "OTP Manager",
  p = "Pritunl",
  P = "Photos",
  q = "Safari",
  r = "Microsoft Remote Desktop",
  s = "TablePlus",
  t = "Microsoft Teams",
  w = "kitty",
  x = "FileZilla",
  z = "Messages",
}):start()

-- Vim Keybinds
local function vimBind(bindKey, mods, key)
  local stroke = function() hs.eventtap.keyStroke(mods, key, 0) end
  local bindMods = { "cmd" }
  if string.lower(bindKey) ~= bindKey then
    table.insert(bindMods, "shift")
  end
  hs.hotkey.bind(bindMods, bindKey, stroke, nil, stroke)
end
vimBind("h", "", "left")
vimBind("j", "", "down")
vimBind("k", "", "up")
vimBind("l", "", "right")
vimBind("g", "cmd", "up")
vimBind("G", "cmd", "down")

-- Toggle macOS dark mode
hs.hotkey.bind({ "ctrl", "cmd" }, "m", function()
  hs.osascript.applescript(
    [[tell application "System Events" to tell appearance preferences to set dark mode to ]]
    .. tostring(hs.host.interfaceStyle() ~= "Dark")
  )
end)

-- Reload Hammerspoon
hs.hotkey.bind({ "ctrl", "cmd" }, "r", hs.reload)

hs.alert("Hammerspoon Loaded")
