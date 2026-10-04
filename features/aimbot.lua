--// ============================================================
--// features/aimbot.lua — Camera Aimbot (Hold RMB)
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
    Smooth    = 0.25,      -- 0.05 = швидко, 1 = повільно
    Fov       = 150,       -- радіус FOV у пікселях
    Head      = true,      -- цілитись у голову
    TeamCheck = true,
    WallCheck = false,
}

--// ---------- ЗМІННІ ----------
local HoldingRMB = false
local CurrentTarget = nil
local Highlight = nil      -- підсвітка цілі

--// ---------- FOV CIRCLE (Drawing) ----------
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
    return S.Head
        and plr.Character:FindFirstChild("Head")
        or  plr.Character:FindFirstChild("UpperTorso")
        or  plr.Character:FindFirstChild("Torso")
end

local function IsVisible(part)
    if not S.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir    = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

--// ---------- ПОШУК НАЙКРАЩОЇ ЦІЛІ ----------
local function FindTarget()
    local mousePos = UserInputService:GetMouseLocation()
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

--// ---------- ПІДСВІТКА ЦІЛІ ----------
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

--// ---------- ПКМ: ВКЛ / ВИКЛ ----------
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

        -- FOV Circle
        FovCircle.Radius  = S.Fov
        FovCircle.Visible = S.Enabled
    end
end)

--// ---------- ГОЛОВНИЙ ЦИКЛ ----------
RunService.RenderStepped:Connect(function(dt)
    -- Позиція FOV-кола — центр екрана (як у CS:GO / Valorant)
    local viewport = Camera.ViewportSize
    FovCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)

    -- Якщо не активовано / не тримаємо ПКМ — нічого не робимо
    if not S.Enabled or not HoldingRMB then return end

    -- Знаходимо ціль (або оновлюємо)
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

    -- Отримуємо точку цілі
    local part = GetAimPart(CurrentTarget)
    if not part then
        CurrentTarget = nil
        UpdateHighlight(nil)
        return
    end

    -- Плавне наведення камери
    local camPos = Camera.CFrame.Position
    local targetCFrame = CFrame.new(camPos, part.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(S.Smooth * 60 * dt, 0, 1))
end)

print("[Aimbot] Camera Aimbot завантажено (Hold RMB)")
