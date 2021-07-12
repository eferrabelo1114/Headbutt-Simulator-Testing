--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local HammerLibrary = require(ReplicatedStorage.Modules.HammerLibrary)

local HammerService = Knit.CreateService {
    Name = "HammerService",
    Client = {}
}

function HammerService:GetHammerData(hammerName)
    return HammerLibrary[hammerName]
end


return HammerService