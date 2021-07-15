--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)
local Sounds = require(Knit.Util.Sounds)

local HammerService = Knit.GetService("HammerService")

--Variables
local Player = game.Players.LocalPlayer
local Animations = ReplicatedStorage:FindFirstChild("Animations")

local HammerAnimation = Animations:FindFirstChild("Hammer")

local hitDb = false
--Events


--Knit Stuff
local HammerController = Knit.CreateController {
    Name = "HammerController";
}

function HammerController:ConnectHammer(hammer)
    hammer.Activated:Connect(function()
        if not hitDb then
            hitDb = true

            local char = Player.Character

            if Player:GetAttribute("Headmuscle") < Player:GetAttribute("MaxHeadmuscle") then
                HammerService:HammerHead()

                local loadedAnimation = char.Humanoid:LoadAnimation(HammerAnimation)
                loadedAnimation:Play()

                Sounds:PlaySound("HeadbuttHitSound", Player)
            else
                --Tell player inventory is full
                print("Inventory Full")
            end

            wait(Player:GetAttribute("HammerDelay") + 0.1)
            hitDb = false
        end
    end)
end

function HammerController:KnitStart()
    local PlayerProfileService = Knit.GetService("PlayerProfilesService")

    PlayerProfileService.PlayerEquippedHammer:Connect(function(hammer)
        self:ConnectHammer(hammer)
    end)
end

return HammerController