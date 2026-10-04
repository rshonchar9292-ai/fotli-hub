--// ============================================================
--// MOD MENU UI - Частина 1 (КРАСИВА ВЕРСІЯ з анімаціями)
--// Для Fotli Hub / HitHub / Xeno / Delta
--// ============================================================

-- Захист від повторного завантаження
if game:GetService("CoreGui"):FindFirstChild("ModMenuUI") then
    game:GetService("CoreGui"):FindFirstChild("ModMenuUI"):Destroy()
end

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

--// Палітра кольорів (кіберпанк/неон)
local COLORS = {
    Background      = Color3.fromRGB(15, 15, 22),
    BackgroundAlt   = Color3.fromRGB(22, 22, 32),
    Element         = Color3.fromRGB(30, 30, 42),
    ElementHover    = Color3.fromRGB(40, 40, 55),
    Stroke          = Color3.fromRGB(60, 60, 85),
    StrokeGlow      = Color3.fromRGB(120, 90, 255),
    Accent          = Color3.fromRGB(120, 90, 255),   -- фіолетовий
    Accent2         = Color3.fromRGB(80, 200, 255),   -- блакитний
    AccentActive    = Color3.fromRGB(140, 110, 255),
    Text            = Color3.fromRGB(230, 230, 245),
    TextDim         = Color3.fromRGB(150, 150, 170),
    Success         = Color3.fromRGB(80, 220, 140),
    Danger          = Color3.fromRGB(240, 80, 100),
}

--// ------------------------------------------------------------
--// 1. ScreenGui
--// ------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModMenuUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = game:GetService("CoreGui")

--// ------------------------------------------------------------
--// 2. Головне вікно (Main Frame)
--// ------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 360)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.Stroke
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Тінь під вікном
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5028857084"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(24, 24, 276, 276)
Shadow.ZIndex = -1
Shadow.Parent = MainFrame

--// ------------------------------------------------------------
--// 3. Верхня панель (TitleBar) з градієнтом
--// ------------------------------------------------------------
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
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

-- Анімований градієнт зверху
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

-- Анімація градієнта (переливання)
task.spawn(function()
    local offset = 0
    while GradientHolder.Parent do
        offset = offset + 0.01
        if offset > 1 then offset = 0 end
        Gradient.Offset = Vector2.new(offset, 0)
        task.wait(0.03)
    end
end)

-- Логотип (крапка що світиться)
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

-- Пульсація логотипу
task.spawn(function()
    while LogoDot.Parent do
        TweenService:Create(LogoDotGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.8}):Play()
        task.wait(1)
        TweenService:Create(LogoDotGlow, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.2}):Play()
        task.wait(1)
    end
end)

-- Назва
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.Position = UDim2.new(0, 32, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FOTLI HUB"
TitleLabel.TextColor3 = COLORS.Text
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

-- Кнопка згортання
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
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

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

MinimizeButton.MouseEnter:Connect(function()
    TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.ElementHover}):Play()
end)
MinimizeButton.MouseLeave:Connect(function()
    TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Element}):Play()
end)

-- Кнопка закриття
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
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

--// ------------------------------------------------------------
--// 4. Ліва панель контенту (ScrollingFrame)
--// ------------------------------------------------------------
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -130, 1, -54)
ContentFrame.Position = UDim2.new(0, 12, 0, 48)
ContentFrame.BackgroundColor3 = COLORS.BackgroundAlt
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 3
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
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)
ContentPadding.Parent = ContentFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentFrame

--// ------------------------------------------------------------
--// 5. Права панель вкладок
--// ------------------------------------------------------------
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(0, 106, 1, -66)
TabsFrame.Position = UDim2.new(1, -118, 0, 48)
TabsFrame.BackgroundColor3 = COLORS.BackgroundAlt
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame

local TabsCorner = Instance.new("UICorner")
TabsCorner.CornerRadius = UDim.new(0, 10)
TabsCorner.Parent = TabsFrame

local TabsPadding = Instance.new("UIPadding")
TabsPadding.PaddingTop = UDim.new(0, 8)
TabsPadding.PaddingBottom = UDim.new(0, 8)
TabsPadding.PaddingLeft = UDim.new(0, 8)
TabsPadding.PaddingRight = UDim.new(0, 8)
TabsPadding.Parent = TabsFrame

local TabsLayout = Instance.new("UIListLayout")
TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabsLayout.Padding = UDim.new(0, 6)
TabsLayout.Parent = TabsFrame

--// ------------------------------------------------------------
--// 6. Сховище
--// ------------------------------------------------------------
local Tabs       = {}
local TabPages   = {}
local ActiveTab  = nil

--// ------------------------------------------------------------
--// 7. Створення вкладки з анімацією
--// ------------------------------------------------------------
local function CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, 0, 0, 34)
    TabButton.BackgroundColor3 = COLORS.Element
    TabButton.BorderSizePixel = 0
    TabButton.Text = name
    TabButton.TextColor3 = COLORS.TextDim
    TabButton.TextSize = 13
    TabButton.Font = Enum.Font.GothamMedium
    TabButton.AutoButtonColor = false
    TabButton.Parent = TabsFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = COLORS.Stroke
    TabStroke.Thickness = 1
    TabStroke.Transparency = 0.5
    TabStroke.Parent = TabButton

    -- Акцентна смужка зліва (прихована за замовчуванням)
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(0, 3, 0, 0)
    AccentBar.Position = UDim2.new(0, 0, 0.5, 0)
    AccentBar.BackgroundColor3 = COLORS.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = TabButton

    local AccentBarCorner = Instance.new("UICorner")
    AccentBarCorner.CornerRadius = UDim.new(1, 0)
    AccentBarCorner.Parent = AccentBar

    -- Сторінка контенту
    local Page = Instance.new("Frame")
    Page.Name = name .. "Page"
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

    -- Hover
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

    -- Клік
    TabButton.MouseButton1Click:Connect(function()
        for tabName, data in pairs(Tabs) do
            -- Анімоване згасання неактивних
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

        -- Активна вкладка
        TweenService:Create(TabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.ElementHover,
            TextColor3 = COLORS.Text,
        }):Play()
        TweenService:Create(AccentBar, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 3, 0, 22),
        }):Play()
        TweenService:Create(TabStroke, TweenInfo.new(0.2), {
            Color = COLORS.Accent,
            Transparency = 0,
        }):Play()

        -- Плавна поява контенту
        Page.Visible = true
        for _, child in ipairs(Page:GetChildren()) do
            if child:IsA("GuiObject") then
                child.BackgroundTransparency = 1
                TweenService:Create(child, TweenInfo.new(0.25), {BackgroundTransparency = 0}):Play()
            end
        end

        ActiveTab = name
    end)

    return Page
end

--// ------------------------------------------------------------
--// 8. Toggle з анімацією
--// ------------------------------------------------------------
local function CreateToggle(parent, text, default, callback)
    local state = default or false

    local Holder = Instance.new("Frame")
    Holder.Name = text .. "Toggle"
    Holder.Size = UDim2.new(1, 0, 0, 38)
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
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    -- Toggle
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 44, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
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
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
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
            TweenService:Create(Knob, info, {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            TweenService:Create(ToggleGlow, info, {Transparency = 0}):Play()
            TweenService:Create(HolderStroke, info, {Color = COLORS.Accent, Transparency = 0.3}):Play()
        else
            TweenService:Create(ToggleBtn, info, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}):Play()
            TweenService:Create(Knob, info, {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
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

--// ------------------------------------------------------------
--// 9. Slider з анімацією
--// ------------------------------------------------------------
local function CreateSlider(parent, text, min, max, default, callback)
    local value = default or min

    local Holder = Instance.new("Frame")
    Holder.Name = text .. "Slider"
    Holder.Size = UDim2.new(1, 0, 0, 54)
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
    Label.Position = UDim2.new(0, 14, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.Text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, -14, 0, 22)
    ValueLabel.Position = UDim2.new(0.6, 0, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(value)
    ValueLabel.TextColor3 = COLORS.Accent
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Holder

    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -28, 0, 6)
    SliderBack.Position = UDim2.new(0, 14, 0, 36)
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
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new((value - min) / (max - min), -8, 0.5, -8)
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
        TweenService:Create(Knob, info, {Position = UDim2.new(relX, -8, 0.5, -8)}):Play()
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
            Knob.Position = UDim2.new(relX, -8, 0.5, -8)
            ValueLabel.Text = tostring(v)
            if callback then callback(v) end
        end,
        Get = function() return value end,
        Instance = Holder,
    }
end

--// ------------------------------------------------------------
--// 10. Section Label
--// ------------------------------------------------------------
local function CreateSection(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.BackgroundTransparency = 1
    Label.Text = "›  " .. string.upper(text)
    Label.TextColor3 = COLORS.Accent
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

--// ------------------------------------------------------------
--// 11. Створення вкладок
--// ------------------------------------------------------------
local CombatPage    = CreateTab("Combat")
local VisualPage    = CreateTab("Visual")
local MovementPage  = CreateTab("Movement")
local AnimationPage = CreateTab("Animation")

--// Combat
CreateSection(CombatPage, "Aim Assist")
local SilentAimToggle = CreateToggle(CombatPage, "Silent Aim", false, function(s) print("[UI] Silent Aim:", s) end)
local FovToggle       = CreateToggle(CombatPage, "Aim (FOV)",  false, function(s) print("[UI] Aim FOV:", s) end)
local FovSlider       = CreateSlider(CombatPage, "FOV Radius", 10, 500, 100, function(v) print("[UI] FOV:", v) end)

--// Movement
CreateSection(MovementPage, "Movement")
local SpeedSlider  = CreateSlider(MovementPage, "Speed", 16, 500, 16, function(v) print("[UI] Speed:", v) end)
local FlyToggle    = CreateToggle(MovementPage, "Fly",    false, function(s) print("[UI] Fly:", s) end)
local NoclipToggle = CreateToggle(MovementPage, "Noclip", false, function(s) print("[UI] Noclip:", s) end)

--// Visual (порожня)
CreateSection(VisualPage, "Visual")

--// Animation (порожня)
CreateSection(AnimationPage, "Animation")

--// Активуємо Combat за замовчуванням
Tabs["Combat"].Button.MouseButton1Click:Fire()
-- Ручна активація (бо :Fire() не існує)
for tabName, data in pairs(Tabs) do
    data.Button.BackgroundColor3 = COLORS.Element
    data.Button.TextColor3 = COLORS.TextDim
    TabPages[tabName].Visible = false
end
Tabs["Combat"].Button.BackgroundColor3 = COLORS.ElementHover
Tabs["Combat"].Button.TextColor3 = COLORS.Text
Tabs["Combat"].AccentBar.Size = UDim2.new(0, 3, 0, 22)
Tabs["Combat"].Stroke.Color = COLORS.Accent
Tabs["Combat"].Stroke.Transparency = 0
TabPages["Combat"].Visible = true
ActiveTab = "Combat"

--// ------------------------------------------------------------
--// 12. Drag-переміщення
--// ------------------------------------------------------------
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

--// ------------------------------------------------------------
--// 13. Згортання / розгортання
--// ------------------------------------------------------------
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        TabsFrame.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 560, 0, 40),
        }):Play()
        MinimizeButton.Text = "+"
    else
        ContentFrame.Visible = true
        TabsFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 560, 0, 360),
        }):Play()
        MinimizeButton.Text = "–"
    end
end)

--// ------------------------------------------------------------
--// 14. Закриття
--// ------------------------------------------------------------
CloseButton.MouseButton1Click:Connect(function()
    -- Плавне зникання
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

--// ------------------------------------------------------------
--// 15. Поява вікна (scale + fade in)
--// ------------------------------------------------------------
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 560, 0, 360),
    BackgroundTransparency = 0,
}):Play()

--// ------------------------------------------------------------
--// 16. Експорт
--// ------------------------------------------------------------
_G.ModMenu = _G.ModMenu or {}
_G.ModMenu.ScreenGui = ScreenGui
_G.ModMenu.MainFrame = MainFrame
_G.ModMenu.Tabs = Tabs
_G.ModMenu.TabPages = TabPages
_G.ModMenu.Elements = {
    SilentAim  = SilentAimToggle,
    FovToggle  = FovToggle,
    FovSlider  = FovSlider,
    SpeedSlider = SpeedSlider,
    FlyToggle  = FlyToggle,
    NoclipToggle = NoclipToggle,
}

print("[ModMenu] UI з анімаціями успішно завантажено!")
