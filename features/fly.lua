--// ============================================================
--// features/fly.lua — Fly (3 методи)
--// ============================================================

print("[Fly] === СТАРТ ===")

--// ---------- 1. ЧЕКАЄМО UI ----------
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements) and tries < 50 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[Fly] ❌ UI не знайдено")
    return
end

local E = _G.ModMenu.Elements
print("[Fly] ✓ UI знайдено")

--// ---------- 2. СЕРВІСИ ----------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer

--// ---------- 3. СТАН ----------
local State = {
    Enabled  = false,
    Speed    = 60,
    Method   = "velocity",  -- velocity | bodyvelocity | cframe
    Vertical = 0,           -- для мобільних кнопок (+1 / -1)
}

--// ---------- 4. ЗМІННІ ДЛЯ КОЖНОГО МЕТОДУ ----------
local FlyBV = nil         -- BodyVelocity
local FlyBG = nil         -- BodyGyro
local FlyAttach = nil     -- Attachment
local FlyLV = nil         -- LinearVelocity
local FlyAO = nil         -- AlignOrientation
local FlyConn = nil       -- RunService connection

--// ---------- 5. УТИЛІТИ ----------
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

local function isAlive()
    local hum = getHumanoid()
    return hum ~= nil and hum.Health > 0
end

local function isTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

--// ---------- 6. НАПРЯМОК РУХУ ----------
local function getMoveDir(includeVertical)
    local camera = Workspace.CurrentCamera
    if not camera then return Vector3.zero end

    local cf = camera.CFrame
    local dir = Vector3.zero

    if not isTyping() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if includeVertical then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
        end
    end

    --// Мобільні кнопки (+ / -)
    if includeVertical and State.Vertical ~= 0 then
        dir = dir + Vector3.yAxis * State.Vertical
    end

    if dir.Magnitude < 0.0001 then return Vector3.zero end
    return dir.Unit
end

--// ---------- 7. ОЧИСТКА ----------
local function cleanup()
    if FlyConn then
        pcall(function() FlyConn:Disconnect() end)
        FlyConn = nil
    end
    if FlyBV then pcall(function() FlyBV:Destroy() end) FlyBV = nil end
    if FlyBG then pcall(function() FlyBG:Destroy() end) FlyBG = nil end
    if FlyLV then pcall(function() FlyLV:Destroy() end) FlyLV = nil end
    if FlyAO then pcall(function() FlyAO:Destroy() end) FlyAO = nil end
    if FlyAttach then pcall(function() FlyAttach:Destroy() end) FlyAttach = nil end

    --// Повертаємо гравітацію та стан
    local root = getRoot()
    if root then
        pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
    end
    local hum = getHumanoid()
    if hum then
        pcall(function() hum.PlatformStand = false end)
    end
end

--// ---------- 8. МЕТОД 1: BodyVelocity (найпростіший) ----------
local function startBodyVelocity()
    local root = getRoot()
    if not root then return end

    FlyBV = Instance.new("BodyVelocity")
    FlyBV.Name = "FotliFlyBV"
    FlyBV.MaxForce = Vector3.one * 1e6
    FlyBV.Velocity = Vector3.zero
    FlyBV.Parent = root

    local camera = Workspace.CurrentCamera
    FlyBG = Instance.new("BodyGyro")
    FlyBG.Name = "FotliFlyBG"
    FlyBG.MaxTorque = Vector3.one * 4e5
    FlyBG.P = 1e4
    FlyBG.CFrame = camera and camera.CFrame or root.CFrame
    FlyBG.Parent = root

    FlyConn = RunService.Heartbeat:Connect(function()
        if not isAlive() or not FlyBV or not FlyBV.Parent then return end
        FlyBV.Velocity = getMoveDir(true) * State.Speed
        if FlyBG and FlyBG.Parent and camera then
            FlyBG.CFrame = camera.CFrame
        end
    end)
end

--// ---------- 9. МЕТОД 2: LinearVelocity (плавний) ----------
local function startLinearVelocity()
    local root = getRoot()
    if not root then return end

    FlyAttach = Instance.new("Attachment")
    FlyAttach.Name = "FotliFlyAttach"
    FlyAttach.Parent = root

    FlyLV = Instance.new("LinearVelocity")
    FlyLV.Name = "FotliFlyLV"
    FlyLV.Attachment0 = FlyAttach
    FlyLV.MaxForce = 1e6
    FlyLV.RelativeTo = Enum.ActuatorRelativeTo.World
    FlyLV.VectorVelocity = Vector3.zero
    FlyLV.Parent = root

    FlyAO = Instance.new("AlignOrientation")
    FlyAO.Name = "FotliFlyAO"
    FlyAO.Attachment0 = FlyAttach
    FlyAO.Mode = Enum.OrientationAlignmentMode.OneAttachment
    FlyAO.RigidityEnabled = true
    FlyAO.Parent = root

    FlyConn = RunService.Heartbeat:Connect(function()
        if not isAlive() or not FlyLV or not FlyLV.Parent then return end
        FlyLV.VectorVelocity = getMoveDir(true) * State.Speed
        local camera = Workspace.CurrentCamera
        if FlyAO and FlyAO.Parent and camera then
            FlyAO.CFrame = CFrame.lookAt(Vector3.zero, camera.CFrame.LookVector)
        end
    end)
end

--// ---------- 10. МЕТОД 3: Velocity напряму (без слідів) ----------
local function startVelocity()
    FlyConn = RunService.Heartbeat:Connect(function()
        if not isAlive() then return end
        local root = getRoot()
        if not root then return end
        root.AssemblyLinearVelocity = getMoveDir(true) * State.Speed
    end)
end

--// ---------- 11. ЗАПУСК / ЗУПИНКА ----------
local function startFly()
    cleanup()

    if State.Method == "bodyvelocity" then
        startBodyVelocity()
    elseif State.Method == "linearvelocity" then
        startLinearVelocity()
    else
        startVelocity()
    end

    print("[Fly] ✓ Політ запущено (метод: " .. State.Method .. ")")
end

local function stopFly()
    cleanup()
    print("[Fly] ✗ Політ зупинено")
end

--// ---------- 12. МОБІЛЬНІ КНОПКИ ----------
local mobilePad = nil
task.spawn(function()
    if not UserInputService.TouchEnabled then return end

    local ScreenGui = _G.ModMenu.ScreenGui
    if not ScreenGui then return end

    mobilePad = Instance.new("Frame")
    mobilePad.Name = "FlyMobilePad"
    mobilePad.BackgroundTransparency = 1
    mobilePad.AnchorPoint = Vector2.new(1, 0.5)
    mobilePad.Position = UDim2.new(1, -20, 0.5, 0)
    mobilePad.Size = UDim2.fromOffset(70, 150)
    mobilePad.Visible = false
    mobilePad.ZIndex = 400
    mobilePad.Parent = ScreenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = mobilePad

    local function makeBtn(label, order, dirValue)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(70, 70)
        b.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        b.Text = label
        b.TextColor3 = Color3.fromRGB(230, 230, 245)
        b.TextSize = 26
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.LayoutOrder = order
        b.ZIndex = 401
        b.Parent = mobilePad

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 18)
        c.Parent = b

        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                State.Vertical = dirValue
                b.BackgroundColor3 = Color3.fromRGB(120, 90, 255)
            end
        end)
        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if State.Vertical == dirValue then State.Vertical = 0 end
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            end
        end)
    end

    makeBtn("+", 1, 1)
    makeBtn("−", 2, -1)
end)

--// ---------- 13. СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end

        local ok, v

        --// Fly enable/disable
        ok, v = pcall(function() return E.FlyToggle:Get() end)
        if ok and v ~= State.Enabled then
            State.Enabled = v
            if v then
                startFly()
                if mobilePad then mobilePad.Visible = true end
            else
                stopFly()
                if mobilePad then mobilePad.Visible = false end
            end
        end

        --// Speed
        ok, v = pcall(function() return E.SpeedSlider:Get() end)
        if ok then State.Speed = v end
    end
end)

--// ---------- 14. АВТО-ВИМКНЕННЯ ПРИ СМЕРТІ ----------
LocalPlayer.CharacterAdded:Connect(function()
    if State.Enabled then
        task.wait(1)
        if State.Enabled then
            startFly()
        end
    end
end)

--// ---------- 15. ОЧИСТКА ПРИ ВИХОДІ ----------
game:BindToClose(function()
    if State.Enabled then stopFly() end
end)

print("[Fly] ✓ Bind встановлено")
print("[Fly] === ГОТОВО ===")
print("[Fly] F4 → Movement → Fly + Speed")
