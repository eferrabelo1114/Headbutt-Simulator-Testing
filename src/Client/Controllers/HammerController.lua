--Services
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Maid = require(Knit.Util.Maid)

local HammerService = Knit.GetService("HammerService")

--Variables
local Player = game.Players.LocalPlayer

--Events


--Knit Stuff
local HammerController = Knit.CreateController {
    Name = "HammerController";
}

function HammerController:ConnectHammer(hammer)
    print("Connect Hammer")

    hammer.Activated:Connect(function()
        if Player:GetAttribute("Headmuscle") < Player:GetAttribute("MaxHeadmuscle") then
            HammerService:HammerHead()
        else
            
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