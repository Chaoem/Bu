local TweenService = game:service"TweenService"
local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local mouse = plr:GetMouse()
local RunService = game:GetService("RunService")

-- ============================================
-- CONFIG: here
-- ============================================
local UI_CONFIG = {
    LogoAssetId = "rbxassetid://6023426923",
    CloseButtonAssetId = "rbxassetid://6023426923"
}

-- ============================================
-- CORE GUI PARENT ()
-- ============================================
local ParentGui
if gethui then
    ParentGui = gethui()
elseif syn and syn.protect_gui then
    ParentGui = game:GetService("CoreGui")
else
    ParentGui = game:GetService("CoreGui")
end

local Library = {}

makedraggable = function (topbar, object)
	local Dragging = false
	local DragInput = nil
	local DragStart = nil
	local PositionStart = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local newPos = UDim2.new(
			PositionStart.X.Scale,
			PositionStart.X.Offset + Delta.X,
			PositionStart.Y.Scale,
			PositionStart.Y.Offset + Delta.Y
		)
		object.Position = newPos
	end

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			PositionStart = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	uis.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

function Library:AddNotify(ConfigNotify)
    ConfigNotify = ConfigNotify or {}
    ConfigNotify.Title = ConfigNotify.Title or "Notification"
    ConfigNotify.Content = ConfigNotify.Content or "This Is Notification"
    ConfigNotify.Time = ConfigNotify.Time or 5

    spawn(function()
        local UniqueNotify = ParentGui:FindFirstChild("NotifyGay_Protected")
        if not UniqueNotify then
            UniqueNotify = Instance.new("ScreenGui")
            UniqueNotify.Name = "NotifyGay_Protected"
            UniqueNotify.Parent = ParentGui
            UniqueNotify.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            UniqueNotify.ResetOnSpawn = false
        end

        local NotifyLayout = UniqueNotify:FindFirstChild("NotifyLayout")
        if not NotifyLayout then
            NotifyLayout = Instance.new("Frame")
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = UniqueNotify
            NotifyLayout.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NotifyLayout.BackgroundTransparency = 1.000
            NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, 200, 1, -100)
            NotifyLayout.Size = UDim2.new(0, 200, 0, 63)
            local Count = 0
            NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for r, v in next, NotifyLayout:GetChildren() do
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))}):Play()
                    Count = Count + 1
                end
            end)
        end

        local NotifyPosHeigh = 0
        for i, v in NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end

        local NotifyReal = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local Title = Instance.new("TextLabel")
        local UIPadding = Instance.new("UIPadding")
        local Desc = Instance.new("TextLabel")
        local UIPadding_2 = Instance.new("UIPadding")
        local Time = Instance.new("Frame")
        local Close = Instance.new("Frame")
        local Logo = Instance.new("ImageLabel")
        local Click = Instance.new("TextButton")
        local NotifyFunc = {}

        NotifyReal.Name = "NotifyReal"
        NotifyReal.Parent = NotifyLayout
        NotifyReal.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        NotifyReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyReal.BorderSizePixel = 0
        NotifyReal.Position = UDim2.new(0, 0, 0, -(NotifyPosHeigh))
        NotifyReal.Size = UDim2.new(0, 200, 0, 66)

        UICorner.CornerRadius = UDim.new(0, 4)
        UICorner.Parent = NotifyReal

        Title.Name = "Title"
        Title.Parent = NotifyReal
        Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Title.BackgroundTransparency = 1.000
        Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Title.BorderSizePixel = 0
        Title.Size = UDim2.new(1, 0, 0, 20)
        Title.Font = Enum.Font.GothamBold
        Title.Text = ConfigNotify.Title
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14.000
        Title.TextXAlignment = Enum.TextXAlignment.Left

        UIPadding.Parent = Title
        UIPadding.PaddingLeft = UDim.new(0, 12)
        UIPadding.PaddingTop = UDim.new(0, 7)

        Desc.Name = "Desc"
        Desc.Parent = NotifyReal
        Desc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Desc.BackgroundTransparency = 1.000
        Desc.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Desc.BorderSizePixel = 0
        Desc.Position = UDim2.new(0, 0, 0, 23)
        Desc.Size = UDim2.new(1, 0, 1, -23)
        Desc.Font = Enum.Font.GothamBold
        Desc.Text = ConfigNotify.Content
        Desc.TextColor3 = Color3.fromRGB(144, 144, 144)
        Desc.TextSize = 12.000
        Desc.TextWrapped = true
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextYAlignment = Enum.TextYAlignment.Top

        UIPadding_2.Parent = Desc
        UIPadding_2.PaddingLeft = UDim.new(0, 12)
        UIPadding_2.PaddingTop = UDim.new(0, 2)

        Time.Name = "Time"
        Time.Parent = NotifyReal
        Time.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Time.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Time.BorderSizePixel = 0
        Time.Size = UDim2.new(1, 0, 0, 1)

        Close.Name = "Close"
        Close.Parent = NotifyReal
        Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Close.BackgroundTransparency = 1.000
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -20, 0, 0)
        Close.Size = UDim2.new(0, 20, 0, 20)

        Logo.Name = "Logo"
        Logo.Parent = Close
        Logo.AnchorPoint = Vector2.new(0.5, 0.5)
        Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Logo.BackgroundTransparency = 1.000
        Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Logo.BorderSizePixel = 0
        Logo.Position = UDim2.new(0.5, 0, 0.5, 0)
        Logo.Size = UDim2.new(0, 10, 0, 10)
        Logo.Image = UI_CONFIG.CloseButtonAssetId

        Click.Name = "Click"
        Click.Parent = Close
        Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Click.BackgroundTransparency = 1.000
        Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Click.BorderSizePixel = 0
        Click.Size = UDim2.new(1, 0, 1, 0)
        Click.Font = Enum.Font.SourceSans
        Click.Text = ""
        Click.TextColor3 = Color3.fromRGB(0, 0, 0)
        Click.TextSize = 14.000

        local waitbruh = false
        function NotifyFunc:Close()
            if waitbruh then
                return false
            end
            waitbruh = true
            TweenService:Create(
                NotifyReal,
                TweenInfo.new(tonumber(.2), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                {Position = UDim2.new(0, 400, 0, 0)}
            ):Play()
            task.wait(tonumber(.2))
            NotifyReal:Destroy()
        end

        Click.MouseButton1Click:Connect(function()
            NotifyFunc:Close()
        end)

        TweenService:Create(
            NotifyReal,
            TweenInfo.new(tonumber(.2), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            {Position = UDim2.new(0, -444, 1, -(NotifyPosHeigh) - 20)}
        ):Play()
        Time:TweenSize(UDim2.new(0, 0, 0, 1),"Out","Quad",tonumber(ConfigNotify.Time),true)
        task.wait(tonumber(ConfigNotify.Time))
        TweenService:Create(
            NotifyReal,
            TweenInfo.new(tonumber(.2), Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
            {Position = UDim2.new(1, -0, 1, -(NotifyPosHeigh) - 20)}
        ):Play()
        task.wait(tonumber(.2))
        NotifyFunc:Close()
        return NotifyFunc
    end)
end

function Library:AddWindows()
    local existingUI = ParentGui:FindFirstChild("ScreenShit_Protected")
    if existingUI then
        existingUI:Destroy()
    end

    local ScreenShit = Instance.new("ScreenGui")
    local AnDzGUI = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local LogoHut = Instance.new("ImageLabel")
    local TabList = Instance.new("Frame")
    local UICorner_2 = Instance.new("UICorner")
    local AnNigga = Instance.new("ScrollingFrame")
    local UIPadding = Instance.new("UIPadding")
    local UIListLayout = Instance.new("UIListLayout")
    local LayoutReal = Instance.new("Frame")
    local CCC = Instance.new("Folder")
    local UIPageLayout = Instance.new("UIPageLayout")
    local TOP = Instance.new("Frame")
    local UIStroke_15 = Instance.new("UIStroke")
    local CloseUI = Instance.new("Frame")
    local UICorner_47 = Instance.new("UICorner")
    local LogoHut_2 = Instance.new("ImageLabel")
    local Click_3 = Instance.new("TextButton")

    ScreenShit.Name = "ScreenShit_Protected"
    ScreenShit.Parent = ParentGui
    ScreenShit.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenShit.ResetOnSpawn = false

    AnDzGUI.Name = "AnDzGUI"
    AnDzGUI.Parent = ScreenShit
    AnDzGUI.AnchorPoint = Vector2.new(0.5, 0.5)
    AnDzGUI.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    AnDzGUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
    AnDzGUI.BorderSizePixel = 0
    AnDzGUI.Position = UDim2.new(0.5, 0, 0.5, 0)
    AnDzGUI.Size = UDim2.new(0, 481, 0, 332)
    AnDzGUI.ClipsDescendants = true

    UICorner.Parent = AnDzGUI

    TOP.Name = "TOP"
    TOP.Parent = AnDzGUI
    TOP.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TOP.BackgroundTransparency = 1.000
    TOP.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TOP.BorderSizePixel = 0
    TOP.Size = UDim2.new(1, 0, 0, 75)

    UIStroke_15.Parent = AnDzGUI
    UIStroke_15.Color = Color3.fromRGB(65, 115, 196)
    UIStroke_15.Transparency = 0.210
    UIStroke_15.Thickness = 1.200

    LogoHut.Name = "LogoHut"
    LogoHut.Parent = AnDzGUI
    LogoHut.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LogoHut.BackgroundTransparency = 1.000
    LogoHut.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LogoHut.BorderSizePixel = 0
    LogoHut.Position = UDim2.new(0.0222222228, 0, 0.0149999997, 0)
    LogoHut.Size = UDim2.new(0, 55, 0, 55)
    LogoHut.Image = UI_CONFIG.LogoAssetId

    TabList.Name = "Tab List"
    TabList.Parent = AnDzGUI
    TabList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabList.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabList.BorderSizePixel = 0
    TabList.Position = UDim2.new(0.162222117, 0, 0.0350000001, 0)
    TabList.Size = UDim2.new(0, 502, 0, 39)

    UICorner_2.CornerRadius = UDim.new(0, 4)
    UICorner_2.Parent = TabList

    AnNigga.Name = "AnNigga"
    AnNigga.Parent = TabList
    AnNigga.AnchorPoint = Vector2.new(0.5, 0.5)
    AnNigga.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AnNigga.BackgroundTransparency = 1.000
    AnNigga.BorderColor3 = Color3.fromRGB(0, 0, 0)
    AnNigga.BorderSizePixel = 0
    AnNigga.Position = UDim2.new(0.5, 0, 0.5, 0)
    AnNigga.Size = UDim2.new(1, -7, 1, -7)
    AnNigga.CanvasSize = UDim2.new(2, 0, 0, 0)
    AnNigga.ScrollBarThickness = 0

    RunService.Stepped:Connect(function()
        pcall(function()
            AnNigga.CanvasSize = UDim2.new(0, UIListLayout.AbsoluteContentSize.X + 100, 0, 0)
        end)
    end)

    UIPadding.Parent = AnNigga
    UIPadding.PaddingBottom = UDim.new(0, 2)
    UIPadding.PaddingLeft = UDim.new(0, 3)
    UIPadding.PaddingRight = UDim.new(0, 3)
    UIPadding.PaddingTop = UDim.new(0, 4)

    UIListLayout.Parent = AnNigga
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 12)

    LayoutReal.Name = "LayoutReal"
    LayoutReal.Parent = AnDzGUI
    LayoutReal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LayoutReal.BackgroundTransparency = 1.000
    LayoutReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LayoutReal.BorderSizePixel = 0
    LayoutReal.Size = UDim2.new(1, 0, 1, 0)
    LayoutReal.ClipsDescendants = true

    CCC.Name = "CCC"
    CCC.Parent = LayoutReal

    UIPageLayout.Parent = CCC
    UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIPageLayout.TweenTime = 0.350
    UIPageLayout.GamepadInputEnabled = false
    UIPageLayout.ScrollWheelInputEnabled = false
    UIPageLayout.TouchInputEnabled = false

    CloseUI.Name = "CloseUI"
    CloseUI.Parent = ScreenShit
    CloseUI.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
    CloseUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseUI.BorderSizePixel = 0
    CloseUI.Position = UDim2.new(0.130987287, 0, 0.10569106, 0)
    CloseUI.Size = UDim2.new(0, 45, 0, 45)
    CloseUI.Active = true

    UICorner_47.Parent = CloseUI

    LogoHut_2.Name = "LogoHut"
    LogoHut_2.Parent = CloseUI
    LogoHut_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LogoHut_2.BackgroundTransparency = 1.000
    LogoHut_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LogoHut_2.BorderSizePixel = 0
    LogoHut_2.Position = UDim2.new(0.0222222228, 0, 0.0149999997, 0)
    LogoHut_2.Size = UDim2.new(1, 0, 1, 0)
    LogoHut_2.Image = UI_CONFIG.LogoAssetId

    Click_3.Name = "Click"
    Click_3.Parent = CloseUI
    Click_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Click_3.BackgroundTransparency = 1.000
    Click_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Click_3.BorderSizePixel = 0
    Click_3.Size = UDim2.new(1, 0, 1, 0)
    Click_3.Font = Enum.Font.SourceSans
    Click_3.Text = ""
    Click_3.TextColor3 = Color3.fromRGB(0, 0, 0)
    Click_3.TextSize = 14.000
    Click_3.Activated:Connect(function()
        AnDzGUI.Visible = not AnDzGUI.Visible
    end)

    makedraggable(Click_3, CloseUI)
    makedraggable(TOP, AnDzGUI)

    local CountTab = 1
    local TabFunc = {}

    function TabFunc:AddTab(cf)
        cf = cf or {}
        cf.Name = cf.Name or "Tab 1"

        local TabDisable = Instance.new("Frame")
        local UICorner_4 = Instance.new("UICorner")
        local NameTab_2 = Instance.new("TextLabel")
        local Click_2 = Instance.new("TextButton")
        local Channel = Instance.new("Frame")
        local Left = Instance.new("Frame")
        local UICorner_5 = Instance.new("UICorner")
        local ChannelLeft = Instance.new("ScrollingFrame")
        local UIListLayout_2 = Instance.new("UIListLayout")
        local UIPadding_2 = Instance.new("UIPadding")
        local Right = Instance.new("Frame")
        local UICorner_26 = Instance.new("UICorner")
        local ChannelLeft_2 = Instance.new("ScrollingFrame")
        local UIListLayout_5 = Instance.new("UIListLayout")
        local UIPadding_7 = Instance.new("UIPadding")

        TabDisable.Name = "Tab Disable"
        TabDisable.Parent = AnNigga
        TabDisable.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        TabDisable.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabDisable.BorderSizePixel = 0
        TabDisable.Size = UDim2.new(0, 100, 1, -2)

        UICorner_4.CornerRadius = UDim.new(0, 6)
        UICorner_4.Parent = TabDisable

        NameTab_2.Name = "NameTab"
        NameTab_2.Parent = TabDisable
        NameTab_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        NameTab_2.BackgroundTransparency = 1.000
        NameTab_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NameTab_2.BorderSizePixel = 0
        NameTab_2.Size = UDim2.new(1, 0, 1, 0)
        NameTab_2.Font = Enum.Font.GothamBold
        NameTab_2.Text = cf.Name
        NameTab_2.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameTab_2.TextSize = 13.000

        Click_2.Name = "Click"
        Click_2.Parent = TabDisable
        Click_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Click_2.BackgroundTransparency = 1.000
        Click_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Click_2.BorderSizePixel = 0
        Click_2.Size = UDim2.new(1, 0, 1, 0)
        Click_2.Font = Enum.Font.SourceSans
        Click_2.Text = ""
        Click_2.TextColor3 = Color3.fromRGB(0, 0, 0)
        Click_2.TextSize = 14.000

        Channel.Name = "Channel"
        Channel.Parent = CCC
        Channel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Channel.BackgroundTransparency = 1.000
        Channel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Channel.BorderSizePixel = 0
        Channel.LayoutOrder = CountTab
        Channel.Size = UDim2.new(1,0,1,0)

        Left.Name = "Left"
        Left.Parent = Channel
        Left.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Left.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Left.Position = UDim2.new(0, 15, 0, 65)
        Left.BorderSizePixel = 0
        Left.Size = UDim2.new(0.468006402, 0, 1, -75)

        UICorner_5.Parent = Left

        ChannelLeft.Name = "ChannelLeft"
        ChannelLeft.Parent = Left
        ChannelLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ChannelLeft.BackgroundTransparency = 1.000
        ChannelLeft.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ChannelLeft.BorderSizePixel = 0
        ChannelLeft.Size = UDim2.new(1, 0, 1, 0)
        ChannelLeft.ScrollBarThickness = 0

        RunService.Stepped:Connect(function()
            pcall(function()
                ChannelLeft.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_2.AbsoluteContentSize.Y + 20)
            end)
        end)

        UIListLayout_2.Parent = ChannelLeft
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.Padding = UDim.new(0, 12)

        UIPadding_2.Parent = ChannelLeft
        UIPadding_2.PaddingBottom = UDim.new(0, 6)
        UIPadding_2.PaddingLeft = UDim.new(0, 6)
        UIPadding_2.PaddingRight = UDim.new(0, 6)
        UIPadding_2.PaddingTop = UDim.new(0, 8)

        Right.Name = "Right"
        Right.Parent = Channel
        Right.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Right.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Right.BorderSizePixel = 0
        Right.Position = UDim2.new(0.515, 0, 0, 65)
        Right.Size = UDim2.new(0.468006402, 0, 1, -75)

        UICorner_26.Parent = Right

        ChannelLeft_2.Name = "ChannelLeft"
        ChannelLeft_2.Parent = Right
        ChannelLeft_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ChannelLeft_2.BackgroundTransparency = 1.000
        ChannelLeft_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ChannelLeft_2.BorderSizePixel = 0
        ChannelLeft_2.Size = UDim2.new(1, 0, 1, 0)
        ChannelLeft_2.ScrollBarThickness = 0

        RunService.Stepped:Connect(function()
            pcall(function()
                ChannelLeft_2.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_5.AbsoluteContentSize.Y + 20)
            end)
        end)

        UIListLayout_5.Parent = ChannelLeft_2
        UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_5.Padding = UDim.new(0, 12)

        UIPadding_7.Parent = ChannelLeft_2
        UIPadding_7.PaddingBottom = UDim.new(0, 6)
        UIPadding_7.PaddingLeft = UDim.new(0, 6)
        UIPadding_7.PaddingRight = UDim.new(0, 6)
        UIPadding_7.PaddingTop = UDim.new(0, 8)

        if CountTab == 1 then
            UIPageLayout:JumpToIndex(1)
        end

        Click_2.Activated:Connect(function()
            for r, v in next, AnNigga:GetChildren() do
                if v.Name == "Tab Disable" then
                    v.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
            TabDisable.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
            UIPageLayout:JumpTo(Channel)
        end)

        CountTab = CountTab + 1
        local Fe = {}
        Fe.Channel = Channel
        Fe.ChannelLeft = ChannelLeft
        Fe.ChannelRight = ChannelLeft_2

        function Fe:AddSection(andaubuoi, cf)
            cf = cf or {}
            cf.Name = cf.Name or "Section"

            local Nigga
            if andaubuoi == "Left" or typeof(andaubuoi) ~= "string" then
                Nigga = self.ChannelLeft
            elseif andaubuoi == "Right" then
                Nigga = self.ChannelRight
            end

            local Section = Instance.new("Frame")
            local UICorner_6 = Instance.new("UICorner")
            local NameSection = Instance.new("TextLabel")
            local Listed = Instance.new("Frame")
            local UIListLayout_3 = Instance.new("UIListLayout")
            local UIPadding_3 = Instance.new("UIPadding")
            local UIStroke_7 = Instance.new("UIStroke")
            local Line = Instance.new("Frame")

            Line.Name = "Line"
            Line.Parent = Section
            Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Line.BackgroundTransparency = 0.900
            Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Line.BorderSizePixel = 0
            Line.Position = UDim2.new(0, 5, 0, 30)
            Line.Size = UDim2.new(1, -10, 0, 1)

            UIStroke_7.Parent = Section
            UIStroke_7.Color = Color3.fromRGB(255, 255, 255)
            UIStroke_7.Transparency = 0.970

            Section.Name = "Section"
            Section.Parent = Nigga
            Section.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
            Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Section.BorderSizePixel = 0
            Section.Size = UDim2.new(1, 0, 0, 400)

            UICorner_6.Parent = Section

            NameSection.Name = "NameSection"
            NameSection.Parent = Section
            NameSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            NameSection.BackgroundTransparency = 1.000
            NameSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NameSection.BorderSizePixel = 0
            NameSection.Size = UDim2.new(1, 0, 0, 30)
            NameSection.Font = Enum.Font.GothamBold
            NameSection.Text = cf.Name
            NameSection.TextColor3 = Color3.fromRGB(193, 193, 193)
            NameSection.TextSize = 13.000

            Listed.Name = "Listed"
            Listed.Parent = Section
            Listed.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Listed.BackgroundTransparency = 1.000
            Listed.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Listed.BorderSizePixel = 0
            Listed.Position = UDim2.new(0, 0, 0, 35)
            Listed.Size = UDim2.new(1, 0, 1, -35)

            UIListLayout_3.Parent = Listed
            UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_3.Padding = UDim.new(0, 5)

            UIPadding_3.Parent = Listed
            UIPadding_3.PaddingBottom = UDim.new(0, 6)
            UIPadding_3.PaddingLeft = UDim.new(0, 6)
            UIPadding_3.PaddingRight = UDim.new(0, 6)
            UIPadding_3.PaddingTop = UDim.new(0, 8)

            RunService.Stepped:Connect(function()
                pcall(function()
                    Section.Size = UDim2.new(1, 0, 0, UIListLayout_3.AbsoluteContentSize.Y + 100)
                end)
            end)

            local Sec = {}

            -- ============================================
            -- FIX: AddLabel mới nằm trong Section
            -- ============================================
            function Sec:AddLabel(text)
                text = text or "Label"

                local Wrap = Instance.new("Frame")
                Wrap.Name = "LabelWrap"
                Wrap.Parent = Listed
                Wrap.BackgroundTransparency = 1
                Wrap.Size = UDim2.new(1, 0, 0, 26)

                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Parent = Wrap
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, -12, 1, 0)
                Label.Position = UDim2.new(0, 6, 0, 0)
                Label.Font = Enum.Font.GothamSemibold
                Label.Text = text
                Label.TextSize = 12
                Label.TextColor3 = Color3.fromRGB(150,150,150)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextYAlignment = Enum.TextYAlignment.Center
                Label.RichText = true

                return Label
            end

            function Sec:AddButton(cffe)
                cffe = cffe or {}
                cffe.Name = cffe.Name or "Button"
                cffe.Callback = cffe.Callback or function() end

                local Button = Instance.new("Frame")
                local UICorner_7 = Instance.new("UICorner")
                local UIStroke = Instance.new("UIStroke")
                local Title = Instance.new("TextLabel")
                local Clicked = Instance.new("TextButton")

                Button.Name = "Button"
                Button.Parent = Listed
                Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Button.BorderSizePixel = 0
                Button.Size = UDim2.new(1, 0, 0, 35)

                UICorner_7.CornerRadius = UDim.new(0, 4)
                UICorner_7.Parent = Button

                UIStroke.Parent = Button
                UIStroke.Color = Color3.fromRGB(255, 255, 255)
                UIStroke.Transparency = 0.970

                Title.Name = "Title"
                Title.Parent = Button
                Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Title.BackgroundTransparency = 1.000
                Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Title.BorderSizePixel = 0
                Title.Size = UDim2.new(1, 0, 1, 0)
                Title.Font = Enum.Font.ArialBold
                Title.Text = cffe.Name
                Title.TextColor3 = Color3.fromRGB(144, 144, 144)
                Title.TextSize = 13.000

                Clicked.Name = "Clicked"
                Clicked.Parent = Button
                Clicked.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Clicked.BackgroundTransparency = 1.000
                Clicked.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Clicked.BorderSizePixel = 0
                Clicked.Size = UDim2.new(1, 0, 1, 0)
                Clicked.Font = Enum.Font.SourceSans
                Clicked.Text = ""
                Clicked.TextColor3 = Color3.fromRGB(0, 0, 0)
                Clicked.TextSize = 14.000

                Clicked.Activated:Connect(function()
                    Button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                    TweenService:Create(Button, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
                    pcall(cffe.Callback)
                end)
            end

            function Sec:AddToggle(cffe)
                cffe = cffe or {}
                cffe.Name = cffe.Name or "Toggle"
                cffe.Default = cffe.Default or false
                cffe.Callback = cffe.Callback or function() end

                local Toggle = Instance.new("Frame")
                local UICorner_8 = Instance.new("UICorner")
                local UIStroke_2 = Instance.new("UIStroke")
                local Title_2 = Instance.new("TextLabel")
                local Clicked_2 = Instance.new("TextButton")
                local Check = Instance.new("Frame")
                local UICorner_9 = Instance.new("UICorner")
                local UIStroke_3 = Instance.new("UIStroke")
                local Check_2 = Instance.new("Frame")
                local UICorner_10 = Instance.new("UICorner")
                local ImageLabel = Instance.new("ImageLabel")
                local ToggleFunc = {}

                Toggle.Name = "Toggle"
                Toggle.Parent = Listed
                Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Toggle.BorderSizePixel = 0
                Toggle.Size = UDim2.new(1, 0, 0, 35)

                UICorner_8.CornerRadius = UDim.new(0, 4)
                UICorner_8.Parent = Toggle

                UIStroke_2.Parent = Toggle
                UIStroke_2.Color = Color3.fromRGB(255, 255, 255)
                UIStroke_2.Transparency = 0.980

                Title_2.Name = "Title"
                Title_2.Parent = Toggle
                Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Title_2.BackgroundTransparency = 1.000
                Title_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Title_2.BorderSizePixel = 0
                Title_2.Position = UDim2.new(0, 10, 0, 0)
                Title_2.Size = UDim2.new(1, -40, 1, 0)
                Title_2.Font = Enum.Font.ArialBold
                Title_2.Text = cffe.Name
                Title_2.TextColor3 = Color3.fromRGB(144, 144, 144)
                Title_2.TextSize = 13.000
                Title_2.TextXAlignment = Enum.TextXAlignment.Left

                Clicked_2.Name = "Clicked"
                Clicked_2.Parent = Toggle
                Clicked_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Clicked_2.BackgroundTransparency = 1.000
                Clicked_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Clicked_2.BorderSizePixel = 0
                Clicked_2.Size = UDim2.new(1, 0, 1, 0)
                Clicked_2.Font = Enum.Font.SourceSans
                Clicked_2.Text = ""
                Clicked_2.TextColor3 = Color3.fromRGB(0, 0, 0)
                Clicked_2.TextSize = 14.000

                Check.Name = "Check"
                Check.Parent = Toggle
                Check.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
                Check.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Check.BorderSizePixel = 0
                Check.Position = UDim2.new(0.858953297, 0, 0.200000003, 0)
                Check.Size = UDim2.new(0, 21, 0, 21)

                UICorner_9.CornerRadius = UDim.new(1, 0)
                UICorner_9.Parent = Check

                UIStroke_3.Parent = Check
                UIStroke_3.Color = Color3.fromRGB(255, 255, 255)
                UIStroke_3.Transparency = 0.870

                Check_2.Name = "Check"
                Check_2.Parent = Check
                Check_2.AnchorPoint = Vector2.new(0.5, 0.5)
                Check_2.BackgroundColor3 = Color3.fromRGB(58, 147, 255)
                Check_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Check_2.BorderSizePixel = 0
                Check_2.Position = UDim2.new(0.5, 0, 0.5, 0)
                Check_2.Size = UDim2.new(0, 0, 0, 0)

                UICorner_10.CornerRadius = UDim.new(1, 0)
                UICorner_10.Parent = Check_2

                ImageLabel.Parent = Check_2
                ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ImageLabel.BackgroundTransparency = 1.000
                ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ImageLabel.BorderSizePixel = 0
                ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
                ImageLabel.Size = UDim2.new(0, 0, 0, 0)
                ImageLabel.Image = "http://www.roblox.com/asset/?id=73386528985648"
                ImageLabel.ImageColor3 = Color3.fromRGB(45, 45, 45)

                local Toggled = false
                function ToggleFunc:Set(Value)
                    if Value then
                        TweenService:Create(Title_2, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                        TweenService:Create(Check_2, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 19, 0, 19)}):Play()
                        TweenService:Create(ImageLabel, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, -5, 1, -5)}):Play()
                    else
                        TweenService:Create(Title_2, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(144, 144, 144)}):Play()
                        TweenService:Create(Check_2, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                        TweenService:Create(ImageLabel, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                    end
                    Toggled = Value
                    pcall(cffe.Callback, Toggled)
                end

                if cffe.Default then
                    ToggleFunc:Set(true)
                end

                Clicked_2.Activated:Connect(function()
                    Toggled = not Toggled
                    ToggleFunc:Set(Toggled)
                end)

                return ToggleFunc
            end

            return Sec
        end

        return Fe
    end

    return TabFunc
end
