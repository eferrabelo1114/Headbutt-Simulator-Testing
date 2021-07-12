--Services
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Maid = require(Knit.Util.Maid)

--Variables
local Player = game.Players.LocalPlayer

--Knit Stuff
local HammerController = Knit.CreateController {
    Name = "HammerController";
}

function HammerController:ConnectHammer(hammer)
    print("Connect Hammer")

    self.HammerConnected = true
end

function HammerController:KnitStart()
    

    --In the morning re-do hammer to be one hammer tool and just change the skin/hammer type of the one tool

  

end

return HammerController