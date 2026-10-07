--// ============================================================
--// ui.lua — Fotli Hub UI (v2 with FOV/BunnyHop/AntiAim)
--// Вкладки зліва, F4 toggle
--// ============================================================

if game:GetService("CoreGui"):FindFirstChild("ModMenuUI") then
    game:GetService("CoreGui"):FindFirstChild("ModMenuUI"):Destroy()
end

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

local COLORS = {
    Background    = Color3.fromRGB(15, 15, 22),
    BackgroundAlt = Color3.fromRGB(22, 22, 32),
    Element       = Color3.fromRGB(30, 30, 42),
    ElementHover  = Color3.fromRGB(40, 40, 55),
    Stroke        = Color3.fromRGB(60, 60, 85),
    Accent        = Color3.fromRGB(120, 90, 255),
    Accent2       = Color3.fromRGB(80, 200, 255),
    Text          = Color3.fromRGB(230, 230, 245),
    TextDim       = Color3.fromRGB(150, 150, 170),
    Success       = Color3.fromRGB(80, 220, 140),
    Danger        = Color3.fromRGB(240, 80, 100),
}

local WINDOW_W = 720
local WINDOW_H = 500
local TABS_W   = 150

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
MainFrame.Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.Stroke
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

--// TitleBar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = COLORS.BackgroundAlt
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 14)
TitleBarCorner.Parent = TitleBar

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 14)
TitleBarFix.Position = UDim2.new(0, 0, 1, -14)
TitleBarFix.BackgroundColor3 = COLORS.BackgroundAlt
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 2
TitleBarFix.Parent = TitleBar

local GradientHolder = Instance.new("Frame")
GradientHolder.Size = UDim2.new(1, 0, 0, 2)
GradientHolder.Position = UDim2.new(0, 0, 1, -2)
GradientHolder.BackgroundTransparency = 1
GradientHolder.ZIndex = 4
GradientHolder.Parent = TitleBar

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, COLORS.Accent),
    ColorSequenceKeypoint.new(0.5, COLORS.Accent2),
    ColorSequenceKeypoint.new(1.0, COLORS.Accent),
})
Gradient.Parent = GradientHolder

task.spawn(function()
    local offset = 0
    while GradientHolder.Parent do
        offset = offset + 0.01
        if offset > 1 then offset = 0 end
        Gradient.Offset = Vector2.new(offset, 0)
        task.wait(0.03)
    end
end)

local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 8, 0, 8)
LogoDot.Position = UDim2.new(0, 16, 0.5, -4)
LogoDot.BackgroundColor3 = COLORS.Accent
LogoDot.BorderSizePixel = 0
LogoDot.ZIndex = 3
LogoDot.Parent = TitleBar

local LogoDotCorner = Instance.new("UICorner")
LogoDotCorner.CornerRadius = UDim.new(1, 0)
LogoDotCorner.Parent = LogoDot

local LogoDotGlow = Instance.new("UIStroke")
LogoDotGlow.Color = COLORS.Accent
LogoDotGlow.Thickness = 2
LogoDotGlow.Transparency = 0.3
LogoDotGlow.Parent = LogoDot

task.spawn(function()
    while LogoDot.Parent do
        TweenService:Create(LogoDotGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.8}):Play()
        task.wait(1)
        TweenService:Create(LogoDotGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.2}):Play()
        task.wait(1)
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -180, 1, 0)
TitleLabel.Position = UDim2.new(0, 32, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FOTLI HUB   [F4]"
TitleLabel.TextColor3 = COLORS.Text
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 26, 0, 26)
MinimizeButton.Position = UDim2.new(1, -68, 0.5, -13)
MinimizeButton.BackgroundColor3 = COLORS.Element
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = COLORS.Text
MinimizeButton.TextSize = 18
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.AutoButtonColor = false
MinimizeButton.ZIndex = 3
MinimizeButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinimizeButton

MinimizeButton.MouseEnter:Connect(function()
    TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover}):Play()
end)
MinimizeButton.MouseLeave:Connect(function()
    TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
end)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -36, 0.5, -13)
CloseButton.BackgroundColor3 = COLORS.Element
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = COLORS.Text
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 3
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Danger}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
end)

--// TabsFrame — зліва
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(0, TABS_W, 1, -58)
TabsFrame.Position = UDim2.new(0, 12, 0, 50)
TabsFrame.BackgroundColor3 = COLORS.BackgroundAlt
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame

local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = UDim.new(0, 10)
TabsCorner.Parent = TabsFrame

local TabsPadding = Instance.new("UIPadding")
TabsPadding.PaddingTop = UDim.new(0, 10)
TabsPadding.PaddingBottom = UDim.new(0, 10)
TabsPadding.PaddingLeft = UDim.new(0, 10)
TabsPadding.PaddingRight = UDim.new(0, 10)
TabsPadding.Parent = TabsFrame

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 8)
TabsLayout.Parent = TabsFrame

--// ContentFrame — справа
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -TABS_W - 36, 1, -58)
ContentFrame.Position = UDim2.new(0, TABS_W + 24, 0, 50)
ContentFrame.BackgroundColor3 = COLORS.BackgroundAlt
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = COLORS.Accent
ContentFrame.ScrollBarImageTransparency = 0.3
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentFrame

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 12)
ContentPadding.PaddingBottom = UDim.new(0, 12)
ContentPadding.PaddingLeft = UDim.new(0, 12)
ContentPadding.PaddingRight = UDim.new(0, 12)
ContentPadding.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentFrame

local Tabs, TabPages, ActiveTab = {}, {}, nil

local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 38)
    TabButton.BackgroundColor3 = COLORS.Element
    TabButton.BorderSizePixel = 0
    TabButton.Text = "  " .. name
    TabButton.TextColor3 = COLORS.TextDim
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.AutoButtonColor = false
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabsFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = COLORS.Stroke
    TabStroke.Thickness = 1
    TabStroke.Transparency = 0.5
    TabStroke.Parent = TabButton

    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 3, 0, 0)
    AccentBar.Position = UDim2.new(0, 0, 0.5, 0)
    AccentBar.BackgroundColor3 = COLORS.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = TabButton

    local AccentBarCorner = Instance.new("UICorner")
    AccentBarCorner.CornerRadius = UDim.new(1, 0)
    AccentBarCorner.Parent = AccentBar

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = ContentFrame

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = Page

    Tabs[name] = {Button = TabButton, AccentBar = AccentBar, Stroke = TabStroke}
    TabPages[name] = Page

    TabButton.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover}):Play()
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
        end
    end)

    TabButton.MouseButton1Click:Connect(function()
        for tabName, data in pairs(Tabs) do
            TweenService:Create(data.Button, TweenInfo.new(0.2), {
                BackgroundColor3 = COLORS.Element,
                TextColor3 = COLORS.TextDim,
            }):Play()
            TweenService:Create(data.AccentBar, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            TweenService:Create(data.Stroke, TweenInfo.new(0.2), {
                Color = COLORS.Stroke,
                Transparency = 0.5,
            }):Play()
            TabPages[tabName].Visible = false
        end

        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.ElementHover,
            TextColor3 = COLORS.Text,
        }):Play()
        TweenService:Create(AccentBar, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 3, 0, 26),
        }):Play()
        TweenService:Create(TabStroke, TweenInfo.new(0.2), {
            Color = COLORS.Accent,
            Transparency = 0,
        }):Play()

        Page.Visible = true
        ActiveTab = name
    end)

    return Page
end

local function CreateToggle(parent, text, default, callback)
    local state = default or false

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 40)
    Holder.BackgroundColor3 = COLORS.Element
    Holder.BorderSizePixel = 0
    Holder.Parent = parent

    local HolderCorner = Instance.new("UICorner")
    HolderCorner.CornerRadius = UDim.new(0, 8)
    HolderCorner.Parent = Holder

    local HolderStroke = Instance.new("UIStroke")
    HolderStroke.Color = COLORS.Stroke
    HolderStroke.Thickness = 1
    HolderStroke.Transparency = 0.5
    HolderStroke.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 46, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleBtn.BackgroundColor3 = state and COLORS.Accent or Color3.fromRGB(50, 50, 65)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Holder

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn

    local ToggleGlow = Instance.new("UIStroke")
    ToggleGlow.Color = COLORS.Accent
    ToggleGlow.Thickness = 1.5
    ToggleGlow.Transparency = state and 0 or 1
    ToggleGlow.Parent = ToggleBtn

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    Knob.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    Knob.BorderSizePixel = 0
    Knob.Parent = ToggleBtn

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local function SetState(newState, animate)
        state = newState
        local info = TweenInfo.new(animate and 0.25 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(ToggleBtn, info, {BackgroundColor3 = COLORS.Accent}):Play()
            TweenService:Create(Knob, info, {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
            TweenService:Create(ToggleGlow, info, {Transparency = 0}):Play()
            TweenService:Create(HolderStroke, info, {Color = COLORS.Accent, Transparency = 0.3}):Play()
        else
            TweenService:Create(ToggleBtn, info, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
            TweenService:Create(Knob, info, {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
            TweenService:Create(ToggleGlow, info, {Transparency = 1}):Play()
            TweenService:Create(HolderStroke, info, {Color = COLORS.Stroke, Transparency = 0.5}):Play()
        end
        if callback then callback(state) end
    end

    ToggleBtn.MouseButton1Click:Connect(function()
        SetState(not state, true)
    end)

    Holder.MouseEnter:Connect(function()
        TweenService:Create(Holder, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover}):Play()
    end)
    Holder.MouseLeave:Connect(function()
        TweenService:Create(Holder, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
    end)

    return {
        Set = function(v) SetState(v, true) end,
        Get = function() return state end,
        Instance = Holder,
    }
end

local function CreateSlider(parent, text, min, max, default, callback)
    local value = default or min

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 58)
    Holder.BackgroundColor3 = COLORS.Element
    Holder.BorderSizePixel = 0
    Holder.Parent = parent

    local HolderCorner = Instance.new("UICorner")
    HolderCorner.CornerRadius = UDim.new(0, 8)
    HolderCorner.Parent = Holder

    local HolderStroke = Instance.new("UIStroke")
    HolderStroke.Color = COLORS.Stroke
    HolderStroke.Thickness = 1
    HolderStroke.Transparency = 0.5
    HolderStroke.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 22)
    Label.Position = UDim2.new(0, 14, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, -14, 0, 22)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 8)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = COLORS.Accent
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Holder

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -28, 0, 8)
    SliderBack.Position = UDim2.new(0, 14, 0, 38)
    SliderBack.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = Holder

    local SliderBackCorner = Instance.new("UICorner")
    SliderBackCorner.CornerRadius = UDim.new(1, 0)
    SliderBackCorner.Parent = SliderBack

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = COLORS.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack

    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill

    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Accent),
        ColorSequenceKeypoint.new(1, COLORS.Accent2),
    })
    FillGradient.Parent = SliderFill

    local Knob = Instance.new("TextButton")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new((value - min) / (max - min), -9, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
    Knob.BorderSizePixel = 0
    Knob.Text = ""
    Knob.AutoButtonColor = false
    Knob.Parent = SliderBack

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local KnobGlow = Instance.new("UIStroke")
    KnobGlow.Color = COLORS.Accent
    KnobGlow.Thickness = 2
    KnobGlow.Transparency = 0.4
    KnobGlow.Parent = Knob

    local dragging = false

    local function UpdateFromPosition(inputX, animate)
        local relX = (inputX - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
        relX = math.clamp(relX, 0, 1)
        local newValue = min + (max - min) * relX
        newValue = math.floor(newValue * 100 + 0.5) / 100
        value = newValue

        local info = TweenInfo.new(animate and 0.08 or 0, Enum.EasingStyle.Quad)
        TweenService:Create(SliderFill, info, {Size = UDim2.new(relX, 0, 1, 0)}):Play()
        TweenService:Create(Knob, info, {Position = UDim2.new(relX, -9, 0.5, -9)}):Play()
        ValueLabel.Text = tostring(value)

        if callback then callback(value) end
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            TweenService:Create(KnobGlow, TweenInfo.new(0.15), {Transparency = 0}):Play()
        end
    end)

    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateFromPosition(input.Position.X, true)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromPosition(input.Position.X, false)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            TweenService:Create(KnobGlow, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end
    end)

    Holder.MouseEnter:Connect(function()
        TweenService:Create(Holder, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover}):Play()
    end)
    Holder.MouseLeave:Connect(function()
        TweenService:Create(Holder, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
    end)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local relX = (v - min) / (max - min)
            SliderFill.Size = UDim2.new(relX, 0, 1, 0)
            Knob.Position = UDim2.new(relX, -9, 0.5, -9)
            ValueLabel.Text = tostring(v)
            if callback then callback(v) end
        end,
        Get = function() return value end,
        Instance = Holder,
    }
end

local function CreateSection(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 26)
    Label.BackgroundTransparency = 1
    Label.Text = "›  " .. string.upper(text)
    Label.TextColor3 = COLORS.Accent
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

--// ============================================================
--// СТВОРЕННЯ ВКЛАДОК
--// ============================================================
local CombatPage    = CreateTab("Combat")
local VisualPage    = CreateTab("Visual")
local MovementPage  = CreateTab("Movement")
local RagePage      = CreateTab("Rage")
local AnimationPage = CreateTab("Animation")

--// -------- COMBAT --------
CreateSection(CombatPage, "Camera Aimbot")

local AimEnabled   = CreateToggle(CombatPage, "Aimbot (Hold RMB)", false, nil)
local AimSmooth    = CreateSlider(CombatPage, "Aimbot Smoothness", 0.05, 1, 0.15, nil)
local AimFovSlider = CreateSlider(CombatPage, "Aimbot FOV", 10, 500, 150, nil)

CreateSection(CombatPage, "Silent Aim")

local SilentEnabled   = CreateToggle(CombatPage, "Silent Aim",      false, nil)
local SilentShowFov   = CreateToggle(CombatPage, "Show Silent FOV", true,  nil)
local SilentFovSlider = CreateSlider(CombatPage, "Silent FOV", 10, 500, 150, nil)
local SilentHitChance = CreateSlider(CombatPage, "Hit Chance (%)", 0, 100, 100, nil)

CreateSection(CombatPage, "Target")

local AimTargetPart = CreateToggle(CombatPage, "Aim at Head", true, nil)
local AimTeamCheck  = CreateToggle(CombatPage, "Team Check", true, nil)
local AimWallCheck  = CreateToggle(CombatPage, "Wall Check", false, nil)

--// -------- VISUAL (ESP) --------
CreateSection(VisualPage, "Player ESP")

local EspEnabled   = CreateToggle(VisualPage, "Enable ESP",        false, nil)
local EspFill      = CreateToggle(VisualPage, "Fill (Glow)",       true,  nil)
local EspOutline   = CreateToggle(VisualPage, "Outline",           true,  nil)
local EspSeeThru   = CreateToggle(VisualPage, "See Through Walls", true,  nil)
local EspTeamCheck = CreateToggle(VisualPage, "Team Check",        true,  nil)

CreateSection(VisualPage, "Settings")

local EspMaxDist   = CreateSlider(VisualPage, "Max Distance", 50, 5000, 1500, nil)
local EspFillAlpha = CreateSlider(VisualPage, "Fill Alpha",   0,  1,    0.35, nil)

--// -------- MOVEMENT --------
CreateSection(MovementPage, "Movement")

local SpeedSlider  = CreateSlider(MovementPage, "Speed", 16, 500, 16, nil)
local FlyToggle    = CreateToggle(MovementPage, "Fly",    false, nil)
local NoclipToggle = CreateToggle(MovementPage, "Noclip", false, nil)

CreateSection(MovementPage, "Jump")

local BunnyHopToggle   = CreateToggle(MovementPage, "Bunny Hop", true, nil)
local AutoJumpToggle   = CreateToggle(MovementPage, "Auto Jump (Hold Space)", false, nil)
local JumpPowerSlider  = CreateSlider(MovementPage, "Jump Power", 50, 300, 50, nil)

--// -------- RAGE (Anti-Aim + FOV) --------
CreateSection(RagePage, "Anti-Aim (CS-style)")

local AntiAimEnabled  = CreateToggle(RagePage, "Anti-Aim", false, nil)
local AntiAimMode     = CreateToggle(RagePage, "Use: Spin (off = Jitter)", true, nil)
local AntiAimSpeed    = CreateSlider(RagePage, "Spin Speed", 1, 60, 18, nil)
local AntiAimJitter   = CreateSlider(RagePage, "Jitter Angle", 10, 180, 90, nil)

CreateSection(RagePage, "Camera FOV")

local FovEnabled = CreateToggle(RagePage, "FOV Changer", false, nil)
local FovSlider  = CreateSlider(RagePage, "FOV Value", 20, 120, 90, nil)

--// -------- ANIMATION --------
CreateSection(AnimationPage, "Animation")

local AnimSpeedEnabled = CreateToggle(AnimationPage, "Animation Speed", false, nil)
local AnimSpeedSlider  = CreateSlider(AnimationPage, "Speed Multiplier", 0.1, 5, 1, nil)

--// Активуємо Combat
for tabName, data in pairs(Tabs) do
    data.Button.BackgroundColor3 = COLORS.Element
    data.Button.TextColor3 = COLORS.TextDim
    TabPages[tabName].Visible = false
end
Tabs["Combat"].Button.BackgroundColor3 = COLORS.ElementHover
Tabs["Combat"].Button.TextColor3 = COLORS.Text
Tabs["Combat"].AccentBar.Size = UDim2.new(0, 3, 0, 26)
Tabs["Combat"].Stroke.Color = COLORS.Accent
Tabs["Combat"].Stroke.Transparency = 0
TabPages["Combat"].Visible = true
ActiveTab = "Combat"

--// Drag
local dragging, dragStart, startPos = false, nil, nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--// Minimize
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        TabsFrame.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, WINDOW_W, 0, 42),
        }):Play()
        MinimizeButton.Text = "+"
    else
        ContentFrame.Visible = true
        TabsFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
        }):Play()
        MinimizeButton.Text = "–"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local function ToggleMenu()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
        }):Play()
        task.wait(0.2)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
        }):Play()
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        ToggleMenu()
    end
end)

--// ============================================================
--// ЕКСПОРТ ЕЛЕМЕНТІВ
--// ============================================================
_G.ModMenu = _G.ModMenu or {}
_G.ModMenu.ScreenGui = ScreenGui
_G.ModMenu.MainFrame = MainFrame
_G.ModMenu.Tabs = Tabs
_G.ModMenu.TabPages = TabPages

_G.ModMenu.Elements = {
    -- Combat
    AimEnabled    = AimEnabled,
    AimSmooth     = AimSmooth,
    AimFovSlider  = AimFovSlider,
    SilentEnabled = SilentEnabled,
    SilentShowFov = SilentShowFov,
    SilentFovSlider = SilentFovSlider,
    SilentHitChance = SilentHitChance,
    AimTargetPart = AimTargetPart,
    AimTeamCheck  = AimTeamCheck,
    AimWallCheck  = AimWallCheck,

    -- Visual
    EspEnabled   = EspEnabled,
    EspFill      = EspFill,
    EspOutline   = EspOutline,
    EspSeeThru   = EspSeeThru,
    EspTeamCheck = EspTeamCheck,
    EspMaxDist   = EspMaxDist,
    EspFillAlpha = EspFillAlpha,

    -- Movement
    SpeedSlider    = SpeedSlider,
    FlyToggle      = FlyToggle,
    NoclipToggle   = NoclipToggle,
    BunnyHopToggle = BunnyHopToggle,
    AutoJumpToggle = AutoJumpToggle,
    JumpPowerSlider = JumpPowerSlider,

    -- Rage
    AntiAimEnabled = AntiAimEnabled,
    AntiAimMode    = AntiAimMode,
    AntiAimSpeed   = AntiAimSpeed,
    AntiAimJitter  = AntiAimJitter,
    FovEnabled     = FovEnabled,
    FovSlider      = FovSlider,

    -- Animation
    AnimSpeedEnabled = AnimSpeedEnabled,
    AnimSpeedSlider  = AnimSpeedSlider,
}

print("[ModMenu] UI v2 завантажено (FOV/BunnyHop/AntiAim). Натисни F4.")
