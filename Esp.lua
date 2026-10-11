
-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NickoyPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(260, 250)
panel.Position = UDim2.new(0.5, -130, 0.35, 0)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
panel.BorderSizePixel = 0
panel.ZIndex = 2
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(220, 45, 55)
stroke.Thickness = 2
stroke.Parent = panel

-- Show panel button
local guiToggle = Instance.new("TextButton")
guiToggle.Name = "EnableGUI"
guiToggle.Size = UDim2.fromOffset(120, 38)
guiToggle.Position = UDim2.fromOffset(15, 15)
guiToggle.BackgroundColor3 = Color3.fromRGB(150, 35, 42)
guiToggle.TextColor3 = Color3.new(1, 1, 1)
guiToggle.Text = "SHOW PANEL"
guiToggle.TextSize = 14
guiToggle.Font = Enum.Font.GothamBold
guiToggle.Visible = false
guiToggle.ZIndex = 10
guiToggle.Parent = gui

Instance.new("UICorner", guiToggle).CornerRadius = UDim.new(0, 8)

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -55, 0, 42)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "NICKOY | PANEL"
title.TextColor3 = Color3.fromRGB(255, 75, 80)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = panel

-- Close button
local close = Instance.new("TextButton")
close.Name = "CloseButton"
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -40, 0, 7)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(150, 35, 42)
close.Font = Enum.Font.GothamBold
close.TextSize = 15
close.ZIndex = 4
close.Parent = panel

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

-- Button container
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Position = UDim2.fromOffset(12, 50)
buttonContainer.Size = UDim2.new(1, -24, 1, -62)
buttonContainer.BackgroundTransparency = 1
buttonContainer.ZIndex = 3
buttonContainer.Parent = panel

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = buttonContainer

-- Create buttons
local function makeButton(text, order)
    local button = Instance.new("TextButton")
    button.Name = text:gsub("[^%w]", "") .. "Button"
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
    button.TextColor3 = Color3.fromRGB(245, 245, 245)
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = true
    button.LayoutOrder = order
    button.ZIndex = 4
    button.Parent = buttonContainer

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    return button
end

local espButton = makeButton("ESP: OFF", 1)
local flyButton = makeButton("FLY: OFF", 2)
local aimButton = makeButton("AIM ASSIST: OFF", 3)
