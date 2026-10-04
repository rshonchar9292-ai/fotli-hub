--// ============================================================
--// LOADER для Fotli Hub
--// Структура: ui.lua + features/*.lua
--// ============================================================

if _G.FotliMenuLoaded then
    warn("[FotliMenu] Вже завантажено!")
    return
end
_G.FotliMenuLoaded = true

local BASE = "https://raw.githubusercontent.com/rshonchar9232-ai/fotli-hub/main/"

-- Універсальне завантаження
local function Load(path)
    local url = BASE .. path
    local ok, code = pcall(game.HttpGet, game, url)
    if not ok or not code or #code < 20 then
        warn("[FotliMenu] Не завантажено:", path)
        return false
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[FotliMenu] Помилка компіляції", path .. ":", err)
        return false
    end

    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[FotliMenu] Помилка виконання", path .. ":", runErr)
        return false
    end

    print("[FotliMenu] ✓", path)
    return true
end

-- 1. UI
Load("ui.lua")
task.wait(0.3)

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[FotliMenu] UI не завантажився")
    return
end

-- 2. Features (логіка)
Load("features/esp.lua")
Load("features/silentaim.lua")
Load("features/speed.lua")
Load("features/fly.lua")
Load("features/noclip.lua")

print("[FotliMenu] Готово!")
