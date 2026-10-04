--// ============================================================
--// features/silentaim.lua — Silent Aim
--// Кульки летять у ворога, камера НЕ рухається
--// Працює через hookmetamethod __namecall (перехоплення FireServer)
--// ============================================================

--// Чекаємо UI
repeat task.wait(0.1) until _G.ModMenu and _G.ModMenu.Elements
local E = _G.ModMenu.Elements

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

--// ---------- СТАН (читається з UI у циклі) ----------
local S = {
    Enabled   = false,
    ShowFov   = true,
    Fov       = 150,
    HitChance = 100,
    Head      = true,
    TeamCheck = true,
    WallCheck = false,
}

--// ---------- ЗМІННІ ----------
local CurrentTarget = nil
local oldNamecall   = nil
local HookInstalled = false

--// ---------- FOV CIRCLE (Drawing) ----------
local SilentCircle = Drawing.new("Circle")
SilentCircle.Thickness = 1.5
SilentCircle.NumSides = 64
SilentCircle.Filled = false
SilentCircle.Color = Color3.fromRGB(80, 200, 255)   -- блакитне
SilentCircle.Transparency = 0.7
SilentCircle.Visible = false

--// ---------- ДОПОМІЖНІ ----------
local function Alive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetAimPart(plr)
    if not plr or not plr.Character then return nil end
    if S.Head then
        return plr.Character:FindFirstChild("Head")
            or plr.Character:FindFirstChild("UpperTorso")
    else
        return plr.Character:FindFirstChild("UpperTorso")
            or plr.Character:FindFirstChild("Torso")
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
-- Знаходимо найближчого до центру екрана ворога в радіусі FOV
local function FindTarget()
    local screenCenter = Camera.ViewportSize / 2
    local bestPart, bestPlayer, bestDist = nil, nil, S.Fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
            and Alive(plr)
            and not (S.TeamCheck and plr.Team and plr.Team == LocalPlayer.Team) then

            local part = GetAimPart(plr)
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local pos  = Vector2.new(sp.X, sp.Y)
                    local dist = (pos - screenCenter).Magnitude
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

--// ---------- ПЕРЕВІРКА АРГУМЕНТІВ ----------
-- У FireServer-аргументах шукаємо Vector3 або CFrame, які схожі на "точку влучання"
local function LooksLikeAimArg(arg)
    local t = typeof(arg)
    if t == "Vector3" then
        local dist = (arg - Camera.CFrame.Position).Magnitude
        return dist > 5 and dist < 5000
    elseif t == "CFrame" then
        return true
    end
    return false
end

--// ---------- ХУК __namecall ----------
local function InstallHook()
    if HookInstalled then return end
    HookInstalled = true

    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        -- Перехоплюємо тільки FireServer / InvokeServer
        if S.Enabled
            and (method == "FireServer" or method == "InvokeServer")
            and CurrentTarget then

            -- Шанс влучання
            if math.random(1, 100) <= S.HitChance then
                local part = GetAimPart(CurrentTarget)
                if part then
                    local targetPos = part.Position

                    for i, arg in ipairs(args) do
                        if LooksLikeAimArg(arg) then
                            local t = typeof(arg)
                            if t == "Vector3" then
                                args[i] = targetPos
                            elseif t == "CFrame" then
                                -- Зберігаємо позицію, змінюємо напрямок на ціль
                                args[i] = CFrame.new(arg.Position, targetPos)
                            end
                        end
                    end

                    return oldNamecall(self, unpack(args))
                end
            end
        end

        return oldNamecall(self, ...)
    end))
end

--// ---------- СИНХРОНІЗАЦІЯ З UI ----------
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        S.Enabled   = E.SilentEnabled:Get()
        S.ShowFov   = E.SilentShowFov:Get()
        S.Fov       = E.SilentFovSlider:Get()
        S.HitChance = E.SilentHitChance:Get()
        S.Head      = E.AimTargetPart:Get()
        S.TeamCheck = E.AimTeamCheck:Get()
        S.WallCheck = E.AimWallCheck:Get()

        -- FOV Circle
        SilentCircle.Radius  = S.Fov
        SilentCircle.Visible = S.Enabled and S.ShowFov
    end
end)

--// ---------- ГОЛОВНИЙ ЦИКЛ ----------
RunService.RenderStepped:Connect(function(dt)
    -- FOV коло завжди по центру екрана
    local vp = Camera.ViewportSize
    SilentCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)

    if not S.Enabled then
        CurrentTarget = nil
        return
    end

    -- Оновлюємо ціль
    if not CurrentTarget or not Alive(CurrentTarget) then
        local _, plr = FindTarget()
        CurrentTarget = plr
    else
        -- Перевіряємо, чи ціль ще в радіусі FOV
        local part = GetAimPart(CurrentTarget)
        if part then
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local pos  = Vector2.new(sp.X, sp.Y)
                local dist = (pos - vp / 2).Magnitude
                if dist > S.Fov then
                    CurrentTarget = nil
                end
            else
                CurrentTarget = nil
            end
        else
            CurrentTarget = nil
        end
    end
end)

--// ---------- ВСТАНОВЛЕННЯ ХУКА ----------
task.spawn(function()
    task.wait(1)
    local ok, err = pcall(InstallHook)
    if ok then
        print("[SilentAim] Hook встановлено")
    else
        warn("[SilentAim] Не вдалося встановити hook:", err)
    end
end)

print("[SilentAim] Silent Aim завантажено")
