--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local ProfileService = Knit.GetService("PlayerProfilesService")
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)
local Zone = require(ReplicatedStorage.Modules.Zone)

--Main Knit service
local ZoneManagementService = Knit.CreateService {
    Name = "ZoneManagementService";
    Client = {};
}

--Variables
local SellRegion = Zone.new(workspace.Touch.Sell)

SellRegion.playerEntered:Connect(function(player)
    if ProfileService.Profiles[player] then
        local Profile = ProfileService.Profiles[player]

        if player.Character then
            if player.Character.Humanoid.Health > 0 then
                if Profile.Data.Headmuscle > 0 then
                    Profile:SellHeadmuscle()
                end
            end
        end
    end
end)


return ZoneManagementService