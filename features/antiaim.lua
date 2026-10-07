--// ============================================================
--// features/antiaim.lua — Anti-Aim v2 (не ламає стрільбу)
--// Обертає ТІЛЬКИ візуальну модель, не чіпаючи позицію
--// ============================================================

print("[AntiAim] === СТАРТ ===")

--// ---------- 1. ЧЕКАЄМО UI ----------
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements) and tries < 50 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[AntiAim] ❌ UI не знайдено")
    return
end

local E = _G.ModMenu.Elements
print("[AntiAim] ✓ UI знайдено")

--// ---------- 2. СЕРВІСИ ----------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

--// ---------- 3. СТАН ----------
local State = {
    Enabled        = false,
    Mode           = "Spin",   -- Spin | Jitter
    Speed          = 18,
    JitterAngle    = 90,
    PauseOnShoot   = true,     -- пауза під час пострілу
    OldAutoRotate  = nil,
    Conn           = nil,
    Accumulator    = 0,
    Flip           = false,
    RootJoint      = nil,      -- Motor6D у HumanoidRootPart
    OriginalC0     = nil,      -- оригінальний C0
}

--// ---------- 4. УТИЛІТИ ----------
local function getChar()
    return LocalPlayer.Character
end

local function getRoot()
    local char = getChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isShooting()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

--// ---------- 5. ЗНАЙТИ ROOT JOINT ----------
--// Обертаємо через Motor6D, а не CFrame → не чіпаємо фізику
local function findRootJoint()
    local char = getChar()
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    --// У R15 та R6 root joint називається "RootJoint" (Motor6D)
    --// Він з'єднує HumanoidRootPart з LowerTorso (R15) або Torso (R6)
    for _, d in ipairs(root:GetChildren()) do
        if d:IsA("Motor6D") then
            return d
        end
    end

    --// Іноді він називається інакше — шукаємо серед усіх Motor6D у моделі
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Motor6D") and (d.Part0 == root or d.Part1 == root) then
            return d
        end
    end

    return nil
end

--// ---------- 6. ОЧИСТКА ----------
local function cleanup()
    if State.Conn then
        State.Conn:Disconnect()
        State.Conn = nil
    end

    --// Повертаємо Motor6D.C0
    if State.RootJoint and State.OriginalC0 then
        pcall(function() State.RootJoint.C0 = State.OriginalC0 end)
    end
    State.RootJoint = nil
    State.OriginalC0 = nil

    --// Повертаємо AutoRotate
    local hum = getHumanoid()
    if hum and State.OldAutoRotate ~= nil then
        hum.AutoRotate = State.OldAutoRotate
        State.OldAutoRotate = nil
    end
end

--// ---------- 7. ЗАПУСК ----------
local function startAntiAim()
    local hum = getHumanoid()
    if not hum then return end

    State.OldAutoRotate = hum.AutoRotate
    --// НЕ вимикаємо AutoRotate — хай гра крутить тіло за рухом
    --// Ми перехоплюємо через Motor6D.C0 незалежно

    State.RootJoint = findRootJoint()
    if State.RootJoint then
        State.OriginalC0 = State.RootJoint.C0
    else
        warn("[AntiAim] ⚠ RootJoint не знайдено — anti-aim може не працювати")
    end

    State.Accumulator = 0
    State.Flip = false

    State.Conn = RunService.RenderStepped:Connect(function(dt)
        local root = getRoot()
        if not root then return end

        --// Якщо увімкнено "пауза під час пострілу" — не крутимось під час ЛКМ
        if State.PauseOnShoot and isShooting() then
            if State.RootJoint and State.OriginalC0 then
                State.RootJoint.C0 = State.OriginalC0
            end
            return
        end

        local angle = 0

        if State.Mode == "Spin" then
            --// Безперервне обертання
            State.Accumulator = State.Accumulator + dt * State.Speed
            if State.Accumulator > 360 then State.Accumulator = State.Accumulator - 360 end
            angle = math.rad(State.Accumulator)

        elseif State.Mode == "Jitter" then
            --// Сіпання
            State.Accumulator = State.Accumulator + dt * State.Speed
            if State.Accumulator >= 1 then
                State.Accumulator = 0
                State.Flip = not State.Flip
            end
            angle = State.Flip and math.rad(State.JitterAngle) or math.rad(-State.JitterAngle)
        end

        --// Обертаємо тільки через Motor6D.C0 — фізика не чіпається
        if State.RootJoint and State.OriginalC0 then
            State.RootJoint.C0 = State.OriginalC0 * CFrame.Angles(0, angle, 0)
        end
    end)

    print("[AntiAim] ✓ Увімкнено, режим: " .. State.Mode)
end

--// ---------- 8. ЗУПИНКА ----------
local function stopAntiAim()
    cleanup()
    print("[AntiAim] ✗ Вимкнено")
end

--// ---------- 9. СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        local ok, v

        ok, v = pcall(function() return E.AntiAimEnabled:Get() end)
        if ok and v ~= State.Enabled then
            State.Enabled = v
            if v then startAntiAim() else stopAntiAim() end
        end

        ok, v = pcall(function() return E.AntiAimMode:Get() end)
        if ok then State.Mode = v and "Spin" or "Jitter" end

        ok, v = pcall(function() return E.AntiAimSpeed:Get() end)
        if ok then State.Speed = v end

        ok, v = pcall(function() return E.AntiAimJitter:Get() end)
        if ok then State.JitterAngle = v end

        --// PauseOnShoot — якщо є в UI (може не бути)
        ok, v = pcall(function() return E.AntiAimPauseShoot:Get() end)
        if ok then State.PauseOnShoot = v end
    end
end)

--// ---------- 10. ПРИ ЗМІНІ ПЕРСОНАЖА ----------
LocalPlayer.CharacterAdded:Connect(function()
    if State.Enabled then
        task.wait(1)
        if State.Enabled then
            cleanup()
            startAntiAim()
        end
    end
end)

--// ---------- 11. ГОТОВО ----------
print("[AntiAim] ✓ Bind встановлено")
print("[AntiAim] === ГОТОВО ===")
print("[AntiAim] F4 → Rage → Anti-Aim")
