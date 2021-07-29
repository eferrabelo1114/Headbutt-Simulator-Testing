--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)
local Sounds = require(Knit.Util.Sounds)
local Tween = require(Knit.Util.Tween)

local HammerService = Knit.GetService("HammerService")

--Variables
local Player = game.Players.LocalPlayer
local Animations = ReplicatedStorage:FindFirstChild("Animations")

local HammerAnimation = Animations:FindFirstChild("Hammer")

local hitDb = false

local Camera = game.Workspace.CurrentCamera
--Events


--Knit Stuff
local HammerController = Knit.CreateController {
    Name = "HammerController";
}

function HammerController:ConnectHammer(hammer)
    local UIController = Knit.GetController("UIController")

    hammer.Activated:Connect(function()
        if not hitDb then
            hitDb = true

            local char = Player.Character

            if Player:GetAttribute("Headmuscle") < Player:GetAttribute("MaxHeadmuscle") then
                HammerService:HammerHead()

                --Load Blur
                local blurEffect = Instance.new("BlurEffect")
                blurEffect.Size = 0
                blurEffect.Parent = game.Workspace.CurrentCamera

                --Play sound
                Sounds:PlaySound("HeadbuttHitSound", Player)

                --Tween Camera
                local BlurTween = Tween:tween(blurEffect, {"Size"}, {7}, 0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                Tween:tween(Camera, {"FieldOfView"}, {50}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

                --Play hammer animation
                local loadedAnimation = char.Humanoid:LoadAnimation(HammerAnimation)
                loadedAnimation:Play()

                --Cleanup
                BlurTween.Completed:Wait()
                local BlurTweenb = Tween:tween(blurEffect, {"Size"}, {0}, 0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                Tween:tween(Camera, {"FieldOfView"}, {70}, 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                BlurTweenb.Completed:Wait()
                blurEffect:Remove()
            else
                --Tell player inventory is full
                UIController:OpenMenu("SellHM")
            end

            wait(Player:GetAttribute("HammerDelay") + 0.1)
            hitDb = false
        end
    end)
end

function HammerController:KnitInit()
    local PlayerProfileService = Knit.GetService("PlayerProfilesService")

    PlayerProfileService.PlayerEquippedHammer:Connect(function(hammer)
        self:ConnectHammer(hammer)
    end)
end

return HammerController