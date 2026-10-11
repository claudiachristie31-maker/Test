-- NICKOY PANEL
-- For your own Roblox Studio experience

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local espEnabled = false
local flyEnabled = false
local aimAssistEnabled = false

local flyConnection
local aimConnection
local bodyVelocity
local bodyGyro
local flyAttachment

local MAX_AIM_DISTANCE = 150
local AIM_SMOOTHNESS = 0.15

local npcFolder = workspace:WaitForChild("PracticeNPCs")

local highlights = {}
local tracked = {}
local characterConnections = {}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NickoyPanel"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 100
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.fromOffset(260, 250)
panel.Position = UDim2.new(0.5, -130, 0.5, -125)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(235, 45, 55)
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 42)
title.Position = UDim2.fromOffset(12, 3)
title.BackgroundTransparency = 1
title.Text = "NICKOY | PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -40, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(180, 35, 45)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 15
close.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

local guiToggle = Instance.new("TextButton")
guiToggle.Size = UDim2.fromOffset(125, 36)
guiToggle.Position = UDim2.fromOffset(15, 100)
guiToggle.BackgroundColor3 = Color3.fromRGB(180, 35, 45)
guiToggle.Text = "SHOW PANEL"
guiToggle.TextColor3 = Color3.new(1, 1, 1)
guiToggle.Font = Enum.Font.GothamBold
guiToggle.TextSize = 13
guiToggle.Visible = false
guiToggle.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 7)
toggleCorner.Parent = guiToggle

-- Button layout
local buttonContainer = Instance.new("Frame")
buttonContainer.Position = UDim2.fromOffset(12, 50)
buttonContainer.Size = UDim2.new(1, -24, 1, -62)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = buttonContainer

local function makeButton(text, order)
    local button = Instance.new("TextButton")
    button.Name = text:gsub("[^%w]", "") .. "Button"
    button.Size = UDim2.new(1, 0, 0, 42)
    button.BackgroundColor3 = Color3.fromRGB(48, 48, 56)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.LayoutOrder = order
    button.Parent = buttonContainer

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 7)
    buttonCorner.Parent = button

    return button
end

local espButton = makeButton("ESP: OFF", 1)
local flyButton = makeButton("FLY: OFF", 2)
local aimButton = makeButton("AIM ASSIST: OFF", 3)

local function setButton(button, enabled, label)
    button.Text = label .. (enabled and ": ON" or ": OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(180, 35, 45)
        or Color3.fromRGB(48, 48, 56)
end

-- ESP
local function clearHighlights()
    for character, highlight in pairs(highlights) do
        highlight:Destroy()
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
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    highlights[character] = highlight
end

local function track(otherPlayer)
    if otherPlayer == player or tracked[otherPlayer] then
        return
    end

    tracked[otherPlayer] = true

    characterConnections[otherPlayer] =
        otherPlayer.CharacterAdded:Connect(function(character)
            if espEnabled then
                task.wait(0.5)
                addHighlight(otherPlayer, character)
            end
        end)

    if otherPlayer.Character and espEnabled then
        addHighlight(otherPlayer, otherPlayer.Character)
    end
end

for _, otherPlayer in ipairs(Players:GetPlayers()) do
    track(otherPlayer)
end

Players.PlayerAdded:Connect(track)

Players.PlayerRemoving:Connect(function(otherPlayer)
    tracked[otherPlayer] = nil

    if characterConnections[otherPlayer] then
        characterConnections[otherPlayer]:Disconnect()
        characterConnections[otherPlayer] = nil
    end

    if otherPlayer.Character and highlights[otherPlayer.Character] then
        highlights[otherPlayer.Character]:Destroy()
        highlights[otherPlayer.Character] = nil
    end
end)

espButton.Activated:Connect(function()
    espEnabled = not espEnabled
    setButton(espButton, espEnabled, "ESP")

    if espEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                addHighlight(otherPlayer, otherPlayer.Character)
            end
        end
    else
        clearHighlights()
    end
end)

-- FLY
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
    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        return
    end

    stopFly()

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "NickoyFlyAttachment"
    flyAttachment.Parent = root

    bodyVelocity = Instance.new("LinearVelocity")
    bodyVelocity.Name = "NickoyFlyVelocity"
    bodyVelocity.Attachment0 = flyAttachment
    bodyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    bodyVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    bodyVelocity.ForceLimitsEnabled = false
    bodyVelocity.VectorVelocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("AlignOrientation")
    bodyGyro.Name = "NickoyFlyOrientation"
    bodyGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
    bodyGyro.MaxTorque = 100000
    bodyGyro.Responsiveness = 15
    bodyGyro.Attachment0 = flyAttachment
    bodyGyro.Parent = root

    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

    flyConnection = RunService.Heartbeat:Connect(function()
        if not root.Parent or not humanoid.Parent then
            flyEnabled = false
            stopFly()
            setButton(flyButton, false, "FLY")
            return
        end

        local camera = workspace.CurrentCamera
        if not camera or not bodyVelocity or not bodyGyro then
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
end

flyButton.Activated:Connect(function()
    flyEnabled = not flyEnabled

    if flyEnabled then
        startFly()
        if not flyConnection then
            flyEnabled = false
        end
    else
        stopFly()
    end

    setButton(flyButton, flyEnabled, "FLY")
end)

-- AIM ASSIST: NPC PRACTICE TARGET HEADS
local function getNearestNPCHead()
    local camera = workspace.CurrentCamera
    if not camera then
        return nil
    end

    local nearestHead = nil
    local nearestDistance = MAX_AIM_DISTANCE

    for _, npc in ipairs(npcFolder:GetChildren()) do
        local humanoid = npc:FindFirstChildOfClass("Humanoid")
        local head = npc:FindFirstChild("Head")

        if humanoid
            and humanoid.Health > 0
            and head
            and head:IsA("BasePart") then

            local distance =
                (head.Position - camera.CFrame.Position).Magnitude

            local _, onScreen =
                camera:WorldToViewportPoint(head.Position)

            if onScreen and distance < nearestDistance then
                nearestDistance = distance
                nearestHead = head
            end
        end
    end

    return nearestHead
end

local function stopAimAssist()
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end

aimButton.Activated:Connect(function()
    aimAssistEnabled = not aimAssistEnabled
    stopAimAssist()

    if aimAssistEnabled then
        aimConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local head = getNearestNPCHead()

            if camera and head then
                local targetCFrame = CFrame.lookAt(
                    camera.CFrame.Position,
                    head.Position
                )

                camera.CFrame = camera.CFrame:Lerp(
                    targetCFrame,
                    AIM_SMOOTHNESS
                )
            end
        end)
    end

    setButton(aimButton, aimAssistEnabled, "AIM ASSIST")
end)

-- RESPAWN HANDLING
player.CharacterAdded:Connect(function()
    stopFly()
    flyEnabled = false
    setButton(flyButton, false, "FLY")
end)

-- SHOW/HIDE PANEL
guiToggle.Activated:Connect(function()
    panel.Visible = true
    guiToggle.Visible = false
end)

close.Activated:Connect(function()
    stopFly()
    flyEnabled = false
    setButton(flyButton, false, "FLY")

    stopAimAssist()
    aimAssistEnabled = false
    setButton(aimButton, false, "AIM ASSIST")

    panel.Visible = false
    guiToggle.Visible = true
end)

-- DRAG PANEL BY TITLE
local dragging = false
local dragInput
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = panel.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        panel.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)
