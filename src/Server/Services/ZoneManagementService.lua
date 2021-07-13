--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local ProfileService = require(ReplicatedStorage.ProfileService)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)

--Main Knit service
local ZoneManagementService = Knit.CreateService {
    Name = "ZoneManagementService";
    Client = {};
}





return ZoneManagementService