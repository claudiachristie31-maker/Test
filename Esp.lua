loadstring([[
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function addHighlight(character)
    if character == localPlayer.Character then return end
    if character:FindFirstChild("ESPHighlight") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = Color3.fromRGB(255, 60, 60)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.65
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = character
end

local function trackPlayer(player)
    if player.Character then
        addHighlight(player.Character)
    end
    player.CharacterAdded:Connect(addHighlight)
end

for _, player in Players:GetPlayers() do
    trackPlayer(player)
end

Players.PlayerAdded:Connect(trackPlayer)
