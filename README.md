# Multi-Slot Clipboard (Hammerspoon)

Copy several things at once. Keep normal `Cmd+C`, but file each clipping into a
numbered slot and paste any of them back later.

## Keymap

| Action | Shortcut |
|---|---|
| Copy selection into slot N | `Cmd + Ctrl + N` |
| Paste slot N | `Cmd + Opt + N` |
| Open slot picker | `Cmd + Opt + 0` |

`N` is `1`–`9`. Both `Cmd+Ctrl+number` and `Cmd+Opt+number` are unused by macOS,
so nothing else is disturbed. Normal `Cmd+C` / `Cmd+V` are untouched.

## How it works

Each shortcut is a **registered global hotkey** — macOS only invokes the code when
that exact combo fires, so the tool never watches your keystrokes. Storing copies the
current selection for you (it synthesizes `Cmd+C`), so the flow is just:

1. Select text → `Cmd+Ctrl+1` → that text is now in slot 1.
2. Later, `Cmd+Opt+1` → it's pasted back.

(No separate `Cmd+C` needed. If nothing is selected, it flashes "Nothing selected".)

Stored slots survive Hammerspoon reloads (persisted via `hs.settings`). The 📋
menu-bar icon lists what's stored and lets you paste or clear.

## Install

1. `brew install --cask hammerspoon` and launch Hammerspoon.
2. Grant **Accessibility** permission: System Settings → Privacy & Security →
   Accessibility → enable Hammerspoon. (Needed only to synthesize the paste keystroke.)
3. Link this config in: `ln -sf "$PWD/init.lua" ~/.hammerspoon/init.lua`
4. Hammerspoon menu icon → **Reload Config**.

## Config

Edit the constants at the top of `init.lua`:

- `SLOTS` — how many slots (default 9).
- `STORE_MODS` / `PASTE_MODS` — change the modifier sets.
- `PREVIEW_LEN` — preview length in menus/alerts.

## Limitations

- **Text only** for now. Images/files would need `readImage`/`readContents` branches.
