-- init
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- services
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new

-- additional
local utility = {}

-- themes
local objects = {}
local themes = {
	Background = Color3.fromRGB(24, 24, 24), 
	Glow = Color3.fromRGB(0, 0, 0), 
	Accent = Color3.fromRGB(10, 10, 10), 
	LightContrast = Color3.fromRGB(20, 20, 20), 
	DarkContrast = Color3.fromRGB(14, 14, 14),  
	TextColor = Color3.fromRGB(255, 255, 255)
}

do
	function utility:create(instance, properties, children)
		local object = Instance.new(instance)

		for i, v in pairs(properties or {}) do
			object[i] = v

			--if typeof(v) == "Color3" then -- save for theme changer later
			--	local theme = utility:Find(themes, v)

			--	if theme then
			--		objects[theme] = objects[theme] or {}
			--		objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})

			--		table.insert(objects[theme][i], object)
			--	end
			--end
		end

		for i, module in pairs(children or {}) do
			module.Parent = object
		end

		return object
	end
	
	function utility:getGameName()
		if (game.GameId == 2459091562) then
			return "RH THE JOURNEY 2"
		end
	end
	
	function utility:ripple(Button, X, Y)
		coroutine.resume(coroutine.create(function()

			Button.ClipsDescendants = true

			local Circle = Instance.new("ImageLabel")
			Circle.Name = "Circle"
			Circle.Parent = nil
			Circle = Circle:Clone()
			Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Circle.BackgroundTransparency = 1.000
			Circle.BorderSizePixel = 0
			Circle.ZIndex = 10
			Circle.Image = "rbxassetid://266543268"
			Circle.ImageColor3 = Color3.fromRGB(147, 147, 147)
			Circle.ImageTransparency = 0.900
			Circle.Parent = Button
			local NewX = X - Circle.AbsolutePosition.X
			local NewY = Y - Circle.AbsolutePosition.Y
			Circle.ZIndex = 50
			Circle.Position = UDim2.new(0, NewX, 0, NewY)

			local Size = 0
			if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
				Size = Button.AbsoluteSize.X*1.5
			elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
				Size = Button.AbsoluteSize.Y*1.5
			elseif Button.AbsoluteSize.X == Button.AbsoluteSize.Y then																																																																														
				Size = Button.AbsoluteSize.X*1.5
			end

			local Time = 0.35
			Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
			for i=1,10 do
				Circle.ImageTransparency = Circle.ImageTransparency + 0.01
				wait(Time/10)
			end
			Circle:Destroy()

		end))
	end

	function utility:Tween(instance, properties, duration, ...)
		tween:Create(instance, tweeninfo(duration, ...), properties):Play()
	end

	function utility:Wait()
		run.RenderStepped:Wait()
		return true
	end

	function utility:Find(table, value) -- table.find doesn't work for dictionaries
		for i, v in  pairs(table) do
			if v == value then
				return i
			end
		end
	end

	function utility:Sort(pattern, values)
		local new = {}
		pattern = pattern:lower()

		if pattern == "" then
			return values
		end

		for i, value in pairs(values) do
			if tostring(value):lower():find(pattern) then
				table.insert(new, value)
			end
		end

		return new
	end

	function utility:Pop(object, shrink)
		local clone = object:Clone()

		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
		clone.Position = UDim2.new(0.5, 0, 0.5, 0)

		clone.Parent = object
		clone:ClearAllChildren()

		object.ImageTransparency = 1
		utility:Tween(clone, {Size = object.Size}, 0.2)

		spawn(function()
			wait(0.2)

			object.ImageTransparency = 0
			clone:Destroy()
		end)

		return clone
	end

	function utility:InitializeKeybind()
		self.keybinds = {}
		self.ended = {}

		input.InputBegan:Connect(function(key)
			if self.keybinds[key.KeyCode] then
				for i, bind in pairs(self.keybinds[key.KeyCode]) do
					bind()
				end
			end
		end)

		input.InputEnded:Connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				for i, callback in pairs(self.ended) do
					callback()
				end
			end
		end)
	end

	function utility:BindToKey(key, callback)

		self.keybinds[key] = self.keybinds[key] or {}

		table.insert(self.keybinds[key], callback)

		return {
			UnBind = function()
				for i, bind in pairs(self.keybinds[key]) do
					if bind == callback then
						table.remove(self.keybinds[key], i)
					end
				end
			end
		}
	end

	function utility:KeyPressed() -- yield until next key is pressed
		local key = input.InputBegan:Wait()

		while key.UserInputType ~= Enum.UserInputType.Keyboard	 do
			key = input.InputBegan:Wait()
		end

		wait() -- overlapping connection

		return key
	end

	function utility:DraggingEnabled(frame, parent)

		parent = parent or frame

		-- stolen from wally or kiriot, kek
		local dragging = false
		local dragInput, mousePos, framePos

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				mousePos = input.Position
				framePos = parent.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		input.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePos
				parent:TweenPosition(UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y), "InOut","Quad",.05,true)
			end
		end)

	end

	function utility:DraggingEnded(callback)
		table.insert(self.ended, callback)
	end

end

-- classes

local library = {} -- main
local page = {}
local section = {}

do
	library.__index = library
	page.__index = page
	section.__index = section

	-- new classes

	function library.new(title)
		local container = utility:create("ScreenGui", {
			Name = title,
			Parent = player.PlayerGui
		}, {
			utility:create("Frame", {
				Name = "Main",
				BackgroundColor3 = Color3.fromRGB(25, 28, 52),
				Size = UDim2.new(.343,0,.633,0),
				BorderSizePixel = 0,
				Position = UDim2.new(.257,0,.252,0),
				ClipsDescendants = true,
			}, {
				utility:create("ImageLabel", {
					Name = "Glow",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -15, 0, -15),
					Size = UDim2.new(1, 30, 1, 30),
					Image = "rbxassetid://5028857084",
					ImageColor3 = themes.Glow,
					ZIndex = 19,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(22, 22, 278, 278)
				}),
				utility:create("UICorner", {
					CornerRadius = UDim.new(0,8)
				}),

				utility:create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = Color3.fromRGB(32, 37, 68),
					LineJoinMode = Enum.LineJoinMode.Round,
					Thickness = 2.5,
					Transparency = 0
				}),

				utility:create("Frame", {
					Name = "Sidebar",
					Position = UDim2.new(0,0,0,0),
					BorderSizePixel = 0,
					Size = UDim2.new(.295,0,1,0),
					BackgroundColor3 = Color3.fromRGB(30, 33, 62)
				}, {
					--utility:create("ImageLabel", { -- pattern
					--	AnchorPoint = Vector2.new(.5,.5),
					--	Position = UDim2.new(.5,0,.5,0),
					--	BackgroundTransparency = 1,
					--	ImageColor3 = Color3.fromRGB(34,38,72),
					--	Image = "rbxassetid://300134974",
					--	Size = UDim2.new(1,0,1,0),
					--	ImageTransparency = .4,
					--}),

					utility:create("TextLabel", {
						Name = "Credits",
						Text = "ALIMO, CJ & MO",
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255,255,255),
						TextScaled = true,
						Font = Enum.Font.GothamSemibold,
						Size = UDim2.new(.573,0,.042,0),
						Position = UDim2.new(.346,0,.069,0),
					}),

					utility:create("TextLabel", {
						Name = "Hub Label",
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = "HUB",
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255,255,255),
						TextScaled = true,
						Font = Enum.Font.GothamSemibold,
						Size = UDim2.new(.251,0,.042,0),
						Position = UDim2.new(.72,0,.027,0),
					}),

					utility:create("TextLabel", {
						Name = "Astro Label",
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = "ASTRO",
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255,255,255),
						TextScaled = true,
						Font = Enum.Font.GothamSemibold,
						Size = UDim2.new(.369,0,.042,0),
						Position = UDim2.new(.346,0,.027,0),
					}),

					utility:create("TextLabel", {
						Name = "Pages Label",
						Text = "PAGES",
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255,255,255),
						TextScaled = true,
						Font = Enum.Font.GothamBold,
						Size = UDim2.new(.695,0,.03,0),
						Position = UDim2.new(.054,0,.179,0),
					}),

					utility:create("UICorner", {
						CornerRadius = UDim.new(0,8)
					}),

					utility:create("Frame", {
						Name = "Coverup Frame",
						Size = UDim2.new(.057,0,1,0),
						Position = UDim2.new(.943,0,0,0),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(30,33,62),
					}),

					utility:create("Frame", {
						Name = "Coverup Frame",
						Size = UDim2.new(.106,0,.006,0),
						Position = UDim2.new(0.05, 0,0.151, 0),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(51, 45, 97),
					}),

					utility:create("Frame", {
						Name = "Coverup Frame",
						Size = UDim2.new(.106,0,.006,0),
						Position = UDim2.new(.05,0,.844,0),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(51, 45, 97),
					}),

					utility:create("Frame", {
						Name = "GameName",
						Size = UDim2.new(.77,0,.052,0),
						Position = UDim2.new(.061,0,.937,0),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(51, 45, 97),
					}, {
						utility:create("UICorner", {
							CornerRadius = UDim.new(0,5)
						}),

						utility:create("UIGradient", {
							Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
						}),

						--utility:create("ImageLabel", {
						--	AnchorPoint = Vector2.new(.5,.5),
						--	Position = UDim2.new(.5,0,.5,0),
						--	BackgroundTransparency = 1,
						--	ImageColor3 = Color3.fromRGB(34,38,72),
						--	Image = "rbxassetid://300134974",
						--	Size = UDim2.new(1,0,1,0),
						--	ImageTransparency = .4,
						--}),

						utility:create("TextLabel", {
							Name = "Label",
							Position = UDim2.new(.07,0,.222,0),
							Size = UDim2.new(.887,0,.533,0),
							TextScaled = true,
							Font = Enum.Font.GothamSemibold,
							TextColor3 = Color3.new(1,1,1),
							Text = utility:getGameName(),
							BackgroundTransparency = 1,
						})
					}),

					utility:create("Frame", {
						Name = "List Layout",
						Size = UDim2.new(.918,0,.723,0),
						Position = UDim2.new(.044,0,.238,0),
						BorderSizePixel = 0,
						BackgroundTransparency = 1,
					}, {
						utility:create("UIListLayout", {
							Padding = UDim.new(0,5),
							SortOrder = Enum.SortOrder.LayoutOrder
						})
					}),

					utility:create("Frame", {
						Name = "MainIcon",
						Size = UDim2.new(.264,0,.096,0),
						BorderSizePixel = 0,
						Position = UDim2.new(.047,0,.028,0),
						BackgroundColor3 = Color3.fromRGB(51, 45, 97),
					}, {
						utility:create("UICorner", {
							CornerRadius = UDim.new(0,5),
						}),

						utility:create("UIGradient", {
							Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
						}),

						--utility:create("ImageLabel", {
						--	Name = "Pattern",
						--	BackgroundTransparency = 1,
						--	Size = UDim2.new(1,0,1,0),
						--	ZIndex = 16,
						--	Position = UDim2.new(.5,0,.5,0),
						--	AnchorPoint = Vector2.new(.5,.5),
						--	Image = "rbxassetid://300134974",
						--	ImageTransparency = 0.8,
						--	ImageColor3 = Color3.fromRGB(30, 33, 62)
						--}),

						utility:create("ImageLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(.718,0,.794,0),
							Position = UDim2.new(.136,0,.096,0),
							Image = "rbxassetid://8382209171"
						})
					}),



					utility:create("Frame", {
						Name = "Timezone",
						Size = UDim2.new(.527,0,.052,0),
						Position = UDim2.new(.054,0,.874,0),
						BorderSizePixel = 0,
						BackgroundColor3 = Color3.fromRGB(51, 45, 97),
					}, {
						utility:create("UICorner", {
							CornerRadius = UDim.new(0,5)
						}),

						utility:create("UIGradient", {
							Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
						}),

						--utility:create("ImageLabel", {
						--	AnchorPoint = Vector2.new(.5,.5),
						--	Position = UDim2.new(.5,0,.5,0),
						--	BackgroundTransparency = 1,
						--	ImageColor3 = Color3.fromRGB(34,38,72),
						--	Image = "rbxassetid://300134974",
						--	Size = UDim2.new(1,0,1,0),
						--	ImageTransparency = .4,
						--}),

						utility:create("TextLabel", {
							Name = "Label",
							Position = UDim2.new(.07,0,.222,0),
							Size = UDim2.new(.887,0,.533,0),
							TextScaled = true,
							Font = Enum.Font.GothamSemibold,
							TextColor3 = Color3.new(1,1,1),
							Text = "EST 12/24/21",
							BackgroundTransparency = 1,
						})
					}),
				})
			}),
		})
		
		utility:InitializeKeybind()
		utility:DraggingEnabled(container.Main)

		return setmetatable({
			container = container,
			pagesContainer = container.Main.Sidebar['List Layout'],
			pages = {},
		}, library)
	end

	function page.new(library, title, icon)
		local button = utility:create("ImageButton", {
			Name = title,
			Parent = library.pagesContainer,
			BackgroundColor3 = Color3.fromRGB(51,45,97),
			AutoButtonColor = false,
			Size = UDim2.new(.996,0,.084,0),
		}, {
			utility:create("UICorner", {
				CornerRadius = UDim.new(0,5)
			}),

			utility:create("UIGradient", {
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			}),

			--utility:create("ImageLabel", {
			--	Name = "Pattern",
			--	ZIndex = 16,
			--	BackgroundTransparency = 1,
			--	Size = UDim2.new(1,0,1,0),
			--	Position = UDim2.new(.5,0,.5,0),
			--	AnchorPoint = Vector2.new(.5,.5),
			--	Image = "rbxassetid://300134974",
			--	ImageTransparency = 0.8,
			--	ImageColor3 = Color3.fromRGB(30, 33, 62)
			--}),

			utility:create("TextLabel", {
				Name = "Label",
				Position = UDim2.new(.07,0,.222,0),
				Size = UDim2.new(.887,0,.533,0),
				TextScaled = true,
				Font = Enum.Font.GothamSemibold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Color3.new(1,1,1),
				Text = title,
				BackgroundTransparency = 1,
			})
		})

		local container = utility:create("Frame", {
			Name = title,
			Parent = library.pagesContainer.Parent.Parent,
			Size = UDim2.new(.671,0,.96,0),
			Position = UDim2.new(.312,0,-1.028,0),
			BackgroundColor3 = Color3.fromRGB(30,33,62),
			Visible = false,
		}, {
			utility:create("UICorner", {
				CornerRadius = UDim.new(0,8),
			}),

			utility:create("UIStroke", {
				Color = Color3.fromRGB(32,37,68),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
				Thickness = 2.5,
			}),

			utility:create("ScrollingFrame", {
				Name = "SectionHolder",
				Size = UDim2.new(1,0,.886,0),
				Position = UDim2.new(0,0,.126,0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 3,
			}, {
				utility:create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8)
				}),
			}),

			utility:create("Frame", {
				Name = "SearchIcon",
				BackgroundColor3 = Color3.fromRGB(51, 45, 97),
				Size = UDim2.new(.09,0,.071,0),
				Position = UDim2.new(.019,0,.021,0),
				ZIndex = 7,
			}, {
				utility:create("UICorner", {
					CornerRadius = UDim.new(0,5),
				}),

				utility:create("UIGradient", {
					Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
				}),

				--utility:create("ImageLabel", { -- pattern
				--	AnchorPoint = Vector2.new(.5,.5),
				--	Position = UDim2.new(.5,0,.5,0),
				--	ZIndex = 16,
				--	BackgroundTransparency = 1,
				--	ImageColor3 = Color3.fromRGB(34,38,72),
				--	Image = "rbxassetid://300134974",
				--	Size = UDim2.new(1,0,1,0),
				--	ImageTransparency = .4,
				--}),

				utility:create("ImageLabel", {
					AnchorPoint = Vector2.new(.5,.5),
					Position = UDim2.new(.5,0,.5,0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://8403605400",
					Size = UDim2.new(1,0,1,0),
					ZIndex = 8,
				})						
			}),

			utility:create("Frame", {
				Name = "Searchbar",
				BackgroundColor3 = Color3.fromRGB(51, 45, 97),
				Size = UDim2.new(.829,0,.07,0),
				Position = UDim2.new(.147,0,.021,0),
				ZIndex = 5,
			}, {
				utility:create("UICorner", {
					CornerRadius = UDim.new(0,5),
				}),

				utility:create("UIGradient", {
					Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
				}),

				--utility:create("ImageLabel", { -- pattern
				--	AnchorPoint = Vector2.new(.5,.5),
				--	Position = UDim2.new(.5,0,.5,0),
				--	BackgroundTransparency = 1,
				--	ImageColor3 = Color3.fromRGB(34,38,72),
				--	Image = "rbxassetid://300134974",
				--	Size = UDim2.new(1,0,1,0),
				--	ImageTransparency = .4,
				--	ZIndex = 6,
				--}),

				utility:create("TextBox", {
					PlaceholderText = "Type To Search...",
					PlaceholderColor3 = Color3.fromRGB(255,255,255),
					TextScaled = true,
					TextColor3 = Color3.new(1,1,1),
					ZIndex = 6,
					Font = Enum.Font.GothamSemibold,
					Size = UDim2.new(.974,0,.443,0),
					Position = UDim2.new(.506,0,.5,0),
					AnchorPoint = Vector2.new(.5,.5),
					Name = "Searchbox",
					CursorPosition = 1,
					Text = "",
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1
				})
			})
		})

		container.Searchbar.Searchbox:GetPropertyChangedSignal("Text"):Connect(function()
			local newText = container.Searchbar.Searchbox.Text
			local sections = container.SectionHolder:GetChildren()
			local found = {}
			local foundSections = {}

			if (newText == "") then
				for i,v in pairs (sections) do
					if not (v:IsA("UIListLayout")) then
						v.Visible = true
						for _, newObject in pairs (v.Container:GetChildren()) do
							if not (newObject:IsA("UIListLayout")) then
								newObject.Visible = true
							end
						end
					end
				end

				return
			end

			for i, v in pairs (sections) do
				if (v:IsA("Frame")) then
					local container = v.Container
					for _, newObject in pairs (container:GetChildren()) do
						if (newObject:IsA("ImageButton")) then
							newObject.Visible = false
							if (newObject.Name:lower():match(newText:lower())) then
								table.insert(found, {
									object = newObject,
									section = v
								})
								newObject.Visible = true
							elseif (newObject.Name == 'Title') then
								newObject.Visible = true
							end
						end
					end
				end
			end

			for i,v in pairs (found) do
				local section = v.section
				if (foundSections[section.Name] == nil) then
					foundSections[section.Name] = 1
				else
					foundSections[section.Name] += 1
				end
			end

			for i,v in pairs (sections) do
				if (foundSections[v.Name] == nil and v:IsA("Frame")) then
					v.Visible = false
				end
			end
		end)

		return setmetatable({
			library = library,
			container = container.SectionHolder,
			button = button,
			sections = {}
		}, page)
	end

	function section.new(page, title)
		local container = utility:create("Frame", {
			Name = title,
			Parent = page.container,
			Size = UDim2.new(1, -10, 0, 28),
			ZIndex = 9,
			BackgroundColor3 = Color3.fromRGB(51, 45, 97),
			BackgroundTransparency = 1,
			ClipsDescendants = true
		}, {
			utility:create("Frame", {
				Name = "Container",
				Active = true,
				ZIndex = 10,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 8, 0, 8),
				Size = UDim2.new(1, -16, 1, -16)
			}, {
				utility:create("TextLabel", {
					Name = "Title",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 11,
					Font = Enum.Font.GothamSemibold,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, {
					utility:create("Frame", {
						BorderSizePixel = 0,
						Size = UDim2.new(.07,0,.1,0),
						Position = UDim2.new(0,0,.8,0),
						BackgroundColor3 = Color3.new(1,1,1),
						ZIndex = 50,
					})
				}),
				utility:create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4)
				})
			})
		})

		return setmetatable({
			page = page,
			container = container.Container,
			colorpickers = {},
			modules = {},
			binds = {},
			lists = {},
		}, section) 
	end

	function library:addPage(...)
		
		if (#self.pages > 8) then 
			warn ("Too many pages!")
			return 
		end
		
		local page = page.new(self, ...)
		local button = page.button

		table.insert(self.pages, page)

		button.MouseButton1Click:Connect(function()
			utility:ripple(button, mouse.X, mouse.Y)
			self:SelectPage(page, true)
		end)

		return page
	end

	function page:addSection(...)
		local section = section.new(self, ...)

		table.insert(self.sections, section)

		return section
	end

	-- functions

	function library:setTheme(theme, color3)
		themes[theme] = color3

		for property, objects in pairs(objects[theme]) do
			for i, object in pairs(objects) do
				if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
					objects[i] = nil -- i can do this because weak tables :D
				else
					object[property] = color3
				end
			end
		end
	end

	function library:toggle()

		if self.toggling then
			return
		end

		self.toggling = true

		local container = self.container.Main
		local topbar = container.TopBar

		if self.position then
			utility:Tween(container, {
				Size = UDim2.new(0, 511, 0, 428),
				Position = self.position
			}, 0.2)
			wait(0.2)

			utility:Tween(topbar, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
			wait(0.2)

			container.ClipsDescendants = false
			self.position = nil
		else
			self.position = container.Position
			container.ClipsDescendants = true

			utility:Tween(topbar, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
			wait(0.2)

			utility:Tween(container, {
				Size = UDim2.new(0, 511, 0, 0),
				Position = self.position + UDim2.new(0, 0, 0, 428)
			}, 0.2)
			wait(0.2)
		end

		self.toggling = false
	end

	-- new modules

	function library:Notify(title, text, callback)

		-- overwrite last notification
		if self.activeNotification then
			self.activeNotification = self.activeNotification()
		end

		-- standard create
		local notification = utility:create("ImageLabel", {
			Name = "Notification",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 200, 0, 60),
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.Background,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(4, 4, 296, 296),
			ZIndex = 3,
			ClipsDescendants = true
		}, {
			utility:create("ImageLabel", {
				Name = "Flash",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://4641149554",
				ImageColor3 = themes.TextColor,
				ZIndex = 5
			}),
			utility:create("ImageLabel", {
				Name = "Glow",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, -15, 0, -15),
				Size = UDim2.new(1, 30, 1, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857084",
				ImageColor3 = themes.Glow,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(24, 24, 276, 276)
			}),
			utility:create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.GothamSemibold,
				TextColor3 = themes.TextColor,
				TextSize = 14.000,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:create("TextLabel", {
				Name = "Text",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 1, -24),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 4,
				Font = Enum.Font.Gotham,
				TextColor3 = themes.TextColor,
				TextSize = 12.000,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:create("ImageButton", {
				AutoButtonColor = false,
				Name = "Accept",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538259",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			}),
			utility:create("ImageButton", {
				AutoButtonColor = false,
				Name = "Decline",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 1, -24),
				Size = UDim2.new(0, 16, 0, 16),
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor,
				ZIndex = 4
			})
		})

		-- dragging
		utility:DraggingEnabled(notification)

		-- position and size
		title = title or "Notification"
		text = text or ""

		notification.Title.Text = title
		notification.Text.Text = text

		local padding = 10
		local textSize = game:GetService("TextService"):GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

		notification.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
		notification.Size = UDim2.new(0, 0, 0, 60)

		utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
		wait(0.2)

		notification.ClipsDescendants = false
		utility:Tween(notification.Flash, {
			Size = UDim2.new(0, 0, 0, 60),
			Position = UDim2.new(1, 0, 0, 0)
		}, 0.2)

		-- callbacks
		local active = true
		local close = function()

			if not active then
				return
			end

			active = false
			notification.ClipsDescendants = true

			library.lastNotification = notification.Position
			notification.Flash.Position = UDim2.new(0, 0, 0, 0)
			utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)

			wait(0.2)
			utility:Tween(notification, {
				Size = UDim2.new(0, 0, 0, 60),
				Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)
			}, 0.2)

			wait(0.2)
			notification:Destroy()
		end

		self.activeNotification = close

		notification.Accept.MouseButton1Click:Connect(function()

			if not active then 
				return
			end

			if callback then
				callback(true)
			end

			close()
		end)

		notification.Decline.MouseButton1Click:Connect(function()

			if not active then 
				return
			end

			if callback then
				callback(false)
			end

			close()
		end)
	end

	function section:addButton(title, callback)
		local button = utility:create("ImageButton", {
			AutoButtonColor = false,
			Name = title,
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 15,
			Image = "rbxassetid://5028857472",
			ImageColor3 = Color3.fromRGB(51, 45, 97),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:create("UIGradient", {
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
			}),

			utility:create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Text = title,
				ZIndex = 18,
				TextColor3 = Color3.new(1,1,1),
				Font = Enum.Font.GothamSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(.475,0,.45,0),
				Position = UDim2.new(.028,0,.261,0),
			}),

			--utility:create("ImageLabel", { -- pattern
			--	AnchorPoint = Vector2.new(.5,.5),
			--	Position = UDim2.new(.5,0,.5,0),
			--	BackgroundTransparency = 1,
			--	ZIndex = 16,
			--	ImageColor3 = Color3.fromRGB(34,38,72),
			--	Image = "rbxassetid://300134974",
			--	Size = UDim2.new(1,0,1,0),
			--	ImageTransparency = .4,
			--}),

			utility:create("ImageLabel", {
				Name = "ClickIcon",
				BackgroundTransparency = 1,
				ImageColor3 = Color3.fromRGB(120, 140, 255),
				Image = "rbxassetid://8386925406",
				ZIndex = 18,
				Size = UDim2.new(.072,0,.674,0),
				Position = UDim2.new(.873,0,.157,0),
			})
		})

		table.insert(self.modules, button)
		self:Resize()

		local text = button.Title
		local debounce

		button.MouseButton1Click:Connect(function()

			if debounce then
				return
			end

			-- animation
			--utility:Pop(button, 10)

			--debounce = true
			--text.TextSize = 0
			--utility:Tween(button.Title, {TextSize = 14}, 0.2)

			--wait(0.2)
			--utility:Tween(button.Title, {TextSize = 12}, 0.2)

			utility:ripple(button, mouse.X, mouse.Y)

			if callback then
				callback(function(...)
					self:updateButton(button, ...)
				end)
			end

			debounce = false
		end)

		return button
	end

	function section:addToggle(title, default, callback)
		local toggle = utility:create("ImageButton", {
			AutoButtonColor = false,
			Name = title,
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 15,
			Image = "rbxassetid://5028857472",
			ImageColor3 = Color3.fromRGB(51, 45, 97),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:create("UIGradient", {
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
			}),

			--utility:create("ImageLabel", { -- pattern
			--	AnchorPoint = Vector2.new(.5,.5),
			--	Position = UDim2.new(.5,0,.5,0),
			--	BackgroundTransparency = 1,
			--	ZIndex = 16,
			--	ImageColor3 = Color3.fromRGB(34,38,72),
			--	Image = "rbxassetid://300134974",
			--	Size = UDim2.new(1,0,1,0),
			--	ImageTransparency = .4,
			--}),

			utility:create("ImageButton", {
				AutoButtonColor = false,
				Name = "Switch",
				Size = UDim2.new(.173,0,.688,0),
				BackgroundColor3 = Color3.fromRGB(32,37,68),
				Image = "",
				ZIndex = 16,
				Position = UDim2.new(.789,0,.142,0),
			}, {
				utility:create("UICorner", {
					CornerRadius = UDim.new(0,100),
				}),

				utility:create("UIGradient", {
					Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(194, 187, 226)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(225, 222, 241)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
				})
			}),

			utility:create("ImageButton", {
				AutoButtonColor = false,
				Name = "Toggle",
				Image = "",
				ZIndex = 17,
				Size = UDim2.new(.071,0,.445,0),
				Position = UDim2.new(.804,0,.27,0),
				BackgroundColor3 = Color3.fromRGB(255,255,255),
			}, {
				utility:create("UICorner", {
					CornerRadius = UDim.new(0,100)
				})
			}),

			utility:create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Text = title,
				ZIndex = 18,
				TextColor3 = Color3.new(1,1,1),
				Font = Enum.Font.GothamSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(.475,0,.45,0),
				Position = UDim2.new(.028,0,.261,0),
			})
		})

		table.insert(self.modules, toggle)
		self:Resize()

		local active = default
		self:updateToggle(toggle, nil, active)

		toggle.MouseButton1Click:Connect(function()
			active = not active
			self:updateToggle(toggle, nil, active)
			utility:ripple(toggle, mouse.X, mouse.Y)

			if callback then
				callback(active, function(...)
					self:updateToggle(toggle, ...)
				end)
			end
		end)

		toggle.Switch.MouseButton1Click:Connect(function()
			active = not active
			self:updateToggle(toggle, nil, active)

			if callback then
				callback(active, function(...)
					self:updateToggle(toggle, ...)
				end)
			end
		end)

		toggle.Toggle.MouseButton1Click:Connect(function()
			active = not active
			self:updateToggle(toggle, nil, active)

			if callback then
				callback(active, function(...)
					self:updateToggle(toggle, ...)
				end)
			end
		end)

		return toggle
	end

	function section:addTextbox(title, default, callback)
		local textbox = utility:create("ImageButton", {
			AutoButtonColor = false,
			Name = "Textbox",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:create("TextBox", {
					Name = "Textbox", 
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 5, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = default or "",
					TextColor3 = themes.TextColor,
					TextSize = 11
				})
			})
		})

		table.insert(self.modules, textbox)
		--self:Resize()

		local button = textbox.Button
		local input = button.Textbox

		textbox.MouseButton1Click:Connect(function()

			if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then
				return
			end

			utility:Tween(textbox.Button, {
				Size = UDim2.new(0, 200, 0, 16),
				Position = UDim2.new(1, -210, 0.5, -8)
			}, 0.2)

			wait()

			input.TextXAlignment = Enum.TextXAlignment.Left
			input:CaptureFocus()
		end)

		input:GetPropertyChangedSignal("Text"):Connect(function()

			if button.ImageTransparency == 0 and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then -- i know, i dont like this either
				utility:Pop(button, 10)
			end

			if callback then
				callback(input.Text, nil, function(...)
					self:updateTextbox(textbox, ...)
				end)
			end
		end)

		input.FocusLost:Connect(function()

			input.TextXAlignment = Enum.TextXAlignment.Center

			utility:Tween(textbox.Button, {
				Size = UDim2.new(0, 100, 0, 16),
				Position = UDim2.new(1, -110, 0.5, -8)
			}, 0.2)

			if callback then
				callback(input.Text, true, function(...)
					self:updateTextbox(textbox, ...)
				end)
			end
		end)

		return textbox
	end

	function section:addKeybind(title, default, callback, changedCallback)
		local keybind = utility:create("ImageButton", {
			AutoButtonColor = false,
			Name = "Keybind",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			Image = "rbxassetid://5028857472",
			ImageColor3 = themes.DarkContrast,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:create("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.Gotham,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 12,
				TextTransparency = 0.10000000149012,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:create("ImageLabel", {
				Name = "Button",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.LightContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:create("TextLabel", {
					Name = "Text",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = default and default.Name or "None",
					TextColor3 = themes.TextColor,
					TextSize = 11
				})
			})
		})

		table.insert(self.modules, keybind)
		--self:Resize()

		local text = keybind.Button.Text
		local button = keybind.Button

		local animate = function()
			if button.ImageTransparency == 0 then
				utility:Pop(button, 10)
			end
		end

		self.binds[keybind] = {callback = function()
			animate()

			if callback then
				callback(function(...)
					self:updateKeybind(keybind, ...)
				end)
			end
		end}

		if default and callback then
			self:updateKeybind(keybind, nil, default)
		end

		keybind.MouseButton1Click:Connect(function()

			animate()

			if self.binds[keybind].connection then -- unbind
				return self:updateKeybind(keybind)
			end

			if text.Text == "None" then -- new bind
				text.Text = "..."

				local key = utility:KeyPressed()

				self:updateKeybind(keybind, nil, key.KeyCode)
				animate()

				if changedCallback then
					changedCallback(key, function(...)
						self:updateKeybind(keybind, ...)
					end)
				end
			end
		end)

		return keybind
	end

	function section:addColorPicker(title, default, callback)
		local colorpicker = utility:create("ImageButton", {
			AutoButtonColor = false,
			Name = "ColorPicker",
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 15,
			Image = "rbxassetid://5028857472",
			ImageColor3 = Color3.fromRGB(51, 45, 97),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		},{
			utility:create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Text = title,
				ZIndex = 18,
				AnchorPoint = Vector2.new(0,.5),
				TextColor3 = Color3.new(1,1,1),
				Font = Enum.Font.GothamSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(.45,0,.5,0),
				Position = UDim2.new(.02,0,.5,0),
			}),
			utility:create("UIGradient", {
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
			}),
			utility:create("ImageButton", {
				AutoButtonColor = false,
				Name = "Button",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -50, 0.5, -7),
				Size = UDim2.new(0, 40, 0, 14),
				ZIndex = 18,
				Image = "rbxassetid://5028857472",
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			})
		})

		local tab = utility:create("ImageLabel", {
			Name = "ColorPicker",
			Parent = self.page.library.container,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.75, 0, 0.400000006, 0),
			Selectable = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 162, 0, 169),
			Image = "rbxassetid://5028857472",
			ZIndex = 18,
			ImageColor3 = Color3.fromRGB(25, 28, 52),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298),
			Visible = false,
		}, {
			utility:create("ImageLabel", {
				Name = "Glow",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, -15, 0, -15),
				Size = UDim2.new(1, 30, 1, 30),
				Image = "rbxassetid://5028857084",
				ImageColor3 = themes.Glow,
				ZIndex = 19,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(22, 22, 278, 278)
			}),
			utility:create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0, 8),
				Size = UDim2.new(1, -40, 0, 16),
				ZIndex = 19,
				Font = Enum.Font.GothamSemibold,
				Text = title,
				TextColor3 = themes.TextColor,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			utility:create("ImageButton", {
				AutoButtonColor = false,
				Name = "Close",
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -26, 0, 8),
				Size = UDim2.new(0, 16, 0, 16),
				ZIndex = 19,
				Image = "rbxassetid://5012538583",
				ImageColor3 = themes.TextColor
			}), 
			utility:create("Frame", {
				Name = "Container",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 8, 0, 32),
				Size = UDim2.new(1, -18, 1, -40),
				ZIndex = 19,
			}, {
				utility:create("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6)
				}),
				utility:create("ImageButton", {
					Name = "Canvas",
					BackgroundTransparency = 1,
					ZIndex = 20,
					BorderColor3 = themes.LightContrast,
					Size = UDim2.new(1, 0, 0, 60),
					AutoButtonColor = false,
					Image = "rbxassetid://5108535320",
					ImageColor3 = Color3.fromRGB(255, 0, 0),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:create("ImageLabel", {
						Name = "White_Overlay",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 60),
						ZIndex = 20,
						Image = "rbxassetid://5107152351",
						SliceCenter = Rect.new(2, 2, 298, 298)
					}),
					utility:create("ImageLabel", {
						Name = "Black_Overlay",
						BackgroundTransparency = 1,
						ZIndex = 20,
						Size = UDim2.new(1, 0, 0, 60),
						Image = "rbxassetid://5107152095",
						SliceCenter = Rect.new(2, 2, 298, 298)
					}),
					utility:create("ImageLabel", {
						Name = "Cursor",
						BackgroundColor3 = themes.TextColor,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1.000,
						Size = UDim2.new(0, 10, 0, 10),
						ZIndex = 20,
						Position = UDim2.new(0, 0, 0, 0),
						Image = "rbxassetid://5100115962",
						SliceCenter = Rect.new(2, 2, 298, 298)
					})
				}),
				utility:create("ImageButton", {
					Name = "Color",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 0, 4),
					Selectable = false,
					Size = UDim2.new(1, 0, 0, 16),
					ZIndex = 19,
					AutoButtonColor = false,
					Image = "rbxassetid://5028857472",
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:create("Frame", {
						Name = "Select",
						BackgroundColor3 = themes.TextColor,
						BorderSizePixel = 1,
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.new(0, 2, 1, 0),
						ZIndex = 20
					}),
					utility:create("UIGradient", { -- rainbow canvas
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), 
							ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), 
							ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), 
							ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), 
							ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), 
							ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)), 
							ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
						})
					})
				}),
				utility:create("Frame", {
					Name = "Inputs",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 158),
					Size = UDim2.new(1, 0, 0, 16),
					ZIndex = 19,
				}, {
					utility:create("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 6)
					}),
					utility:create("ImageLabel", {
						Name = "R",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 20,
						Image = "rbxassetid://5028857472",
						ImageColor3 = Color3.fromRGB(51, 45, 97),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							ZIndex = 20,
							Font = Enum.Font.Gotham,
							Text = "R:",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						}),
						utility:create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 20,
							Font = Enum.Font.Gotham,
							PlaceholderColor3 = themes.DarkContrast,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						})
					}),
					utility:create("ImageLabel", {
						Name = "G",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 19,
						Image = "rbxassetid://5028857472",
						ImageColor3 = Color3.fromRGB(51, 45, 97),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							ZIndex = 20,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							Font = Enum.Font.Gotham,
							Text = "G:",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						}),
						utility:create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 20,
							Font = Enum.Font.Gotham,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						})
					}),
					utility:create("ImageLabel", {
						Name = "B",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.new(0.305, 0, 1, 0),
						ZIndex = 19,
						Image = "rbxassetid://5028857472",
						ImageColor3 = Color3.fromRGB(51, 45, 97),
						ScaleType = Enum.ScaleType.Slice,
						SliceCenter = Rect.new(2, 2, 298, 298)
					}, {
						utility:create("TextLabel", {
							Name = "Text",
							BackgroundTransparency = 1,
							Size = UDim2.new(0.400000006, 0, 1, 0),
							ZIndex = 20,
							Font = Enum.Font.Gotham,
							Text = "B:",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						}),
						utility:create("TextBox", {
							Name = "Textbox",
							BackgroundTransparency = 1,
							Position = UDim2.new(0.300000012, 0, 0, 0),
							Size = UDim2.new(0.600000024, 0, 1, 0),
							ZIndex = 20,
							Font = Enum.Font.Gotham,
							Text = "255",
							TextColor3 = themes.TextColor,
							TextSize = 10.000
						})
					}),
				}),
				utility:create("ImageButton", {
					AutoButtonColor = false,
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 20),
					ZIndex = 19,
					Image = "rbxassetid://5028857472",
					ImageColor3 = Color3.fromRGB(51, 45, 97),
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(2, 2, 298, 298)
				}, {
					utility:create("TextLabel", {
						Name = "Text",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 21,
						Font = Enum.Font.Gotham,
						Text = "Submit",
						TextColor3 = themes.TextColor,
						TextSize = 11.000
					})
				})
			})
		})

		--utility:DraggingEnabled(tab)
		table.insert(self.modules, colorpicker)
		self:Resize()

		local allowed = {
			[""] = true
		}

		local canvas = tab.Container.Canvas
		local color = tab.Container.Color

		local canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
		local colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition

		local draggingColor, draggingCanvas

		local color3 = default or Color3.fromRGB(255, 255, 255)
		local hue, sat, brightness = 0, 0, 1
		local rgb = {
			r = 255,
			g = 255,
			b = 255
		}

		self.colorpickers[colorpicker] = {
			tab = tab,
			callback = function(prop, value)
				rgb[prop] = value
				hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
			end
		}

		local callback = function(value)
			if callback then
				callback(value, function(...)
					self:updateColorPicker(colorpicker, ...)
				end)
			end
		end

		utility:DraggingEnded(function()
			draggingColor, draggingCanvas = false, false
		end)

		if default then
			self:updateColorPicker(colorpicker, nil, default)

			hue, sat, brightness = Color3.toHSV(default)
			default = Color3.fromHSV(hue, sat, brightness)

			for i, prop in pairs({"r", "g", "b"}) do
				rgb[prop] = default[prop:upper()] * 255
			end
		end

		for i, container in pairs(tab.Container.Inputs:GetChildren()) do -- i know what you are about to say, so shut up
			if container:IsA("ImageLabel") then
				local textbox = container.Textbox
				local focused

				textbox.Focused:Connect(function()
					focused = true
				end)

				textbox.FocusLost:Connect(function()
					focused = false

					if not tonumber(textbox.Text) then
						textbox.Text = math.floor(rgb[container.Name:lower()])
					end
				end)

				textbox:GetPropertyChangedSignal("Text"):Connect(function()
					local text = textbox.Text

					if not allowed[text] and not tonumber(text) then
						textbox.Text = text:sub(1, #text - 1)
					elseif focused and not allowed[text] then
						rgb[container.Name:lower()] = math.clamp(tonumber(textbox.Text), 0, 255)

						local color3 = Color3.fromRGB(rgb.r, rgb.g, rgb.b)
						hue, sat, brightness = Color3.toHSV(color3)

						self:updateColorPicker(colorpicker, nil, color3)
						callback(color3)
					end
				end)
			end
		end

		canvas.MouseButton1Down:Connect(function()
			draggingCanvas = true

			while draggingCanvas do

				local x, y = mouse.X, mouse.Y

				sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
				brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)

				color3 = Color3.fromHSV(hue, sat, brightness)

				for i, prop in pairs({"r", "g", "b"}) do
					rgb[prop] = color3[prop:upper()] * 255
				end

				self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
				utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1) -- overwrite

				callback(color3)
				utility:Wait()
			end
		end)

		color.MouseButton1Down:Connect(function()
			draggingColor = true

			while draggingColor do

				hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
				color3 = Color3.fromHSV(hue, sat, brightness)

				for i, prop in pairs({"r", "g", "b"}) do
					rgb[prop] = color3[prop:upper()] * 255
				end

				local x = hue -- hue is updated
				self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
				utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1) -- overwrite

				callback(color3)
				utility:Wait()
			end
		end)

		-- click events
		local button = colorpicker.Button
		local toggle, debounce, animate

		lastColor = Color3.fromHSV(hue, sat, brightness)
		animate = function(visible, overwrite)

			if overwrite then

				if not toggle then
					return
				end

				if debounce then
					while debounce do
						utility:Wait()
					end
				end
			elseif not overwrite then
				if debounce then 
					return 
				end

				if button.ImageTransparency == 0 then
					--utility:Pop(button, 10)
				end
			end
 
			toggle = visible
			debounce = true

			if visible then

				if self.page.library.activePicker and self.page.library.activePicker ~= animate then
					self.page.library.activePicker(nil, true)
				end

				self.page.library.activePicker = animate
				lastColor = Color3.fromHSV(hue, sat, brightness)

				local x1, x2 = button.AbsoluteSize.X / 2, 162--tab.AbsoluteSize.X
				local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y

				tab.ClipsDescendants = true
				tab.Visible = true
				tab.Size = UDim2.new(0, 0, 0, 0)

				tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
				utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0)

				-- update size and position
				wait(0.2)
				tab.ClipsDescendants = false

				canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
				colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
			else
				utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0)
				tab.ClipsDescendants = true

				wait(0.2)
				tab.Visible = false
			end

			debounce = false
		end

		local toggleTab = function()
			animate(not toggle)
		end

		button.MouseButton1Click:Connect(toggleTab)
		colorpicker.MouseButton1Click:Connect(toggleTab)

		tab.Container.Button.MouseButton1Click:Connect(function()
			animate()
		end)

		tab.Close.MouseButton1Click:Connect(function()
			self:updateColorPicker(colorpicker, nil, lastColor)
			animate()
		end)

		return colorpicker
	end

	function section:addSlider(title, default, min, max, callback)
		local slider = utility:create("ImageButton", {
			AutoButtonColor = false,
			Name = title,
			Parent = self.container,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
			Size = UDim2.new(1, 0, 0, 50),
			ZIndex = 17,
			Image = "rbxassetid://5028857472",
			ImageColor3 = Color3.fromRGB(51, 45, 97),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(2, 2, 298, 298)
		}, {
			utility:create("UIGradient", {
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(214, 202, 239)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(235, 229, 247)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}
			}),
			utility:create("TextBox", {
				Size = UDim2.new(.087,0,.322,0),
				Position = UDim2.new(.888,0,.084,0),
				BackgroundTransparency = 1,
				Text = "50",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.GothamBold,
				Name = "Amount",
				TextScaled = true,
				ZIndex = 18,
			}),
			utility:create("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Text = title,
				ZIndex = 18,
				TextColor3 = Color3.new(1,1,1),
				Font = Enum.Font.GothamSemibold,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1,0,.28,0),
				Position = UDim2.new(.028,0,.15,0),
			}),
			utility:create("ImageButton", {
				Name = "Slider",
				Size = UDim2.new(.923,0,.223,0),
				Position = UDim2.new(.028,0,.608,0),
				BackgroundColor3 = Color3.fromRGB(25, 28, 52),
				BorderSizePixel = 0,
				ZIndex = 18,
				AutoButtonColor = false,
			}, {
				utility:create("UICorner", {
					CornerRadius = UDim.new(0,100)
				}),
				utility:create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
					Color = Color3.fromRGB(32,37,68),
					LineJoinMode = Enum.LineJoinMode.Round,
					Thickness =  4.2
				}),
				utility:create("ImageButton", {
					Size = UDim2.new(.5,0,1,0),
					BackgroundColor3 = Color3.fromRGB(120, 140, 255),
					AutoButtonColor = false,
					ZIndex = 18,
					Name = "Fill",	
				}, {
					utility:create("UICorner", {
						CornerRadius = UDim.new(1,0)
					}),
				})
			})
		})
		
		table.insert(self.modules, slider)
		self:Resize()
		
		local textbox = slider.Amount

		local allowed = {
			[""] = true,
			["-"] = true
		}

		local value = default or min
		local dragging, last

		local callback = function(value)
			if callback then
				callback(value, function(...)
					self:updateSlider(slider.Slider, ...)
				end)
			end
		end

		self:updateSlider(slider.Slider, nil, value, min, max)

		utility:DraggingEnded(function()
			dragging = false
		end)

		slider.Slider.MouseButton1Down:Connect(function(input)
			dragging = true

			while dragging do

				value = self:updateSlider(slider.Slider, nil, nil, min, max, value)
				callback(value)

				utility:Wait()
			end
		end)


		slider.Slider.Fill.MouseButton1Down:Connect(function(input)
			dragging = true

			while dragging do

				value = self:updateSlider(slider.Slider, nil, nil, min, max, value)
				callback(value)

				utility:Wait()
			end
		end)

		textbox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = textbox.Text

			if not allowed[text] and not tonumber(text) then
				textbox.Text = text:sub(1, #text - 1)
			elseif not allowed[text] then	
				value = self:updateSlider(slider.Slider, nil, tonumber(text) or value, min, max)
				callback(value)
			end
		end)

		return slider
	end

	function section:addDropdown(title, list, callback)
		local dropdown = utility:create("Frame", {
			Name = "Dropdown",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true
		}, {
			utility:create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4)
			}),
			utility:create("ImageLabel", {
				Name = "Search",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:create("TextBox", {
					Name = "TextBox",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Position = UDim2.new(0, 10, 0.5, 1),
					Size = UDim2.new(1, -42, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = title,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextTransparency = 0.10000000149012,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				utility:create("ImageButton", {
					AutoButtonColor = false,
					Name = "Button",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -28, 0.5, -9),
					Size = UDim2.new(0, 18, 0, 18),
					ZIndex = 3,
					Image = "rbxassetid://5012539403",
					ImageColor3 = themes.TextColor,
					SliceCenter = Rect.new(2, 2, 298, 298)
				})
			}),
			utility:create("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.Background,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:create("ScrollingFrame", {
					Name = "Frame",
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 4, 0, 4),
					Size = UDim2.new(1, -8, 1, -8),
					CanvasPosition = Vector2.new(0, 28),
					CanvasSize = UDim2.new(0, 0, 0, 120),
					ZIndex = 2,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = themes.DarkContrast
				}, {
					utility:create("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4)
					})
				})
			})
		})

		table.insert(self.modules, dropdown)
		--self:Resize()

		local search = dropdown.Search
		local focused

		list = list or {}

		search.Button.MouseButton1Click:Connect(function()
			if search.Button.Rotation == 0 then
				self:updateDropdown(dropdown, nil, list, callback)
			else
				self:updateDropdown(dropdown, nil, nil, callback)
			end
		end)

		search.TextBox.Focused:Connect(function()
			if search.Button.Rotation == 0 then
				self:updateDropdown(dropdown, nil, list, callback)
			end

			focused = true
		end)

		search.TextBox.FocusLost:Connect(function()
			focused = false
		end)

		search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local list = utility:Sort(search.TextBox.Text, list)
				list = #list ~= 0 and list 

				self:updateDropdown(dropdown, nil, list, callback)
			end
		end)

		dropdown:GetPropertyChangedSignal("Size"):Connect(function()
			self:Resize()
		end)

		return dropdown
	end

	-- class functions

	function library:SelectPage(page, toggle)

		local button = page.button
		local page = page.container.Parent
		local currentPage = self.focusedPage

		if (currentPage == page) then return end

		if (currentPage) then
			self.focusedPage = page
			page.Visible = true
			currentPage:TweenPosition(UDim2.new(.312,0,1.028,0),'InOut','Quad',.3,true)
			page:TweenPosition(UDim2.new(.312,0,.028,0),'InOut','Quad',.3,true)
			wait (.3)
			currentPage.Position = UDim2.new(.312,0,-1.028,0)
		else
			page.Visible = true
			page:TweenPosition(UDim2.new(.312,0,.028,0),'InOut','Quad',.3,true)
			self.focusedPage = page
		end
	end

	function page:Resize(scroll)
		local padding = 10
		local size = 0

		for i, section in pairs(self.sections) do
			size = size + section.container.Parent.AbsoluteSize.Y + padding
		end

		self.container.CanvasSize = UDim2.new(0, 0, 0, size)
		self.container.ScrollBarImageTransparency = size > self.container.AbsoluteSize.Y

		if scroll then
			utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
		end
	end

	function section:Resize(smooth)

		--if self.page.library.focusedPage ~= self.page then
		--	return
		--end

		local padding = 4
		local size = (4 * padding) + self.container.Title.AbsoluteSize.Y -- offset

		for i, module in pairs(self.modules) do
			size = size + module.AbsoluteSize.Y + padding
		end

		if smooth then
			utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
		else
			self.container.Parent.Size = UDim2.new(1, -10, 0, size)
			self.page:Resize()
		end
	end

	function section:getModule(info)

		if table.find(self.modules, info) then
			return info
		end

		for i, module in pairs(self.modules) do
			if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
				return module
			end
		end

		error("No module found under "..tostring(info))
	end

	-- updates

	function section:updateButton(button, title)
		button = self:getModule(button)

		button.Title.Text = title
	end

	function section:updateToggle(toggle, title, value)
		toggle = self:getModule(toggle)

		local position = {
			In = UDim2.new(.804,0,.27,0),
			Out = UDim2.new(.876, 0,0.27, 0)
		}

		local colors = {
			In = Color3.fromRGB(32, 37, 68),
			Out = Color3.fromRGB(120, 140, 255)
		}

		local frame = toggle.Toggle
		value = value and "Out" or "In"
		local color = colors[value]

		if title then
			toggle.Title.Text = title
		end

		utility:Tween(frame, {
			Position = position[value]
		}, 0.15)

		utility:Tween(toggle.Switch, {
			BackgroundColor3 = color
		}, 0.15)
	end

	function section:updateTextbox(textbox, title, value)
		textbox = self:getModule(textbox)

		if title then
			textbox.Title.Text = title
		end

		if value then
			textbox.Button.Textbox.Text = value
		end

	end

	function section:updateKeybind(keybind, title, key)
		keybind = self:getModule(keybind)

		local text = keybind.Button.Text
		local bind = self.binds[keybind]

		if title then
			keybind.Title.Text = title
		end

		if bind.connection then
			bind.connection = bind.connection:UnBind()
		end

		if key then
			self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
			text.Text = key.Name
		else
			text.Text = "None"
		end
	end

	function section:updateColorPicker(colorpicker, title, color)
		colorpicker = self:getModule(colorpicker)

		local picker = self.colorpickers[colorpicker]
		local tab = picker.tab
		local callback = picker.callback

		if title then
			colorpicker.Title.Text = title
			tab.Title.Text = title
		end

		local color3
		local hue, sat, brightness

		if type(color) == "table" then -- roblox is literally retarded x2
			hue, sat, brightness = unpack(color)
			color3 = Color3.fromHSV(hue, sat, brightness)
		else
			color3 = color
			hue, sat, brightness = Color3.toHSV(color3)
		end

		utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
		utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)

		utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
		utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)

		for i, container in pairs(tab.Container.Inputs:GetChildren()) do
			if container:IsA("ImageLabel") then
				local value = math.clamp(color3[container.Name], 0, 1) * 255

				container.Textbox.Text = math.floor(value)
				--callback(container.Name:lower(), value)
			end
		end
	end

	function section:updateSlider(slider, title, value, min, max, lvalue)
		slider = self:getModule(slider.Parent)

		if title then
			slider.Title.Text = title
		end

		local bar = slider.Slider
		local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

		if value then -- support negative ranges
			percent = (value - min) / (max - min)
		end

		percent = math.clamp(percent, 0, 1)
		value = value or math.floor(min + (max - min) * percent)
		slider.Amount.Text = value

		utility:Tween(bar.Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)

		return value
	end

	function section:updateDropdown(dropdown, title, list, callback)
		dropdown = self:getModule(dropdown)

		if title then
			dropdown.Search.TextBox.Text = title
		end

		local entries = 0

		utility:Pop(dropdown.Search, 10)

		for i, button in pairs(dropdown.List.Frame:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		for i, value in pairs(list or {}) do
			local button = utility:create("ImageButton", {
				AutoButtonColor = false,
				Parent = dropdown.List.Frame,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = themes.DarkContrast,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298)
			}, {
				utility:create("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -10, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.Gotham,
					Text = value,
					TextColor3 = themes.TextColor,
					TextSize = 12,
					TextXAlignment = "Left",
					TextTransparency = 0.10000000149012
				})
			})

			button.MouseButton1Click:Connect(function()
				if callback then
					callback(value, function(...)
						self:updateDropdown(dropdown, ...)
					end)	
				end

				self:updateDropdown(dropdown, value, nil, callback)
			end)

			entries = entries + 1
		end

		local frame = dropdown.List.Frame

		utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
		utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)

		if entries > 3 then

			for i, button in pairs(dropdown.List.Frame:GetChildren()) do
				if button:IsA("ImageButton") then
					button.Size = UDim2.new(1, -6, 0, 30)
				end
			end

			frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
			frame.ScrollBarImageTransparency = 0
		else
			frame.CanvasSize = UDim2.new(0, 0, 0, 0)
			frame.ScrollBarImageTransparency = 1
		end
	end
end

print("Astro Hub Library Loaded!")
return library