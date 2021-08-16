--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(ReplicatedStorage.Knit)
local maid = require(Knit.Util.Maid)
local Sounds = require(Knit.Util.Sounds)

local ZoneManagementService = Knit.GetService("ZoneManagementService")

--Variables
local Player = game.Players.LocalPlayer

--Knit Stuff
local ServerFeedback = Knit.CreateController {
    Name = "ServerFeedback";
}



function ServerFeedback:KnitStart()

    ZoneManagementService.Feedback:Connect(function()
        Sounds:PlaySound("Sell", Player)
    end)

end

return ServerFeedback