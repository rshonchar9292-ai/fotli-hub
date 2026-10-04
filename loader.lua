--// ============================================================
--// Fotli Hub — Self-contained Loader
--// Не залежить від loader.lua на GitHub
--// ============================================================

if _G.FotliMenuLoaded then
    warn("[FotliMenu] Вже завантажено!")
    return
end
_G.FotliMenuLoaded = true

--// Правильний юзернейм — 9292
local BASE = "https://raw.githubusercontent.com/rshonchar9292-ai/fotli-hub/main/"

--// Універсальне завантаження модуля
local function Load(path)
    local url = BASE .. path .. "?t=" .. os.time()   -- обхід кешу GitHub
    local ok, code = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        warn("[FotliMenu] HTTP-помилка (" .. path .. "):", code)
        return false
    end

    if not code or #code < 20 then
        warn("[FotliMenu] Порожня відповідь (" .. path .. ")")
        return false
    end

    --// Перевірка на 404
    if code:sub(1, 3) == "404" or code:find("^404:") then
        warn("[FotliMenu] Файл не знайдено: " .. path)
        return false
    end

    local fn, err = loadstring(code)
    if not fn then
        warn("[FotliMenu] Помилка компіляції (" .. path .. "):", err)
        return false
    end

    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[FotliMenu] Помилка виконання (" .. path .. "):", runErr)
        return false
    end

    print("[FotliMenu] ✓ " .. path)
    return true
end

--// 1. UI
print("[FotliMenu] Завантаження UI...")
Load("ui.lua")

--// 2. Чекаємо, поки UI створить _G.ModMenu.Elements
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements) and tries < 30 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[FotliMenu] UI не ініціалізувався — модулі не запущено")
    return
end

print("[FotliMenu] UI готовий, завантаження модулів...")

--// 3. Features
Load("features/esp.lua")
Load("features/silentaim.lua")
Load("features/speed.lua")
Load("features/fly.lua")
Load("features/noclip.lua")

print("[FotliMenu] Готово! Меню запущено.")
