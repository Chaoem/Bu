-- Modified Fluent UI Library - Compact Version
-- Removed OnChanged callbacks, Added spawn-based monitoring system

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local Themes = {
    Dark = {
        Accent = Color3.fromRGB(96, 205, 255),
        AcrylicMain = Color3.fromRGB(60, 60, 60),
        AcrylicBorder = Color3.fromRGB(90, 90, 90),
        Element = Color3.fromRGB(120, 120, 120),
        ElementBorder = Color3.fromRGB(35, 35, 35),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(170, 170, 170),
        Input = Color3.fromRGB(160, 160, 160),
        Dialog = Color3.fromRGB(45, 45, 45),
        DialogBorder = Color3.fromRGB(70, 70, 70)
    },
    Light = {
        Accent = Color3.fromRGB(0, 103, 192),
        AcrylicMain = Color3.fromRGB(200, 200, 200),
        AcrylicBorder = Color3.fromRGB(120, 120, 120),
        Element = Color3.fromRGB(255, 255, 255),
        ElementBorder = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(0, 0, 0),
        SubText = Color3.fromRGB(40, 40, 40),
        Input = Color3.fromRGB(200, 200, 200),
        Dialog = Color3.fromRGB(255, 255, 255),
        DialogBorder = Color3.fromRGB(140, 140, 140)
    }
}

local Library = {
    Version = "1.2.2 Modified",
    Options = {},
    Window = nil,
    Theme = "Dark"
}

local Creator = {
    Registry = {},
    Signals = {}
}

function Creator.New(className, properties, children)
    local object = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "ThemeTag" then
            object[prop] = value
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = object
    end
    if properties and properties.ThemeTag then
        Creator.AddThemeObject(object, properties.ThemeTag)
    end
    return object
end

function Creator.AddThemeObject(object, properties)
    Creator.Registry[object] = properties
    Creator.UpdateTheme()
end

function Creator.UpdateTheme()
    local theme = Themes[Library.Theme]
    for object, props in pairs(Creator.Registry) do
        if object and object.Parent then
            for prop, colorKey in pairs(props) do
                if theme[colorKey] then
                    object[prop] = theme[colorKey]
                end
            end
        end
    end
end

function Creator.AddSignal(signal, func)
    local connection = signal:Connect(func)
    table.insert(Creator.Signals, connection)
    return connection
end

local GUI = Creator.New("ScreenGui", {
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
})
ProtectGui(GUI)

function Library:SafeCallback(func, ...)
    if not func then return end
    local success, result = pcall(func, ...)
    if not success then warn("Callback error:", result) end
end

function Library:Round(number, factor)
    if factor == 0 then return math.floor(number) end
    local str = tostring(number)
    return str:find("%.") and tonumber(str:sub(1, str:find("%.") + factor)) or number
end

function Library:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "Fluent"
    config.SubTitle = config.SubTitle or ""
    config.Size = config.Size or UDim2.fromOffset(580, 460)
    config.TabWidth = config.TabWidth or 160
    
    local Window = {
        Root = nil,
        Tabs = {},
        SelectedTab = 1,
        TabCount = 0
    }
    
    Window.Root = Creator.New("Frame", {
        Size = config.Size,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = GUI,
        ThemeTag = {BackgroundColor3 = "AcrylicMain"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "AcrylicBorder"}})
    })
    
    -- Make draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    Window.Root.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Window.Root.Position
        end
    end)
    
    Window.Root.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Window.Root.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Title bar
    Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = Window.Root
    }, {
        Creator.New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.fromOffset(15, 8),
            BackgroundTransparency = 1,
            Text = config.Title,
            TextSize = 16,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeTag = {TextColor3 = "Text"}
        }),
        Creator.New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 14),
            Position = UDim2.fromOffset(15, 22),
            BackgroundTransparency = 1,
            Text = config.SubTitle,
            TextSize = 12,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeTag = {TextColor3 = "SubText"}
        })
    })
    
    -- Tab container
    Window.TabContainer = Creator.New("ScrollingFrame", {
        Size = UDim2.new(0, config.TabWidth, 1, -50),
        Position = UDim2.fromOffset(10, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.fromScale(0, 0),
        Parent = Window.Root,
        BorderSizePixel = 0
    }, {
        Creator.New("UIListLayout", {Padding = UDim.new(0, 5)}),
        Creator.New("UIPadding", {PaddingAll = UDim.new(0, 5)})
    })
    
    -- Content container
    Window.ContentContainer = Creator.New("ScrollingFrame", {
        Size = UDim2.new(1, -config.TabWidth - 30, 1, -60),
        Position = UDim2.fromOffset(config.TabWidth + 20, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.fromScale(0, 0),
        Parent = Window.Root,
        BorderSizePixel = 0
    }, {
        Creator.New("UIListLayout", {Padding = UDim.new(0, 10)}),
        Creator.New("UIPadding", {PaddingAll = UDim.new(0, 10)})
    })
    
    -- Update canvas sizes
    Creator.AddSignal(Window.TabContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Window.TabContainer.CanvasSize = UDim2.new(0, 0, 0, Window.TabContainer.UIListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    Creator.AddSignal(Window.ContentContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Window.ContentContainer.CanvasSize = UDim2.new(0, 0, 0, Window.ContentContainer.UIListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    function Window:AddTab(config)
        config = config or {}
        config.Title = config.Title or "Tab"
        
        Window.TabCount = Window.TabCount + 1
        local tabIndex = Window.TabCount
        
        local Tab = {
            Title = config.Title,
            Index = tabIndex,
            Active = false
        }
        
        -- Create tab button
        Tab.Button = Creator.New("TextButton", {
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundTransparency = tabIndex == 1 and 0.1 or 0.3,
            Text = "",
            Parent = Window.TabContainer,
            ThemeTag = {BackgroundColor3 = "Element"}
        }, {
            Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
            Creator.New("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.fromOffset(10, 0),
                BackgroundTransparency = 1,
                Text = config.Title,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                ThemeTag = {TextColor3 = "Text"}
            })
        })
        
        -- Create tab content
        Tab.Content = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1,
            Visible = tabIndex == 1,
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = Window.ContentContainer
        }, {
            Creator.New("UIListLayout", {Padding = UDim.new(0, 10)})
        })
        
        -- Tab selection
        Creator.AddSignal(Tab.Button.MouseButton1Click, function()
            Window:SelectTab(tabIndex)
        end)
        
        function Tab:AddButton(config)
            config = config or {}
            config.Title = config.Title or "Button"
            config.Description = config.Description or ""
            config.Callback = config.Callback or function() end
            
            local Button = Creator.New("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 0.1,
                Text = "",
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 14),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            Creator.AddSignal(Button.MouseButton1Click, function()
                Library:SafeCallback(config.Callback)
            end)
            
            return Button
        end
        
        function Tab:AddToggle(id, config)
            config = config or {}
            config.Title = config.Title or "Toggle"
            config.Description = config.Description or ""
            config.Default = config.Default or false
            
            Library.Options[id] = {Value = config.Default, Type = "Toggle"}
            
            local Toggle = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 14),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            local switchFrame = Creator.New("Frame", {
                Size = UDim2.fromOffset(40, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Parent = Toggle
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Creator.New("Frame", {
                    Size = UDim2.fromOffset(16, 16),
                    Position = UDim2.fromOffset(2, 2),
                    ThemeTag = {BackgroundColor3 = "Text"}
                }, {
                    Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
                })
            })
            
            local switch = switchFrame:GetChildren()[2]
            local isToggled = config.Default
            
            local function updateToggle()
                local targetPos = isToggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
                local targetColor = isToggled and Themes[Library.Theme].Accent or Themes[Library.Theme].Text
                TweenService:Create(switch, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
            end
            
            updateToggle()
            
            local button = Creator.New("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "",
                Parent = Toggle
            })
            
            Creator.AddSignal(button.MouseButton1Click, function()
                isToggled = not isToggled
                Library.Options[id].Value = isToggled
                updateToggle()
            end)
            
            return Toggle
        end
        
        function Tab:AddDropdown(id, config)
            config = config or {}
            config.Title = config.Title or "Dropdown"
            config.Description = config.Description or ""
            config.Values = config.Values or {}
            config.Multi = config.Multi or false
            config.Default = config.Default or (config.Multi and {} or 1)
            
            local initialValue = config.Multi and {} or (config.Values[config.Default] or config.Values[1] or "")
            Library.Options[id] = {Value = initialValue, Type = "Dropdown"}
            
            local Dropdown = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -120, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -120, 0, 14),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            local dropdownButton = Creator.New("TextButton", {
                Size = UDim2.fromOffset(100, 25),
                Position = UDim2.new(1, -110, 0.5, -12.5),
                Text = tostring(initialValue),
                TextSize = 12,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                Parent = Dropdown,
                ThemeTag = {BackgroundColor3 = "Input", TextColor3 = "Text"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)})
            })
            
            if config.Multi then
                local currentSelection = {}
                dropdownButton.Text = "None"
                Creator.AddSignal(dropdownButton.MouseButton1Click, function()
                    for i, value in ipairs(config.Values) do
                        if not currentSelection[value] then
                            currentSelection[value] = true
                            Library.Options[id].Value = currentSelection
                            local displayText = ""
                            local count = 0
                            for k, v in pairs(currentSelection) do
                                if v then
                                    count = count + 1
                                    if count <= 2 then
                                        displayText = displayText == "" and k or displayText .. ", " .. k
                                    end
                                end
                            end
                            if count > 2 then displayText = displayText .. "..." end
                            dropdownButton.Text = count > 0 and displayText or "None"
                            break
                        end
                    end
                end)
            else
                local currentIndex = config.Default or 1
                dropdownButton.Text = tostring(config.Values[currentIndex] or "")
                Creator.AddSignal(dropdownButton.MouseButton1Click, function()
                    currentIndex = (currentIndex % #config.Values) + 1
                    local newValue = config.Values[currentIndex]
                    Library.Options[id].Value = newValue
                    dropdownButton.Text = tostring(newValue)
                end)
            end
            
            return Dropdown
        end
        
        function Tab:AddSlider(id, config)
            config = config or {}
            config.Title = config.Title or "Slider"
            config.Description = config.Description or ""
            config.Min = config.Min or 0
            config.Max = config.Max or 100
            config.Default = config.Default or config.Min
            config.Rounding = config.Rounding or 0
            
            Library.Options[id] = {Value = config.Default, Type = "Slider"}
            
            local Slider = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.fromOffset(50, 18),
                    Position = UDim2.new(1, -55, 0, 6),
                    BackgroundTransparency = 1,
                    Text = tostring(config.Default),
                    TextSize = 13,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            if config.Description ~= "" then
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 12),
                    Position = UDim2.fromOffset(10, 24),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 11,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Slider,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            end
            
            local sliderRail = Creator.New("Frame", {
                Size = UDim2.new(1, -20, 0, 4),
                Position = UDim2.fromOffset(10, 40),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                Parent = Slider
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
            })
            
            local sliderHandle = Creator.New("Frame", {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(0, -6, 0.5, -6),
                AnchorPoint = Vector2.new(0, 0.5),
                Parent = sliderRail,
                ThemeTag = {BackgroundColor3 = "Text"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(1, 0)})
            })
            
            local valueLabel = Slider:GetChildren()[3]
            local dragging = false
            local currentValue = config.Default
            
            local function updateSlider(value)
                value = math.clamp(value, config.Min, config.Max)
                if config.Rounding > 0 then
                    value = Library:Round(value, config.Rounding)
                else
                    value = math.floor(value)
                end
                currentValue = value
                Library.Options[id].Value = value
                valueLabel.Text = tostring(value)
                local percentage = (value - config.Min) / (config.Max - config.Min)
                sliderHandle.Position = UDim2.new(percentage, -6, 0.5, -6)
            end
            
            updateSlider(config.Default)
            
            Creator.AddSignal(sliderRail.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local mouse = UserInputService:GetMouseLocation()
                    local railPos = sliderRail.AbsolutePosition
                    local railSize = sliderRail.AbsoluteSize
                    local percentage = math.clamp((mouse.X - railPos.X) / railSize.X, 0, 1)
                    local value = config.Min + (config.Max - config.Min) * percentage
                    updateSlider(value)
                end
            end)
            
            Creator.AddSignal(UserInputService.InputChanged, function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mouse = UserInputService:GetMouseLocation()
                    local railPos = sliderRail.AbsolutePosition
                    local railSize = sliderRail.AbsoluteSize
                    local percentage = math.clamp((mouse.X - railPos.X) / railSize.X, 0, 1)
                    local value = config.Min + (config.Max - config.Min) * percentage
                    updateSlider(value)
                end
            end)
            
            Creator.AddSignal(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            return Slider
        end
        
        function Tab:AddInput(id, config)
            config = config or {}
            config.Title = config.Title or "Input"
            config.Description = config.Description or ""
            config.Default = config.Default or ""
            config.Placeholder = config.Placeholder or "Enter text..."
            config.Numeric = config.Numeric or false
            config.Callback = config.Callback or function() end
            
            Library.Options[id] = {Value = config.Default, Type = "Input"}
            
            local Input = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(0.4, 0, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(0.4, 0, 0, 14),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            local inputBox = Creator.New("TextBox", {
                Size = UDim2.new(0.5, -10, 0, 25),
                Position = UDim2.new(0.5, 5, 0.5, -12.5),
                Text = config.Default,
                PlaceholderText = config.Placeholder,
                TextSize = 12,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Input,
                ThemeTag = {BackgroundColor3 = "Input", TextColor3 = "Text", PlaceholderColor3 = "SubText"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Creator.New("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
            })
            
            Creator.AddSignal(inputBox.FocusLost, function(enterPressed)
                local text = inputBox.Text
                if config.Numeric then text = tonumber(text) or 0 end
                Library.Options[id].Value = text
                Library:SafeCallback(config.Callback, text)
            end)
            
            return Input
        end
        
        function Tab:AddKeybind(id, config)
            config = config or {}
            config.Title = config.Title or "Keybind"
            config.Description = config.Description or ""
            config.Default = config.Default or Enum.KeyCode.E
            config.Callback = config.Callback or function() end
            
            Library.Options[id] = {Value = config.Default, Type = "Keybind"}
            
            local Keybind = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -100, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -100, 0, 14),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            local keybindButton = Creator.New("TextButton", {
                Size = UDim2.fromOffset(80, 25),
                Position = UDim2.new(1, -90, 0.5, -12.5),
                Text = config.Default.Name,
                TextSize = 11,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                Parent = Keybind,
                ThemeTag = {BackgroundColor3 = "Input", TextColor3 = "Text"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)})
            })
            
            local listening = false
            local currentKey = config.Default
            
            Creator.AddSignal(keybindButton.MouseButton1Click, function()
                if not listening then
                    listening = true
                    keybindButton.Text = "..."
                    local connection
                    connection = Creator.AddSignal(UserInputService.InputBegan, function(input, gameProcessed)
                        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            Library.Options[id].Value = currentKey
                            keybindButton.Text = currentKey.Name
                            listening = false
                            connection:Disconnect()
                        end
                    end)
                end
            end)
            
            Creator.AddSignal(UserInputService.InputBegan, function(input, gameProcessed)
                if not gameProcessed and input.KeyCode == currentKey then
                    Library:SafeCallback(config.Callback)
                end
            end)
            
            return Keybind
        end
        
        function Tab:AddColorPicker(id, config)
            config = config or {}
            config.Title = config.Title or "Color Picker"
            config.Description = config.Description or ""
            config.Default = config.Default or Color3.fromRGB(255, 255, 255)
            
            Library.Options[id] = {Value = config.Default, Type = "ColorPicker"}
            
            local ColorPicker = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 18),
                    Position = UDim2.fromOffset(10, 6),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 14),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = config.Description,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
            
            local colorButton = Creator.New("TextButton", {
                Size = UDim2.fromOffset(40, 25),
                Position = UDim2.new(1, -50, 0.5, -12.5),
                BackgroundColor3 = config.Default,
                Text = "",
                Parent = ColorPicker
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Creator.New("UIStroke", {Color = Color3.fromRGB(100, 100, 100), Thickness = 1})
            })
            
            local colors = {
                Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 0)
            }
            
            local colorIndex = 1
            for i, color in ipairs(colors) do
                if color == config.Default then colorIndex = i break end
            end
            
            Creator.AddSignal(colorButton.MouseButton1Click, function()
                colorIndex = (colorIndex % #colors) + 1
                local newColor = colors[colorIndex]
                colorButton.BackgroundColor3 = newColor
                Library.Options[id].Value = newColor
            end)
            
            return ColorPicker
        end
        
        function Tab:AddSection(title)
            return Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Tab.Content
            }, {
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text = title or "Section",
                    TextSize = 16,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Bottom,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("Frame", {
                    Size = UDim2.new(1, -20, 0, 1),
                    Position = UDim2.new(0, 10, 1, -1),
                    ThemeTag = {BackgroundColor3 = "ElementBorder"}
                })
            })
        end
        
        function Tab:AddParagraph(config)
            config = config or {}
            config.Title = config.Title or "Paragraph"
            config.Content = config.Content or "Content"
            
            return Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 0.1,
                Parent = Tab.Content,
                AutomaticSize = Enum.AutomaticSize.Y,
                ThemeTag = {BackgroundColor3 = "Element"}
            }, {
                Creator.New("UICorner", {CornerRadius = UDim.new(0, 6)}),
                Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "ElementBorder"}}),
                Creator.New("UIPadding", {PaddingAll = UDim.new(0, 10)}),
                Creator.New("UIListLayout", {Padding = UDim.new(0, 5)}),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = config.Title,
                    TextSize = 14,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    ThemeTag = {TextColor3 = "Text"}
                }),
                Creator.New("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = config.Content,
                    TextSize = 12,
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true,
                    ThemeTag = {TextColor3 = "SubText"}
                })
            })
        end
        
        Window.Tabs[tabIndex] = Tab
        return Tab
    end
    
    function Window:SelectTab(index)
        for i, tab in pairs(Window.Tabs) do
            if tab.Content then
                tab.Content.Visible = (i == index)
                tab.Active = (i == index)
                local transparency = (i == index) and 0.05 or 0.3
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = transparency}):Play()
            end
        end
        Window.SelectedTab = index
    end
    
    function Window:SetTheme(themeName)
        if Themes[themeName] then
            Library.Theme = themeName
            Creator.UpdateTheme()
        end
    end
    
    Library.Window = Window
    return Window
end

function Library:Notify(config)
    config = config or {}
    config.Title = config.Title or "Notification"
    config.Content = config.Content or ""
    config.Duration = config.Duration or 5
    
    local notification = Creator.New("Frame", {
        Size = UDim2.fromOffset(300, 80),
        Position = UDim2.new(1, -320, 1, -100),
        Parent = GUI,
        ThemeTag = {BackgroundColor3 = "Dialog"}
    }, {
        Creator.New("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Creator.New("UIStroke", {Thickness = 1, ThemeTag = {Color = "DialogBorder"}}),
        Creator.New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            Text = config.Title,
            TextSize = 14,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
            TextXAlignment = Enum.TextXAlignment.Left,
            ThemeTag = {TextColor3 = "Text"}
        }),
        Creator.New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.fromOffset(10, 35),
            BackgroundTransparency = 1,
            Text = config.Content,
            TextSize = 12,
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ThemeTag = {TextColor3 = "SubText"}
        })
    })
    
    notification.Position = UDim2.new(1, 20, 1, -100)
    notification:TweenPosition(UDim2.new(1, -320, 1, -100), "Out", "Quart", 0.3)
    
    if config.Duration then
        spawn(function()
            wait(config.Duration)
            notification:TweenPosition(UDim2.new(1, 20, 1, -100), "In", "Quart", 0.3)
            wait(0.3)
            notification:Destroy()
        end)
    end
end

function Library:GetIcon(name)
    local icons = {
        home = "rbxassetid://10734884548",
        user = "rbxassetid://10734949856", 
        settings = "rbxassetid://10734950309",
        gem = "rbxassetid://10734884548"
    }
    return icons[name] or ""
end

setmetatable(Library.Options, {
    __index = function(t, k)
        return rawget(t, k) or {Value = nil, Type = "Unknown"}
    end,
    __newindex = function(t, k, v)
        if type(v) == "table" and v.Value ~= nil then
            rawset(t, k, v)
        else
            rawset(t, k, {Value = v, Type = "Unknown"})
        end
    end
})

return Library
