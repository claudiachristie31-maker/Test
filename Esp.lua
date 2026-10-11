-- NickoyPanel - startup-fixed Studio training panel
-- Place in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove previous copy
local oldGui = playerGui:FindFirstChild("NickoyPanel")
if oldGui then
    oldGui:Destroy()
end

-- Create the GUI first, so missing targets cannot block it
local gui = Instance.new("ScreenGui")
gui.Name = "NickoyPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Enabled = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(250, 230)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 38)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "NickoyPanel"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(32, 28)
closeButton.Position = UDim2.new(1, -38, 0, 5)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
closeButton.Parent = main

local function createButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 42)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Text = text .. ": OFF"
    button.Parent = main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    return button
end

local espButton = createButton("TRAINING ESP", 48)
local flyButton = createButton("FLY", 98)
local aimButton = createButton("HEAD-LOCK TRAINING", 148)

-- Create the target folder without yielding
local targetFolder = workspace:FindFirstChild("AimTrainingTargets")
if not targetFolder then
    targetFolder = Instance.new("Folder")
    targetFolder.Name = "AimTrainingTargets"
    targetFolder.Parent = workspace
end

local function setButton(button, enabled, label)
    button.Text = label .. (enabled and ": ON" or ": OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(35, 135, 95)
        or Color3.fromRGB(55, 55, 68)
end

-- Drag panel with mouse or touch
do
    local dragging = false
    local dragStart
    local startPosition

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Buttons indicate that the panel loaded.
-- Connect your approved Studio training features here.
espButton.Activated:Connect(function()
    setButton(espButton, espButton.Text:find(": OFF") ~= nil,
        "TRAINING ESP")
end)

flyButton.Activated:Connect(function()
    setButton(flyButton, flyButton.Text:find(": OFF") ~= nil, "FLY")
end)

aimButton.Activated:Connect(function()
    setButton(aimButton, aimButton.Text:find(": OFF") ~= nil,
        "HEAD-LOCK TRAINING")
end)

closeButton.Activated:Connect(function()
    gui:Destroy()
end)

print("NickoyPanel loaded successfully")
