--// ============================================================
--// features/aimbot.lua — Camera Aimbot (Hold RMB) — v3 FIXED
--// ============================================================

--// Чекаємо UI
local tries = 0
while (not _G.ModMenu or not _G.ModMenu.Elements or not _G.ModMenu.ScreenGui) and tries < 50 do
    task.wait(0.1)
    tries = tries + 1
end

if not _G.ModMenu or not _G.ModMenu.Elements then
    warn("[Aimbot] UI не завантажено — вихід")
    return
end

local E = _G.ModMenu.Elements
local ScreenGui = _G.ModMenu.ScreenGui
if not ScreenGui then
    warn("[Aimbot] ScreenGui не знайдено — вихід")
    return
end

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local GuiService       = game:GetService("GuiService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

--// ------------------------------------------------------------
--// СТАН
--// ------------------------------------------------------------
local S = {
    Enabled    = false,
    Smoothness = 0.25,
    Fov        = 150,
    TeamCheck  = true,
    WallCheck  = false,
    Head       = true,
}

--// ------------------------------------------------------------
--// ДОПОМІЖНІ
--// ------------------------------------------------------------
local function localAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function mousePos()
    --// ScreenGui з IgnoreGuiInset = true → використовуємо GetMouseLocation напряму
    return UserInputService:GetMouseLocation()
end

local function getPart(plr)
    if not plr.Character then return nil end
    if S.Head then
        return plr.Character:FindFirstChild("Head")
            or plr.Character:FindFirstChild("UpperTorso")
    else
        return plr.Character:FindFirstChild("UpperTorso")
            or plr.Character:FindFirstChild("HumanoidRootPart")
    end
end

local function visible(part)
    if not S.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    return Workspace:Raycast(origin, part.Position - origin, params) == nil
end

local function findTarget()
    local mp = mousePos()
    local bestPart, bestDist = nil, S.Fov
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local skip = S.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if not skip and hum and hum.Health > 0 then
                local part = getPart(plr)
                if part then
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
                        if d < bestDist and visible(part) then
                            bestDist = d
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

--// ------------------------------------------------------------
--// FOV CIRCLE — Drawing.new (fallback Frame)
--// ------------------------------------------------------------
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
    fovCircle.Transparency = 0.6
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Visible = false
    print("[Aimbot] FOV circle: Drawing API")
else
    fovFrame = Instance.new("Frame")
    fovFrame.Name = "AimbotFOV"
    fovFrame.BackgroundTransparency = 1
    fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovFrame.Size = UDim2.fromOffset(S.Fov * 2, S.Fov * 2)
    fovFrame.Visible = false
    fovFrame.ZIndex = 500
    fovFrame.Parent = ScreenGui

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = fovFrame

    fovStroke = Instance.new("UIStroke")
    fovStroke.Color = Color3.fromRGB(255, 255, 255)
    fovStroke.Thickness = 1.5
    fovStroke.Transparency = 0.6
    fovStroke.Parent = fovFrame
    print("[Aimbot] FOV circle: Frame fallback")
end

--// ------------------------------------------------------------
--// СИНХРОНІЗАЦІЯ З UI
--// ------------------------------------------------------------
task.spawn(function()
    while task.wait(0.1) do
        if not _G.ModMenu or not _G.ModMenu.Elements then break end
        local ok, v
        ok, v = pcall(function() return E.AimEnabled:Get() end)     if ok then S.Enabled    = v end
        ok, v = pcall(function() return E.AimSmooth:Get() end)      if ok then S.Smoothness = v end
        ok, v = pcall(function() return E.AimFovSlider:Get() end)   if ok then S.Fov        = v end
        ok, v = pcall(function() return E.AimTeamCheck:Get() end)   if ok then S.TeamCheck  = v end
        ok, v = pcall(function() return E.AimWallCheck:Get() end)   if ok then S.WallCheck  = v end
        ok, v = pcall(function() return E.AimTargetPart:Get() end)  if ok then S.Head       = v end
    end
end)

--// ------------------------------------------------------------
--// ЗНІМАЄМО СТАРИЙ BIND (якщо є)
--// ------------------------------------------------------------
pcall(function() RunService:UnbindFromRenderStep("FotliAimbot") end)
pcall(function() RunService:UnbindFromRenderStep("FotliAimbotV3") end)

--// ------------------------------------------------------------
--// ГОЛОВНИЙ ЦИКЛ
--// ------------------------------------------------------------
RunService:BindToRenderStep("FotliAimbotV3", Enum.RenderPriority.Camera.Value + 1, function(dt)
    --// Оновлюємо FOV circle
    if fovCircle then
        local mp = mousePos()
        fovCircle.Position = mp
        fovCircle.Radius = S.Fov
        fovCircle.Visible = S.Enabled
    elseif fovFrame then
        local mp = mousePos()
        fovFrame.Position = UDim2.fromOffset(mp.X, mp.Y)
        fovFrame.Size = UDim2.fromOffset(S.Fov * 2, S.Fov * 2)
        fovFrame.Visible = S.Enabled
    end

    if not S.Enabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        if fovCircle then fovCircle.Color = Color3.fromRGB(255, 255, 255) end
        if fovStroke then fovStroke.Color = Color3.fromRGB(255, 255, 255) end
        return
    end
    if not localAlive() then return end

    local target = findTarget()
    if not target then
        if fovCircle then fovCircle.Color = Color3.fromRGB(255, 255, 255) end
        if fovStroke then fovStroke.Color = Color3.fromRGB(255, 255, 255) end
        return
    end

    --// Підсвічуємо FOV червоним
    if fovCircle then fovCircle.Color = Color3.fromRGB(255, 60, 60) end
    if fovStroke then fovStroke.Color = Color3.fromRGB(255, 60, 60) end

    --// Плавне наведення
    --// Smoothness: 0.05 = майже миттєво, 1 = дуже плавно
    local cam = Camera
    local goal = CFrame.lookAt(cam.CFrame.Position, target.Position)
    local alpha = math.clamp(1 / math.max(S.Smoothness * 15, 1), 0.02, 0.5)
    cam.CFrame = cam.CFrame:Lerp(goal, alpha)
end)

print("[Aimbot] Aimbot v3 завантажено (Hold RMB для наведення)")
