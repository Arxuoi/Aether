-- ============================================================
--  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗██████╗  █████╗ ██╗     ██╗██████╗
--  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔══██╗██╔══██╗██║     ██║██╔══██╗
--  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝███████║██║     ██║██████╔╝
--  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══██║██║     ██║██╔══██╗
--  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║██║  ██║███████╗██║██████╔╝
--  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝
--  Modern Glassmorphism UI Library for Roblox
--  Version: 1.0.0  |  Non-OOP Functional Architecture
-- ============================================================

local Nexuralib = {}
Nexuralib.__index = Nexuralib

-- ============================================================
-- SERVICES
-- ============================================================
local Players            = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")

local LocalPlayer        = Players.LocalPlayer

-- ============================================================
-- DESIGN TOKENS
-- ============================================================
local COLORS = {
    Background      = Color3.fromRGB(255, 255, 255),
    TextPrimary     = Color3.fromRGB(20,  20,  20),
    TextSecondary   = Color3.fromRGB(100, 100, 100),
    TextMuted       = Color3.fromRGB(150, 150, 150),
    Accent          = Color3.fromRGB(0,   122, 255),
    AccentHover     = Color3.fromRGB(10,  132, 255),
    Success         = Color3.fromRGB(52,  199, 89),
    Warning         = Color3.fromRGB(255, 204, 0),
    Error           = Color3.fromRGB(255, 59,  48),
    Surface         = Color3.fromRGB(250, 250, 250),
    White           = Color3.fromRGB(255, 255, 255),
    Black           = Color3.fromRGB(0,   0,   0),
    GlassBorder     = Color3.fromRGB(255, 255, 255),
    GlassBackground = Color3.fromRGB(255, 255, 255),
    SidebarBg       = Color3.fromRGB(245, 245, 247),
    SidebarActive   = Color3.fromRGB(0,   122, 255),
    Transparent     = Color3.fromRGB(0,   0,   0),
}

local FONTS = {
    Display  = Enum.Font.GothamBlack,
    Title    = Enum.Font.GothamBold,
    Subtitle = Enum.Font.GothamMedium,
    Body     = Enum.Font.Gotham,
    Caption  = Enum.Font.Gotham,
    Code     = Enum.Font.RobotoMono,
}

local CORNERS = {
    XS   = 8,
    SM   = 12,
    MD   = 16,
    LG   = 20,
    XL   = 24,
    FULL = 999,
}

local SPACING = {
    XS   = 4,
    SM   = 8,
    MD   = 12,
    LG   = 16,
    XL   = 24,
    XXL  = 32,
    XXXL = 48,
}

local DURATION = {
    Fast   = 0.15,
    Normal = 0.3,
    Slow   = 0.5,
}

local EASING = {
    Standard = Enum.EasingStyle.Quart,
    Enter    = Enum.EasingStyle.Back,
    Exit     = Enum.EasingStyle.Quint,
    Spring   = Enum.EasingStyle.Elastic,
}

local BG_TRANS   = 0.15   -- glass transparency
local BLUR_INT   = 20     -- BlurEffect intensity (integer for Roblox)

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or DURATION.Normal,
        style or EASING.Standard,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function SpringTween(obj, props, duration)
    local info = TweenInfo.new(
        duration or 0.4,
        Enum.EasingStyle.Elastic,
        Enum.EasingDirection.Out,
        0, false, 0
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function ApplyCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or CORNERS.MD)
    c.Parent = parent
    return c
end

local function ApplyStroke(parent, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.GlassBorder
    s.Thickness = thickness or 1
    s.Transparency = trans or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function ApplyShadow(parent, size, transparency)
    -- Using ImageLabel with shadow asset
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "_Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
    shadow.ZIndex = (parent.ZIndex or 1) - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

local function ApplyTextShadow(label)
    -- Roblox doesn't have native text shadow, we simulate via duplicate
    -- This is a lightweight approach: just slightly darken via UIStroke
    -- Real shadow is complex; we skip stroke on labels for perf
    return label
end

local function MakeFrame(props)
    local f = Instance.new("Frame")
    f.Name              = props.Name or "Frame"
    f.Size              = props.Size or UDim2.new(1, 0, 0, 40)
    f.Position          = props.Position or UDim2.new(0, 0, 0, 0)
    f.AnchorPoint       = props.AnchorPoint or Vector2.new(0, 0)
    f.BackgroundColor3  = props.Color or COLORS.White
    f.BackgroundTransparency = props.Trans or 0
    f.ZIndex            = props.ZIndex or 1
    f.BorderSizePixel   = 0
    f.ClipsDescendants  = props.ClipsDescendants or false
    if props.Parent then f.Parent = props.Parent end
    return f
end

local function MakeLabel(props)
    local l = Instance.new("TextLabel")
    l.Name              = props.Name or "Label"
    l.Text              = props.Text or ""
    l.Font              = props.Font or FONTS.Body
    l.TextSize          = props.Size or 14
    l.TextColor3        = props.Color or COLORS.TextPrimary
    l.TextXAlignment    = props.AlignX or Enum.TextXAlignment.Left
    l.TextYAlignment    = props.AlignY or Enum.TextYAlignment.Center
    l.BackgroundTransparency = 1
    l.Size              = props.FrameSize or UDim2.new(1, 0, 1, 0)
    l.Position          = props.Position or UDim2.new(0, 0, 0, 0)
    l.ZIndex            = props.ZIndex or 2
    l.TextTruncate      = Enum.TextTruncate.AtEnd
    l.RichText          = props.RichText or false
    if props.Parent then l.Parent = props.Parent end
    return l
end

local function MakeButton(props)
    local b = Instance.new("TextButton")
    b.Name              = props.Name or "Button"
    b.Text              = props.Text or ""
    b.Font              = props.Font or FONTS.Body
    b.TextSize          = props.TextSize or 14
    b.TextColor3        = props.TextColor or COLORS.TextPrimary
    b.BackgroundColor3  = props.Color or COLORS.Surface
    b.BackgroundTransparency = props.Trans or 0
    b.Size              = props.Size or UDim2.new(0, 100, 0, 36)
    b.Position          = props.Position or UDim2.new(0, 0, 0, 0)
    b.AutoButtonColor   = false
    b.BorderSizePixel   = 0
    b.ZIndex            = props.ZIndex or 2
    if props.Parent then b.Parent = props.Parent end
    return b
end

local function MakeImage(props)
    local i = Instance.new("ImageLabel")
    i.Name              = props.Name or "Image"
    i.Image             = props.Image or ""
    i.ImageColor3       = props.Color or COLORS.TextSecondary
    i.BackgroundTransparency = 1
    i.Size              = props.Size or UDim2.new(0, 20, 0, 20)
    i.Position          = props.Position or UDim2.new(0, 0, 0.5, -10)
    i.ZIndex            = props.ZIndex or 3
    i.ScaleType         = Enum.ScaleType.Fit
    if props.Parent then i.Parent = props.Parent end
    return i
end

local function MakeScrollFrame(props)
    local sf = Instance.new("ScrollingFrame")
    sf.Name                    = props.Name or "ScrollFrame"
    sf.Size                    = props.Size or UDim2.new(1, 0, 1, 0)
    sf.Position                = props.Position or UDim2.new(0, 0, 0, 0)
    sf.BackgroundTransparency  = 1
    sf.BorderSizePixel         = 0
    sf.ScrollBarThickness      = props.BarThickness or 3
    sf.ScrollBarImageColor3    = COLORS.Accent
    sf.ScrollBarImageTransparency = 0.4
    sf.CanvasSize              = props.CanvasSize or UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize     = props.AutoCanvas or Enum.AutomaticSize.Y
    sf.ZIndex                  = props.ZIndex or 2
    sf.ClipsDescendants        = true
    if props.Parent then sf.Parent = props.Parent end
    return sf
end

-- Ripple effect on a button
local function CreateRipple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "_Ripple"
    ripple.BackgroundColor3 = COLORS.White
    ripple.BackgroundTransparency = 0.6
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = (button.ZIndex or 1) + 5
    ripple.BorderSizePixel = 0
    ApplyCorner(ripple, CORNERS.FULL)
    ripple.Parent = button

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    game:GetService("Debris"):AddItem(ripple, 0.6)
end

-- ============================================================
-- CONFIG SYSTEM
-- ============================================================
local ConfigData = {}

local function SaveConfig(name, data)
    local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then
        if writefile then
            local folder = "Nexuralib"
            if not isfolder(folder) then makefolder(folder) end
            writefile(folder .. "/" .. name .. ".json", encoded)
        end
        ConfigData[name] = data
    end
end

local function LoadConfig(name)
    if ConfigData[name] then return ConfigData[name] end
    if readfile then
        local path = "Nexuralib/" .. name .. ".json"
        if isfile(path) then
            local ok, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
            if ok then
                ConfigData[name] = decoded
                return decoded
            end
        end
    end
    return nil
end

Nexuralib.SaveConfig = SaveConfig
Nexuralib.LoadConfig = LoadConfig

-- ============================================================
-- FLAGS REGISTRY
-- ============================================================
Nexuralib.Flags = {}

-- ============================================================
-- NOTIFY SYSTEM  (must be declared before Window so Window can call it)
-- ============================================================
local NotifyGui = nil
local NotifyContainer = nil
local ActiveNotifs = {}

local function EnsureNotifyGui()
    if NotifyGui and NotifyGui.Parent then return end
    NotifyGui = Instance.new("ScreenGui")
    NotifyGui.Name = "NexuralibNotify"
    NotifyGui.ResetOnSpawn = false
    NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotifyGui.DisplayOrder = 200
    pcall(function() NotifyGui.Parent = CoreGui end)
    if not NotifyGui.Parent then NotifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    NotifyContainer = Instance.new("Frame")
    NotifyContainer.Name = "NotifyContainer"
    NotifyContainer.BackgroundTransparency = 1
    NotifyContainer.Size = UDim2.new(0, 340, 1, 0)
    NotifyContainer.Position = UDim2.new(1, -355, 0, 0)
    NotifyContainer.ZIndex = 200
    NotifyContainer.Parent = NotifyGui

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom
    list.Padding = UDim.new(0, SPACING.SM)
    list.Parent = NotifyContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0, SPACING.LG)
    pad.PaddingRight = UDim.new(0, SPACING.SM)
    pad.Parent = NotifyContainer
end

function Nexuralib:Notify(config)
    local cfg = config or {}
    local title    = cfg.Title or "Notification"
    local content  = cfg.Content or ""
    local ntype    = cfg.Type or "info"
    local duration = cfg.Duration or 4
    local icon     = cfg.Icon or ""
    local actions  = cfg.Actions or {}

    EnsureNotifyGui()

    local typeColor = COLORS.Accent
    local typeIcon  = "rbxassetid://7733960981"
    if ntype == "success" then
        typeColor = COLORS.Success
        typeIcon  = "rbxassetid://7733715400"
    elseif ntype == "warning" then
        typeColor = COLORS.Warning
        typeIcon  = "rbxassetid://7733658504"
    elseif ntype == "error" then
        typeColor = COLORS.Error
        typeIcon  = "rbxassetid://7734014475"
    end
    if icon ~= "" then typeIcon = icon end

    local notifHeight = 76 + (content ~= "" and 20 or 0) + (#actions > 0 and 40 or 0)

    -- Main card
    local card = MakeFrame({
        Name  = "Notif",
        Size  = UDim2.new(1, 0, 0, notifHeight),
        Color = COLORS.White,
        Trans = BG_TRANS,
        ZIndex = 201,
        Parent = NotifyContainer,
    })
    ApplyCorner(card, CORNERS.LG)
    ApplyStroke(card, COLORS.GlassBorder, 1, 0.5)
    ApplyShadow(card, 16, 0.75)

    -- Accent bar
    local bar = MakeFrame({
        Name   = "AccentBar",
        Size   = UDim2.new(0, 4, 1, -16),
        Position = UDim2.new(0, 0, 0, 8),
        Color  = typeColor,
        Trans  = 0,
        ZIndex = 202,
        Parent = card,
    })
    ApplyCorner(bar, CORNERS.FULL)

    -- Icon
    local iconImg = MakeImage({
        Name   = "Icon",
        Image  = typeIcon,
        Color  = typeColor,
        Size   = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 18, 0, 14),
        ZIndex = 202,
        Parent = card,
    })

    -- Title
    MakeLabel({
        Name   = "Title",
        Text   = title,
        Font   = FONTS.Title,
        Size   = 14,
        Color  = COLORS.TextPrimary,
        FrameSize = UDim2.new(1, -90, 0, 20),
        Position  = UDim2.new(0, 46, 0, 12),
        ZIndex = 202,
        Parent = card,
    })

    -- Content
    if content ~= "" then
        MakeLabel({
            Name   = "Content",
            Text   = content,
            Font   = FONTS.Body,
            Size   = 12,
            Color  = COLORS.TextSecondary,
            FrameSize = UDim2.new(1, -90, 0, 18),
            Position  = UDim2.new(0, 46, 0, 34),
            ZIndex = 202,
            Parent = card,
        })
    end

    -- Close button
    local closeBtn = MakeButton({
        Name  = "Close",
        Text  = "✕",
        TextSize = 11,
        TextColor = COLORS.TextMuted,
        Color = COLORS.Transparent,
        Trans = 1,
        Size  = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -32, 0, 8),
        ZIndex = 203,
        Parent = card,
    })

    -- Actions
    if #actions > 0 then
        local actFrame = MakeFrame({
            Name   = "Actions",
            Size   = UDim2.new(1, -60, 0, 32),
            Position = UDim2.new(0, 46, 1, -40),
            Color  = COLORS.Transparent,
            Trans  = 1,
            ZIndex = 202,
            Parent = card,
        })
        local al = Instance.new("UIListLayout")
        al.FillDirection = Enum.FillDirection.Horizontal
        al.Padding = UDim.new(0, SPACING.SM)
        al.Parent = actFrame

        for _, act in ipairs(actions) do
            local ab = MakeButton({
                Name  = act.Text or "Action",
                Text  = act.Text or "",
                Font  = FONTS.Subtitle,
                TextSize = 12,
                TextColor = typeColor,
                Color = typeColor,
                Trans = 0.9,
                Size  = UDim2.new(0, 80, 1, 0),
                ZIndex = 203,
                Parent = actFrame,
            })
            ApplyCorner(ab, CORNERS.SM)
            ab.MouseButton1Click:Connect(function()
                if act.Callback then act.Callback() end
            end)
        end
    end

    -- Animate in from right
    card.Position = UDim2.new(1, 20, 0, 0)
    card.BackgroundTransparency = 1
    Tween(card, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = BG_TRANS},
        DURATION.Normal, EASING.Enter, Enum.EasingDirection.Out)

    local function dismiss()
        Tween(card, {
            Position = UDim2.new(1, 20, 0, 0),
            BackgroundTransparency = 1
        }, DURATION.Normal, EASING.Exit, Enum.EasingDirection.In)
        task.delay(DURATION.Normal, function()
            card:Destroy()
        end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    task.delay(duration, dismiss)

    return { Dismiss = dismiss }
end

-- ============================================================
-- MODAL SYSTEM
-- ============================================================
local ModalGui = nil

local function EnsureModalGui()
    if ModalGui and ModalGui.Parent then return end
    ModalGui = Instance.new("ScreenGui")
    ModalGui.Name = "NexuralibModal"
    ModalGui.ResetOnSpawn = false
    ModalGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ModalGui.DisplayOrder = 150
    pcall(function() ModalGui.Parent = CoreGui end)
    if not ModalGui.Parent then ModalGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

function Nexuralib:ShowModal(config)
    local cfg = config or {}
    local mtype      = cfg.Type or "info"
    local title      = cfg.Title or "Modal"
    local content    = cfg.Content or ""
    local icon       = cfg.Icon or ""
    local primary    = cfg.PrimaryAction or {Text = "OK"}
    local secondary  = cfg.SecondaryAction or nil
    local inputCfg   = cfg.Input or nil

    EnsureModalGui()

    local typeColor = COLORS.Accent
    if mtype == "success" then typeColor = COLORS.Success
    elseif mtype == "warning" then typeColor = COLORS.Warning
    elseif mtype == "error" then typeColor = COLORS.Error
    elseif mtype == "danger" then typeColor = COLORS.Error end

    -- Backdrop
    local backdrop = MakeFrame({
        Name  = "Backdrop",
        Size  = UDim2.new(1, 0, 1, 0),
        Color = COLORS.Black,
        Trans = 0.5,
        ZIndex = 150,
        Parent = ModalGui,
    })

    -- Modal frame
    local modalW = 420
    local modalH = 260 + (inputCfg and 56 or 0) + (content ~= "" and 40 or 0)

    local modal = MakeFrame({
        Name     = "Modal",
        Size     = UDim2.new(0, modalW, 0, modalH),
        Position = UDim2.new(0.5, -modalW/2, 0.5, -modalH/2),
        Color    = COLORS.White,
        Trans    = BG_TRANS,
        ZIndex   = 151,
        Parent   = ModalGui,
    })
    ApplyCorner(modal, CORNERS.LG)
    ApplyStroke(modal, COLORS.GlassBorder, 1, 0.4)
    ApplyShadow(modal, 24, 0.6)

    -- Animate open
    modal.Size = UDim2.new(0, modalW * 0.8, 0, modalH * 0.8)
    modal.Position = UDim2.new(0.5, -(modalW*0.8)/2, 0.5, -(modalH*0.8)/2)
    modal.BackgroundTransparency = 1
    backdrop.BackgroundTransparency = 1
    Tween(backdrop, {BackgroundTransparency = 0.5}, DURATION.Normal)
    Tween(modal, {
        Size = UDim2.new(0, modalW, 0, modalH),
        Position = UDim2.new(0.5, -modalW/2, 0.5, -modalH/2),
        BackgroundTransparency = BG_TRANS,
    }, DURATION.Normal, EASING.Enter, Enum.EasingDirection.Out)

    -- Icon area
    local iconCircle = MakeFrame({
        Name  = "IconCircle",
        Size  = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0.5, -28, 0, 28),
        Color = typeColor,
        Trans = 0.85,
        ZIndex = 152,
        Parent = modal,
    })
    ApplyCorner(iconCircle, CORNERS.FULL)
    ApplyStroke(iconCircle, typeColor, 1.5, 0.5)

    if icon ~= "" then
        MakeImage({
            Image  = icon,
            Color  = typeColor,
            Size   = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0.5, -12, 0.5, -12),
            ZIndex = 153,
            Parent = iconCircle,
        })
    end

    -- Title
    MakeLabel({
        Text      = title,
        Font      = FONTS.Title,
        Size      = 18,
        Color     = COLORS.TextPrimary,
        FrameSize = UDim2.new(1, -40, 0, 24),
        Position  = UDim2.new(0, 20, 0, 96),
        AlignX    = Enum.TextXAlignment.Center,
        ZIndex    = 152,
        Parent    = modal,
    })

    -- Content
    if content ~= "" then
        MakeLabel({
            Text      = content,
            Font      = FONTS.Body,
            Size      = 14,
            Color     = COLORS.TextSecondary,
            FrameSize = UDim2.new(1, -40, 0, 40),
            Position  = UDim2.new(0, 20, 0, 126),
            AlignX    = Enum.TextXAlignment.Center,
            AlignY    = Enum.TextYAlignment.Top,
            ZIndex    = 152,
            Parent    = modal,
        })
    end

    -- Input field (optional)
    local inputResult = ""
    if inputCfg then
        local inputBg = MakeFrame({
            Name   = "InputBg",
            Size   = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, content ~= "" and 174 or 134),
            Color  = COLORS.Surface,
            Trans  = 0.3,
            ZIndex = 152,
            Parent = modal,
        })
        ApplyCorner(inputBg, CORNERS.SM)
        ApplyStroke(inputBg, COLORS.GlassBorder, 1, 0.5)

        local box = Instance.new("TextBox")
        box.PlaceholderText = inputCfg.Placeholder or "Type here..."
        box.Text = inputCfg.Default or ""
        box.Font = FONTS.Body
        box.TextSize = 14
        box.TextColor3 = COLORS.TextPrimary
        box.PlaceholderColor3 = COLORS.TextMuted
        box.BackgroundTransparency = 1
        box.Size = UDim2.new(1, -16, 1, 0)
        box.Position = UDim2.new(0, 8, 0, 0)
        box.ZIndex = 153
        box.ClearTextOnFocus = false
        box.Parent = inputBg

        box.Focused:Connect(function()
            Tween(inputBg, {BackgroundTransparency = 0.1}, DURATION.Fast)
            Tween(ApplyStroke(inputBg, COLORS.Accent, 1.5, 0.2), {}, 0)
        end)
        box.FocusLost:Connect(function()
            inputResult = box.Text
            Tween(inputBg, {BackgroundTransparency = 0.3}, DURATION.Fast)
        end)
    end

    -- Button row
    local btnY = modalH - 64
    local btnCount = secondary and 2 or 1
    local btnW = btnCount == 2 and (modalW - 52) / 2 or modalW - 40

    local function closeModal()
        Tween(backdrop, {BackgroundTransparency = 1}, DURATION.Fast)
        Tween(modal, {
            Size = UDim2.new(0, modalW * 0.8, 0, modalH * 0.8),
            BackgroundTransparency = 1,
        }, DURATION.Fast, EASING.Exit, Enum.EasingDirection.In)
        task.delay(DURATION.Fast, function()
            backdrop:Destroy()
            modal:Destroy()
        end)
    end

    if secondary then
        local secBtn = MakeButton({
            Text      = secondary.Text or "Cancel",
            Font      = FONTS.Subtitle,
            TextSize  = 14,
            TextColor = COLORS.TextSecondary,
            Color     = COLORS.Surface,
            Trans     = 0.3,
            Size      = UDim2.new(0, btnW, 0, 40),
            Position  = UDim2.new(0, 20, 0, btnY),
            ZIndex    = 152,
            Parent    = modal,
        })
        ApplyCorner(secBtn, CORNERS.SM)
        ApplyStroke(secBtn, COLORS.GlassBorder, 1, 0.5)
        secBtn.MouseButton1Click:Connect(function()
            if secondary.Callback then secondary.Callback(inputResult) end
            closeModal()
        end)
    end

    local primBtnX = secondary and (20 + btnW + 12) or 20
    local primBtn = MakeButton({
        Text      = primary.Text or "OK",
        Font      = FONTS.Title,
        TextSize  = 14,
        TextColor = COLORS.White,
        Color     = typeColor,
        Trans     = 0,
        Size      = UDim2.new(0, btnW, 0, 40),
        Position  = UDim2.new(0, primBtnX, 0, btnY),
        ZIndex    = 152,
        Parent    = modal,
    })
    ApplyCorner(primBtn, CORNERS.SM)

    primBtn.MouseEnter:Connect(function()
        Tween(primBtn, {BackgroundTransparency = 0.1}, DURATION.Fast)
    end)
    primBtn.MouseLeave:Connect(function()
        Tween(primBtn, {BackgroundTransparency = 0}, DURATION.Fast)
    end)
    primBtn.MouseButton1Click:Connect(function()
        if primary.Callback then primary.Callback(inputResult) end
        closeModal()
    end)

    backdrop.MouseButton1Click:Connect(closeModal)

    return { Close = closeModal }
end

-- ============================================================
-- WINDOW
-- ============================================================
function Nexuralib:CreateWindow(config)
    local cfg = config or {}
    local winTitle      = cfg.Title or "Nexuralib"
    local winSubtitle   = cfg.Subtitle or ""
    local winSize       = cfg.Size or Vector2.new(780, 520)
    local winPos        = cfg.Position or nil
    local showAvatar    = cfg.ShowUserAvatar ~= false
    local avatarPos     = cfg.AvatarPosition or "left"  -- "left" or "right"
    local draggable     = cfg.Draggable ~= false
    local animateOpen   = cfg.AnimateOpen ~= false

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexuralibUI_" .. winTitle
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Blur effect
    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = game:GetService("Lighting")

    -- Main container
    local containerPos = winPos
        and UDim2.new(0, winPos.X, 0, winPos.Y)
        or  UDim2.new(0.5, -winSize.X/2, 0.5, -winSize.Y/2)

    local Container = MakeFrame({
        Name     = "NexuralibContainer",
        Size     = UDim2.new(0, winSize.X, 0, winSize.Y),
        Position = containerPos,
        Color    = COLORS.White,
        Trans    = BG_TRANS,
        ZIndex   = 1,
        Parent   = ScreenGui,
    })
    ApplyCorner(Container, CORNERS.XL)
    ApplyStroke(Container, COLORS.GlassBorder, 1.5, 0.4)
    ApplyShadow(Container, 32, 0.65)

    -- Animate open
    if animateOpen then
        Container.Size = UDim2.new(0, winSize.X * 0.85, 0, winSize.Y * 0.85)
        Container.Position = UDim2.new(
            0.5, -(winSize.X*0.85)/2,
            0.5, -(winSize.Y*0.85)/2
        )
        Container.BackgroundTransparency = 1
        Tween(Container, {
            Size     = UDim2.new(0, winSize.X, 0, winSize.Y),
            Position = containerPos,
            BackgroundTransparency = BG_TRANS,
        }, DURATION.Slow, EASING.Enter, Enum.EasingDirection.Out)
        Tween(blurEffect, {Size = BLUR_INT}, DURATION.Slow)
    else
        blurEffect.Size = BLUR_INT
    end

    -- ==================== HEADER ====================
    local Header = MakeFrame({
        Name  = "Header",
        Size  = UDim2.new(1, 0, 0, 72),
        Color = COLORS.White,
        Trans = 0.7,
        ZIndex = 2,
        Parent = Container,
    })
    -- Bottom border for header
    local headerBorder = MakeFrame({
        Name  = "HeaderBorder",
        Size  = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        Color = COLORS.GlassBorder,
        Trans = 0.6,
        ZIndex = 3,
        Parent = Header,
    })

    -- Avatar
    local avatarContainer = nil
    if showAvatar then
        local avSize = 44
        local avXPos = avatarPos == "right"
            and UDim2.new(1, -(avSize + 16), 0.5, -avSize/2)
            or  UDim2.new(0, 16, 0.5, -avSize/2)

        avatarContainer = MakeFrame({
            Name     = "AvatarContainer",
            Size     = UDim2.new(0, avSize, 0, avSize),
            Position = avXPos,
            Color    = COLORS.White,
            Trans    = 0.1,
            ZIndex   = 3,
            Parent   = Header,
        })
        ApplyCorner(avatarContainer, CORNERS.FULL)
        ApplyStroke(avatarContainer, COLORS.White, 2.5, 0)

        local userId = LocalPlayer.UserId
        local avatarUrl = "https://www.roblox.com/bust-thumbnail/image?userId=" .. userId
            .. "&width=180&height=180&format=png"
        local thumbUrl = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"

        local avatarImg = MakeImage({
            Image    = thumbUrl,
            Color    = COLORS.White,
            Size     = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex   = 4,
            Parent   = avatarContainer,
        })
        avatarImg.ImageColor3 = COLORS.White  -- no tint for avatar
        ApplyCorner(avatarImg, CORNERS.FULL)

        -- Status dot
        local statusDot = MakeFrame({
            Name   = "StatusDot",
            Size   = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -12, 1, -12),
            Color  = COLORS.Success,
            Trans  = 0,
            ZIndex = 5,
            Parent = avatarContainer,
        })
        ApplyCorner(statusDot, CORNERS.FULL)
        ApplyStroke(statusDot, COLORS.White, 2, 0)
    end

    -- Title text
    local titleX = showAvatar and (avatarPos ~= "right" and 72 or 16) or 16
    MakeLabel({
        Text      = winTitle,
        Font      = FONTS.Display,
        Size      = 20,
        Color     = COLORS.TextPrimary,
        FrameSize = UDim2.new(1, -160, 0, 26),
        Position  = UDim2.new(0, titleX, 0, winSubtitle ~= "" and 12 or 23),
        ZIndex    = 3,
        Parent    = Header,
    })
    if winSubtitle ~= "" then
        MakeLabel({
            Text      = winSubtitle,
            Font      = FONTS.Body,
            Size      = 12,
            Color     = COLORS.TextSecondary,
            FrameSize = UDim2.new(1, -160, 0, 18),
            Position  = UDim2.new(0, titleX, 0, 40),
            ZIndex    = 3,
            Parent    = Header,
        })
    end

    -- Close button
    local closeBtn = MakeButton({
        Name     = "CloseBtn",
        Text     = "✕",
        TextSize = 14,
        TextColor = COLORS.TextMuted,
        Color    = COLORS.Surface,
        Trans    = 0.3,
        Size     = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -48, 0.5, -16),
        ZIndex   = 4,
        Parent   = Header,
    })
    ApplyCorner(closeBtn, CORNERS.FULL)
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = COLORS.Error, TextColor3 = COLORS.White, BackgroundTransparency = 0}, DURATION.Fast)
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = COLORS.Surface, TextColor3 = COLORS.TextMuted, BackgroundTransparency = 0.3}, DURATION.Fast)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(Container, {
            Size = UDim2.new(0, winSize.X * 0.85, 0, winSize.Y * 0.85),
            BackgroundTransparency = 1,
        }, DURATION.Normal, EASING.Exit, Enum.EasingDirection.In)
        Tween(blurEffect, {Size = 0}, DURATION.Normal)
        task.delay(DURATION.Normal, function()
            ScreenGui:Destroy()
            blurEffect:Destroy()
        end)
    end)

    -- ==================== SIDEBAR ====================
    local Sidebar = MakeFrame({
        Name     = "Sidebar",
        Size     = UDim2.new(0, 200, 1, -72),
        Position = UDim2.new(0, 0, 0, 72),
        Color    = COLORS.SidebarBg,
        Trans    = 0.4,
        ZIndex   = 2,
        Parent   = Container,
    })
    -- Sidebar right border
    local sidebarBorder = MakeFrame({
        Name     = "SidebarBorder",
        Size     = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        Color    = COLORS.GlassBorder,
        Trans    = 0.6,
        ZIndex   = 3,
        Parent   = Sidebar,
    })

    local SidebarScroll = MakeScrollFrame({
        Size      = UDim2.new(1, 0, 1, -16),
        Position  = UDim2.new(0, 0, 0, 8),
        BarThickness = 2,
        ZIndex    = 3,
        Parent    = Sidebar,
    })
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 4)
    SidebarList.Parent = SidebarScroll
    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingLeft = UDim.new(0, SPACING.SM)
    SidebarPad.PaddingRight = UDim.new(0, SPACING.SM)
    SidebarPad.PaddingTop = UDim.new(0, SPACING.XS)
    SidebarPad.Parent = SidebarScroll

    -- ==================== CONTENT AREA ====================
    local ContentArea = MakeFrame({
        Name     = "ContentArea",
        Size     = UDim2.new(1, -200, 1, -72),
        Position = UDim2.new(0, 200, 0, 72),
        Color    = COLORS.White,
        Trans    = BG_TRANS + 0.3,
        ZIndex   = 2,
        Parent   = Container,
    })
    -- Rounded bottom-right corner only via frame clip
    local ContentScroll = MakeScrollFrame({
        Size      = UDim2.new(1, 0, 1, 0),
        AutoCanvas = Enum.AutomaticSize.Y,
        BarThickness = 3,
        ZIndex    = 3,
        Parent    = ContentArea,
    })
    local ContentList = Instance.new("UIListLayout")
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder
    ContentList.Padding = UDim.new(0, SPACING.SM)
    ContentList.Parent = ContentScroll
    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingAll = UDim.new(0, SPACING.LG)
    ContentPad.Parent = ContentScroll

    -- ==================== DRAGGABLE ====================
    if draggable then
        local dragging = false
        local dragStart, startPos

        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Container.Position
            end
        end)
        Header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Container.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- ==================== TAB SYSTEM ====================
    local tabs = {}
    local activeTab = nil

    local function setActiveTab(tabName)
        for name, tabData in pairs(tabs) do
            local isActive = name == tabName
            -- Animate tab button
            Tween(tabData.Button, {
                BackgroundColor3 = isActive and COLORS.Accent or COLORS.Transparent,
                BackgroundTransparency = isActive and 0.85 or 1,
            }, DURATION.Fast)
            Tween(tabData.Label, {
                TextColor3 = isActive and COLORS.Accent or COLORS.TextSecondary,
            }, DURATION.Fast)
            if tabData.IconImg then
                Tween(tabData.IconImg, {
                    ImageColor3 = isActive and COLORS.Accent or COLORS.TextSecondary,
                }, DURATION.Fast)
            end
            -- Show/hide content
            tabData.ContentFrame.Visible = isActive
        end
        activeTab = tabName
    end

    -- ==================== WINDOW API ====================
    local WindowAPI = {}

    function WindowAPI:CreateTab(config)
        local cfg = config or {}
        local tabName   = cfg.Name or "Tab"
        local tabIcon   = cfg.Icon or ""
        local tabOrder  = cfg.Order or (#tabs + 1) * 10
        local tabBadge  = cfg.Badge or nil

        -- Sidebar button
        local tabBtn = MakeButton({
            Name     = tabName .. "_TabBtn",
            Text     = "",
            Color    = COLORS.Transparent,
            Trans    = 1,
            Size     = UDim2.new(1, 0, 0, 40),
            ZIndex   = 4,
            Parent   = SidebarScroll,
        })
        tabBtn.LayoutOrder = tabOrder
        ApplyCorner(tabBtn, CORNERS.SM)

        local tabIconImg = nil
        if tabIcon ~= "" then
            tabIconImg = MakeImage({
                Image    = tabIcon,
                Color    = COLORS.TextSecondary,
                Size     = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, -9),
                ZIndex   = 5,
                Parent   = tabBtn,
            })
        end

        local tabLabel = MakeLabel({
            Text      = tabName,
            Font      = FONTS.Subtitle,
            Size      = 13,
            Color     = COLORS.TextSecondary,
            FrameSize = UDim2.new(1, tabIcon ~= "" and -36 or -12, 1, 0),
            Position  = UDim2.new(0, tabIcon ~= "" and 34 or 10, 0, 0),
            ZIndex    = 5,
            Parent    = tabBtn,
        })

        -- Badge
        if tabBadge then
            local badge = MakeFrame({
                Name   = "Badge",
                Size   = UDim2.new(0, 20, 0, 18),
                Position = UDim2.new(1, -24, 0.5, -9),
                Color  = COLORS.Error,
                Trans  = 0,
                ZIndex = 6,
                Parent = tabBtn,
            })
            ApplyCorner(badge, CORNERS.FULL)
            MakeLabel({
                Text      = tostring(tabBadge),
                Font      = FONTS.Caption,
                Size      = 10,
                Color     = COLORS.White,
                FrameSize = UDim2.new(1, 0, 1, 0),
                AlignX    = Enum.TextXAlignment.Center,
                ZIndex    = 7,
                Parent    = badge,
            })
        end

        -- Content frame for this tab (inside ContentScroll)
        local tabContent = MakeFrame({
            Name   = tabName .. "_Content",
            Size   = UDim2.new(1, 0, 0, 0),  -- auto size
            Color  = COLORS.Transparent,
            Trans  = 1,
            ZIndex = 3,
            Parent = ContentScroll,
        })
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Visible = false

        local tabContentList = Instance.new("UIListLayout")
        tabContentList.SortOrder = Enum.SortOrder.LayoutOrder
        tabContentList.Padding = UDim.new(0, SPACING.SM)
        tabContentList.Parent = tabContent

        tabs[tabName] = {
            Button       = tabBtn,
            Label        = tabLabel,
            IconImg      = tabIconImg,
            ContentFrame = tabContent,
            ContentList  = tabContentList,
        }

        -- Auto-activate first tab
        if activeTab == nil then
            setActiveTab(tabName)
        end

        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabName then
                Tween(tabBtn, {BackgroundTransparency = 0.95}, DURATION.Fast)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabName then
                Tween(tabBtn, {BackgroundTransparency = 1}, DURATION.Fast)
            end
        end)
        tabBtn.MouseButton1Click:Connect(function()
            setActiveTab(tabName)
        end)

        -- =====================================================
        -- TAB COMPONENT API
        -- =====================================================
        local TabAPI = {}
        local componentOrder = 0
        local function nextOrder()
            componentOrder = componentOrder + 10
            return componentOrder
        end

        local function BaseRow(height, order)
            local row = MakeFrame({
                Name    = "Row_" .. tostring(order),
                Size    = UDim2.new(1, 0, 0, height or 60),
                Color   = COLORS.White,
                Trans   = BG_TRANS,
                ZIndex  = 4,
                Parent  = tabContent,
            })
            row.LayoutOrder = order
            row.AutomaticSize = Enum.AutomaticSize.Y
            ApplyCorner(row, CORNERS.MD)
            ApplyStroke(row, COLORS.GlassBorder, 1, 0.6)
            return row
        end

        -- ============== TOGGLE ==============
        function TabAPI:CreateToggle(config)
            local cfg = config or {}
            local name     = cfg.Name or "Toggle"
            local desc     = cfg.Description or ""
            local icon     = cfg.Icon or ""
            local default  = cfg.Default or false
            local flag     = cfg.Flag or nil
            local callback = cfg.Callback or function() end
            local o        = nextOrder()

            local rowH = desc ~= "" and 64 or 48
            local row  = BaseRow(rowH, o)

            -- Icon
            local iconImg = nil
            if icon ~= "" then
                iconImg = MakeImage({
                    Image    = icon,
                    Color    = default and COLORS.Accent or COLORS.TextSecondary,
                    Size     = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, SPACING.LG, 0.5, -10),
                    ZIndex   = 5,
                    Parent   = row,
                })
            end

            local textX = icon ~= "" and SPACING.LG + 28 or SPACING.LG
            MakeLabel({
                Text      = name,
                Font      = FONTS.Subtitle,
                Size      = 14,
                Color     = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -120, 0, 20),
                Position  = UDim2.new(0, textX, 0, desc ~= "" and 10 or (rowH/2 - 10)),
                ZIndex    = 5,
                Parent    = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text      = desc,
                    Font      = FONTS.Caption,
                    Size      = 12,
                    Color     = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, -120, 0, 16),
                    Position  = UDim2.new(0, textX, 0, 34),
                    ZIndex    = 5,
                    Parent    = row,
                })
            end

            -- iOS-style switch
            local switchTrack = MakeFrame({
                Name   = "SwitchTrack",
                Size   = UDim2.new(0, 50, 0, 28),
                Position = UDim2.new(1, -66, 0.5, -14),
                Color  = default and COLORS.Accent or Color3.fromRGB(210, 210, 215),
                Trans  = 0,
                ZIndex = 5,
                Parent = row,
            })
            ApplyCorner(switchTrack, CORNERS.FULL)

            local switchThumb = MakeFrame({
                Name   = "SwitchThumb",
                Size   = UDim2.new(0, 22, 0, 22),
                Position = default
                    and UDim2.new(0, 25, 0.5, -11)
                    or  UDim2.new(0, 3, 0.5, -11),
                Color  = COLORS.White,
                Trans  = 0,
                ZIndex = 6,
                Parent = switchTrack,
            })
            ApplyCorner(switchThumb, CORNERS.FULL)
            ApplyShadow(switchThumb, 8, 0.5)

            local toggled = default
            if flag then Nexuralib.Flags[flag] = toggled end

            local function setToggle(val, skipCallback)
                toggled = val
                if flag then Nexuralib.Flags[flag] = val end
                -- Spring thumb
                SpringTween(switchThumb, {
                    Position = val
                        and UDim2.new(0, 25, 0.5, -11)
                        or  UDim2.new(0, 3, 0.5, -11)
                }, 0.35)
                Tween(switchTrack, {
                    BackgroundColor3 = val and COLORS.Accent or Color3.fromRGB(210, 210, 215)
                }, DURATION.Normal)
                if iconImg then
                    Tween(iconImg, {
                        ImageColor3 = val and COLORS.Accent or COLORS.TextSecondary
                    }, DURATION.Fast)
                end
                if not skipCallback then callback(val) end
            end

            switchTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    setToggle(not toggled)
                end
            end)

            return {
                SetValue = function(val) setToggle(val, true) end,
                GetValue = function() return toggled end,
            }
        end

        -- ============== BUTTON ==============
        function TabAPI:CreateButton(config)
            local cfg    = config or {}
            local name   = cfg.Name or "Button"
            local desc   = cfg.Description or ""
            local icon   = cfg.Icon or ""
            local variant= cfg.Variant or "primary"
            local loading= cfg.Loading or false
            local fw     = cfg.FullWidth or false
            local callback = cfg.Callback or function() end
            local o      = nextOrder()

            local btnH   = desc ~= "" and 64 or 48
            local row    = BaseRow(btnH, o)

            -- Variant colors
            local bgColor, textColor, bgTrans
            if variant == "primary" then
                bgColor = COLORS.Accent; textColor = COLORS.White; bgTrans = 0
            elseif variant == "secondary" then
                bgColor = COLORS.Surface; textColor = COLORS.Accent; bgTrans = 0.2
            elseif variant == "ghost" then
                bgColor = COLORS.Transparent; textColor = COLORS.Accent; bgTrans = 1
            elseif variant == "danger" then
                bgColor = COLORS.Error; textColor = COLORS.White; bgTrans = 0
            else
                bgColor = COLORS.Accent; textColor = COLORS.White; bgTrans = 0
            end

            local btnW = fw and -SPACING.XXL or 160
            local btnFrame = MakeButton({
                Name     = "Btn_" .. name,
                Text     = "",
                Color    = bgColor,
                Trans    = bgTrans,
                Size     = fw
                    and UDim2.new(1, -SPACING.XXL, 0, btnH - 16)
                    or  UDim2.new(0, 160, 0, btnH - 16),
                Position = UDim2.new(fw and 0 or 1, fw and SPACING.MD or -(160 + SPACING.MD), 0.5, -(btnH-16)/2),
                ZIndex   = 5,
                Parent   = row,
            })
            if fw then btnFrame.AnchorPoint = Vector2.new(0, 0.5) end
            ApplyCorner(btnFrame, CORNERS.SM)
            if variant == "secondary" or variant == "ghost" then
                ApplyStroke(btnFrame, COLORS.Accent, 1.5, 0.4)
            end

            -- Icon inside button
            local btnIconImg = nil
            if icon ~= "" then
                btnIconImg = MakeImage({
                    Image    = icon,
                    Color    = textColor,
                    Size     = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, SPACING.MD, 0.5, -8),
                    ZIndex   = 6,
                    Parent   = btnFrame,
                })
            end

            MakeLabel({
                Text      = name,
                Font      = FONTS.Title,
                Size      = 13,
                Color     = textColor,
                FrameSize = UDim2.new(1, icon ~= "" and -44 or -SPACING.MD, 1, 0),
                Position  = UDim2.new(0, icon ~= "" and 36 or SPACING.SM, 0, 0),
                AlignX    = Enum.TextXAlignment.Center,
                ZIndex    = 6,
                Parent    = btnFrame,
            })

            if desc ~= "" and not fw then
                MakeLabel({
                    Text      = desc,
                    Font      = FONTS.Caption,
                    Size      = 12,
                    Color     = COLORS.TextMuted,
                    FrameSize = UDim2.new(0.5, -SPACING.MD, 0, 16),
                    Position  = UDim2.new(0, SPACING.LG, 1, -24),
                    ZIndex    = 5,
                    Parent    = row,
                })
            end

            -- Loading spinner (simple rotation)
            local spinner = nil
            local spinConn = nil
            local function setLoading(isLoading)
                if isLoading then
                    if not spinner then
                        spinner = MakeImage({
                            Image    = "rbxassetid://4031732851",
                            Color    = textColor,
                            Size     = UDim2.new(0, 16, 0, 16),
                            Position = UDim2.new(0.5, -8, 0.5, -8),
                            ZIndex   = 7,
                            Parent   = btnFrame,
                        })
                    end
                    spinner.Visible = true
                    local rot = 0
                    spinConn = RunService.Heartbeat:Connect(function(dt)
                        rot = rot + 360 * dt
                        spinner.Rotation = rot
                    end)
                else
                    if spinner then spinner.Visible = false end
                    if spinConn then spinConn:Disconnect() spinConn = nil end
                end
            end

            if loading then setLoading(true) end

            -- Hover & click effects
            btnFrame.MouseEnter:Connect(function()
                Tween(btnFrame, {
                    BackgroundTransparency = math.max(0, bgTrans - 0.1),
                    Position = UDim2.new(
                        btnFrame.Position.X.Scale,
                        btnFrame.Position.X.Offset,
                        btnFrame.Position.Y.Scale,
                        btnFrame.Position.Y.Offset - 2
                    )
                }, DURATION.Fast)
            end)
            btnFrame.MouseLeave:Connect(function()
                Tween(btnFrame, {
                    BackgroundTransparency = bgTrans,
                    Position = UDim2.new(
                        btnFrame.Position.X.Scale,
                        btnFrame.Position.X.Offset,
                        btnFrame.Position.Y.Scale,
                        btnFrame.Position.Y.Offset + 2
                    )
                }, DURATION.Fast)
            end)
            btnFrame.MouseButton1Click:Connect(function()
                -- Ripple
                local mp = UserInputService:GetMouseLocation()
                local relX = mp.X - btnFrame.AbsolutePosition.X
                local relY = mp.Y - btnFrame.AbsolutePosition.Y
                CreateRipple(btnFrame, relX, relY)
                callback()
            end)

            return {
                SetLoading = setLoading,
                SetText    = function(t)
                    for _, c in ipairs(btnFrame:GetChildren()) do
                        if c:IsA("TextLabel") then c.Text = t end
                    end
                end,
            }
        end

        -- ============== SLIDER ==============
        function TabAPI:CreateSlider(config)
            local cfg    = config or {}
            local name   = cfg.Name or "Slider"
            local desc   = cfg.Description or ""
            local icon   = cfg.Icon or ""
            local minV   = cfg.Min or 0
            local maxV   = cfg.Max or 100
            local def    = cfg.Default or minV
            local inc    = cfg.Increment or 1
            local fmt    = cfg.ValueFormat or "%d"
            local showV  = cfg.ShowValue ~= false
            local flag   = cfg.Flag or nil
            local callback = cfg.Callback or function() end
            local o      = nextOrder()

            local rowH = desc ~= "" and 80 or 64
            local row  = BaseRow(rowH, o)

            -- Icon
            if icon ~= "" then
                MakeImage({
                    Image    = icon,
                    Color    = COLORS.TextSecondary,
                    Size     = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, SPACING.LG, 0, 12),
                    ZIndex   = 5,
                    Parent   = row,
                })
            end

            local textX = icon ~= "" and SPACING.LG + 28 or SPACING.LG
            MakeLabel({
                Text      = name,
                Font      = FONTS.Subtitle,
                Size      = 14,
                Color     = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -80, 0, 18),
                Position  = UDim2.new(0, textX, 0, 10),
                ZIndex    = 5,
                Parent    = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text      = desc,
                    Font      = FONTS.Caption,
                    Size      = 12,
                    Color     = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, -80, 0, 14),
                    Position  = UDim2.new(0, textX, 0, 30),
                    ZIndex    = 5,
                    Parent    = row,
                })
            end

            local valueLabel = nil
            if showV then
                valueLabel = MakeLabel({
                    Text      = string.format(fmt, def),
                    Font      = FONTS.Code,
                    Size      = 13,
                    Color     = COLORS.Accent,
                    FrameSize = UDim2.new(0, 60, 0, 18),
                    Position  = UDim2.new(1, -68, 0, 10),
                    AlignX    = Enum.TextXAlignment.Right,
                    ZIndex    = 5,
                    Parent    = row,
                })
            end

            -- Track
            local trackY = desc ~= "" and 58 or 42
            local track = MakeFrame({
                Name   = "SliderTrack",
                Size   = UDim2.new(1, -(SPACING.LG * 2 + (showV and 64 or 0)), 0, 6),
                Position = UDim2.new(0, SPACING.LG, 0, trackY),
                Color  = Color3.fromRGB(220, 220, 225),
                Trans  = 0.2,
                ZIndex = 5,
                Parent = row,
            })
            ApplyCorner(track, CORNERS.FULL)

            -- Fill
            local fill = MakeFrame({
                Name   = "SliderFill",
                Size   = UDim2.new(0, 0, 1, 0),
                Color  = COLORS.Accent,
                Trans  = 0,
                ZIndex = 6,
                Parent = track,
            })
            ApplyCorner(fill, CORNERS.FULL)

            -- Thumb
            local thumb = MakeFrame({
                Name   = "SliderThumb",
                Size   = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, -10, 0.5, -10),
                Color  = COLORS.White,
                Trans  = 0,
                ZIndex = 7,
                Parent = fill,
            })
            ApplyCorner(thumb, CORNERS.FULL)
            ApplyStroke(thumb, COLORS.Accent, 2, 0)
            ApplyShadow(thumb, 8, 0.5)

            local currentVal = def
            if flag then Nexuralib.Flags[flag] = currentVal end

            local function snapValue(raw)
                local snapped = math.round((raw - minV) / inc) * inc + minV
                return math.clamp(snapped, minV, maxV)
            end

            local function setSlider(val, skipCallback)
                currentVal = snapValue(val)
                if flag then Nexuralib.Flags[flag] = currentVal end
                local pct = (currentVal - minV) / (maxV - minV)
                Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, DURATION.Fast)
                if valueLabel then
                    valueLabel.Text = string.format(fmt, currentVal)
                end
                if not skipCallback then callback(currentVal) end
            end

            -- Init
            setSlider(def, true)

            -- Drag logic
            local dragging = false
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    -- Glow on drag
                    Tween(thumb, {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, -12, 0.5, -12)}, DURATION.Fast)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                    dragging = false
                    Tween(thumb, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, -10, 0.5, -10)}, DURATION.Fast)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local trackAbs = track.AbsolutePosition
                    local trackW   = track.AbsoluteSize.X
                    local relX     = math.clamp(input.Position.X - trackAbs.X, 0, trackW)
                    local pct      = relX / trackW
                    setSlider(minV + pct * (maxV - minV))
                end
            end)

            return {
                SetValue = function(v) setSlider(v, true) end,
                GetValue = function() return currentVal end,
            }
        end

        -- ============== DROPDOWN ==============
        function TabAPI:CreateDropdown(config)
            local cfg      = config or {}
            local name     = cfg.Name or "Dropdown"
            local desc     = cfg.Description or ""
            local icon     = cfg.Icon or ""
            local options  = cfg.Options or {}
            local default  = cfg.Default or nil
            local multi    = cfg.MultiSelect or false
            local search   = cfg.Searchable or false
            local showCnt  = cfg.ShowSelectedCount or false
            local flag     = cfg.Flag or nil
            local callback = cfg.Callback or function() end
            local o        = nextOrder()

            local rowH = desc ~= "" and 72 or 56
            local row  = BaseRow(rowH, o)

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = COLORS.TextSecondary,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, SPACING.LG, 0.5, -10),
                    ZIndex = 5, Parent = row,
                })
            end

            local textX = icon ~= "" and SPACING.LG + 28 or SPACING.LG
            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 14,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -100, 0, 18),
                Position  = UDim2.new(0, textX, 0, desc ~= "" and 8 or (rowH/2 - 12)),
                ZIndex = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 12,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, -100, 0, 14),
                    Position = UDim2.new(0, textX, 0, 28),
                    ZIndex = 5, Parent = row,
                })
            end

            -- Selected display button
            local selectedText = default or "Select..."
            local selBtn = MakeButton({
                Name = "DropdownSel",
                Text = selectedText,
                Font = FONTS.Body, TextSize = 12,
                TextColor = default and COLORS.TextPrimary or COLORS.TextMuted,
                Color = COLORS.Surface, Trans = 0.2,
                Size = UDim2.new(0, 140, 0, 32),
                Position = UDim2.new(1, -(140 + SPACING.MD), 0.5, -16),
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(selBtn, CORNERS.SM)
            ApplyStroke(selBtn, COLORS.GlassBorder, 1, 0.5)

            -- Chevron icon
            local chevron = MakeLabel({
                Text = "▾", Font = FONTS.Body, Size = 12,
                Color = COLORS.TextMuted,
                FrameSize = UDim2.new(0, 16, 1, 0),
                Position = UDim2.new(1, -18, 0, 0),
                AlignX = Enum.TextXAlignment.Center,
                ZIndex = 6, Parent = selBtn,
            })

            local selected = multi and {} or default
            if flag then Nexuralib.Flags[flag] = selected end

            -- Floating dropdown menu
            local menuOpen = false
            local menuFrame = nil

            local function closeMenu()
                if menuFrame then
                    Tween(menuFrame, {BackgroundTransparency = 1, Size = UDim2.new(menuFrame.Size.X.Scale, menuFrame.Size.X.Offset, 0, 0)}, DURATION.Fast, EASING.Exit, Enum.EasingDirection.In)
                    task.delay(DURATION.Fast, function()
                        if menuFrame then menuFrame:Destroy(); menuFrame = nil end
                    end)
                end
                Tween(chevron, {Rotation = 0}, DURATION.Fast)
                menuOpen = false
            end

            local function openMenu()
                if menuFrame then closeMenu() return end
                menuOpen = true
                Tween(chevron, {Rotation = 180}, DURATION.Fast)

                local menuH = math.min(#options * 36 + (search and 40 or 8) + 8, 200)
                menuFrame = MakeFrame({
                    Name   = "DropdownMenu",
                    Size   = UDim2.new(0, 200, 0, 0),
                    Position = UDim2.new(1, -(200 + SPACING.MD), 0, rowH + 4),
                    Color  = COLORS.White,
                    Trans  = BG_TRANS,
                    ZIndex = 20,
                    Parent = row,
                })
                menuFrame.ClipsDescendants = true
                ApplyCorner(menuFrame, CORNERS.MD)
                ApplyStroke(menuFrame, COLORS.GlassBorder, 1, 0.4)
                ApplyShadow(menuFrame, 16, 0.6)

                Tween(menuFrame, {Size = UDim2.new(0, 200, 0, menuH)}, DURATION.Normal, EASING.Enter, Enum.EasingDirection.Out)

                local menuScroll = MakeScrollFrame({
                    Size = UDim2.new(1, 0, 1, 0),
                    BarThickness = 2,
                    ZIndex = 21,
                    Parent = menuFrame,
                })
                local menuList = Instance.new("UIListLayout")
                menuList.SortOrder = Enum.SortOrder.LayoutOrder
                menuList.Padding = UDim.new(0, 2)
                menuList.Parent = menuScroll
                local menuPad = Instance.new("UIPadding")
                menuPad.PaddingAll = UDim.new(0, 4)
                menuPad.Parent = menuScroll

                -- Search box
                local searchQuery = ""
                if search then
                    local searchBox = Instance.new("TextBox")
                    searchBox.PlaceholderText = "Search..."
                    searchBox.Text = ""
                    searchBox.Font = FONTS.Body
                    searchBox.TextSize = 12
                    searchBox.TextColor3 = COLORS.TextPrimary
                    searchBox.PlaceholderColor3 = COLORS.TextMuted
                    searchBox.BackgroundColor3 = COLORS.Surface
                    searchBox.BackgroundTransparency = 0.3
                    searchBox.Size = UDim2.new(1, -8, 0, 30)
                    searchBox.ZIndex = 22
                    searchBox.ClearTextOnFocus = false
                    searchBox.LayoutOrder = 0
                    searchBox.Parent = menuScroll
                    ApplyCorner(searchBox, CORNERS.SM)
                end

                local function buildOptions(filter)
                    -- Clear existing options
                    for _, c in ipairs(menuScroll:GetChildren()) do
                        if c.Name:sub(1, 4) == "Opt_" then c:Destroy() end
                    end
                    for i, opt in ipairs(options) do
                        if filter == "" or opt:lower():find(filter:lower(), 1, true) then
                            local isSelected = multi
                                and (function()
                                    for _, v in ipairs(selected) do if v == opt then return true end end
                                    return false
                                end)()
                                or selected == opt

                            local optBtn = MakeButton({
                                Name = "Opt_" .. opt,
                                Text = "",
                                Color = isSelected and COLORS.Accent or COLORS.Transparent,
                                Trans = isSelected and 0.85 or 1,
                                Size = UDim2.new(1, 0, 0, 32),
                                ZIndex = 22,
                                Parent = menuScroll,
                            })
                            optBtn.LayoutOrder = i
                            ApplyCorner(optBtn, CORNERS.SM)

                            MakeLabel({
                                Text = opt, Font = FONTS.Body, Size = 13,
                                Color = isSelected and COLORS.Accent or COLORS.TextPrimary,
                                FrameSize = UDim2.new(1, -32, 1, 0),
                                Position = UDim2.new(0, 8, 0, 0),
                                ZIndex = 23, Parent = optBtn,
                            })

                            if isSelected then
                                MakeLabel({
                                    Text = "✓", Font = FONTS.Title, Size = 13,
                                    Color = COLORS.Accent,
                                    FrameSize = UDim2.new(0, 20, 1, 0),
                                    Position = UDim2.new(1, -24, 0, 0),
                                    AlignX = Enum.TextXAlignment.Center,
                                    ZIndex = 23, Parent = optBtn,
                                })
                            end

                            optBtn.MouseEnter:Connect(function()
                                if not isSelected then
                                    Tween(optBtn, {BackgroundTransparency = 0.95}, DURATION.Fast)
                                end
                            end)
                            optBtn.MouseLeave:Connect(function()
                                if not isSelected then
                                    Tween(optBtn, {BackgroundTransparency = 1}, DURATION.Fast)
                                end
                            end)
                            optBtn.MouseButton1Click:Connect(function()
                                if multi then
                                    local found = false
                                    for i2, v in ipairs(selected) do
                                        if v == opt then
                                            table.remove(selected, i2)
                                            found = true break
                                        end
                                    end
                                    if not found then table.insert(selected, opt) end
                                    local dispText = showCnt
                                        and (#selected > 0 and #selected .. " selected" or "Select...")
                                        or (#selected > 0 and table.concat(selected, ", ") or "Select...")
                                    selBtn.Text = dispText
                                    selBtn.TextColor3 = #selected > 0 and COLORS.TextPrimary or COLORS.TextMuted
                                    if flag then Nexuralib.Flags[flag] = selected end
                                    callback(selected)
                                    buildOptions(searchQuery)
                                else
                                    selected = opt
                                    selBtn.Text = opt
                                    selBtn.TextColor3 = COLORS.TextPrimary
                                    if flag then Nexuralib.Flags[flag] = selected end
                                    callback(selected)
                                    closeMenu()
                                end
                            end)
                        end
                    end
                end
                buildOptions("")
            end

            selBtn.MouseButton1Click:Connect(openMenu)

            return {
                SetValue = function(v)
                    selected = v
                    if type(v) == "table" then
                        selBtn.Text = #v > 0 and table.concat(v, ", ") or "Select..."
                    else
                        selBtn.Text = v or "Select..."
                    end
                    selBtn.TextColor3 = v and COLORS.TextPrimary or COLORS.TextMuted
                    if flag then Nexuralib.Flags[flag] = selected end
                end,
                GetValue = function() return selected end,
                Refresh  = function(newOpts)
                    options = newOpts
                    if menuFrame then closeMenu() end
                end,
            }
        end

        -- ============== INPUT ==============
        function TabAPI:CreateInput(config)
            local cfg      = config or {}
            local name     = cfg.Name or "Input"
            local desc     = cfg.Description or ""
            local icon     = cfg.Icon or ""
            local ph       = cfg.Placeholder or "Enter value..."
            local default  = cfg.Default or ""
            local itype    = cfg.Type or "text"
            local maxLen   = cfg.MaxLength or nil
            local clearBtn = cfg.ClearButton ~= false
            local valid    = cfg.Validation or nil
            local flag     = cfg.Flag or nil
            local callback = cfg.Callback or function() end
            local o        = nextOrder()

            local rowH = desc ~= "" and 80 or 64
            local row  = BaseRow(rowH, o)

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = COLORS.TextSecondary,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, SPACING.LG, 0, 10),
                    ZIndex = 5, Parent = row,
                })
            end

            local textX = icon ~= "" and SPACING.LG + 28 or SPACING.LG
            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 14,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -100, 0, 18),
                Position = UDim2.new(0, textX, 0, 8),
                ZIndex = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 12,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, -100, 0, 14),
                    Position = UDim2.new(0, textX, 0, 28),
                    ZIndex = 5, Parent = row,
                })
            end

            -- Input background
            local inputY = desc ~= "" and 48 or 34
            local inputBg = MakeFrame({
                Name   = "InputBg",
                Size   = UDim2.new(1, -(SPACING.LG * 2), 0, 34),
                Position = UDim2.new(0, SPACING.LG, 0, inputY),
                Color  = COLORS.Surface,
                Trans  = 0.3,
                ZIndex = 5,
                Parent = row,
            })
            ApplyCorner(inputBg, CORNERS.SM)
            local inputStroke = ApplyStroke(inputBg, COLORS.GlassBorder, 1, 0.5)

            local box = Instance.new("TextBox")
            box.PlaceholderText = ph
            box.Text = default
            box.Font = FONTS.Body
            box.TextSize = 13
            box.TextColor3 = COLORS.TextPrimary
            box.PlaceholderColor3 = COLORS.TextMuted
            box.BackgroundTransparency = 1
            box.Size = UDim2.new(1, clearBtn and -36 or -8, 1, 0)
            box.Position = UDim2.new(0, 8, 0, 0)
            box.ZIndex = 6
            box.ClearTextOnFocus = false
            box.Parent = inputBg

            if itype == "password" then box.TextEditable = true end

            if clearBtn then
                local clrBtn = MakeButton({
                    Name = "ClearBtn", Text = "✕",
                    TextSize = 11, TextColor = COLORS.TextMuted,
                    Color = COLORS.Transparent, Trans = 1,
                    Size = UDim2.new(0, 28, 0, 28),
                    Position = UDim2.new(1, -30, 0.5, -14),
                    ZIndex = 7, Parent = inputBg,
                })
                clrBtn.MouseButton1Click:Connect(function()
                    box.Text = ""
                    if flag then Nexuralib.Flags[flag] = "" end
                    callback("")
                end)
            end

            -- Validation label
            local validLabel = MakeLabel({
                Text = "", Font = FONTS.Caption, Size = 11,
                Color = COLORS.Error,
                FrameSize = UDim2.new(1, -SPACING.XXL, 0, 14),
                Position = UDim2.new(0, SPACING.LG, 1, -16),
                ZIndex = 5, Parent = row,
            })

            box.Focused:Connect(function()
                Tween(inputBg, {BackgroundTransparency = 0.1}, DURATION.Fast)
                inputStroke.Color = COLORS.Accent
                inputStroke.Transparency = 0.2
            end)
            box.FocusLost:Connect(function(enter)
                Tween(inputBg, {BackgroundTransparency = 0.3}, DURATION.Fast)
                inputStroke.Color = COLORS.GlassBorder
                inputStroke.Transparency = 0.5
                local val = box.Text
                if maxLen and #val > maxLen then
                    val = val:sub(1, maxLen)
                    box.Text = val
                end
                if valid then
                    local ok, msg = valid(val)
                    validLabel.Text = ok and "" or (msg or "Invalid input")
                    validLabel.TextColor3 = ok and COLORS.Success or COLORS.Error
                end
                if flag then Nexuralib.Flags[flag] = val end
                callback(val)
            end)

            return {
                SetValue = function(v) box.Text = v end,
                GetValue = function() return box.Text end,
            }
        end

        -- ============== KEYBIND ==============
        function TabAPI:CreateKeybind(config)
            local cfg      = config or {}
            local name     = cfg.Name or "Keybind"
            local desc     = cfg.Description or ""
            local icon     = cfg.Icon or ""
            local default  = cfg.Default or Enum.KeyCode.Unknown
            local hold     = cfg.Hold or false
            local blacklist = cfg.Blacklist or {}
            local flag     = cfg.Flag or nil
            local callback = cfg.Callback or function() end
            local o        = nextOrder()

            local rowH = desc ~= "" and 64 or 48
            local row  = BaseRow(rowH, o)

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = COLORS.TextSecondary,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, SPACING.LG, 0.5, -10),
                    ZIndex = 5, Parent = row,
                })
            end

            local textX = icon ~= "" and SPACING.LG + 28 or SPACING.LG
            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 14,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -120, 0, 18),
                Position = UDim2.new(0, textX, 0, desc ~= "" and 8 or (rowH/2 - 9)),
                ZIndex = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 12,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, -120, 0, 14),
                    Position = UDim2.new(0, textX, 0, 28),
                    ZIndex = 5, Parent = row,
                })
            end

            -- Key pill
            local currentKey = default
            if flag then Nexuralib.Flags[flag] = currentKey end

            local pill = MakeButton({
                Name = "KeyPill",
                Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name,
                Font = FONTS.Code, TextSize = 12,
                TextColor = COLORS.Accent,
                Color = COLORS.Accent, Trans = 0.88,
                Size = UDim2.new(0, 90, 0, 28),
                Position = UDim2.new(1, -106, 0.5, -14),
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(pill, CORNERS.FULL)
            ApplyStroke(pill, COLORS.Accent, 1, 0.5)

            local recording = false

            pill.MouseButton1Click:Connect(function()
                if recording then return end
                recording = true
                pill.Text = "..."
                Tween(pill, {BackgroundTransparency = 0.7}, DURATION.Fast)
                local conn
                conn = UserInputService.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    local blacklisted = false
                    for _, k in ipairs(blacklist) do
                        if input.KeyCode == k then blacklisted = true break end
                    end
                    if not blacklisted and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        pill.Text = currentKey.Name
                        if flag then Nexuralib.Flags[flag] = currentKey end
                        recording = false
                        Tween(pill, {BackgroundTransparency = 0.88}, DURATION.Fast)
                        conn:Disconnect()
                    end
                end)
            end)

            -- Listen for keybind trigger
            UserInputService.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
                    if not hold then callback(true) end
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.KeyCode == currentKey and hold and currentKey ~= Enum.KeyCode.Unknown then
                    callback(false)
                end
            end)

            return {
                SetKey = function(k)
                    currentKey = k
                    pill.Text = k == Enum.KeyCode.Unknown and "None" or k.Name
                    if flag then Nexuralib.Flags[flag] = k end
                end,
                GetKey = function() return currentKey end,
            }
        end

        -- ============== COLOR PICKER ==============
        function TabAPI:CreateColorPicker(config)
            local cfg      = config or {}
            local name     = cfg.Name or "Color"
            local desc     = cfg.Description or ""
            local icon     = cfg.Icon or ""
            local default  = cfg.Default or Color3.fromRGB(0, 122, 255)
            local presets  = cfg.Presets or {
                Color3.fromRGB(255,59,48), Color3.fromRGB(255,149,0),
                Color3.fromRGB(255,204,0), Color3.fromRGB(52,199,89),
                Color3.fromRGB(0,122,255), Color3.fromRGB(175,82,222),
            }
            local showHex  = cfg.ShowHex ~= false
            local showRGB  = cfg.ShowRGB or false
            local flag     = cfg.Flag or nil
            local callback = cfg.Callback or function() end
            local o        = nextOrder()

            local rowH = 56
            local row  = BaseRow(rowH, o)

            if icon ~= "" then
                MakeImage({
                    Image = icon, Color = COLORS.TextSecondary,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, SPACING.LG, 0.5, -10),
                    ZIndex = 5, Parent = row,
                })
            end

            local textX = icon ~= "" and SPACING.LG + 28 or SPACING.LG
            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 14,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -100, 0, 18),
                Position = UDim2.new(0, textX, 0, desc ~= "" and 8 or (rowH/2 - 9)),
                ZIndex = 5, Parent = row,
            })
            if desc ~= "" then
                MakeLabel({
                    Text = desc, Font = FONTS.Caption, Size = 12,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, -100, 0, 14),
                    Position = UDim2.new(0, textX, 0, 28),
                    ZIndex = 5, Parent = row,
                })
            end

            -- Color preview swatch
            local currentColor = default
            if flag then Nexuralib.Flags[flag] = currentColor end

            local swatch = MakeButton({
                Name = "ColorSwatch",
                Text = "",
                Color = currentColor, Trans = 0,
                Size = UDim2.new(0, 40, 0, 28),
                Position = UDim2.new(1, -(40 + SPACING.MD), 0.5, -14),
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(swatch, CORNERS.SM)
            ApplyStroke(swatch, COLORS.GlassBorder, 1.5, 0.3)

            -- Hex label
            local r2, g2, b2 = math.floor(default.R*255), math.floor(default.G*255), math.floor(default.B*255)
            local hexLabel = MakeLabel({
                Text = string.format("#%02X%02X%02X", r2, g2, b2),
                Font = FONTS.Code, Size = 12,
                Color = COLORS.TextSecondary,
                FrameSize = UDim2.new(0, 70, 0, 18),
                Position = UDim2.new(1, -(40 + SPACING.MD + 78), 0.5, -9),
                AlignX = Enum.TextXAlignment.Right,
                ZIndex = 5, Parent = row,
            })

            -- Expanded picker panel (shows when swatch clicked)
            local pickerOpen = false
            local pickerPanel = nil

            local function updateColor(c, skipCallback)
                currentColor = c
                swatch.BackgroundColor3 = c
                local r3, g3, b3 = math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255)
                hexLabel.Text = string.format("#%02X%02X%02X", r3, g3, b3)
                if flag then Nexuralib.Flags[flag] = c end
                if not skipCallback then callback(c) end
            end

            local function openPicker()
                if pickerPanel then
                    Tween(pickerPanel, {BackgroundTransparency = 1, Size = UDim2.new(pickerPanel.Size.X.Scale, pickerPanel.Size.X.Offset, 0, 0)}, DURATION.Fast)
                    task.delay(DURATION.Fast, function()
                        if pickerPanel then pickerPanel:Destroy(); pickerPanel = nil end
                    end)
                    pickerOpen = false
                    return
                end
                pickerOpen = true

                local panelH = 240 + (showRGB and 60 or 0) + (#presets > 0 and 40 or 0)
                pickerPanel = MakeFrame({
                    Name   = "ColorPickerPanel",
                    Size   = UDim2.new(1, -SPACING.XXL, 0, 0),
                    Position = UDim2.new(0, SPACING.MD, 0, rowH + 4),
                    Color  = COLORS.White,
                    Trans  = BG_TRANS,
                    ZIndex = 15,
                    Parent = row,
                })
                pickerPanel.ClipsDescendants = true
                ApplyCorner(pickerPanel, CORNERS.MD)
                ApplyStroke(pickerPanel, COLORS.GlassBorder, 1, 0.4)
                ApplyShadow(pickerPanel, 16, 0.6)

                Tween(pickerPanel, {Size = UDim2.new(1, -SPACING.XXL, 0, panelH)}, DURATION.Normal, EASING.Enter, Enum.EasingDirection.Out)

                -- Hue/Sat box (simulated with gradient)
                local hsvBox = MakeFrame({
                    Name = "HSVBox",
                    Size = UDim2.new(1, -SPACING.XXL, 0, 140),
                    Position = UDim2.new(0, SPACING.MD, 0, SPACING.MD),
                    Color = currentColor,
                    Trans = 0,
                    ZIndex = 16,
                    Parent = pickerPanel,
                })
                ApplyCorner(hsvBox, CORNERS.SM)

                -- White to transparent gradient overlay
                local wGrad = Instance.new("UIGradient")
                wGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                })
                wGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                })
                wGrad.Parent = hsvBox

                -- Crosshair
                local crosshair = MakeFrame({
                    Name = "Crosshair",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, -6, 0, -6),
                    Color = COLORS.White,
                    Trans = 0,
                    ZIndex = 17,
                    Parent = hsvBox,
                })
                ApplyCorner(crosshair, CORNERS.FULL)
                ApplyStroke(crosshair, COLORS.White, 2, 0)

                -- Hue slider
                local hueTrack = MakeFrame({
                    Name = "HueTrack",
                    Size = UDim2.new(1, -SPACING.XXL, 0, 16),
                    Position = UDim2.new(0, SPACING.MD, 0, 160),
                    Color = COLORS.White,
                    Trans = 0,
                    ZIndex = 16,
                    Parent = pickerPanel,
                })
                ApplyCorner(hueTrack, CORNERS.FULL)

                local hueGrad = Instance.new("UIGradient")
                hueGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0/6,   Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(1/6,   Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(2/6,   Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(3/6,   Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(4/6,   Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(5/6,   Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1,     Color3.fromRGB(255,0,0)),
                })
                hueGrad.Parent = hueTrack

                local hueThumb = MakeFrame({
                    Name = "HueThumb",
                    Size = UDim2.new(0, 16, 1, 4),
                    Position = UDim2.new(0, -8, 0, -2),
                    Color = COLORS.White,
                    Trans = 0,
                    ZIndex = 17,
                    Parent = hueTrack,
                })
                ApplyCorner(hueThumb, CORNERS.SM)
                ApplyStroke(hueThumb, COLORS.White, 2, 0)
                ApplyShadow(hueThumb, 6, 0.5)

                -- Presets
                if #presets > 0 then
                    local presetRow = MakeFrame({
                        Name = "Presets",
                        Size = UDim2.new(1, -SPACING.XXL, 0, 30),
                        Position = UDim2.new(0, SPACING.MD, 0, 185),
                        Color = COLORS.Transparent, Trans = 1,
                        ZIndex = 16, Parent = pickerPanel,
                    })
                    local presetList = Instance.new("UIListLayout")
                    presetList.FillDirection = Enum.FillDirection.Horizontal
                    presetList.Padding = UDim.new(0, SPACING.SM)
                    presetList.Parent = presetRow

                    for _, pc in ipairs(presets) do
                        local pb = MakeButton({
                            Name = "Preset",
                            Text = "", Color = pc, Trans = 0,
                            Size = UDim2.new(0, 24, 0, 24),
                            ZIndex = 17, Parent = presetRow,
                        })
                        ApplyCorner(pb, CORNERS.FULL)
                        ApplyStroke(pb, COLORS.GlassBorder, 1.5, 0.3)
                        pb.MouseButton1Click:Connect(function()
                            updateColor(pc)
                        end)
                    end
                end

                -- Hex input
                if showHex then
                    local hexBg = MakeFrame({
                        Name = "HexBg",
                        Size = UDim2.new(1, -SPACING.XXL, 0, 32),
                        Position = UDim2.new(0, SPACING.MD, 0, panelH - 44),
                        Color = COLORS.Surface, Trans = 0.3,
                        ZIndex = 16, Parent = pickerPanel,
                    })
                    ApplyCorner(hexBg, CORNERS.SM)
                    ApplyStroke(hexBg, COLORS.GlassBorder, 1, 0.5)

                    local hexBox = Instance.new("TextBox")
                    hexBox.PlaceholderText = "#RRGGBB"
                    local hr, hg, hb = math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255)
                    hexBox.Text = string.format("#%02X%02X%02X", hr, hg, hb)
                    hexBox.Font = FONTS.Code
                    hexBox.TextSize = 13
                    hexBox.TextColor3 = COLORS.TextPrimary
                    hexBox.BackgroundTransparency = 1
                    hexBox.Size = UDim2.new(1, -12, 1, 0)
                    hexBox.Position = UDim2.new(0, 6, 0, 0)
                    hexBox.ZIndex = 17
                    hexBox.ClearTextOnFocus = false
                    hexBox.Parent = hexBg

                    hexBox.FocusLost:Connect(function()
                        local hex = hexBox.Text:gsub("#", "")
                        if #hex == 6 then
                            local r3 = tonumber(hex:sub(1,2), 16) or 0
                            local g3 = tonumber(hex:sub(3,4), 16) or 0
                            local b3 = tonumber(hex:sub(5,6), 16) or 0
                            updateColor(Color3.fromRGB(r3, g3, b3))
                        end
                    end)
                end
            end

            swatch.MouseButton1Click:Connect(openPicker)

            updateColor(default, true)

            return {
                SetValue = function(c) updateColor(c, true) end,
                GetValue = function() return currentColor end,
            }
        end

        -- ============== PROGRESS ==============
        function TabAPI:CreateProgress(config)
            local cfg      = config or {}
            local name     = cfg.Name or "Progress"
            local ptype    = cfg.Type or "bar"
            local progress = cfg.Progress or 0
            local indet    = cfg.Indeterminate or false
            local showPct  = cfg.ShowPercentage ~= false
            local color    = cfg.Color or COLORS.Accent
            local o        = nextOrder()

            local rowH = 60
            local row  = BaseRow(rowH, o)

            MakeLabel({
                Text = name, Font = FONTS.Subtitle, Size = 14,
                Color = COLORS.TextPrimary,
                FrameSize = UDim2.new(1, -80, 0, 18),
                Position = UDim2.new(0, SPACING.LG, 0, 10),
                ZIndex = 5, Parent = row,
            })

            local pctLabel = nil
            if showPct then
                pctLabel = MakeLabel({
                    Text = math.floor(progress * 100) .. "%",
                    Font = FONTS.Code, Size = 13,
                    Color = COLORS.Accent,
                    FrameSize = UDim2.new(0, 50, 0, 18),
                    Position = UDim2.new(1, -(50 + SPACING.MD), 0, 10),
                    AlignX = Enum.TextXAlignment.Right,
                    ZIndex = 5, Parent = row,
                })
            end

            local track = MakeFrame({
                Name = "ProgressTrack",
                Size = UDim2.new(1, -(SPACING.LG * 2), 0, 8),
                Position = UDim2.new(0, SPACING.LG, 0, 38),
                Color = Color3.fromRGB(220, 220, 225),
                Trans = 0.2,
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(track, CORNERS.FULL)

            local fill = MakeFrame({
                Name = "ProgressFill",
                Size = UDim2.new(progress, 0, 1, 0),
                Color = color, Trans = 0,
                ZIndex = 6, Parent = track,
            })
            ApplyCorner(fill, CORNERS.FULL)

            -- Gradient on fill
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, color),
                ColorSequenceKeypoint.new(1, Color3.new(
                    math.min(1, color.R + 0.2),
                    math.min(1, color.G + 0.2),
                    math.min(1, color.B + 0.3)
                )),
            })
            grad.Parent = fill

            -- Indeterminate animation
            local indConn = nil
            if indet then
                local t = 0
                indConn = RunService.Heartbeat:Connect(function(dt)
                    t = t + dt
                    local pct2 = (math.sin(t * 2) + 1) / 2
                    fill.Size = UDim2.new(0.4, 0, 1, 0)
                    fill.Position = UDim2.new(pct2 * 0.6, 0, 0, 0)
                end)
            end

            local function setProgress(v)
                progress = math.clamp(v, 0, 1)
                Tween(fill, {Size = UDim2.new(progress, 0, 1, 0)}, DURATION.Normal)
                if pctLabel then pctLabel.Text = math.floor(progress * 100) .. "%" end
            end

            return {
                SetProgress = setProgress,
                GetProgress = function() return progress end,
                Destroy = function()
                    if indConn then indConn:Disconnect() end
                    row:Destroy()
                end,
            }
        end

        -- ============== CARD ==============
        function TabAPI:CreateCard(config)
            local cfg        = config or {}
            local title      = cfg.Title or ""
            local desc       = cfg.Description or ""
            local icon       = cfg.Icon or ""
            local collapsible= cfg.Collapsible or false
            local expanded   = cfg.DefaultExpanded ~= false
            local padding    = cfg.Padding or SPACING.MD
            local o          = nextOrder()

            local card = MakeFrame({
                Name = "Card_" .. title,
                Size = UDim2.new(1, 0, 0, 0),
                Color = COLORS.White,
                Trans = BG_TRANS,
                ZIndex = 4,
                Parent = tabContent,
            })
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.LayoutOrder = o
            ApplyCorner(card, CORNERS.MD)
            ApplyStroke(card, COLORS.GlassBorder, 1, 0.5)

            -- Card header
            local headerH = (title ~= "" or icon ~= "") and 44 or 0
            if headerH > 0 then
                local cardHeader = MakeFrame({
                    Name = "CardHeader",
                    Size = UDim2.new(1, 0, 0, headerH),
                    Color = COLORS.Surface, Trans = 0.4,
                    ZIndex = 5, Parent = card,
                })
                ApplyCorner(cardHeader, CORNERS.MD)

                if icon ~= "" then
                    MakeImage({
                        Image = icon, Color = COLORS.Accent,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(0, SPACING.MD, 0.5, -9),
                        ZIndex = 6, Parent = cardHeader,
                    })
                end

                local hTextX = icon ~= "" and SPACING.MD + 26 or SPACING.MD
                if title ~= "" then
                    MakeLabel({
                        Text = title, Font = FONTS.Title, Size = 14,
                        Color = COLORS.TextPrimary,
                        FrameSize = UDim2.new(1, -64, 0, 18),
                        Position = UDim2.new(0, hTextX, 0, desc ~= "" and 4 or (headerH/2 - 9)),
                        ZIndex = 6, Parent = cardHeader,
                    })
                end
                if desc ~= "" then
                    MakeLabel({
                        Text = desc, Font = FONTS.Caption, Size = 12,
                        Color = COLORS.TextMuted,
                        FrameSize = UDim2.new(1, -64, 0, 14),
                        Position = UDim2.new(0, hTextX, 0, 24),
                        ZIndex = 6, Parent = cardHeader,
                    })
                end

                -- Collapse toggle
                if collapsible then
                    local chevron = MakeButton({
                        Name = "CollapseBtn",
                        Text = expanded and "▴" or "▾",
                        TextSize = 12, TextColor = COLORS.TextMuted,
                        Color = COLORS.Transparent, Trans = 1,
                        Size = UDim2.new(0, 32, 1, 0),
                        Position = UDim2.new(1, -36, 0, 0),
                        ZIndex = 6, Parent = cardHeader,
                    })
                    local bodyFrame = nil
                    chevron.MouseButton1Click:Connect(function()
                        expanded = not expanded
                        chevron.Text = expanded and "▴" or "▾"
                        if bodyFrame then
                            bodyFrame.Visible = expanded
                        end
                    end)
                end
            end

            -- Card body
            local body = MakeFrame({
                Name = "CardBody",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, headerH),
                Color = COLORS.Transparent, Trans = 1,
                ZIndex = 5, Parent = card,
            })
            body.AutomaticSize = Enum.AutomaticSize.Y
            body.Visible = expanded

            local bodyList = Instance.new("UIListLayout")
            bodyList.SortOrder = Enum.SortOrder.LayoutOrder
            bodyList.Padding = UDim.new(0, SPACING.SM)
            bodyList.Parent = body

            local bodyPad = Instance.new("UIPadding")
            bodyPad.PaddingAll = UDim.new(0, padding)
            bodyPad.Parent = body

            -- Mini TabAPI for card body
            local CardAPI = {}
            local cardOrder = 0
            local function cardNextOrder()
                cardOrder = cardOrder + 10
                return cardOrder
            end

            -- Expose a simple AddElement function for card content
            function CardAPI:AddLabel(text, size, color, font)
                local lbl = MakeLabel({
                    Text = text or "",
                    Font = font or FONTS.Body,
                    Size = size or 14,
                    Color = color or COLORS.TextPrimary,
                    FrameSize = UDim2.new(1, 0, 0, 24),
                    ZIndex = 6, Parent = body,
                })
                lbl.LayoutOrder = cardNextOrder()
                lbl.AutomaticSize = Enum.AutomaticSize.Y
                return lbl
            end

            function CardAPI:GetBody()
                return body
            end

            return CardAPI
        end

        -- ============== AVATAR ==============
        function TabAPI:CreateAvatar(config)
            local cfg       = config or {}
            local userId    = cfg.UserId or LocalPlayer.UserId
            local avSize    = cfg.Size or 80
            local showStatus= cfg.ShowStatus or false
            local statusClr = cfg.StatusColor or COLORS.Success
            local clickable = cfg.Clickable ~= false
            local border    = cfg.Border ~= false
            local shadow    = cfg.Shadow ~= false
            local o         = nextOrder()

            local rowH = avSize + SPACING.XXL
            local row  = BaseRow(rowH, o)
            row.AutomaticSize = Enum.AutomaticSize.None

            local avFrame = MakeFrame({
                Name = "AvatarFrame",
                Size = UDim2.new(0, avSize, 0, avSize),
                Position = UDim2.new(0.5, -avSize/2, 0.5, -avSize/2),
                Color = COLORS.White, Trans = 0.1,
                ZIndex = 5, Parent = row,
            })
            ApplyCorner(avFrame, CORNERS.FULL)
            if border then
                ApplyStroke(avFrame, COLORS.White, 3, 0)
            end
            if shadow then ApplyShadow(avFrame, 16, 0.6) end

            local thumbUrl = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
            local avImg = MakeImage({
                Image = thumbUrl,
                Color = COLORS.White,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = 6, Parent = avFrame,
            })
            ApplyCorner(avImg, CORNERS.FULL)

            if showStatus then
                local dot = MakeFrame({
                    Name = "StatusDot",
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -14, 1, -14),
                    Color = statusClr, Trans = 0,
                    ZIndex = 7, Parent = avFrame,
                })
                ApplyCorner(dot, CORNERS.FULL)
                ApplyStroke(dot, COLORS.White, 2, 0)
            end

            -- Click to enlarge
            if clickable then
                local clickBtn = MakeButton({
                    Name = "AvClickZone",
                    Text = "",
                    Color = COLORS.Transparent, Trans = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 8, Parent = avFrame,
                })
                clickBtn.MouseButton1Click:Connect(function()
                    -- Show enlarged modal
                    Nexuralib:ShowModal({
                        Title = "Avatar",
                        Icon  = thumbUrl,
                        PrimaryAction = {Text = "Close"},
                    })
                end)
            end

            return {
                SetUserId = function(id)
                    avImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. id .. "&w=150&h=150"
                end,
            }
        end

        -- ============== SEPARATOR / LABEL ==============
        function TabAPI:AddSeparator(label)
            local o   = nextOrder()
            local sep = MakeFrame({
                Name  = "Separator",
                Size  = UDim2.new(1, 0, 0, label and 28 or 2),
                Color = COLORS.GlassBorder, Trans = 0.7,
                ZIndex = 4, Parent = tabContent,
            })
            sep.LayoutOrder = o
            if label then
                sep.BackgroundTransparency = 1
                MakeLabel({
                    Text = label, Font = FONTS.Caption, Size = 11,
                    Color = COLORS.TextMuted,
                    FrameSize = UDim2.new(1, 0, 1, 0),
                    AlignX = Enum.TextXAlignment.Center,
                    ZIndex = 5, Parent = sep,
                })
                local line = MakeFrame({
                    Size = UDim2.new(0.4, 0, 0, 1),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Color = COLORS.GlassBorder, Trans = 0.6,
                    ZIndex = 4, Parent = sep,
                })
                local line2 = MakeFrame({
                    Size = UDim2.new(0.4, 0, 0, 1),
                    Position = UDim2.new(0.6, 0, 0.5, 0),
                    Color = COLORS.GlassBorder, Trans = 0.6,
                    ZIndex = 4, Parent = sep,
                })
            end
        end

        return TabAPI
    end

    -- Window-level notify shortcut
    function WindowAPI:Notify(config)
        return Nexuralib:Notify(config)
    end

    function WindowAPI:ShowModal(config)
        return Nexuralib:ShowModal(config)
    end

    function WindowAPI:Destroy()
        Tween(Container, {BackgroundTransparency = 1}, DURATION.Normal)
        Tween(blurEffect, {Size = 0}, DURATION.Normal)
        task.delay(DURATION.Normal, function()
            ScreenGui:Destroy()
            blurEffect:Destroy()
        end)
    end

    function WindowAPI:SetTitle(title)
        for _, c in ipairs(Header:GetChildren()) do
            if c:IsA("TextLabel") and c.Font == FONTS.Display then
                c.Text = title
            end
        end
    end

    return WindowAPI
end

-- ============================================================
-- RETURN
-- ============================================================
return Nexuralib

--[[
=============================================================
  NEXURALIB - USAGE GUIDE
=============================================================

  local Nexuralib = loadstring(game:HttpGet("YOUR_URL_HERE"))()

  -- Create window
  local Window = Nexuralib:CreateWindow({
      Title         = "My Script",
      Subtitle      = "v1.0",
      ShowUserAvatar = true,
      AvatarPosition = "left",
      Draggable     = true,
      AnimateOpen   = true,
  })

  -- Create tab
  local Main = Window:CreateTab({
      Name  = "Main",
      Icon  = "rbxassetid://7733715400",
      Order = 1,
  })

  -- Toggle
  Main:CreateToggle({
      Name        = "Auto Farm",
      Description = "Enable automatic farming",
      Icon        = "rbxassetid://7733715400",
      Default     = false,
      Flag        = "AutoFarm",
      Callback    = function(v) print("AutoFarm:", v) end,
  })

  -- Button
  Main:CreateButton({
      Name     = "Teleport",
      Icon     = "rbxassetid://7733960981",
      Variant  = "primary",
      Callback = function() print("Teleport!") end,
  })

  -- Slider
  Main:CreateSlider({
      Name        = "Walk Speed",
      Icon        = "rbxassetid://7733658504",
      Min         = 16,
      Max         = 100,
      Default     = 16,
      Increment   = 1,
      ValueFormat = "%d",
      Flag        = "WalkSpeed",
      Callback    = function(v)
          game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
      end,
  })

  -- Dropdown
  Main:CreateDropdown({
      Name    = "Team",
      Icon    = "rbxassetid://7734014475",
      Options = {"Red", "Blue", "Green"},
      Default = "Red",
      Flag    = "SelectedTeam",
      Callback = function(v) print("Team:", v) end,
  })

  -- Input
  Main:CreateInput({
      Name        = "Player Name",
      Icon        = "rbxassetid://7733715400",
      Placeholder = "Enter name...",
      ClearButton = true,
      Flag        = "PlayerName",
      Callback    = function(v) print("Name:", v) end,
  })

  -- Keybind
  Main:CreateKeybind({
      Name    = "Toggle GUI",
      Icon    = "rbxassetid://7733960981",
      Default = Enum.KeyCode.RightShift,
      Flag    = "ToggleKey",
      Callback = function(v) print("Held:", v) end,
  })

  -- Color Picker
  Main:CreateColorPicker({
      Name    = "Highlight Color",
      Icon    = "rbxassetid://7733658504",
      Default = Color3.fromRGB(0, 122, 255),
      Flag    = "HighlightColor",
      Callback = function(c) print("Color:", c) end,
  })

  -- Progress
  Main:CreateProgress({
      Name         = "Loading...",
      Progress     = 0.75,
      ShowPercentage = true,
  })

  -- Card
  local card = Main:CreateCard({
      Title       = "Information",
      Icon        = "rbxassetid://7733715400",
      Collapsible = true,
      DefaultExpanded = true,
  })
  card:AddLabel("This is inside a card.", 14, nil, nil)

  -- Avatar
  Main:CreateAvatar({
      UserId     = game.Players.LocalPlayer.UserId,
      Size       = 80,
      ShowStatus = true,
  })

  -- Separator
  Main:AddSeparator("Settings")

  -- Notify
  Nexuralib:Notify({
      Title   = "Script Loaded",
      Content = "Nexuralib initialized successfully.",
      Type    = "success",
      Duration = 5,
  })

  -- Modal
  Nexuralib:ShowModal({
      Title   = "Confirm Action",
      Content = "Are you sure you want to continue?",
      Type    = "warning",
      PrimaryAction   = {Text = "Yes", Callback = function() print("Confirmed") end},
      SecondaryAction = {Text = "No"},
  })

  -- Config
  Nexuralib.SaveConfig("settings", {speed = 50, team = "Red"})
  local cfg = Nexuralib.LoadConfig("settings")

  -- Flags
  print(Nexuralib.Flags["AutoFarm"])
  print(Nexuralib.Flags["WalkSpeed"])

=============================================================
]]
