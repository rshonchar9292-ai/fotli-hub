--// ============================================================
--// LOADER для Fotli Hub
--// Завантажує UI з GitHub репозиторію
--// ============================================================

-- Захист від повторного завантаження
if _G.FotliMenuLoaded then
    warn("[FotliMenu] Вже завантажено!")
    return
end
_G.FotliMenuLoaded = true

-- URL файлу з UI
local UI_URL = "https://raw.githubusercontent.com/rshonchar9232-ai/fotli-hub/main/ui.lua"

-- Функція завантаження з перевіркою
local function LoadUI()
    local success, result = pcall(function()
        return game:HttpGet(UI_URL)
    end)

    if not success then
        warn("[FotliMenu] Помилка HTTP-запиту:", result)
        return false
    end

    if not result or #result < 50 then
        warn("[FotliMenu] Порожня або занадто коротка відповідь від GitHub")
        return false
    end

    -- Компіляція Lua-коду
    local fn, err = loadstring(result)
    if not fn then
        warn("[FotliMenu] Помилка компіляції:", err)
        return false
    end

    -- Запуск
    local runSuccess, runErr = pcall(fn)
    if not runSuccess then
        warn("[FotliMenu] Помилка виконання:", runErr)
        return false
    end

    return true
end

-- Запуск
if LoadUI() then
    print("[FotliMenu] UI успішно завантажено через Fotli Hub!")
else
    warn("[FotliMenu] Не вдалося завантажити UI.")
end
