--// ============================================================
--// features/aimbot.lua — Camera Aimbot (Hold RMB) — FIXED v2
--// Камера плавно наводиться на голову цілі, поки затиснута ПКМ
--// ============================================================

--// Чекаємо UI
repeat task.wait(0.1) until _G.ModMenu and _G.ModMenu.Elements
local E = _G.ModMenu.Elements

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

--// ---------- СТАН ----------
local S = {
    Enabled   = false,
    Smooth    = 0.25,
    Fov       = 150,
    Head      = true,
    TeamCheck = true,
    WallCheck = false,
}

--// ---------- ЗМІННІ ----------
local HoldingRMB = false
local CurrentTarget = nil
local Highlight = nil
local OldMouseBehavior = nil

--// ---------- FOV CIRCLE ----------
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(120, 90, 255)
FovCircle.Transparency = 0.7
FovCircle.Visible = false

--// ---------- ДОПОМІЖНІ ----------
local function Alive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetAimPart(plr)
    if not plr.Character then return nil end
    if S.Head then
        return plr.Character:FindFirstChild("Head")
            or plr.Character:FindFirstChild("UpperTorso")
    else
        return plr.Character:FindFirstChild("UpperTorso")
            or plr.Character:FindFirstChild("HumanoidRootPart")
    end
end

local function IsVisible(part)
    if not S.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir    = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    return workspace:Raycast(origin, dir, params) == nil
end

--// ---------- ПОШУК ЦІЛІ ----------
--// УВАГА: GetMouseLocation() враховує topbar (~36px зверху).
--// WorldToViewportPoint — НЕ враховує. Треба компенсувати.
local function GetMousePos()
    local inset = game:GetService("GuiService"):GetGuiInset()
    return UserInputService:GetMouseLocation() - Vector2.new(inset.X, inset.Y)
end

local function FindTarget()
    local mousePos = GetMousePos()
    local bestPart, bestPlayer, bestDist = nil, nil, S.Fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
            and Alive(plr)
            and not (S.TeamCheck and plr.Team and plr.Team == LocalPlayer.Team) then

            local part = GetAimPart(plr)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local sp = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (sp - mousePos).Magnitude
                    if dist < bestDist and IsVisible(part) then
                        bestDist   = dist
                        bestPart   = part
                        bestPlayer = plr
                    end
                end
            end
        end
    end
    return bestPart, bestPlayer
end

--// ---------- ПІДСВІТКА ----------
local function UpdateHighlight(plr)
    if Highlight then
        Highlight:Destroy()
        Highlight = nil
    end
    if plr and plr.Character then
        Highlight = Instance.new("Highlight")
        Highlight.Name          = "AimbotTargetHL"
        Highlight.Adornee       = plr.Character
        Highlight.FillColor     = Color3.fromRGB(255, 70, 90)
        Highlight.OutlineColor  = Color3.fromRGB(255, 200, 200)
        Highlight.FillTransparency    = 0.7
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode     = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent        = workspace
    end
end

--// ---------- ПКМ ----------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingRMB = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        HoldingRMB = false
        CurrentTarget = nil
        UpdateHighlight(nil)
    end
end)

--// ---------- СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        S.Enabled   = E.AimEnabled:Get()
        S.Smooth    = E.AimSmooth:Get()
        S.Fov       = E.AimFovSlider:Get()
        S.Head      = E.AimTargetPart:Get()
        S.TeamCheck = E.AimTeamCheck:Get()
        S.WallCheck = E.AimWallCheck:Get()

        FovCircle.Radius  = S.Fov
        FovCircle.Visible = S.Enabled
    end
end)

--// ---------- ГОЛОВНИЙ ЦИКЛ ----------
--// Використовуємо BindToRenderStep з пріоритетом ПІСЛЯ камери,
--// щоб наш CFrame не перезаписувався вбудованим camera script Roblox.
RunService:BindToRenderStep("FotliAimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
    --// FOV circle — центр екрана
    local vp = Camera.ViewportSize
    FovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)

    if not S.Enabled or not HoldingRMB then return end

    --// Оновлюємо ціль
    if not CurrentTarget or not Alive(CurrentTarget) then
        local part, plr = FindTarget()
        if part and plr then
            CurrentTarget = plr
            UpdateHighlight(plr)
        else
            CurrentTarget = nil
            UpdateHighlight(nil)
            return
        end
    end

    --// Точка цілі
    local part = GetAimPart(CurrentTarget)
    if not part then
        CurrentTarget = nil
        UpdateHighlight(nil)
        return
    end

    --// Плавне наведення
    --// Smooth: 0.05 = миттєво, 1 = плавно
    --// Формула: alpha = 1 - smooth^dt  → стабільна незалежно від FPS
    local camPos = Camera.CFrame.Position
    local targetCFrame = CFrame.new(camPos, part.Position)

    local smooth = math.clamp(S.Smooth, 0.01, 1)
    local alpha  = 1 - math.pow(smooth, dt)

    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
end)

print("[Aimbot] Camera Aimbot v2 завантажено (Hold RMB)")
