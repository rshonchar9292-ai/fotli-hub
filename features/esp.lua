--// ============================================================
--// features/esp.lua
--// Player ESP: Box, Name, Health, Distance, Tracer
--// ============================================================

-- Чекаємо UI
repeat task.wait(0.1) until _G.ModMenu and _G.ModMenu.Elements
local E = _G.ModMenu.Elements

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

--// Стан (читається з UI у циклі)
local State = {
    Enabled     = false,
    Box         = false,
    Name        = false,
    Health      = false,
    Distance    = false,
    Tracer      = false,
    TeamCheck   = true,
    MaxDistance = 1000,
}

--// Чи є Drawing API
local hasDrawing = pcall(function()
    local d = Drawing.new("Square")
    d:Remove()
end)

if not hasDrawing then
    warn("[ESP] Drawing API недоступний — ESP не працюватиме")
    return
end

local Drawings = {}  -- [player] = {Box=, Name=, ...}

--// Допоміжні
local function IsAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end

local function CreateESP(plr)
    if Drawings[plr] then return end

    local d = {}
    d.Box = Drawing.new("Square")
    d.Box.Thickness = 1
    d.Box.Filled = false
    d.Box.Color = Color3.fromRGB(120, 90, 255)
    d.Box.Visible = false

    d.Name = Drawing.new("Text")
    d.Name.Size = 14
    d.Name.Center = true
    d.Name.Outline = true
    d.Name.Color = Color3.fromRGB(255, 255, 255)
    d.Name.Visible = false

    d.Distance = Drawing.new("Text")
    d.Distance.Size = 12
    d.Distance.Center = true
    d.Distance.Outline = true
    d.Distance.Color = Color3.fromRGB(200, 200, 220)
    d.Distance.Visible = false

    d.HealthBg = Drawing.new("Square")
    d.HealthBg.Thickness = 1
    d.HealthBg.Filled = true
    d.HealthBg.Color = Color3.fromRGB(30, 30, 30)
    d.HealthBg.Transparency = 0.5
    d.HealthBg.Visible = false

    d.Health = Drawing.new("Square")
    d.Health.Thickness = 1
    d.Health.Filled = true
    d.Health.Color = Color3.fromRGB(80, 220, 140)
    d.Health.Visible = false

    d.Tracer = Drawing.new("Line")
    d.Tracer.Thickness = 1
    d.Tracer.Color = Color3.fromRGB(120, 90, 255)
    d.Tracer.Visible = false

    Drawings[plr] = d
end

local function RemoveESP(plr)
    local d = Drawings[plr]
    if not d then return end
    for _, obj in pairs(d) do
        pcall(function() obj:Remove() end)
    end
    Drawings[plr] = nil
end

local function HideAll(d)
    for _, obj in pairs(d) do
        pcall(function() obj.Visible = false end)
    end
end

--// Оновлення одного гравця
local function UpdateESP(plr)
    local d = Drawings[plr]
    if not d then return end

    if not State.Enabled
        or plr == LocalPlayer
        or (State.TeamCheck and plr.Team == LocalPlayer.Team and plr.Team ~= nil)
        or not IsAlive(plr) then
        HideAll(d)
        return
    end

    local char = plr.Character
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and head and hum) then HideAll(d) return end

    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > State.MaxDistance then HideAll(d) return end

    -- World → Screen
    local topPos    = head.Position + Vector3.new(0, 0.5, 0)
    local bottomPos = hrp.Position - Vector3.new(0, 3, 0)

    local topSP, topOn       = Camera:WorldToViewportPoint(topPos)
    local bottomSP, bottomOn = Camera:WorldToViewportPoint(bottomPos)

    if not (topOn and bottomOn) then HideAll(d) return end

    local topV    = Vector2.new(topSP.X, topSP.Y)
    local bottomV = Vector2.new(bottomSP.X, bottomSP.Y)

    local height = math.abs(bottomV.Y - topV.Y)
    local width  = height * 0.55
    local boxPos = Vector2.new(topV.X - width / 2, topV.Y)

    -- BOX
    if State.Box then
        d.Box.Visible  = true
        d.Box.Position = boxPos
        d.Box.Size     = Vector2.new(width, height)
    else
        d.Box.Visible = false
    end

    -- NAME
    if State.Name then
        d.Name.Visible  = true
        d.Name.Position = Vector2.new(boxPos.X + width / 2, boxPos.Y - 16)
        d.Name.Text     = plr.Name
    else
        d.Name.Visible = false
    end

    -- DISTANCE
    if State.Distance then
        d.Distance.Visible  = true
        d.Distance.Position = Vector2.new(boxPos.X + width / 2, boxPos.Y + height + 4)
        d.Distance.Text     = string.format("[%d]", math.floor(dist))
    else
        d.Distance.Visible = false
    end

    -- HEALTH
    if State.Health then
        local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barW  = 3
        local barX  = boxPos.X - barW - 3

        d.HealthBg.Visible  = true
        d.HealthBg.Position = Vector2.new(barX, boxPos.Y)
        d.HealthBg.Size     = Vector2.new(barW, height)

        d.Health.Visible  = true
        d.Health.Position = Vector2.new(barX, boxPos.Y + height * (1 - ratio))
        d.Health.Size     = Vector2.new(barW, height * ratio)

        if ratio > 0.6 then
            d.Health.Color = Color3.fromRGB(80, 220, 140)
        elseif ratio > 0.3 then
            d.Health.Color = Color3.fromRGB(240, 200, 80)
        else
            d.Health.Color = Color3.fromRGB(240, 80, 100)
        end
    else
        d.HealthBg.Visible = false
        d.Health.Visible   = false
    end

    -- TRACER
    if State.Tracer then
        d.Tracer.Visible = true
        d.Tracer.From    = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        d.Tracer.To      = Vector2.new(boxPos.X + width / 2, boxPos.Y + height)
    else
        d.Tracer.Visible = false
    end
end

--// Підписки на гравців
Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    CreateESP(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
    RemoveESP(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        CreateESP(plr)
    end
end

--// Синхронізація стану з UI (раз на 0.1 сек)
task.spawn(function()
    while task.wait(0.1) do
        if not _G.ModMenu or not _G.ModMenu.Elements then break end
        State.Enabled     = E.EspEnabled:Get()
        State.Box         = E.EspBox:Get()
        State.Name        = E.EspName:Get()
        State.Health      = E.EspHealth:Get()
        State.Distance    = E.EspDistance:Get()
        State.Tracer      = E.EspTracer:Get()
        State.TeamCheck   = E.EspTeamCheck:Get()
        State.MaxDistance = E.EspMaxDist:Get()
    end
end)

--// Головний цикл малювання
RunService.RenderStepped:Connect(function()
    for plr, _ in pairs(Drawings) do
        if plr.Parent then
            UpdateESP(plr)
        else
            RemoveESP(plr)
        end
    end
end)

print("[ESP] Модуль завантажено з features/esp.lua")
