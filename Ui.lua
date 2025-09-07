--[[             |
'                |   Last changes:     
FluentPlus 1.2.2 |   31.01 - added Show_Assets toggle. Soon ill make normal bypass.
dsc.gg/hydrahub  |   29.01 - well well well removed last update, added "Bloody" theme and fluent-plus settings 😉
'                |   01.01 - fixed this file and mobile support, added a "GUI dragging cooldown".
]]--             |
-- Modified to remove OnChanged and use spawn monitoring system

--- FLUENT PLUS SETTINGS ---
local Show_Button = false -- Shows the button for toggle fluent ui manually. If "false", works only on mobile, if "true", works everytime.
local Button_Icon = "" -- Icon of the button for toggle fluent ui
----------------------------

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local httpService = game:GetService("HttpService")

local Mobile
if RunService:IsStudio() then
	Mobile = false
else
	Mobile = table.find({Enum.Platform.IOS, Enum.Platform.Android}, UserInputService:GetPlatform()) ~= nil
end

if Show_Button then
	Mobile = true
end

local Asset = "rbxassetid://"
if Game.GameId == 5750914919 then
	Asset = ""
end

local RenderStepped = RunService.RenderStepped

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local Themes = {
	Names = {
		"Dark",
		"Darker", 
		"AMOLED",
		"Light",
		"Balloon",
		"SoftCream",
		"Aqua", 
		"Amethyst",
		"Rose",
		"Midnight",
		"Forest",
		"Sunset", 
		"Ocean",
		"Emerald",
		"Sapphire",
		"Cloud",
		"Grape",
		"Bloody",
		"Roblox"
	},
	Dark = {
		Name = "Dark",
		Accent = Color3.fromRGB(96, 205, 255),
		AcrylicMain = Color3.fromRGB(60, 60, 60),
		AcrylicBorder = Color3.fromRGB(90, 90, 90),
		AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
		AcrylicNoise = 0.9,
		TitleBarLine = Color3.fromRGB(75, 75, 75),
		Tab = Color3.fromRGB(120, 120, 120),
		Element = Color3.fromRGB(120, 120, 120),
		ElementBorder = Color3.fromRGB(35, 35, 35),
		InElementBorder = Color3.fromRGB(90, 90, 90),
		ElementTransparency = 0.87,
		ToggleSlider = Color3.fromRGB(120, 120, 120),
		ToggleToggled = Color3.fromRGB(42, 42, 42),
		SliderRail = Color3.fromRGB(120, 120, 120),
		DropdownFrame = Color3.fromRGB(160, 160, 160),
		DropdownHolder = Color3.fromRGB(45, 45, 45),
		DropdownBorder = Color3.fromRGB(35, 35, 35),
		DropdownOption = Color3.fromRGB(120, 120, 120),
		Keybind = Color3.fromRGB(120, 120, 120),
		Input = Color3.fromRGB(160, 160, 160),
		InputFocused = Color3.fromRGB(10, 10, 10),
		InputIndicator = Color3.fromRGB(150, 150, 150),
		Dialog = Color3.fromRGB(45, 45, 45),
		DialogHolder = Color3.fromRGB(35, 35, 35),
		DialogHolderLine = Color3.fromRGB(30, 30, 30),
		DialogButton = Color3.fromRGB(45, 45, 45),
		DialogButtonBorder = Color3.fromRGB(80, 80, 80),
		DialogBorder = Color3.fromRGB(70, 70, 70),
		DialogInput = Color3.fromRGB(55, 55, 55),
		DialogInputLine = Color3.fromRGB(160, 160, 160),
		Text = Color3.fromRGB(240, 240, 240),
		SubText = Color3.fromRGB(170, 170, 170),
		Hover = Color3.fromRGB(120, 120, 120),
		HoverChange = 0.07,
	},
	-- Add other themes here (truncated for space)
}

local Library = {
	Version = "1.2.2",
	OpenFrames = {},
	Options = {},
	Themes = Themes.Names,
	Window = nil,
	WindowFrame = nil,
	Unloaded = false,
	Creator = nil,
	DialogOpen = false,
	UseAcrylic = false,
	Acrylic = false,
	Transparency = true,
	MinimizeKeybind = nil,
	MinimizeKey = Enum.KeyCode.LeftControl,
}

-- Motor system for animations (simplified)
local function createMotor(initial, target)
	local motor = {
		value = initial,
		target = target,
		speed = 8
	}
	
	function motor:setGoal(newTarget)
		self.target = newTarget
	end
	
	function motor:step(dt)
		local diff = self.target - self.value
		if math.abs(diff) > 0.001 then
			self.value = self.value + diff * self.speed * dt
			return false
		else
			self.value = self.target
			return true
		end
	end
	
	return motor
end

-- Signal system for connections
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		connections = {}
	}, Signal)
end

function Signal:Connect(func)
	local connection = {
		func = func,
		connected = true
	}
	table.insert(self.connections, connection)
	
	return {
		Disconnect = function()
			connection.connected = false
		end
	}
end

function Signal:Fire(...)
	for _, connection in pairs(self.connections) do
		if connection.connected then
			spawn(function()
				connection.func(...)
			end)
		end
	end
end

-- Creator system for UI elements
local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		-- Add other default properties...
	},
	Theme = "Dark",
	Themes = Themes
}

function Creator.New(className, properties, children)
	local object = Instance.new(className)
	
	-- Apply default properties
	for prop, value in pairs(Creator.DefaultProperties[className] or {}) do
		object[prop] = value
	end
	
	-- Apply custom properties
	for prop, value in pairs(properties or {}) do
		if prop ~= "ThemeTag" then
			object[prop] = value
		end
	end
	
	-- Add children
	for _, child in pairs(children or {}) do
		child.Parent = object
	end
	
	-- Handle theme tags
	if properties and properties.ThemeTag then
		Creator.AddThemeObject(object, properties.ThemeTag)
	end
	
	return object
end

function Creator.AddThemeObject(object, properties)
	Creator.Registry[object] = {
		Object = object,
		Properties = properties
	}
	Creator.UpdateTheme()
	return object
end

function Creator.UpdateTheme()
	for object, data in pairs(Creator.Registry) do
		for property, colorIdx in pairs(data.Properties) do
			local themeValue = Creator.GetThemeProperty(colorIdx)
			if themeValue then
				object[property] = themeValue
			end
		end
	end
end

function Creator.GetThemeProperty(property)
	if Themes[Creator.Theme] and Themes[Creator.Theme][property] then
		return Themes[Creator.Theme][property]
	end
	return Themes["Dark"][property]
end

Library.Creator = Creator

-- Main GUI
local GUI = Creator.New("ScreenGui", {
	Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
})
Library.GUI = GUI
ProtectGui(GUI)

-- Core Functions
function Library:SafeCallback(func, ...)
	if not func then return end
	
	local success, result = pcall(func, ...)
	if not success then
		warn("Callback error:", result)
	end
end

function Library:Round(number, factor)
	if factor == 0 then
		return math.floor(number)
	end
	local str = tostring(number)
	return str:find("%.") and tonumber(str:sub(1, str:find("%.") + factor)) or number
end

-- Window Creation
function Library:CreateWindow(config)
	config = config or {}
	config.Title = config.Title or "Fluent"
	config.SubTitle = config.SubTitle or ""
	config.Size = config.Size or UDim2.fromOffset(580, 460)
	config.Acrylic = config.Acrylic ~= false
	config.Theme = config.Theme or "Dark"
	config.TabWidth = config.TabWidth or 160
	
	Library.UseAcrylic = config.Acrylic
	Creator.Theme = config.Theme
	
	local Window = {
		Root = nil,
		Title = config.Title,
		Size = config.Size,
		Tabs = {},
		SelectedTab = 1,
		TabCount = 0
	}
	
	-- Create main window frame
	Window.Root = Creator.New("Frame", {
		Size = config.Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		Parent = GUI,
		ThemeTag = {
			BackgroundColor3 = "AcrylicMain"
		}
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 8)
		}),
		Creator.New("UIStroke", {
			Color = Color3.fromRGB(60, 60, 60),
			Thickness = 1,
			ThemeTag = {
				Color = "AcrylicBorder"
			}
		})
	})
	
	-- Title bar
	local titleBar = Creator.New("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent = Window.Root
	}, {
		Creator.New("TextLabel", {
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.fromOffset(15, 0),
			BackgroundTransparency = 1,
			Text = config.Title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 16,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextXAlignment = Enum.TextXAlignment.Left,
			ThemeTag = {
				TextColor3 = "Text"
			}
		})
	})
	
	-- Tab container
	Window.TabContainer = Creator.New("Frame", {
		Size = UDim2.new(0, config.TabWidth, 1, -50),
		Position = UDim2.fromOffset(10, 45),
		BackgroundTransparency = 1,
		Parent = Window.Root
	}, {
		Creator.New("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	
	-- Content container
	Window.ContentContainer = Creator.New("ScrollingFrame", {
		Size = UDim2.new(1, -config.TabWidth - 30, 1, -60),
		Position = UDim2.fromOffset(config.TabWidth + 20, 50),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.fromScale(0, 0),
		Parent = Window.Root
	}, {
		Creator.New("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		Creator.New("UIPadding", {
			PaddingAll = UDim.new(0, 10)
		})
	})
	
	function Window:AddTab(config)
		config = config or {}
		config.Title = config.Title or "Tab"
		config.Icon = config.Icon or ""
		
		Window.TabCount = Window.TabCount + 1
		local tabIndex = Window.TabCount
		
		local Tab = {
			Title = config.Title,
			Icon = config.Icon,
			Index = tabIndex,
			Active = false,
			Elements = {}
		}
		
		-- Create tab button
		Tab.Button = Creator.New("TextButton", {
			Size = UDim2.new(1, 0, 0, 35),
			BackgroundColor3 = Color3.fromRGB(45, 45, 45),
			Text = "",
			LayoutOrder = tabIndex,
			Parent = Window.TabContainer,
			ThemeTag = {
				BackgroundColor3 = "Element"
			}
		}, {
			Creator.New("UICorner", {
				CornerRadius = UDim.new(0, 6)
			}),
			Creator.New("TextLabel", {
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.fromOffset(35, 0),
				BackgroundTransparency = 1,
				Text = config.Title,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				ThemeTag = {
					TextColor3 = "Text"
				}
			})
		})
		
		-- Create tab content
		Tab.Content = Creator.New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Visible = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = Window.ContentContainer
		}, {
			Creator.New("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		})
		
		-- Tab selection
		Tab.Button.MouseButton1Click:Connect(function()
			Window:SelectTab(tabIndex)
		end)
		
		-- Tab methods
		function Tab:AddButton(config)
			config = config or {}
			config.Title = config.Title or "Button"
			config.Description = config.Description or ""
			config.Callback = config.Callback or function() end
			
			local Button = Creator.New("TextButton", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Text = "",
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -20, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -20, 0, 15),
					Position = UDim2.fromOffset(10, 20),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			Button.MouseButton1Click:Connect(function()
				Library:SafeCallback(config.Callback)
			end)
			
			return Button
		end
		
		function Tab:AddToggle(id, config)
			config = config or {}
			config.Title = config.Title or "Toggle"
			config.Description = config.Description or ""
			config.Default = config.Default or false
			
			-- Add to Options table
			Library.Options[id] = {
				Value = config.Default,
				Type = "Toggle"
			}
			
			local Toggle = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 15),
					Position = UDim2.fromOffset(10, 20),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			-- Toggle switch
			local switchFrame = Creator.New("Frame", {
				Size = UDim2.fromOffset(40, 20),
				Position = UDim2.new(1, -50, 0.5, -10),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				Parent = Toggle,
				ThemeTag = {
					BackgroundColor3 = "ToggleSlider"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(1, 0)
				}),
				Creator.New("Frame", {
					Size = UDim2.fromOffset(16, 16),
					Position = UDim2.fromOffset(2, 2),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					ThemeTag = {
						BackgroundColor3 = "Text"
					}
				}, {
					Creator.New("UICorner", {
						CornerRadius = UDim.new(1, 0)
					})
				})
			})
			
			local switch = switchFrame:GetChildren()[2]
			local isToggled = config.Default
			
			-- Update visual state
			local function updateToggle()
				local targetPos = isToggled and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2)
				local targetColor = isToggled and Creator.GetThemeProperty("Accent") or Creator.GetThemeProperty("Text")
				
				TweenService:Create(switch, TweenInfo.new(0.2), {
					Position = targetPos,
					BackgroundColor3 = targetColor
				}):Play()
			end
			
			updateToggle()
			
			-- Click handler
			local button = Creator.New("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				Parent = Toggle
			})
			
			button.MouseButton1Click:Connect(function()
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
			config.Default = config.Default or (config.Multi and {} or (config.Values[1] or ""))
			
			-- Add to Options table
			Library.Options[id] = {
				Value = config.Default,
				Type = "Dropdown"
			}
			
			local Dropdown = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -120, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -120, 0, 15),
					Position = UDim2.fromOffset(10, 20),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			-- Dropdown button
			local dropdownButton = Creator.New("TextButton", {
				Size = UDim2.fromOffset(100, 25),
				Position = UDim2.new(1, -110, 0.5, -12.5),
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				Text = tostring(config.Default),
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 12,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Parent = Dropdown,
				ThemeTag = {
					BackgroundColor3 = "DropdownFrame",
					TextColor3 = "Text"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 4)
				})
			})
			
			-- Simple dropdown functionality (you can expand this)
			local currentIndex = 1
			dropdownButton.MouseButton1Click:Connect(function()
				currentIndex = (currentIndex % #config.Values) + 1
				local newValue = config.Values[currentIndex]
				Library.Options[id].Value = newValue
				dropdownButton.Text = tostring(newValue)
			end)
			
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
			
			-- Add to Options table
			Library.Options[id] = {
				Value = config.Default,
				Type = "Slider"
			}
			
			local Slider = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 18),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.fromOffset(50, 18),
					Position = UDim2.new(1, -55, 0, 5),
					BackgroundTransparency = 1,
					Text = tostring(config.Default),
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 13,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Right,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			if config.Description ~= "" then
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 12),
					Position = UDim2.fromOffset(10, 23),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 11,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = Slider,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			end
			
			-- Slider rail
			local sliderRail = Creator.New("Frame", {
				Size = UDim2.new(1, -20, 0, 4),
				Position = UDim2.fromOffset(10, 40),
				BackgroundColor3 = Color3.fromRGB(60, 60, 60),
				Parent = Slider,
				ThemeTag = {
					BackgroundColor3 = "SliderRail"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(1, 0)
				})
			})
			
			-- Slider handle
			local sliderHandle = Creator.New("Frame", {
				Size = UDim2.fromOffset(12, 12),
				Position = UDim2.new(0, -6, 0.5, -6),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = sliderRail,
				ThemeTag = {
					BackgroundColor3 = "Text"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(1, 0)
				})
			})
			
			local valueLabel = Slider:GetChildren()[3]
			
			-- Slider functionality
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
			
			-- Initial position
			updateSlider(config.Default)
			
			-- Mouse events
			sliderRail.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mouse = UserInputService:GetMouseLocation()
					local railPos = sliderRail.AbsolutePosition
					local railSize = sliderRail.AbsoluteSize
					
					local percentage = math.clamp((mouse.X - railPos.X) / railSize.X, 0, 1)
					local value = config.Min + (config.Max - config.Min) * percentage
					updateSlider(value)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
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
			config.Finished = config.Finished or false
			config.Callback = config.Callback or function() end
			
			-- Add to Options table
			Library.Options[id] = {
				Value = config.Default,
				Type = "Input"
			}
			
			local Input = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(0.4, 0, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(0.4, 0, 0, 15),
					Position = UDim2.fromOffset(10, 20),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			-- Input textbox
			local inputBox = Creator.New("TextBox", {
				Size = UDim2.new(0.5, -10, 0, 25),
				Position = UDim2.new(0.5, 5, 0.5, -12.5),
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				Text = config.Default,
				PlaceholderText = config.Placeholder,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
				TextSize = 12,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Input,
				ThemeTag = {
					BackgroundColor3 = "Input",
					TextColor3 = "Text",
					PlaceholderColor3 = "SubText"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 4)
				}),
				Creator.New("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8)
				})
			})
			
			-- Update value when text changes
			inputBox.FocusLost:Connect(function(enterPressed)
				local text = inputBox.Text
				if config.Numeric then
					text = tonumber(text) or 0
				end
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
			
			-- Add to Options table
			Library.Options[id] = {
				Value = config.Default,
				Type = "Keybind"
			}
			
			local Keybind = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -100, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -100, 0, 15),
					Position = UDim2.fromOffset(10, 20),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			-- Keybind button
			local keybindButton = Creator.New("TextButton", {
				Size = UDim2.fromOffset(80, 25),
				Position = UDim2.new(1, -90, 0.5, -12.5),
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				Text = config.Default.Name,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 11,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Parent = Keybind,
				ThemeTag = {
					BackgroundColor3 = "Keybind",
					TextColor3 = "Text"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 4)
				})
			})
			
			local listening = false
			local currentKey = config.Default
			
			keybindButton.MouseButton1Click:Connect(function()
				if not listening then
					listening = true
					keybindButton.Text = "..."
					
					local connection
					connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
			
			-- Listen for key presses
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
			
			-- Add to Options table
			Library.Options[id] = {
				Value = config.Default,
				Type = "ColorPicker"
			}
			
			local ColorPicker = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 20),
					Position = UDim2.fromOffset(10, 5),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -60, 0, 15),
					Position = UDim2.fromOffset(10, 20),
					BackgroundTransparency = 1,
					Text = config.Description,
					TextColor3 = Color3.fromRGB(170, 170, 170),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			-- Color display button
			local colorButton = Creator.New("TextButton", {
				Size = UDim2.fromOffset(40, 25),
				Position = UDim2.new(1, -50, 0.5, -12.5),
				BackgroundColor3 = config.Default,
				Text = "",
				Parent = ColorPicker
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 4)
				}),
				Creator.New("UIStroke", {
					Color = Color3.fromRGB(100, 100, 100),
					Thickness = 1
				})
			})
			
			-- Simple color cycling (you can expand this to full color picker)
			local colors = {
				Color3.fromRGB(255, 255, 255), -- White
				Color3.fromRGB(255, 0, 0),     -- Red
				Color3.fromRGB(0, 255, 0),     -- Green
				Color3.fromRGB(0, 0, 255),     -- Blue
				Color3.fromRGB(255, 255, 0),   -- Yellow
				Color3.fromRGB(255, 0, 255),   -- Magenta
				Color3.fromRGB(0, 255, 255),   -- Cyan
				Color3.fromRGB(0, 0, 0)        -- Black
			}
			
			local colorIndex = 1
			for i, color in ipairs(colors) do
				if color == config.Default then
					colorIndex = i
					break
				end
			end
			
			colorButton.MouseButton1Click:Connect(function()
				colorIndex = (colorIndex % #colors) + 1
				local newColor = colors[colorIndex]
				colorButton.BackgroundColor3 = newColor
				Library.Options[id].Value = newColor
			end)
			
			return ColorPicker
		end
		
		function Tab:AddSection(title)
			local Section = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = Tab.Content
			}, {
				Creator.New("TextLabel", {
					Size = UDim2.new(1, -20, 1, 0),
					Position = UDim2.fromOffset(10, 0),
					BackgroundTransparency = 1,
					Text = title or "Section",
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 16,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("Frame", {
					Size = UDim2.new(1, -20, 0, 1),
					Position = UDim2.new(0, 10, 1, -1),
					BackgroundColor3 = Color3.fromRGB(60, 60, 60),
					ThemeTag = {
						BackgroundColor3 = "ElementBorder"
					}
				})
			})
			
			return Section
		end
		
		function Tab:AddParagraph(config)
			config = config or {}
			config.Title = config.Title or "Paragraph"
			config.Content = config.Content or "Content"
			
			local Paragraph = Creator.New("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundColor3 = Color3.fromRGB(50, 50, 50),
				Parent = Tab.Content,
				AutomaticSize = Enum.AutomaticSize.Y,
				ThemeTag = {
					BackgroundColor3 = "Element"
				}
			}, {
				Creator.New("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Creator.New("UIPadding", {
					PaddingAll = UDim.new(0, 10)
				}),
				Creator.New("UIListLayout", {
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = config.Title,
					TextColor3 = Color3.fromRGB(240, 240, 240),
					TextSize = 14,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y,
					TextWrapped = true,
					LayoutOrder = 1,
					ThemeTag = {
						TextColor3 = "Text"
					}
				}),
				Creator.New("TextLabel", {
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = config.Content,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextSize = 12,
					FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y,
					TextWrapped = true,
					LayoutOrder = 2,
					ThemeTag = {
						TextColor3 = "SubText"
					}
				})
			})
			
			return Paragraph
		end
		
		Window.Tabs[tabIndex] = Tab
		return Tab
	end
	
	function Window:SelectTab(index)
		for i, tab in pairs(Window.Tabs) do
			if tab.Content then
				tab.Content.Visible = (i == index)
				tab.Active = (i == index)
			end
		end
		Window.SelectedTab = index
	end
	
	function Window:SetTheme(themeName)
		if Themes[themeName] then
			Creator.Theme = themeName
			Creator.UpdateTheme()
		end
	end
	
	function Window:SetTransparency(enabled)
		-- Implement transparency logic here
	end
	
	Library.Window = Window
	return Window
end

-- Notification system
function Library:Notify(config)
	config = config or {}
	config.Title = config.Title or "Notification"
	config.Content = config.Content or ""
	config.Duration = config.Duration or 5
	
	local notification = Creator.New("Frame", {
		Size = UDim2.fromOffset(300, 80),
		Position = UDim2.new(1, -320, 1, -100),
		BackgroundColor3 = Color3.fromRGB(45, 45, 45),
		Parent = GUI,
		ThemeTag = {
			BackgroundColor3 = "Dialog"
		}
	}, {
		Creator.New("UICorner", {
			CornerRadius = UDim.new(0, 8)
		}),
		Creator.New("UIStroke", {
			Color = Color3.fromRGB(70, 70, 70),
			Thickness = 1,
			ThemeTag = {
				Color = "DialogBorder"
			}
		}),
		Creator.New("TextLabel", {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.fromOffset(10, 10),
			BackgroundTransparency = 1,
			Text = config.Title,
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 14,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextXAlignment = Enum.TextXAlignment.Left,
			ThemeTag = {
				TextColor3 = "Text"
			}
		}),
		Creator.New("TextLabel", {
			Size = UDim2.new(1, -20, 0, 40),
			Position = UDim2.fromOffset(10, 35),
			BackgroundTransparency = 1,
			Text = config.Content,
			TextColor3 = Color3.fromRGB(200, 200, 200),
			TextSize = 12,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ThemeTag = {
				TextColor3 = "SubText"
			}
		})
	})
	
	-- Animate in
	notification.Position = UDim2.new(1, 20, 1, -100)
	notification:TweenPosition(UDim2.new(1, -320, 1, -100), "Out", "Quart", 0.3)
	
	-- Auto-hide
	if config.Duration then
		task.wait(config.Duration)
		notification:TweenPosition(UDim2.new(1, 20, 1, -100), "In", "Quart", 0.3)
		task.wait(0.3)
		notification:Destroy()
	end
end

-- Icon system
function Library:GetIcon(name)
	local icons = {
		home = "rbxassetid://10734884548",
		user = "rbxassetid://10734949856", 
		settings = "rbxassetid://10734950309",
		gem = "rbxassetid://10734884548",
		-- Add more icons as needed
	}
	return icons[name] or ""
end

-- Make draggable
local function makeDraggable(frame)
	local dragging = false
	local dragInput, mousePos, framePos
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = frame.Position
		end
	end)
	
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- Apply draggable to windows when created
local originalCreateWindow = Library.CreateWindow
function Library:CreateWindow(config)
	local window = originalCreateWindow(self, config)
	if window and window.Root then
		makeDraggable(window.Root)
	end
	return window
end

-- Handle cleanup
game:GetService("Players").PlayerRemoving:Connect(function(player)
	if player == LocalPlayer then
		for _, connection in pairs(Creator.Signals) do
			if connection.Disconnect then
				connection:Disconnect()
			end
		end
	end
end)

return Library
