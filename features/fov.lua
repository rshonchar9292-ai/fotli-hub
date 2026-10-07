--// ============================================================
--// features/fov.lua — FOV Changer (з регулюванням)
--// Змінює поле зору камери через слайдер
--// ============================================================

print("[FOV] === СТАРТ ===")

--// ---------- 1. ЧЕКАЄМО UI ----------
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements) and tries < 50 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[FOV] ❌ UI не знайдено")
    return
end

local E = _G.ModMenu.Elements
print("[FOV] ✓ UI знайдено")

--// ---------- 2. СЕРВІСИ ----------
local RunService = game:GetService("RunService")
local Workspace  = game:GetService("Workspace")

--// ---------- 3. СТАН ----------
local State = {
    Enabled    = false,
    Value      = 90,       -- цільове значення FOV
    OldFov     = nil,      -- оригінальне значення (щоб відновити)
    OldMode    = nil,      -- оригінальний FieldOfViewMode
    Conn       = nil,      -- RunService з'єднання
}

--// ---------- 4. УТИЛІТИ ----------
local function getCamera()
    return Workspace.CurrentCamera
end

--// ---------- 5. ЗАСТОСУВАННЯ FOV ----------
local function applyFov()
    local cam = getCamera()
    if not cam then return end

    --// Зберігаємо оригінал при першому застосуванні
    if State.OldFov == nil then
        State.OldFov  = cam.FieldOfView
        State.OldMode = cam.FieldOfViewMode
    end

    cam.FieldOfView     = State.Value
    cam.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
end

--// ---------- 6. ЗАПУСК ----------
local function startFov()
    --// Зупиняємо старий цикл, якщо був
    if State.Conn then
        State.Conn:Disconnect()
        State.Conn = nil
    end

    applyFov()

    --// Постійно тримаємо FOV (гра може скинути)
    State.Conn = RunService.RenderStepped:Connect(function()
        local cam = getCamera()
        if not cam then return end
        if math.abs(cam.FieldOfView - State.Value) > 0.01 then
            cam.FieldOfView = State.Value
        end
        if cam.FieldOfViewMode ~= Enum.FieldOfViewMode.Vertical then
            cam.FieldOfViewMode = Enum.FieldOfViewMode.Vertical
        end
    end)

    print("[FOV] ✓ Увімкнено, FOV = " .. tostring(State.Value))
end

--// ---------- 7. ЗУПИНКА ----------
local function stopFov()
    if State.Conn then
        State.Conn:Disconnect()
        State.Conn = nil
    end

    local cam = getCamera()
    if cam and State.OldFov then
        cam.FieldOfView = State.OldFov
        if State.OldMode then
            cam.FieldOfViewMode = State.OldMode
        end
    end

    State.OldFov  = nil
    State.OldMode = nil
    print("[FOV] ✗ Вимкнено, FOV повернуто до оригіналу")
end

--// ---------- 8. СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.05) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end

        local ok, v

        --// Увімкнення/вимкнення
        ok, v = pcall(function() return E.FovEnabled:Get() end)
        if ok and v ~= State.Enabled then
            State.Enabled = v
            if v then startFov() else stopFov() end
        end

        --// Значення FOV зі слайдера
        ok, v = pcall(function() return E.FovSlider:Get() end)
        if ok and v ~= State.Value then
            State.Value = v
            if State.Enabled then applyFov() end
        end
    end
end)

--// ---------- 9. АВТО-ВІДНОВЛЕННЯ ПРИ ЗМІНІ КАМЕРИ ----------
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if State.Enabled then
        task.wait(0.1)
        applyFov()
    end
end)

print("[FOV] ✓ Bind встановлено")
print("[FOV] === ГОТОВО ===")
print("[FOV] F4 → Rage → FOV Changer + FOV Value")
