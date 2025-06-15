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

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 700, 0, 400)
    main.Position = UDim2.new(0.5, -350, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0.3
    main.BorderSizePixel = 0
    main.Parent = gui
    main.ClipsDescendants = true

    local mainCorner = Instance.new("UICorner", main)
    mainCorner.CornerRadius = UDim.new(0, 8)

    local border = Instance.new("UIStroke", main)
    border.Thickness = 2
    border.Color = Color3.fromRGB(255, 255, 255)

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

    local tabButtons = Instance.new("Frame", main)
    tabButtons.Size = UDim2.new(0, 120, 1, -35)
    tabButtons.Position = UDim2.new(0, 0, 0, 35)
    tabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabButtons.BackgroundTransparency = 0.3

    local tabLayout = Instance.new("UIListLayout", tabButtons)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 5)

    local pages = Instance.new("Frame", main)
    pages.Size = UDim2.new(1, -130, 1, -45)
    pages.Position = UDim2.new(0, 130, 0, 40)
    pages.BackgroundTransparency = 1

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

    RunService.RenderStepped:Connect(function()
        toggleButton.Position = UDim2.new(0, main.AbsolutePosition.X - 85, 0, main.AbsolutePosition.Y)
    end)

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

        local tabCorner = Instance.new("UICorner", tabButton)
        tabCorner.CornerRadius = UDim.new(0, 6)

        local pageContainer = Instance.new("Frame", pages)
        pageContainer.Size = UDim2.new(1, 0, 1, 0)
        pageContainer.Visible = false
        pageContainer.BackgroundTransparency = 1
        pageContainer.Name = name .. "_Container"

        local leftColumn = Instance.new("ScrollingFrame", pageContainer)
        leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
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

        local rightColumn = Instance.new("ScrollingFrame", pageContainer)
        rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
        rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
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

            local leftPage = {parent = leftColumn}
            local rightPage = {parent = rightColumn}

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
                    
                    local buttonCorner = Instance.new("UICorner", button)
                    buttonCorner.CornerRadius = UDim.new(0, 6)
                    
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

                elseif elementType == "TextBox" then
                    local text, placeholder, callback = args[1], args[2], args[3]
                    local textBoxFrame = Instance.new("Frame", targetPage.parent)
                    textBoxFrame.Size = UDim2.new(1, -10, 0, 35)
                    textBoxFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    textBoxFrame.BackgroundTransparency = 0.4
                    textBoxFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", textBoxFrame)
                    label.Size = UDim2.new(0.4, 0, 1, 0)
                    label.Position = UDim2.new(0, 10, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 14
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = text

                    local textBox = Instance.new("TextBox", textBoxFrame)
                    textBox.Size = UDim2.new(0.55, 0, 0.7, 0)
                    textBox.Position = UDim2.new(0.42, 0, 0.15, 0)
                    textBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    textBox.BackgroundTransparency = 0.3
                    textBox.BorderSizePixel = 0
                    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textBox.Font = Enum.Font.SourceSans
                    textBox.TextSize = 14
                    textBox.PlaceholderText = placeholder
                    textBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
                    textBox.Text = ""

                    Instance.new("UICorner", textBoxFrame).CornerRadius = UDim.new(0, 6)
                    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 4)

                    textBox.FocusLost:Connect(function()
                        if callback then callback(textBox.Text) end
                    end)

                elseif elementType == "Dropdown" then
                    local text, multiselect, options, callback = args[1], args[2], args[3], args[4]
                    local dropdownFrame = Instance.new("Frame", targetPage.parent)
                    dropdownFrame.Size = UDim2.new(1, -10, 0, 35)
                    dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    dropdownFrame.BackgroundTransparency = 0.4
                    dropdownFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", dropdownFrame)
                    label.Size = UDim2.new(0.4, 0, 1, 0)
                    label.Position = UDim2.new(0, 10, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 14
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = text

                    local dropButton = Instance.new("TextButton", dropdownFrame)
                    dropButton.Size = UDim2.new(0.55, 0, 0.7, 0)
                    dropButton.Position = UDim2.new(0.42, 0, 0.15, 0)
                    dropButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    dropButton.BackgroundTransparency = 0.3
                    dropButton.BorderSizePixel = 0
                    dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    dropButton.Font = Enum.Font.SourceSans
                    dropButton.TextSize = 14
                    dropButton.Text = "Select..."
                    dropButton.TextXAlignment = Enum.TextXAlignment.Left

                    local arrow = Instance.new("TextLabel", dropButton)
                    arrow.Size = UDim2.new(0, 20, 1, 0)
                    arrow.Position = UDim2.new(1, -20, 0, 0)
                    arrow.BackgroundTransparency = 1
                    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
                    arrow.Font = Enum.Font.SourceSans
                    arrow.TextSize = 14
                    arrow.Text = "▼"
                    arrow.TextXAlignment = Enum.TextXAlignment.Center

                    Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 6)
                    Instance.new("UICorner", dropButton).CornerRadius = UDim.new(0, 4)

                    local dropList = Instance.new("ScrollingFrame", dropdownFrame)
                    dropList.Size = UDim2.new(0.55, 0, 0, 0)
                    dropList.Position = UDim2.new(0.42, 0, 1, 5)
                    dropList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    dropList.BackgroundTransparency = 0.2
                    dropList.BorderSizePixel = 0
                    dropList.ScrollBarThickness = 4
                    dropList.Visible = false
                    dropList.ZIndex = 10

                    local listLayout = Instance.new("UIListLayout", dropList)
                    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 4)

                    local selectedValues = {}
                    local isOpen = false

                    local function updateDropdownText()
                        if #selectedValues == 0 then
                            dropButton.Text = "Select..."
                        elseif multiselect then
                            dropButton.Text = table.concat(selectedValues, ", ")
                        else
                            dropButton.Text = selectedValues[1] or "Select..."
                        end
                    end

                    local function toggleDropdown()
                        isOpen = not isOpen
                        dropList.Visible = isOpen
                        arrow.Text = isOpen and "▲" or "▼"
                        
                        if isOpen then
                            local maxHeight = math.min(#options * 25, 100)
                            dropList.Size = UDim2.new(0.55, 0, 0, maxHeight)
                            dropList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
                        else
                            dropList.Size = UDim2.new(0.55, 0, 0, 0)
                        end
                    end

                    dropButton.MouseButton1Click:Connect(toggleDropdown)

                    for i, option in ipairs(options) do
                        local optionButton = Instance.new("TextButton", dropList)
                        optionButton.Size = UDim2.new(1, 0, 0, 25)
                        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        optionButton.BackgroundTransparency = 0.5
                        optionButton.BorderSizePixel = 0
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionButton.Font = Enum.Font.SourceSans
                        optionButton.TextSize = 12
                        optionButton.Text = option
                        optionButton.TextXAlignment = Enum.TextXAlignment.Left

                        optionButton.MouseButton1Click:Connect(function()
                            if multiselect then
                                local index = table.find(selectedValues, option)
                                if index then
                                    table.remove(selectedValues, index)
                                    optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                else
                                    table.insert(selectedValues, option)
                                    optionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                                end
                            else
                                selectedValues = {option}
                                for _, btn in pairs(dropList:GetChildren()) do
                                    if btn:IsA("TextButton") then
                                        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                    end
                                end
                                optionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                                toggleDropdown()
                            end
                            
                            updateDropdownText()
                            if callback then callback(multiselect and selectedValues or selectedValues[1]) end
                        end)
                    end

                    return {
                        UpdateOptions = function(newOptions)
                            options = newOptions
                            for _, child in pairs(dropList:GetChildren()) do
                                if child:IsA("TextButton") then
                                    child:Destroy()
                                end
                            end
                            
                            for i, option in ipairs(options) do
                                local optionButton = Instance.new("TextButton", dropList)
                                optionButton.Size = UDim2.new(1, 0, 0, 25)
                                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                optionButton.BackgroundTransparency = 0.5
                                optionButton.BorderSizePixel = 0
                                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                                optionButton.Font = Enum.Font.SourceSans
                                optionButton.TextSize = 12
                                optionButton.Text = option
                                optionButton.TextXAlignment = Enum.TextXAlignment.Left

                                optionButton.MouseButton1Click:Connect(function()
                                    if multiselect then
                                        local index = table.find(selectedValues, option)
                                        if index then
                                            table.remove(selectedValues, index)
                                            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                        else
                                            table.insert(selectedValues, option)
                                            optionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                                        end
                                    else
                                        selectedValues = {option}
                                        for _, btn in pairs(dropList:GetChildren()) do
                                            if btn:IsA("TextButton") then
                                                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                            end
                                        end
                                        optionButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                                        toggleDropdown()
                                    end
                                    
                                    updateDropdownText()
                                    if callback then callback(multiselect and selectedValues or selectedValues[1]) end
                                end)
                            end
                        end
                    }
                end
            end

            leftPage.Button = function(self, text, callback)
                createElement(self, "Button", text, callback)
            end
            leftPage.Toggle = function(self, text, default, callback)
                createElement(self, "Toggle", text, default, callback)
            end
            leftPage.Label = function(self, txt)
                createElement(self, "Label", txt)
            end
            leftPage.TextBox = function(self, text, placeholder, callback)
                return createElement(self, "TextBox", text, placeholder, callback)
            end
            leftPage.Drop = function(self, text, multiselect, options, callback)
                return createElement(self, "Dropdown", text, multiselect, options, callback)
            end

            rightPage.Button = function(self, text, callback)
                createElement(self, "Button", text, callback)
            end
            rightPage.Toggle = function(self, text, default, callback)
                createElement(self, "Toggle", text, default, callback)
            end
            rightPage.Label = function(self, txt)
                createElement(self, "Label", txt)
            end
            rightPage.TextBox = function(self, text, placeholder, callback)
                return createElement(self, "TextBox", text, placeholder, callback)
            end
            rightPage.Drop = function(self, text, multiselect, options, callback)
                return createElement(self, "Dropdown", text, multiselect, options, callback)
            end

            return leftPage, rightPage
        end

        return newPage
    end

    return tabs
end

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

    local corner = Instance.new("UICorner", notif)
    corner.CornerRadius = UDim.new(0, 6)

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
