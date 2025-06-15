local library = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("redui") then
    CoreGui:FindFirstChild("redui"):Destroy()
end

function library:Win(title)
    local CoreGui = game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    if CoreGui:FindFirstChild("redui") then
        CoreGui:FindFirstChild("redui"):Destroy()
    end

    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "redui"
    gui.ResetOnSpawn = false

    -- Main window (made wider to accommodate left/right columns)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 700, 0, 400) -- Increased width from 500 to 700
    main.Position = UDim2.new(0.5, -350, 0.5, -200) -- Adjusted position
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0.3
    main.BorderSizePixel = 0
    main.Parent = gui
    main.ClipsDescendants = true

    -- Border
    local border = Instance.new("UIStroke", main)
    border.Thickness = 2
    border.Color = Color3.fromRGB(255, 255, 255)

    -- Toggle close button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "BankHubToggle"
    toggleButton.AnchorPoint = Vector2.new(0, 0)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.Size = UDim2.new(0, 28, 0, 28)
    toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    toggleButton.BackgroundTransparency = 0.2
    toggleButton.Text = " X "
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 16
    toggleButton.TextXAlignment = Enum.TextXAlignment.Center
    toggleButton.TextYAlignment = Enum.TextYAlignment.Center
    toggleButton.ZIndex = 10
    toggleButton.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleButton

    -- Title bar
    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BackgroundTransparency = 0.2
    titleBar.Text = title
    titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = 20
    titleBar.Parent = main
    titleBar.Active = true

    -- Tab buttons (left sidebar)
    local tabButtons = Instance.new("Frame", main)
    tabButtons.Size = UDim2.new(0, 120, 1, -35)
    tabButtons.Position = UDim2.new(0, 0, 0, 35)
    tabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabButtons.BackgroundTransparency = 0.3

    local tabLayout = Instance.new("UIListLayout", tabButtons)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    -- Pages container (increased width for left/right columns)
    local pages = Instance.new("Frame", main)
    pages.Size = UDim2.new(1, -130, 1, -45) -- Adjusted for wider window
    pages.Position = UDim2.new(0, 130, 0, 40)
    pages.BackgroundTransparency = 1

    -- Dragging functionality
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle button positioning
    RunService.RenderStepped:Connect(function()
        toggleButton.Position = UDim2.new(0, main.AbsolutePosition.X - 85, 0, main.AbsolutePosition.Y)
    end)

    -- Toggle functionality
    local isOpen = true
    local fullSize = main.Size
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    toggleButton.MouseButton1Click:Connect(function()
        if isOpen then
            local shrink = TweenService:Create(main, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
            shrink:Play()
            shrink.Completed:Once(function()
                main.Visible = false
                main.Size = fullSize
            end)
        else
            main.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(main, tweenInfo, {Size = fullSize}):Play()
        end
        isOpen = not isOpen
    end)

    local tabs = {}

    function tabs:Taps(name)
        local tabButton = Instance.new("TextButton", tabButtons)
        tabButton.Size = UDim2.new(1, -10, 0, 30)
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        tabButton.BackgroundTransparency = 0.4
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextSize = 16
        tabButton.Text = name

        -- Create main page container with left/right columns
        local pageContainer = Instance.new("Frame", pages)
        pageContainer.Size = UDim2.new(1, 0, 1, 0)
        pageContainer.Visible = false
        pageContainer.BackgroundTransparency = 1
        pageContainer.Name = name .. "_Container"

        -- LEFT COLUMN (50% width)
        local leftColumn = Instance.new("ScrollingFrame", pageContainer)
        leftColumn.Size = UDim2.new(0.48, 0, 1, 0) -- 48% width with gap
        leftColumn.Position = UDim2.new(0, 0, 0, 0)
        leftColumn.ScrollBarThickness = 6
        leftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        leftColumn.BackgroundTransparency = 1
        leftColumn.Name = "LeftColumn"

        local leftLayout = Instance.new("UIListLayout", leftColumn)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.Padding = UDim.new(0, 5)

        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            leftColumn.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 10)
        end)

        -- RIGHT COLUMN (50% width)
        local rightColumn = Instance.new("ScrollingFrame", pageContainer)
        rightColumn.Size = UDim2.new(0.48, 0, 1, 0) -- 48% width with gap
        rightColumn.Position = UDim2.new(0.52, 0, 0, 0) -- 52% to create gap
        rightColumn.ScrollBarThickness = 6
        rightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        rightColumn.BackgroundTransparency = 1
        rightColumn.Name = "RightColumn"

        local rightLayout = Instance.new("UIListLayout", rightColumn)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.Padding = UDim.new(0, 5)

        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            rightColumn.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 10)
        end)

        local function hideAllPages()
            for _, v in pairs(pages:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = false
                end
            end
        end

        tabButton.MouseButton1Click:Connect(function()
            hideAllPages()
            pageContainer.Visible = true
        end)

        local newPage = {}

        function newPage:newpage()
            hideAllPages()
            pageContainer.Visible = true

            -- Create page objects for both columns
            local leftPage = {
                parent = leftColumn,
                addElement = function(self, element)
                    element.Parent = self.parent
                end
            }

            local rightPage = {
                parent = rightColumn,
                addElement = function(self, element)
                    element.Parent = self.parent
                end
            }

            -- Helper function to create UI elements
            local function createElement(targetPage, elementType, ...)
                local args = {...}
                
                if elementType == "Button" then
                    local text, callback = args[1], args[2]
                    local button = Instance.new("TextButton", targetPage.parent)
                    button.Size = UDim2.new(1, -10, 0, 30)
                    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    button.BackgroundTransparency = 0.4
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.Font = Enum.Font.SourceSans
                    button.TextSize = 16
                    button.Text = text
                    button.MouseButton1Click:Connect(function()
                        if callback then pcall(callback) end
                    end)
                    
                elseif elementType == "Toggle" then
                    local text, default, callback = args[1], args[2], args[3]
                    local toggleFrame = Instance.new("Frame", targetPage.parent)
                    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
                    toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    toggleFrame.BackgroundTransparency = 0.4
                    toggleFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", toggleFrame)
                    label.Size = UDim2.new(1, -50, 1, 0)
                    label.Position = UDim2.new(0, 10, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 14
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = text

                    local toggleBtn = Instance.new("TextButton", toggleFrame)
                    toggleBtn.Size = UDim2.new(0, 35, 0, 18)
                    toggleBtn.Position = UDim2.new(1, -40, 0.5, -9)
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    toggleBtn.BackgroundTransparency = 0.4
                    toggleBtn.Text = ""
                    toggleBtn.BorderSizePixel = 0

                    local circle = Instance.new("Frame", toggleBtn)
                    circle.Size = UDim2.new(0, 16, 0, 16)
                    circle.Position = default and UDim2.new(1, -17, 0, 1) or UDim2.new(0, 1, 0, 1)
                    circle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(150, 150, 150)
                    circle.BorderSizePixel = 0

                    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
                    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
                    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 6)

                    local toggled = default
                    toggleBtn.MouseButton1Click:Connect(function()
                        toggled = not toggled
                        circle:TweenPosition(toggled and UDim2.new(1, -17, 0, 1) or UDim2.new(0, 1, 0, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                        circle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(150, 150, 150)
                        if callback then callback(toggled) end
                    end)

                elseif elementType == "Label" then
                    local txt = args[1]
                    local label = Instance.new("TextLabel", targetPage.parent)
                    label.Size = UDim2.new(1, -10, 0, 25)
                    label.Text = txt
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 16
                    label.BackgroundTransparency = 1
                    label.TextXAlignment = Enum.TextXAlignment.Left

                elseif elementType == "Section" then
                    local txt = args[1]
                    local sectionFrame = Instance.new("Frame", targetPage.parent)
                    sectionFrame.Size = UDim2.new(1, -10, 0, 30)
                    sectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    sectionFrame.BackgroundTransparency = 1
                    sectionFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", sectionFrame)
                    label.Size = UDim2.new(1, -10, 1, 0)
                    label.Position = UDim2.new(0, 5, 0, 0)
                    label.Text = "^| " .. txt .. " |^"
                    label.TextColor3 = Color3.fromRGB(200, 200, 200)
                    label.Font = Enum.Font.SourceSansBold
                    label.TextSize = 16
                    label.BackgroundTransparency = 1
                    label.TextXAlignment = Enum.TextXAlignment.Left

                    Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
                end
            end

            -- Left column methods
            leftPage.Button = function(self, text, callback)
                createElement(self, "Button", text, callback)
            end
            leftPage.Toggle = function(self, text, default, callback)
                createElement(self, "Toggle", text, default, callback)
            end
            leftPage.Label = function(self, txt)
                createElement(self, "Label", txt)
            end
            leftPage.Section = function(self, txt)
                createElement(self, "Section", txt)
            end

            -- Right column methods
            rightPage.Button = function(self, text, callback)
                createElement(self, "Button", text, callback)
            end
            rightPage.Toggle = function(self, text, default, callback)
                createElement(self, "Toggle", text, default, callback)
            end
            rightPage.Label = function(self, txt)
                createElement(self, "Label", txt)
            end
            rightPage.Section = function(self, txt)
                createElement(self, "Section", txt)
            end

            -- Return both page objects
            return leftPage, rightPage
        end

        return newPage
    end

    return tabs
end

-- Notification function (unchanged)
function library:Notifile(title, msg, duration)
    local gui = CoreGui:FindFirstChild("redui")
    if not gui then return end

    local activeNotifs = {}
    if #activeNotifs >= 3 then
        local oldest = table.remove(activeNotifs, 1)
        oldest:Destroy()
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(1, 310, 1, -80)
    notif.AnchorPoint = Vector2.new(1, 1)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BackgroundTransparency = 0.4
    notif.BorderSizePixel = 0
    notif.Parent = gui

    local label = Instance.new("TextLabel", notif)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = msg
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(activeNotifs, notif)
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, -10, 1, -10)}):Play()

    task.delay(duration or 3, function()
        local tweenOut = TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(1, 310, 1, -10)})
        tweenOut:Play()
        tweenOut.Completed:Wait()
        notif:Destroy()
    end)
end

return library
