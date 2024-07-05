-- Download Spoons, if required
local f = io.open("Spoons/EmmyLua.spoon/annotations/hs.lua")
if f ~= nil then io.close(f) else
  hs.alert("Downloading Spoons")
  os.execute([[
    mkdir -p Spoons && cd Spoons &&
    git clone https://github.com/jasonrudolph/ControlEscape.spoon.git
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

-- Window Movement
local movements = {
  q =  {0.0, 0.0, 0.5, 0.5}, -- Top left
  w =  {0.0, 0.0, 1.0, 0.5}, -- Top half
  e =  {0.5, 0.0, 0.5, 0.5}, -- Top right
  a =  {0.0, 0.0, 0.5, 1.0}, -- Left half
  s =  {0.2, 0.0, 0.6, 1.0}, -- Center half
  d =  {0.5, 0.0, 0.5, 1.0}, -- Right half
  z =  {0.0, 0.5, 0.5, 0.5}, -- Bottom left
  x =  {0.0, 0.5, 1.0, 0.5}, -- Bottom half
  c =  {0.5, 0.5, 0.5, 0.5}, -- Bottom right
  f =  {0.0, 0.0, 1.0, 1.0}, -- Full screen
  g =  {0.1, 0.1, 0.8, 0.8}, -- Center screen
}
for key, rect in pairs(movements) do
  hs.hotkey.bind({ "ctrl", "cmd" }, key, function()
    hs.window.focusedWindow():moveToUnit(rect)
  end)
end

-- Window Resize
local function resize(delta)
  local frame = hs.window.focusedWindow():frame()
  local screen = hs.screen.mainScreen():fullFrame()
  if frame.w < screen.w then
    if frame.x + frame.w == screen.w then
      frame.x = frame.x - delta
    elseif frame.x > 0 then
      frame.x = frame.x - delta/2
    end
    frame.w = math.min(frame.w + delta, screen.w)
  end
  if frame.h < screen.h - 50 then
    if frame.y + frame.h > screen.h - 50 then
      frame.y = frame.y - delta
    elseif frame.y > 50 then
      frame.y = frame.y - delta/2
    end
    frame.h = math.min(frame.h + delta, screen.h)
  end
  hs.window.focusedWindow():setFrame(frame)
end
hs.hotkey.bind({ "ctrl", "cmd" }, "=", function() resize(100) end)
hs.hotkey.bind({ "ctrl", "cmd" }, "-", function() resize(-100) end)

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
