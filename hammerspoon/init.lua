-- Caps Lock acts as Escape when pressed and activates hyper mode when held down
local hyper = hs.hotkey.modal.new()

for _, mods in ipairs({ '', 'cmd', 'shift' }) do
  hs.hotkey.bind(mods, 'F18',
    function()  -- pressedfn
      hyper:enter()
      hyper.triggered = false
    end,
    function()  -- releasedfn
      hyper:exit()
      if not hyper.triggered then
        hs.eventtap.keyStroke('', 'escape')
      end
    end
  )
end

local function hyperBind(mods, key, pressedfn, repeatfn)
  hyper:bind(mods, key,
    function()
      hyper.triggered = true
      pressedfn()
    end,
    nil,
    function()
      if repeatfn == true then
        pressedfn()
      elseif repeatfn ~= nil then
        repeatfn()
      end
    end)
end


-- Move windows
local function bindWindowMove(key, unitrect)
  hyperBind('cmd', key, function()
    hs.window.focusedWindow():moveToUnit(unitrect)
  end)
end

bindWindowMove('q', {0.0, 0.0, 0.5, 0.5})  -- Top left
bindWindowMove('w', {0.0, 0.0, 1.0, 0.5})  -- Top half
bindWindowMove('e', {0.5, 0.0, 0.5, 0.5})  -- Top right
bindWindowMove('a', {0.0, 0.0, 0.5, 1.0})  -- Left half
bindWindowMove('s', {0.25, 0.0, 0.5, 1.0}) -- Center half
bindWindowMove('d', {0.5, 0.0, 0.5, 1.0})  -- Right half
bindWindowMove('z', {0.0, 0.5, 0.5, 0.5})  -- Bottom left
bindWindowMove('x', {0.0, 0.5, 1.0, 0.5})  -- Bottom half
bindWindowMove('c', {0.5, 0.5, 0.5, 0.5})  -- Bottom right
bindWindowMove('f', {0.0, 0.0, 1.0, 1.0})  -- Full screen
bindWindowMove('g', {0.15, 0.1, 0.7, 0.8}) -- Center screen

-- Focus windows
local function bindWindowFocus(key, direction)
  hyperBind('cmd', key, function()
    hs.window.focusedWindow()['focusWindow' .. direction]()
  end)
end

bindWindowFocus('h', 'West')
bindWindowFocus('j', 'South')
bindWindowFocus('k', 'North')
bindWindowFocus('l', 'East')


-- Vim keybinds while in hyper mode
local function map(keys, pressedfn, repeatfn)
  local mods = {}
  if string.sub(keys, 1, 2) == 'S-' then
    table.insert(mods, 'shift')
    keys = string.sub(keys, 3)
  end
  if string.sub(keys, 1, 2) == 'A-' then
    table.insert(mods, 'alt')
    keys = string.sub(keys, 3)
  end
  if string.sub(keys, 1, 2) == 'M-' then
    table.insert(mods, 'cmd')
    keys = string.sub(keys, 3)
  end
  if keys ~= string.lower(keys) then
    table.insert(mods, 'shift')
  end
  hyperBind(mods, keys, pressedfn, repeatfn)
end

local function keyStroke(mods, char, noremap)
  if noremap then hyper:exit() end
  hs.eventtap.keyStroke(mods, char, 0)
  if noremap then hyper:enter() end
end
local S = 'shift'
local C = 'ctrl'
local A = 'alt'
local M = 'cmd'

map('h', function() keyStroke({}, 'left' ) end, true)
map('j', function() keyStroke({}, 'down' ) end, true)
map('k', function() keyStroke({}, 'up'   ) end, true)
map('l', function() keyStroke({}, 'right') end, true)

map('0', function() keyStroke({M}, 'left' ) end)
map('4', function() keyStroke({M}, 'right') end)

map('g', function() keyStroke({M}, 'up'  ) end)
map('G', function() keyStroke({M}, 'down') end)

map('b', function() keyStroke({A}, 'left' ) end, true)
map('e', function() keyStroke({A}, 'right') end, true)
map('w', function()
  keyStroke({A}, 'right')
  keyStroke({A}, 'right')
  keyStroke({A}, 'left' )
end, true)

map('x',  function() keyStroke({},  'forwarddelete') end, true)
map('X',  function() keyStroke({A}, 'forwarddelete') end, true)
map('\\', function() keyStroke({A}, 'delete') end, true)

map('u', function() keyStroke({M},   'z', true) end)
map('r', function() keyStroke({S,M}, 'z', true) end)

map('/', function() keyStroke({M},   'f', true) end)
map('n', function() keyStroke({M},   'g', true) end)
map('N', function() keyStroke({S,M}, 'g', true) end)


-- Copy Mail.app message org-link
hyperBind('cmd', 'm', function()
  local script = [[
    tell application "Mail"
      set emails to selection
      set email to item 1 of emails
      set msgid to message id of email
      set subj to subject of email
      set orgLink to "[[message://%3c" & msgid & "%3e][" & subj & "]" & "]"
      set the clipboard to orgLink
    end tell
  ]]
  hs.osascript.applescript(script)
  hs.alert("Copied org-link to clipboard")
end)

-- Reload Hammerspoon
hyperBind('cmd', 'r', hs.reload)

-- hs.loadSpoon('EmmyLua')
hs.alert.show('Hammerspoon Loaded')
