-- WeaponUnlockServer
-- Place in ServerScriptService.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local weaponsFolder =
    ServerStorage:WaitForChild("TrainingWeapons")

-- Set your Roblox UserId here once.
local OWNER_USER_ID = 123456789 -- Replace this number.

-- Reuse the RemoteEvent if it already exists.
local unlockEvent =
    ReplicatedStorage:FindFirstChild("UnlockTrainingWeapons")

if unlockEvent and not unlockEvent:IsA("RemoteEvent") then
    error("UnlockTrainingWeapons must be a RemoteEvent")
end

if not unlockEvent then
    unlockEvent = Instance.new("RemoteEvent")
    unlockEvent.Name = "UnlockTrainingWeapons"
    unlockEvent.Parent = ReplicatedStorage
end

local function isOwner(player)
    return player.UserId == OWNER_USER_ID
end

unlockEvent.OnServerEvent:Connect(function(player)
    if not isOwner(player) then
        warn("Unauthorized weapon request:", player.Name)
        return
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if not backpack then
        return
    end

    local character = player.Character

    for _, weapon in ipairs(weaponsFolder:GetChildren()) do
        if weapon:IsA("Tool") then
            local alreadyHasWeapon =
                backpack:FindFirstChild(weapon.Name)
                or (character and character:FindFirstChild(weapon.Name))

            if not alreadyHasWeapon then
                weapon:Clone().Parent = backpack
            end
        end
    end

    print("Training weapons granted to owner:", player.Name)
end)
