require("hs.ipc")

local SLOTS      = 9
local STORE_MODS = { "cmd", "ctrl" }
local PASTE_MODS = { "cmd", "alt" }
local PALETTE_KEY = "0"
local PREVIEW_LEN = 40
local SETTINGS_KEY = "multiclip.slots"

local slots = hs.settings.get(SETTINGS_KEY) or {}

local function persist()
  hs.settings.set(SETTINGS_KEY, slots)
end

local function preview(text)
  if not text then return "(empty)" end
  local oneLine = text:gsub("%s+", " ")
  if #oneLine > PREVIEW_LEN then
    oneLine = oneLine:sub(1, PREVIEW_LEN) .. "…"
  end
  return oneLine
end

local function storeSlot(n)
  local before = hs.pasteboard.changeCount()
  hs.eventtap.keyStroke({ "cmd" }, "c", 0)
  hs.timer.doAfter(0.12, function()
    if hs.pasteboard.changeCount() == before then
      hs.alert.show("Nothing selected to copy")
      return
    end
    local text = hs.pasteboard.readString()
    if not text or text == "" then
      hs.alert.show("Nothing to copy")
      return
    end
    slots[tostring(n)] = text
    persist()
    hs.alert.show("Copied to slot " .. n)
  end)
end

local function pasteSlot(n)
  local text = slots[tostring(n)]
  if not text then
    hs.alert.show("Slot " .. n .. " is empty")
    return
  end
  hs.pasteboard.setContents(text)
  hs.timer.doAfter(0.03, function()
    hs.eventtap.keyStroke({ "cmd" }, "v")
  end)
end

local function clearAll()
  slots = {}
  persist()
  hs.alert.show("Cleared all slots")
end

for n = 1, SLOTS do
  local key = tostring(n)
  hs.hotkey.bind(STORE_MODS, key, function() storeSlot(n) end)
  hs.hotkey.bind(PASTE_MODS, key, function() pasteSlot(n) end)
end

local chooser = hs.chooser.new(function(choice)
  if choice then pasteSlot(choice.slot) end
end)

local function showPalette()
  local choices = {}
  for n = 1, SLOTS do
    if slots[tostring(n)] then
      table.insert(choices, {
        text    = "Slot " .. n,
        subText = preview(slots[tostring(n)]),
        slot    = n,
      })
    end
  end
  if #choices == 0 then
    hs.alert.show("No slots stored yet")
    return
  end
  chooser:choices(choices)
  chooser:show()
end

hs.hotkey.bind(PASTE_MODS, PALETTE_KEY, showPalette)

local menu = hs.menubar.new()
if menu then
  menu:setTitle("📋")
  menu:setTooltip("Multi-Slot Clipboard")
  menu:setMenu(function()
    local items = {
      { title = "Stored clippings", disabled = true },
      { title = "-" },
    }
    local any = false
    for n = 1, SLOTS do
      if slots[tostring(n)] then
        any = true
        table.insert(items, {
          title = "Slot " .. n .. ":  " .. preview(slots[tostring(n)]),
          fn = function() pasteSlot(n) end,
        })
      end
    end
    if not any then
      table.insert(items, { title = "(no slots stored)", disabled = true })
    end
    table.insert(items, { title = "-" })
    table.insert(items, { title = "Clear all", fn = clearAll })
    table.insert(items, {
      title = "Reload config",
      fn = function() hs.reload() end,
    })
    return items
  end)
end

hs.alert.show("Multi-clipboard ready  ·  store: ⌘⌃N   paste: ⌘⌥N")
