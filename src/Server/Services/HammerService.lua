--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Knit)
local HammerLibrary = require(ReplicatedStorage.Modules.HammerLibrary)

local HammerService = Knit.CreateService {
    Name = "HammerService",
    Client = {}
}

function HammerService:GetHammerData(hammerName)
    return HammerLibrary[hammerName]
end

function HammerService.Client:HammerHead(player)
    local ProfileService = Knit.Services.PlayerProfilesService
    local Profile = ProfileService.Profiles[player]

    if Profile then
        if player.Character then
            if player.Character.Humanoid.Health > 0 then
                local PlayerHammerEquipped = Profile.Data.Hammer
                local HammerData = HammerService:GetHammerData(PlayerHammerEquipped)

                if (tick() - Profile.TempData.LastHammerHead) >= Profile.TempData.HammerDelay then --Replace 3 with player hammer delay in the future
                    Profile:AddHeadmuscleNormal()
                    Profile.TempData.LastHammerHead = tick()
                end
            end
        end
    end 
end

return HammerService