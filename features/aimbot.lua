--// ============================================================
--// features/aimbot.lua — Aimbot (як у Fleece's Utility Panel)
--// 4 методи: Smooth Aim, Instant Snap, Move Cursor, Silent Aim
--// Працює з UI через _G.ModMenu.Elements
--// ============================================================

--// Чекаємо UI
repeat task.wait(0.1) until _G.ModMenu and _G.ModMenu.Elements
local E = _G.ModMenu.Elements

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

--// ---------- СТАН ----------
local S = {
    Enabled      = false,
    Method       = "camerasmooth",  -- camerasmooth | camerasnap | mousemove | silent
    Part         = "Head",          -- Head | Torso | HumanoidRootPart | closest
    Smoothness   = 10,
    Fov          = 160,
    ShowFov      = true,
    TeamCheck    = false,
    WallCheck    = true,
    HoldRMB      = true,
}

--// ---------- ДОПОМІЖНІ ----------
local function Alive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function LocalAlive()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

--// ---------- ОТРИМАННЯ ПОЗИЦІЇ МИШІ ----------
local function aimOrigin()
    local inset = game:GetService("GuiService"):GetGuiInset()
    return UserInputService:GetMouseLocation() - Vector2.new(inset.X, inset.Y)
end

--// ---------- ВИБІР ЧАСТИНИ ДЛЯ АІМУ ----------
local AIM_PART_SETS = {
    Head           = { "Head" },
    Torso          = { "UpperTorso", "Torso" },
    HumanoidRootPart = { "HumanoidRootPart" },
}

local function aimPartOf(char, key)
    if key == "Closest" or key == "closest" then
        --// Найближча до курсора частина серед усіх
        local best, bestD
        local cursor = aimOrigin()
        for _, list in pairs(AIM_PART_SETS) do
            for _, n in ipairs(list) do
                local part = char:FindFirstChild(n)
                if part and part:IsA("BasePart") then
                    local sp = Camera:WorldToViewportPoint(part.Position)
                    if sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - cursor).Magnitude
                        if not bestD or d < bestD then best, bestD = part, d end
                    end
                end
            end
        end
        return best or char:FindFirstChild("HumanoidRootPart")
    end
    for _, n in ipairs(AIM_PART_SETS[key] or AIM_PART_SETS.Head) do
        local part = char:FindFirstChild(n)
        if part and part:IsA("BasePart") then return part end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

--// ---------- WALL CHECK (чи видно ціль) ----------
local hasLineOfSight
do
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local filter = table.create(2)

    function hasLineOfSight(part)
        local origin = Camera.CFrame.Position
        local char = LocalPlayer.Character
        filter[1] = char
        filter[2] = part.Parent
        params.FilterDescendantsInstances = filter
        return Workspace:Raycast(origin, part.Position - origin, params) == nil
    end
end

--// ---------- ЧИ ТРИМАЄ ГРАВЕЦЬ ПКМ ----------
local function holdActive()
    if not S.HoldRMB then return true end
    return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

--// ---------- ПОШУК ЦІЛІ ----------
local function findAimTarget()
    if not Camera or not LocalAlive() then return nil end
    local cursor = aimOrigin()
    local best, bestD

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local skip = S.TeamCheck and p.Team == LocalPlayer.Team
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if not skip and hum and hum.Health > 0 then
                local part = aimPartOf(p.Character, S.Part)
                if part then
                    local sp = Camera:WorldToViewportPoint(part.Position)
                    if sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - cursor).Magnitude
                        if d <= S.Fov and (not bestD or d < bestD) then
                            if not S.WallCheck or hasLineOfSight(part) then
                                best, bestD = part, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

--// ---------- FOV CIRCLE ----------
local fovCircle
do
    --// Використовуємо Frame (як у Fleece), щоб працювало навіть без Drawing
    local screen = _G.ModMenu.ScreenGui
    local ring = Instance.new("Frame")
    ring.Name = "AimbotFovCircle"
    ring.BackgroundTransparency = 1
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Size = UDim2.new(0, 320, 0, 320)
    ring.Visible = false
    ring.ZIndex = 450
    ring.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ring

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.45
    stroke.Parent = ring

    fovCircle = { Frame = ring, Stroke = stroke }
end

--// ---------- SILENT AIM (окремо) ----------
local silentMouse = LocalPlayer:GetMouse()
local silentTarget = nil
local silentHookInstalled = false

local function installSilentHook()
    if silentHookInstalled then return end
    silentHookInstalled = true

    local original
    original = hookmetamethod(game, "__index", newcclosure(function(self, key)
        if not checkcaller() and self == silentMouse and silentTarget and silentTarget.Parent then
            if key == "Hit" then return CFrame.new(silentTarget.Position) end
            if key == "Target" then return silentTarget end
        end
        return original(self, key)
    end))
end

--// ---------- ГОЛОВНИЙ ЦИКЛ ----------
RunService:BindToRenderStep("FotliAimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
    --// Оновлюємо FOV circle
    if fovCircle then
        local pos = aimOrigin()
        fovCircle.Frame.Position = UDim2.fromOffset(pos.X, pos.Y)
        fovCircle.Frame.Size = UDim2.fromOffset(S.Fov * 2, S.Fov * 2)
        fovCircle.Frame.Visible = S.Enabled and S.ShowFov
        fovCircle.Stroke.Color = silentTarget and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 255, 255)
    end

    if not S.Enabled then
        silentTarget = nil
        return
    end

    --// Silent Aim — окремий потік
    if S.Method == "silent" then
        if not holdActive() then
            silentTarget = nil
            return
        end
        silentTarget = findAimTarget()
        return
    end

    --// Інші методи — звичайні
    if not LocalAlive() or not holdActive() then return end
    local target = findAimTarget()
    if not target then return end

    --// SMOOTH AIM
    if S.Method == "camerasmooth" then
        local cam = Camera
        local goal = CFrame.lookAt(cam.CFrame.Position, target.Position)
        local smooth = math.max(S.Smoothness, 1)
        cam.CFrame = cam.CFrame:Lerp(goal, 1 / smooth * 60 * dt)

    --// INSTANT SNAP
    elseif S.Method == "camerasnap" then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)

    --// MOVE CURSOR (переміщує мишу)
    elseif S.Method == "mousemove" then
        local sp = Camera:WorldToViewportPoint(target.Position)
        if sp.Z > 0 then
            local cursor = aimOrigin()
            local delta = Vector2.new(sp.X, sp.Y) - cursor
            local step = math.max(S.Smoothness, 1)
            pcall(function() mousemoverel(delta.X / step, delta.Y / step) end)
        end
    end
end)

--// ---------- СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end

        --// Основні
        S.Enabled   = E.AimEnabled:Get()
        S.Smoothness = E.AimSmooth:Get()
        S.Fov       = E.AimFovSlider:Get()
        S.TeamCheck = E.AimTeamCheck:Get()
        S.WallCheck = E.AimWallCheck:Get()

        --// Aim at Head → вибір частини
        S.Part = E.AimTargetPart:Get() and "Head" or "Torso"

        --// Silent Aim
        if E.SilentEnabled and E.SilentEnabled:Get() then
            S.Method = "silent"
            if not silentHookInstalled then installSilentHook() end
        elseif S.Method == "silent" then
            S.Method = "camerasmooth"
            silentTarget = nil
        end
    end
end)

print("[Aimbot] Fleece-style Aimbot завантажено (Hold RMB)")
