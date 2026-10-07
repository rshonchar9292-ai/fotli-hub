--// ============================================================
--// features/bunnyhop.lua — Bunny Hop (CS-style)
--// Автоматичний стрибок при приземленні + авто-стрибок на Space
--// ============================================================

print("[BunnyHop] === СТАРТ ===")

--// ---------- 1. ЧЕКАЄМО UI ----------
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements) and tries < 50 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[BunnyHop] ❌ UI не знайдено")
    return
end

local E = _G.ModMenu.Elements
print("[BunnyHop] ✓ UI знайдено")

--// ---------- 2. СЕРВІСИ ----------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer

--// ---------- 3. СТАН ----------
local State = {
    Enabled        = false,       -- BunnyHop
    AutoJump       = false,       -- Auto Jump (hold Space)
    JumpPower      = 50,
    OldJumpPower   = nil,
    OldUseJumpPower = nil,
    Conn           = nil,
    JumpConn       = nil,
    LastJumpTime   = 0,
}

--// ---------- 4. УТИЛІТИ ----------
local function getChar()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getChar()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

local function isShooting()
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
end

--// ---------- 5. СТРИБОК ----------
local function doJump(hum)
    if not hum then return end
    if hum.Health <= 0 then return end
    if hum:GetState() == Enum.HumanoidStateType.Jumping then return end
    if hum:GetState() == Enum.HumanoidStateType.Freefall then return end

    --// Використовуємо ChangeState — це найнадійніший метод
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

--// ---------- 6. ЗАПУСК BUNNY HOP ----------
local function startBunnyHop()
    --// Скидаємо попередній цикл
    if State.Conn then
        State.Conn:Disconnect()
        State.Conn = nil
    end

    State.Conn = RunService.Heartbeat:Connect(function()
        if not State.Enabled and not State.AutoJump then return end

        local hum = getHumanoid()
        if not hum then return end
        if hum.Health <= 0 then return end

        --// Перевірка: чи ми на землі
        local onGround = hum:GetState() == Enum.HumanoidStateType.Running
            or hum:GetState() == Enum.HumanoidStateType.RunningNoPhysics
            or hum:GetState() == Enum.HumanoidStateType.Landed

        if not onGround then return end

        --// Захист від спаму (щоб не було затримки)
        local now = tick()
        if now - State.LastJumpTime < 0.05 then return end

        --// BunnyHop: стрибаємо автоматично при приземленні
        if State.Enabled then
            --// Не стрибаємо під час стрільби (не заважає аіму/стрільбі)
            --// Якщо хочеш стрибати й стріляти одночасно — прибери цю умову
            if not isShooting() then
                doJump(hum)
                State.LastJumpTime = now
            end
            return
        end

        --// AutoJump: стрибаємо, тільки якщо затиснуто Space
        if State.AutoJump then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) and not isTyping() then
                doJump(hum)
                State.LastJumpTime = now
            end
        end
    end)

    print("[BunnyHop] ✓ Цикл запущено")
end

--// ---------- 7. ЗУПИНКА ----------
local function stopBunnyHop()
    if State.Conn then
        State.Conn:Disconnect()
        State.Conn = nil
    end
    print("[BunnyHop] ✗ Цикл зупинено")
end

--// ---------- 8. JUMP POWER ----------
local function applyJumpPower()
    local hum = getHumanoid()
    if not hum then return end

    --// Зберігаємо оригінал (тільки один раз)
    if State.OldJumpPower == nil then
        State.OldJumpPower = hum.JumpPower
        State.OldUseJumpPower = hum.UseJumpPower
    end

    hum.UseJumpPower = true
    hum.JumpPower = State.JumpPower
end

local function restoreJumpPower()
    local hum = getHumanoid()
    if hum and State.OldJumpPower ~= nil then
        hum.JumpPower = State.OldJumpPower
        if State.OldUseJumpPower ~= nil then
            hum.UseJumpPower = State.OldUseJumpPower
        end
    end
    State.OldJumpPower = nil
    State.OldUseJumpPower = nil
end

--// ---------- 9. СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        local ok, v

        --// BunnyHop
        ok, v = pcall(function() return E.BunnyHopToggle:Get() end)
        if ok then
            if v ~= State.Enabled then
                State.Enabled = v
                if v then
                    startBunnyHop()
                elseif not State.AutoJump then
                    stopBunnyHop()
                end
            end
        end

        --// AutoJump
        ok, v = pcall(function() return E.AutoJumpToggle:Get() end)
        if ok then
            if v ~= State.AutoJump then
                State.AutoJump = v
                if v then
                    startBunnyHop()
                elseif not State.Enabled then
                    stopBunnyHop()
                end
            end
        end

        --// JumpPower
        ok, v = pcall(function() return E.JumpPowerSlider:Get() end)
        if ok and v ~= State.JumpPower then
            State.JumpPower = v
            --// Застосовуємо тільки якщо хоч один режим увімкнено
            if State.Enabled or State.AutoJump then
                applyJumpPower()
            end
        end
    end
end)

--// ---------- 10. ВІДНОВЛЕННЯ JUMP POWER ПРИ ВИМКНЕННІ ----------
task.spawn(function()
    local wasOn = false
    while task.wait(0.2) do
        local on = State.Enabled or State.AutoJump
        if wasOn and not on then
            restoreJumpPower()
        end
        wasOn = on
    end
end)

--// ---------- 11. ПРИ ЗМІНІ ПЕРСОНАЖА ----------
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Enabled or State.AutoJump then
        restoreJumpPower()  -- скидаємо старі значення
        startBunnyHop()
    end
end)

--// ---------- 12. ГОТОВО ----------
print("[BunnyHop] ✓ Bind встановлено")
print("[BunnyHop] === ГОТОВО ===")
print("[BunnyHop] F4 → Movement → Bunny Hop / Auto Jump")
