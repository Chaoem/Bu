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

                    local dropList = Instance.new("ScrollingFrame", gui)
                    dropList.Size = UDim2.new(0, 0, 0, 0)
                    dropList.Position = UDim2.new(0, 0, 0, 0)
                    dropList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    dropList.BackgroundTransparency = 0.2
                    dropList.BorderSizePixel = 0
                    dropList.ScrollBarThickness = 4
                    dropList.Visible = false
                    dropList.ZIndex = 100
                    dropList.Active = true

                    local dropListBorder = Instance.new("UIStroke", dropList)
                    dropListBorder.Thickness = 1
                    dropListBorder.Color = Color3.fromRGB(80, 80, 80)

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

                    local function calculateDropdownPosition()
                        local buttonPos = dropButton.AbsolutePosition
                        local buttonSize = dropButton.AbsoluteSize
                        return UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 2)
                    end

                    local function toggleDropdown()
                        isOpen = not isOpen
                        dropList.Visible = isOpen
                        arrow.Text = isOpen and "▲" or "▼"
                        
                        if isOpen then
                            local maxHeight = math.min(#options * 25, 150)
                            local buttonSize = dropButton.AbsoluteSize
                            
                            dropList.Position = calculateDropdownPosition()
                            dropList.Size = UDim2.new(0, buttonSize.X, 0, maxHeight)
                            dropList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
                        else
                            dropList.Size = UDim2.new(0, 0, 0, 0)
                        end
                    end

                    local clickConnection
                    dropButton.MouseButton1Click:Connect(function()
                        toggleDropdown()
                        
                        if isOpen and not clickConnection then
                            clickConnection = UserInputService.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    local mousePos = input.Position
                                    local dropListPos = dropList.AbsolutePosition
                                    local dropListSize = dropList.AbsoluteSize
                                    local buttonPos = dropButton.AbsolutePosition
                                    local buttonSize = dropButton.AbsoluteSize
                                    
                                    local inDropdown = mousePos.X >= dropListPos.X and mousePos.X <= dropListPos.X + dropListSize.X and
                                                     mousePos.Y >= dropListPos.Y and mousePos.Y <= dropListPos.Y + dropListSize.Y
                                    local inButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                                                   mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
                                    
                                    if not inDropdown and not inButton then
                                        toggleDropdown()
                                        if clickConnection then
                                            clickConnection:Disconnect()
                                            clickConnection = nil
                                        end
                                    end
                                end
                            end)
                        elseif not isOpen and clickConnection then
                            clickConnection:Disconnect()
                            clickConnection = nil
                        end
                    end)

                    for i, option in ipairs(options) do
                        local optionButton = Instance.new("TextButton", dropList)
                        optionButton.Size = UDim2.new(1, 0, 0, 25)
                        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                        optionButton.BackgroundTransparency = 0.7
                        optionButton.BorderSizePixel = 0
                        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                        optionButton.Font = Enum.Font.SourceSans
                        optionButton.TextSize = 14
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
                            if callback then callback(selectedValues) end
                        end)

                        optionButton.MouseEnter:Connect(function()
                            if not table.find(selectedValues, option) then
                                optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                            end
                        end)

                        optionButton.MouseLeave:Connect(function()
                            if not table.find(selectedValues, option) then
                                optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                            end
                        end)
                    end

                elseif elementType == "Slider" then
                    local text, min, max, default, callback = args[1], args[2], args[3], args[4], args[5]
                    local sliderFrame = Instance.new("Frame", targetPage.parent)
                    sliderFrame.Size = UDim2.new(1, -10, 0, 40)
                    sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    sliderFrame.BackgroundTransparency = 0.4
                    sliderFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", sliderFrame)
                    label.Size = UDim2.new(0.4, 0, 0.5, 0)
                    label.Position = UDim2.new(0, 10, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 14
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = text

                    local valueLabel = Instance.new("TextLabel", sliderFrame)
                    valueLabel.Size = UDim2.new(0.15, 0, 0.5, 0)
                    valueLabel.Position = UDim2.new(0.82, 0, 0, 0)
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    valueLabel.Font = Enum.Font.SourceSans
                    valueLabel.TextSize = 14
                    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    valueLabel.Text = tostring(default)

                    local sliderBg = Instance.new("Frame", sliderFrame)
                    sliderBg.Size = UDim2.new(0.8, 0, 0, 6)
                    sliderBg.Position = UDim2.new(0.15, 0, 0.65, 0)
                    sliderBg.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    sliderBg.BorderSizePixel = 0

                    local sliderFill = Instance.new("Frame", sliderBg)
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderFill.Position = UDim2.new(0, 0, 0, 0)
                    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                    sliderFill.BorderSizePixel = 0

                    local sliderHandle = Instance.new("Frame", sliderBg)
                    sliderHandle.Size = UDim2.new(0, 14, 0, 14)
                    sliderHandle.Position = UDim2.new((default - min) / (max - min), -7, 0, -4)
                    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    sliderHandle.BorderSizePixel = 0

                    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 6)
                    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)
                    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
                    Instance.new("UICorner", sliderHandle).CornerRadius = UDim.new(1, 0)

                    local dragging = false
                    local currentValue = default

                    local function updateSlider(value)
                        currentValue = math.clamp(value, min, max)
                        local percentage = (currentValue - min) / (max - min)
                        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                        sliderHandle.Position = UDim2.new(percentage, -7, 0, -4)
                        valueLabel.Text = tostring(math.floor(currentValue * 100) / 100)
                        if callback then callback(currentValue) end
                    end

                    sliderHandle.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                        end
                    end)

                    sliderHandle.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)

                    sliderBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mousePos = input.Position.X
                            local sliderPos = sliderBg.AbsolutePosition.X
                            local sliderSize = sliderBg.AbsoluteSize.X
                            local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                            local value = min + (max - min) * percentage
                            updateSlider(value)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local mousePos = input.Position.X
                            local sliderPos = sliderBg.AbsolutePosition.X
                            local sliderSize = sliderBg.AbsoluteSize.X
                            local percentage = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                            local value = min + (max - min) * percentage
                            updateSlider(value)
                        end
                    end)

                elseif elementType == "Keybind" then
                    local text, defaultKey, callback = args[1], args[2], args[3]
                    local keybindFrame = Instance.new("Frame", targetPage.parent)
                    keybindFrame.Size = UDim2.new(1, -10, 0, 35)
                    keybindFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    keybindFrame.BackgroundTransparency = 0.4
                    keybindFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", keybindFrame)
                    label.Size = UDim2.new(0.6, 0, 1, 0)
                    label.Position = UDim2.new(0, 10, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 14
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = text

                    local keybindButton = Instance.new("TextButton", keybindFrame)
                    keybindButton.Size = UDim2.new(0.35, 0, 0.7, 0)
                    keybindButton.Position = UDim2.new(0.62, 0, 0.15, 0)
                    keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    keybindButton.BackgroundTransparency = 0.3
                    keybindButton.BorderSizePixel = 0
                    keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    keybindButton.Font = Enum.Font.SourceSans
                    keybindButton.TextSize = 14
                    keybindButton.Text = defaultKey or "None"

                    Instance.new("UICorner", keybindFrame).CornerRadius = UDim.new(0, 6)
                    Instance.new("UICorner", keybindButton).CornerRadius = UDim.new(0, 4)

                    local currentKey = defaultKey
                    local listening = false

                    keybindButton.MouseButton1Click:Connect(function()
                        if not listening then
                            listening = true
                            keybindButton.Text = "Press a key..."
                            keybindButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                            
                            local connection
                            connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                                if not gameProcessed then
                                    local keyName = input.KeyCode.Name
                                    if keyName ~= "Unknown" then
                                        currentKey = keyName
                                        keybindButton.Text = keyName
                                        keybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                                        listening = false
                                        connection:Disconnect()
                                        if callback then callback(keyName) end
                                    end
                                end
                            end)
                        end
                    end)

                    -- Listen for the keybind activation
                    if defaultKey then
                        UserInputService.InputBegan:Connect(function(input, gameProcessed)
                            if not gameProcessed and input.KeyCode.Name == currentKey then
                                if callback then callback(currentKey) end
                            end
                        end)
                    end

                elseif elementType == "ColorPicker" then
                    local text, defaultColor, callback = args[1], args[2], args[3]
                    local colorFrame = Instance.new("Frame", targetPage.parent)
                    colorFrame.Size = UDim2.new(1, -10, 0, 35)
                    colorFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    colorFrame.BackgroundTransparency = 0.4
                    colorFrame.BorderSizePixel = 0

                    local label = Instance.new("TextLabel", colorFrame)
                    label.Size = UDim2.new(0.6, 0, 1, 0)
                    label.Position = UDim2.new(0, 10, 0, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 14
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Text = text

                    local colorDisplay = Instance.new("Frame", colorFrame)
                    colorDisplay.Size = UDim2.new(0, 30, 0, 20)
                    colorDisplay.Position = UDim2.new(1, -35, 0.5, -10)
                    colorDisplay.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
                    colorDisplay.BorderSizePixel = 1
                    colorDisplay.BorderColor3 = Color3.fromRGB(200, 200, 200)

                    Instance.new("UICorner", colorFrame).CornerRadius = UDim.new(0, 6)
                    Instance.new("UICorner", colorDisplay).CornerRadius = UDim.new(0, 4)

                    local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)

                    colorDisplay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            -- Simple color picker (cycles through predefined colors)
                            local colors = {
                                Color3.fromRGB(255, 0, 0),    -- Red
                                Color3.fromRGB(0, 255, 0),    -- Green
                                Color3.fromRGB(0, 0, 255),    -- Blue
                                Color3.fromRGB(255, 255, 0),  -- Yellow
                                Color3.fromRGB(255, 0, 255),  -- Magenta
                                Color3.fromRGB(0, 255, 255),  -- Cyan
                                Color3.fromRGB(255, 255, 255), -- White
                                Color3.fromRGB(0, 0, 0),      -- Black
                                Color3.fromRGB(128, 128, 128), -- Gray
                                Color3.fromRGB(255, 165, 0),  -- Orange
                                Color3.fromRGB(128, 0, 128),  -- Purple
                                Color3.fromRGB(0, 128, 0),    -- Dark Green
                            }
                            
                            local currentIndex = 1
                            for i, color in ipairs(colors) do
                                if color == currentColor then
                                    currentIndex = i
                                    break
                                end
                            end
                            
                            currentIndex = currentIndex % #colors + 1
                            currentColor = colors[currentIndex]
                            colorDisplay.BackgroundColor3 = currentColor
                            
                            if callback then callback(currentColor) end
                        end
                    end)

                elseif elementType == "Separator" then
                    local separator = Instance.new("Frame", targetPage.parent)
                    separator.Size = UDim2.new(1, -10, 0, 2)
                    separator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                    separator.BackgroundTransparency = 0.5
                    separator.BorderSizePixel = 0

                elseif elementType == "Section" then
                    local sectionText = args[1]
                    local sectionFrame = Instance.new("Frame", targetPage.parent)
                    sectionFrame.Size = UDim2.new(1, -10, 0, 30)
                    sectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    sectionFrame.BackgroundTransparency = 0.3
                    sectionFrame.BorderSizePixel = 0

                    local sectionLabel = Instance.new("TextLabel", sectionFrame)
                    sectionLabel.Size = UDim2.new(1, -10, 1, 0)
                    sectionLabel.Position = UDim2.new(0, 10, 0, 0)
                    sectionLabel.BackgroundTransparency = 1
                    sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sectionLabel.Font = Enum.Font.SourceSansBold
                    sectionLabel.TextSize = 16
                    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    sectionLabel.Text = sectionText

                    Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)
                end
            end

            -- Create methods for left and right pages
            function leftPage:Button(text, callback)
                createElement(self, "Button", text, callback)
                return self
            end

            function leftPage:Toggle(text, default, callback)
                createElement(self, "Toggle", text, default, callback)
                return self
            end

            function leftPage:Label(text)
                createElement(self, "Label", text)
                return self
            end

            function leftPage:TextBox(text, placeholder, callback)
                createElement(self, "TextBox", text, placeholder, callback)
                return self
            end

            function leftPage:Dropdown(text, multiselect, options, callback)
                createElement(self, "Dropdown", text, multiselect, options, callback)
                return self
            end

            function leftPage:Slider(text, min, max, default, callback)
                createElement(self, "Slider", text, min, max, default, callback)
                return self
            end

            function leftPage:Keybind(text, defaultKey, callback)
                createElement(self, "Keybind", text, defaultKey, callback)
                return self
            end

            function leftPage:ColorPicker(text, defaultColor, callback)
                createElement(self, "ColorPicker", text, defaultColor, callback)
                return self
            end

            function leftPage:Separator()
                createElement(self, "Separator")
                return self
            end

            function leftPage:Section(text)
                createElement(self, "Section", text)
                return self
            end

            -- Right page methods (same as left)
            function rightPage:Button(text, callback)
                createElement(self, "Button", text, callback)
                return self
            end

            function rightPage:Toggle(text, default, callback)
                createElement(self, "Toggle", text, default, callback)
                return self
            end

            function rightPage:Label(text)
                createElement(self, "Label", text)
                return self
            end

            function rightPage:TextBox(text, placeholder, callback)
                createElement(self, "TextBox", text, placeholder, callback)
                return self
            end

            function rightPage:Dropdown(text, multiselect, options, callback)
                createElement(self, "Dropdown", text, multiselect, options, callback)
                return self
            end

            function rightPage:Slider(text, min, max, default, callback)
                createElement(self, "Slider", text, min, max, default, callback)
                return self
            end

            function rightPage:Keybind(text, defaultKey, callback)
                createElement(self, "Keybind", text, defaultKey, callback)
                return self
            end

            function rightPage:ColorPicker(text, defaultColor, callback)
                createElement(self, "ColorPicker", text, defaultColor, callback)
                return self
            end

            function rightPage:Separator()
                createElement(self, "Separator")
                return self
            end

            function rightPage:Section(text)
                createElement(self, "Section", text)
                return self
            end

            return {
                Left = leftPage,
                Right = rightPage
            }
        end

        return newPage
    end

    return tabs
end

-- Additional utility functions
function library:Notification(title, text, duration)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Parent = CoreGui

    local corner = Instance.new("UICorner", notification)
    corner.CornerRadius = UDim.new(0, 8)

    local border = Instance.new("UIStroke", notification)
    border.Thickness = 1
    border.Color = Color3.fromRGB(0, 170, 255)

    local titleLabel = Instance.new("TextLabel", notification)
    titleLabel.Size = UDim2.new(1, -10, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title

    local textLabel = Instance.new("TextLabel", notification)
    textLabel.Size = UDim2.new(1, -10, 0, 45)
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Text = text

    -- Slide in animation
    notification:TweenPosition(
        UDim2.new(1, -320, 1, -100),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.5,
        true
    )

    -- Auto-hide after duration
    game:GetService("Debris"):AddItem(notification, duration or 5)
    
    wait(duration or 5 - 0.5)
    notification:TweenPosition(
        UDim2.new(1, 0, 1, -100),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.5,
        true
    )
end

return library
