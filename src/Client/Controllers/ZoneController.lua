--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)
local Sounds = require(Knit.Util.Sounds)
local Tween = require(Knit.Util.Tween)
local Zone = require(ReplicatedStorage.Modules.Zone)



--Variables
local Player = game.Players.LocalPlayer

local HammerShop = Zone.new(workspace.Touch.HammerUpgrade)

--Events


--Knit Stuff
local ZoneController = Knit.CreateController {
    Name = "ZoneController";
}



function ZoneController:KnitInit()
    local UIController = Knit.GetController("UIController")

    HammerShop.localPlayerEntered:Connect(function()
        UIController:OpenMenu("HammerShop")
    end)

end

return ZoneController