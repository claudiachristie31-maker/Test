--// NickoyPanel - Roblox Studio Training Tools
--// Place in StarterPlayer > StarterPlayerScripts
--// Targets must be registered in Workspace.AimTrainingTargets
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
-- SETTINGS
local MAX_AIM_DISTANCE = 150
local AIM_SMOOTHNESS = 0.15
local FLY_SPEED = 45
-- TARGET REGISTRY
local targetFolder = workspace:WaitForChild("AimTrainingTargets")
-- REMOVE OLD GUI
local oldGui = playerGui:FindFirstChild("NickoyPanel")
if oldGui then
    oldGui:Destroy()
end
-- STATE
local espEnabled = false
local flyEnabled = false
local aimAssistEnabled = false
local aimConnection
local flyConnection
local espConnection
local highlights = {}
local flyAttachment
local flyVelocity
local flyOrientation
-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "NickoyPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(240, 250)
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
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton
local function createButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 42)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Text = text .. ": OFF"
    button.AutoButtonColor = true
    button.Parent = main
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button
    return button
end
local espButton = createButton("TRAINING ESP", 48)
local flyButton = createButton("FLY", 98)
local aimButton = createButton("HEAD-LOCK TRAINING", 148)
local function setButton(button, enabled, label)
    button.Text = label .. (enabled and ": ON" or ": OFF")
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(35, 135, 95)
        or Color3.fromRGB(55, 55, 68)
end
-- DRAG WINDOW
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
-- TRAINING ESP: REGISTERED MODELS ONLY
local function removeHighlight(model)
    local highlight = highlights[model]
    if highlight then
        highlight:Destroy()
        highlights[model] = nil
    end
end
local function addHighlight(model)
    if not espEnabled or not model:IsA("Model") then
        return
    end
    if not model:FindFirstChildOfClass("Humanoid")
        or not model:FindFirstChild("Head") then
        return
    end
    if highlights[model] then
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "TrainingTargetHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(30, 200, 120)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = model
    highlights[model] = highlight
end
local function stopESP()
    espEnabled = false
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    for model in pairs(highlights) do
        removeHighlight(model)
    end
end
local function startESP()
    espEnabled = true
    for _, model in ipairs(targetFolder:GetChildren()) do
        addHighlight(model)
    end
    espConnection = targetFolder.ChildAdded:Connect(function(model)
        task.wait(0.1)
        addHighlight(model)
    end)
    targetFolder.ChildRemoved:Connect(function(model)
        removeHighlight(model)
    end)
end
espButton.Activated:Connect(function()
    if espEnabled then
        stopESP()
    else
        startESP()
    end
    setButton(espButton, espEnabled, "TRAINING ESP")
end)
-- FLY
local function stopFly()
    flyEnabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    if flyOrientation then
        flyOrientation:Destroy()
        flyOrientation = nil
    end
    if flyAttachment then
        flyAttachment:Destroy()
        flyAttachment = nil
    end
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end
local function startFly()
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        return
    end
    stopFly()
    flyEnabled = true
    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "NickoyFlyAttachment"
    flyAttachment.Parent = root
    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "NickoyFlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Vector
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.MaxForce = 100000
    flyVelocity.Parent = root
    flyOrientation = Instance.new("AlignOrientation")
    flyOrientation.Name = "NickoyFlyOrientation"
    flyOrientation.Attachment0 = flyAttachment
    flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyOrientation.MaxTorque = 100000
    flyOrientation.Responsiveness = 15
    flyOrientation.Parent = root
    humanoid.PlatformStand = true
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not root.Parent then
            stopFly()
            return
        end
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end
        local direction = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end
        if direction.Magnitude > 0 then
            direction = direction.Unit * FLY_SPEED
        end
        flyVelocity.VectorVelocity = direction
        local look = camera.CFrame.LookVector
        flyOrientation.CFrame = CFrame.lookAt(
            Vector3.zero,
            Vector3.new(look.X, 0, look.Z).Magnitude > 0.001
                and Vector3.new(look.X, 0, look.Z).Unit
                or Vector3.new(0, 0, -1)
        )
    end)
end
flyButton.Activated:Connect(function()
    if flyEnabled then
        stopFly()
    else
        startFly()
    end
    setButton(flyButton, flyEnabled, "FLY")
end)
-- HEAD-LOCK TRAINING
local function getNearestTestHead()
    local camera = workspace.CurrentCamera
    if not camera then
        return nil
    end
    local screenCenter = camera.ViewportSize / 2
    local nearestHead = nil
    local nearestScreenDistance = math.huge
    for _, character in ipairs(targetFolder:GetChildren()) do
        if character:IsA("Model") then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0
                and head and head:IsA("BasePart") then
                local screenPos, onScreen =
                    camera:WorldToViewportPoint(head.Position)
                local worldDistance =
                    (head.Position - camera.CFrame.Position).Magnitude
                if onScreen and screenPos.Z > 0
                    and worldDistance <= MAX_AIM_DISTANCE then
                    local screenDistance = (
                        Vector2.new(screenPos.X, screenPos.Y)
                        - screenCenter
                    ).Magnitude
                    if screenDistance < nearestScreenDistance then
                        nearestScreenDistance = screenDistance
                        nearestHead = head
                    end
                end
            end
        end
    end
    return nearestHead
end
local function stopAimAssist()
    aimAssistEnabled = false
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
end
aimButton.Activated:Connect(function()
    if aimAssistEnabled then
        stopAimAssist()
    else
        aimAssistEnabled = true
        aimConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local head = getNearestTestHead()
            if camera and head and head.Parent then
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
    setButton(aimButton, aimAssistEnabled, "HEAD-LOCK TRAINING")
end)
-- RESPAWN CLEANUP
player.CharacterAdded:Connect(function()
    stopFly()
    setButton(flyButton, false, "FLY")
end)
-- CLOSE PANEL AND CLEAN UP
closeButton.Activated:Connect(function()
    stopFly()
    stopAimAssist()
    stopESP()
    gui:Destroy()
end)
setButton(espButton, false, "TRAINING ESP")
setButton(flyButton, false, "FLY")
setButton(aimButton, false, "HEAD-LOCK TRAINING")
