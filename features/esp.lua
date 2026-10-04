--// ============================================================
--// features/esp.lua — Player Highlight ESP
--// Повна підсвітка моделі гравця через Highlight
--// ============================================================

-- Чекаємо UI
repeat task.wait(0.1) until _G.ModMenu and _G.ModMenu.Elements
local E = _G.ModMenu.Elements

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

--// ---------- СТАН ----------
local S = {
    Enabled   = false,
    Fill      = true,
    Outline   = true,
    SeeThru   = true,
    TeamCheck = true,
    MaxDist   = 1500,
    FillAlpha = 0.35,
}

--// ---------- КОЛЬОРИ ----------
local COL = {
    EnemyFill    = Color3.fromRGB(255, 70, 90),
    EnemyOutline = Color3.fromRGB(255, 200, 200),
    TeamFill     = Color3.fromRGB(70, 220, 120),
    TeamOutline  = Color3.fromRGB(200, 255, 220),
    NeutralFill  = Color3.fromRGB(120, 90, 255),
    NeutralOutl  = Color3.fromRGB(220, 210, 255),
}

--// ---------- СХОВИЩЕ ----------
local Highlights = {}   -- [player] = Highlight

--// ---------- ДОПОМІЖНІ ----------
local function Alive(plr)
    if not plr or not plr.Character then return false end
    local h = plr.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function GetColors(plr)
    if plr.Team and LocalPlayer.Team then
        if plr.Team == LocalPlayer.Team then
            return COL.TeamFill, COL.TeamOutline
        else
            return COL.EnemyFill, COL.EnemyOutline
        end
    end
    return COL.NeutralFill, COL.NeutralOutl
end

--// Створення Highlight для гравця
local function Create(plr)
    if Highlights[plr] then return end
    if plr == LocalPlayer then return end

    local hl = Instance.new("Highlight")
    hl.Name            = "FotliESP"
    hl.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor       = COL.NeutralFill
    hl.OutlineColor    = COL.NeutralOutl
    hl.FillTransparency    = 1 - S.FillAlpha
    hl.OutlineTransparency = 0
    hl.Adornee         = nil    -- буде встановлено при оновленні
    hl.Parent          = game:GetService("CoreGui")

    Highlights[plr] = hl
end

local function Remove(plr)
    local hl = Highlights[plr]
    if hl then
        pcall(function() hl:Destroy() end)
        Highlights[plr] = nil
    end
end

--// Оновлення одного гравця
local function Update(plr)
    local hl = Highlights[plr]
    if not hl then return end

    -- Перевірки
    if not S.Enabled
        or plr == LocalPlayer
        or not Alive(plr)
        or (S.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team) then
        hl.Enabled = false
        return
    end

    local char = plr.Character
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    if not hrp then hl.Enabled = false return end

    -- Дистанція
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > S.MaxDist then
        hl.Enabled = false
        return
    end

    -- Кольори
    local fillColor, outlineColor = GetColors(plr)

    -- Застосовуємо
    hl.Adornee             = char
    hl.Enabled             = true
    hl.FillColor           = fillColor
    hl.OutlineColor        = outlineColor
    hl.FillTransparency    = S.Fill and (1 - S.FillAlpha) or 1
    hl.OutlineTransparency = S.Outline and 0 or 1
    hl.DepthMode           = S.SeeThru
        and Enum.HighlightDepthMode.AlwaysOnTop
        or  Enum.HighlightDepthMode.Occluded
end

--// ---------- ПІДПИСКИ ----------
Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    Create(plr)
end)

Players.PlayerRemoving:Connect(Remove)

-- Створюємо для тих, хто вже у грі
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then Create(plr) end
end

--// ---------- СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        S.Enabled   = E.EspEnabled:Get()
        S.Fill      = E.EspFill:Get()
        S.Outline   = E.EspOutline:Get()
        S.SeeThru   = E.EspSeeThru:Get()
        S.TeamCheck = E.EspTeamCheck:Get()
        S.MaxDist   = E.EspMaxDist:Get()
        S.FillAlpha = E.EspFillAlpha:Get()
    end
end)

--// ---------- ГОЛОВНИЙ ЦИКЛ ----------
RunService.RenderStepped:Connect(function()
    for plr, hl in pairs(Highlights) do
        if plr.Parent and plr.Character then
            Update(plr)
        else
            hl.Enabled = false
        end
    end
end)

print("[ESP] Player Highlight завантажено")
