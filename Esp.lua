
-- Made by Nickoy
-- Roblox Studio GUI Panel
-- Place a LocalScript in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local espEnabled = false
local flyEnabled = false

local flyConnection
local bodyVelocity
local bodyGyro
local flyAttachment

local tracked = {}
local highlights = {}

-- Find a character's head in your own experience
local function getTargetHead(character)
    if not character then
        return nil
    end

    local head = character:FindFirstChild("Head")

    if head and head:IsA("BasePart") then
        return head
    end

    return nil
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NickoyPanel"
gui.ResetOnSpawn = false
gui.Enabled = true
gui.DisplayOrder = 100
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(260, 205)
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

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 45)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "NICKOY  |  PANEL"
title.TextColor3 = Color3.fromRGB(255, 75, 80)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -40, 0, 7)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(150, 35, 42)
close.Font = Enum.Font.GothamBold
close.TextSize = 15
close.ZIndex = 3
close.Parent = panel

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 48)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
    button.TextColor3 = Color3.fromRGB(245, 245, 245)
    button.Text = text
    button.TextSize = 15
    button.Font = Enum.Font.GothamSemibold
    button.ZIndex = 3
    button.Parent = panel

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    return button
end

local espButton = makeButton("ESP: OFF", 55)
local flyButton = makeButton("FLY: OFF", 111)

-- ESP for your own experience
local function clearHighlights()
    for character, highlight in pairs(highlights) do
        if highlight then
            highlight:Destroy()
        end
        highlights[character] = nil
    end
end

local function addHighlight(otherPlayer, character)
    if not espEnabled or otherPlayer == player then
        return
    end

    if not character or highlights[character] then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NickoyESP"
    highlight.FillColor = Color3.fromRGB(235, 45, 55)
    highlight.OutlineColor = Color3.fromRGB(255, 230, 230)
    highlight.FillTransparency = 0.65
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character

    highlights[character] = highlight
end

local function track(otherPlayer)
    if otherPlayer == player or tracked[otherPlayer] then
        return
    end

    tracked[otherPlayer] = true

    otherPlayer.CharacterAdded:Connect(function(character)
        if espEnabled then
            addHighlight(otherPlayer, character)
        end
    end)

    if otherPlayer.Character then
        addHighlight(otherPlayer, otherPlayer.Character)
    end
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
    track(otherPlayer)
end

Players.PlayerAdded:Connect(track)

Players.PlayerRemoving:Connect(function(otherPlayer)
    local character = otherPlayer.Character

    if character and highlights[character] then
        highlights[character]:Destroy()
        highlights[character] = nil
    end

    tracked[otherPlayer] = nil
end)

espButton.Activated:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")

    espButton.BackgroundColor3 = espEnabled
        and Color3.fromRGB(150, 35, 42)
        or Color3.fromRGB(48, 48, 56)

    if espEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer.Character then
                addHighlight(otherPlayer, otherPlayer.Character)
            end
        end
    else
        clearHighlights()
    end
end)

-- Fly movement
local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end
end

local function startFly()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return false
    end

    stopFly()

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "NickoyFlyAttachment"
    flyAttachment.Parent = root

    bodyVelocity = Instance.new("LinearVelocity")
    bodyVelocity.Name = "NickoyFlyVelocity"
    bodyVelocity.Attachment0 = flyAttachment
    bodyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    bodyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    bodyVelocity.ForceLimitsEnabled = false
    bodyVelocity.VectorVelocity = Vector3.new(0, 35, 0)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("AlignOrientation")
    bodyGyro.Name = "NickoyFlyOrientation"
    bodyGyro.Attachment0 = flyAttachment
    bodyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
    bodyGyro.MaxTorque = 100000
    bodyGyro.Responsiveness = 15
    bodyGyro.Parent = root

    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

    flyConnection = RunService.Heartbeat:Connect(function()
        if not root.Parent or not humanoid.Parent then
            stopFly()
            flyEnabled = false
            flyButton.Text = "FLY: OFF"
            flyButton.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        bodyVelocity.VectorVelocity = camera.CFrame.LookVector * 45
        bodyGyro.CFrame = CFrame.lookAt(
            Vector3.zero,
            camera.CFrame.LookVector
        )

        if humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end)

    return true
end

flyButton.Activated:Connect(function()
    if flyEnabled then
        flyEnabled = false
        stopFly()
        flyButton.Text = "FLY: OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
    else
        if startFly() then
            flyEnabled = true
            flyButton.Text = "FLY: ON"
            flyButton.BackgroundColor3 = Color3.fromRGB(150, 35, 42)
        end
    end
end)

player.CharacterAdded:Connect(function()
    stopFly()
    flyEnabled = false
    flyButton.Text = "FLY: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
end)

-- Hide/show panel
guiToggle.Activated:Connect(function()
    panel.Visible = true
    guiToggle.Visible = false
end)

close.Activated:Connect(function()
    flyEnabled = false
    stopFly()
    flyButton.Text = "FLY: OFF"
    flyButton.BackgroundColor3 = Color3.fromRGB(48, 48, 56)

    panel.Visible = false
    guiToggle.Visible = true
end)

-- Drag panel with mouse or touch
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = panel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        panel.Position = UDim2.new(
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
