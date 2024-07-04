-- Caps Lock acts as Esc when tapped, Ctrl when held
---@diagnostic disable-next-line: undefined-field
hs.loadSpoon("ControlEscape"):start()

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
hs.hotkey.bind({ "shift", "cmd" }, "h", function()
  hs.application.frontmostApplication():hide()
end)
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

-- Hammerspoon annotations for lua language server
local f = io.open("Spoons/EmmyLua.spoon/annotations/hs.lua")
if f ~= nil then io.close(f) else hs.loadSpoon("EmmyLua") end

-- Reload Hammerspoon
hs.hotkey.bind({ "ctrl", "cmd" }, "r", hs.reload)

hs.alert("Hammerspoon Loaded")
