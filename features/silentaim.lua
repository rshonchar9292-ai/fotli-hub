--// ============================================================
--// features/silentaim.lua — FORTLINE Silent Aim
--// Працює через hookmetamethod(__namecall) для перехоплення пострілів
--// ============================================================

--// 1. Чекаємо на UI
repeat task.wait(0.1) until _G.ModMenu and _G.ModMenu.Elements
local E = _G.ModMenu.Elements

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 2. Стан (читається з UI у циклі)
local S = {
    Enabled   = false,
    Fov       = 200,
    HitChance = 100,
    Head      = true,
    TeamCheck = true,
    ShowFov   = true,
}

--// 3. Змінні
local CurrentTarget = nil
local oldNamecall = nil
local HookInstalled = false
local fovCircle = nil

--// 4. FOV Circle
if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 1.5
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(150, 18, 220) -- фіолетовий
    fovCircle.Transparency = 0.7
    fovCircle.Visible = false
end

--// 5. Допоміжні функції
local function isAlive(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTargetPart(plr)
    local char = plr.Character
    if not char then return nil end
    if S.Head then
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
    else
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    end
end

--// 6. Пошук цілі
local function findTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local bestPlr, bestDist = nil, S.Fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            if not (S.TeamCheck and plr.Team == LocalPlayer.Team) then
                local part = getTargetPart(plr)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestPlr = plr
                        end
                    end
                end
            end
        end
    end
    return bestPlr
end

--// 7. Хук __namecall
local function installHook()
    if HookInstalled then return end
    HookInstalled = true

    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if S.Enabled and CurrentTarget and (method == "FireServer" or method == "InvokeServer") then
            if math.random(1, 100) <= S.HitChance then
                local targetPart = getTargetPart(CurrentTarget)
                if targetPart then
                    for i, arg in ipairs(args) do
                        local argType = typeof(arg)
                        if argType == "Vector3" then
                            args[i] = targetPart.Position
                        elseif argType == "CFrame" then
                            args[i] = CFrame.new(arg.Position, targetPart.Position)
                        end
                    end
                    return oldNamecall(self, table.unpack(args))
                end
            end
        end
        return oldNamecall(self, ...)
    end))
end

--// 8. Синхронізація з UI
task.spawn(function()
    while task.wait(0.1) do
        if not (_G.ModMenu and _G.ModMenu.Elements) then break end
        S.Enabled   = E.SilentEnabled:Get()
        S.Fov       = E.SilentFovSlider:Get()
        S.HitChance = E.SilentHitChance:Get()
        S.Head      = E.AimTargetPart:Get()
        S.TeamCheck = E.AimTeamCheck:Get()
        S.ShowFov   = E.SilentShowFov:Get()

        if fovCircle then
            fovCircle.Radius = S.Fov
            fovCircle.Visible = S.Enabled and S.ShowFov
        end
    end
end)

--// 9. Головний цикл
RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Position = UserInputService:GetMouseLocation()
    end

    if not S.Enabled then
        CurrentTarget = nil
        return
    end

    CurrentTarget = findTarget()
end)

--// 10. Запуск
task.spawn(function()
    task.wait(1)
    local ok, err = pcall(installHook)
    if ok then
        print("[Fortline-SilentAim] Hook installed successfully")
    else
        warn("[Fortline-SilentAim] Hook error:", err)
    end
end)

print("[Fortline-SilentAim] Silent Aim loaded")
