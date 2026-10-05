--// ============================================================
--// features/aimbot.lua — AIMBOT v5 (WORKING)
--// ============================================================

print("[Aimbot] === СТАРТ ===")

--// ---------- 1. ЧЕКАЄМО UI ----------
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements or not _G.ModMenu.ScreenGui) and tries < 50 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements or not _G.ModMenu.ScreenGui then
    warn("[Aimbot] ❌ UI не знайдено — вихід")
    return
end

local E = _G.ModMenu.Elements
local ScreenGui = _G.ModMenu.ScreenGui
print("[Aimbot] ✓ UI знайдено")

--// ---------- 2. СЕРВІСИ ----------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local GuiService       = game:GetService("GuiService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

--// ---------- 3. СТАН ----------
local State = {
    Enabled       = false,
    Smoothness    = 0.25,
    Fov           = 150,
    TeamCheck     = true,
    WallCheck     = false,
    TargetPart    = "Head",
    CurrentTarget = nil,
    DebugTimer    = 0,
    DebugTargets  = 0,
}

--// ---------- 4. УТИЛІТИ ----------
local function localAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

--// GetMouseLocation враховує topbar (36px)
--// WorldToViewportPoint — НЕ враховує
--// Тому додаємо inset до viewport point
local function getInset()
    local ok, inset = pcall(function() return GuiService:GetGuiInset() end)
    return ok and inset or Vector2.new(0, 36)
end

local function getTargetPart(char)
    if not char then return nil end
    if State.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif State.TargetPart == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function hasLineOfSight(part)
    if not State.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Camera,
        part.Parent,
    }
    return Workspace:Raycast(origin, dir, params) == nil
end

local function isEnemy(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if State.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return false
    end
    return true
end

--// ---------- 5. ПОШУК ЦІЛІ ----------
local function findTarget()
    if not Camera then return nil end

    local inset = getInset()
    local mouseScreen = UserInputService:GetMouseLocation()

    local bestPart, bestPlr, bestDist = nil, nil, State.Fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local part = getTargetPart(plr.Character)
            if part then
                local vpPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and vpPoint.Z > 0 then
                    --// Переводимо viewport → screen (додаємо topbar offset)
                    local screenPoint = Vector2.new(vpPoint.X, vpPoint.Y + inset.Y)
                    local d = (screenPoint - mouseScreen).Magnitude
                    if d < bestDist and hasLineOfSight(part) then
                        bestDist = d
                        bestPart = part
                        bestPlr = plr
                    end
                end
            end
        end
    end

    State.CurrentTarget = bestPlr
    return bestPart
end

--// ---------- 6. FOV CIRCLE ----------
local hasDrawing = pcall(function()
    local d = Drawing.new("Circle")
    d:Remove()
end)

local fovCircle, fovFrame, fovStroke

if hasDrawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 0.5
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Visible = false
    print("[Aimbot] ✓ FOV circle: Drawing API")
else
    fovFrame = Instance.new("Frame")
    fovFrame.Name = "AimbotFOV"
    fovFrame.BackgroundTransparency = 1
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.Size = UDim2.fromOffset(State.Fov * 2, State.Fov * 2)
    fovFrame.Visible = false
    fovFrame.ZIndex = 500
    fovFrame.Parent = ScreenGui

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = fovFrame

    fovStroke = Instance.new("UIStroke")
    fovStroke.Color = Color3.fromRGB(255, 255, 255)
    fovStroke.Thickness = 1.5
    fovStroke.Transparency = 0.5
    fovStroke.Parent = fovFrame
    print("[Aimbot] ✓ FOV circle: Frame fallback")
end

--// ---------- 7. СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        local ok, v

        ok, v = pcall(function() return E.AimEnabled:Get() end)
        if ok then State.Enabled = v end

        ok, v = pcall(function() return E.AimSmooth:Get() end)
        if ok then State.Smoothness = v end

        ok, v = pcall(function() return E.AimFovSlider:Get() end)
        if ok then State.Fov = v end

        ok, v = pcall(function() return E.AimTeamCheck:Get() end)
        if ok then State.TeamCheck = v end

        ok, v = pcall(function() return E.AimWallCheck:Get() end)
        if ok then State.WallCheck = v end

        ok, v = pcall(function() return E.AimTargetPart:Get() end)
        if ok then State.TargetPart = v and "Head" or "Torso" end
    end
end)

--// ---------- 8. АНТИ-КОНФЛІКТ ----------
pcall(function() RunService:UnbindFromRenderStep("FotliAimbot") end)
pcall(function() RunService:UnbindFromRenderStep("FotliAimbotV5") end)

--// ---------- 9. ГОЛОВНИЙ ЦИКЛ ----------
RunService:BindToRenderStep("FotliAimbotV5", Enum.RenderPriority.Camera.Value + 1, function(dt)
    --// 9.1 FOV circle
    local inset = getInset()
    local mouseScreen = UserInputService:GetMouseLocation()

    if fovCircle then
        fovCircle.Position = mouseScreen
        fovCircle.Radius = State.Fov
        fovCircle.Visible = State.Enabled
    elseif fovFrame then
        fovFrame.Position = UDim2.fromOffset(mouseScreen.X, mouseScreen.Y)
        fovFrame.Size = UDim2.fromOffset(State.Fov * 2, State.Fov * 2)
        fovFrame.Visible = State.Enabled
    end

    --// 9.2 Якщо вимкнено — вихід
    if not State.Enabled then return end

    --// 9.3 ПКМ
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        if fovCircle then fovCircle.Color = Color3.fromRGB(255, 255, 255) end
        if fovStroke then fovStroke.Color = Color3.fromRGB(255, 255, 255) end
        return
    end

    --// 9.4 Живий персонаж
    if not localAlive() then return end

    --// 9.5 Пошук цілі
    local targetPart = findTarget()
    if not targetPart then
        if fovCircle then fovCircle.Color = Color3.fromRGB(255, 255, 255) end
        if fovStroke then fovStroke.Color = Color3.fromRGB(255, 255, 255) end
        return
    end

    --// 9.6 Підсвітка FOV
    if fovCircle then fovCircle.Color = Color3.fromRGB(255, 60, 60) end
    if fovStroke then fovStroke.Color = Color3.fromRGB(255, 60, 60) end

    --// 9.7 Наведення камери
    local cam = Camera
    local camPos = cam.CFrame.Position
    local goal = CFrame.lookAt(camPos, targetPart.Position)

    --// Формула незалежна від FPS
    --// smooth = 0.05 → 95% руху за кадр (майже миттєво)
    --// smooth = 0.5  → 50% руху за кадр (плавно)
    --// smooth = 1    → 0% (не рухається)
    local smooth = math.clamp(State.Smoothness, 0.01, 0.99)
    local alpha = 1 - math.pow(smooth, dt * 60)
    alpha = math.clamp(alpha, 0.05, 0.95)
    cam.CFrame = cam.CFrame:Lerp(goal, alpha)

    --// 9.8 DEBUG (раз на 2 секунди)
    State.DebugTimer = State.DebugTimer + dt
    if State.DebugTimer >= 2 then
        State.DebugTimer = 0
        local plr = State.CurrentTarget
        print(string.format("[Aimbot DEBUG] Target: %s | Smooth: %.2f | FOV: %.0f | Alpha: %.2f",
            plr and plr.Name or "none",
            State.Smoothness,
            State.Fov,
            alpha
        ))
    end
end)

--// ---------- 10. ГОТОВО ----------
print("[Aimbot] ✓ Bind встановлено: FotliAimbotV5")
print("[Aimbot] === ГОТОВО ===")
print("[Aimbot] F4 → Combat → Aimbot (Hold RMB) → ПКМ")
