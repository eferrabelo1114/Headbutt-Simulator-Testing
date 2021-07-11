--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local ProfileService = require(ReplicatedStorage.ProfileService)

--Main Knit service
local PlayerProfilesService = Knit.CreateService {
    Name = "PlayerProfilesService";
    Client = {};
}

--Variables
local Players = game:GetService("Players")

PlayerProfilesService.Profiles = {}

local ProfileTemplate = {
    Cash = 0;

}

local ProfileStore = ProfileService.GetProfileStore(
    "PlayerData_Version_1.0",
    ProfileTemplate
)

--Function Stuff
function PlayerProfilesService:CreateProfile(player)
    local profile = ProfileStore:LoadProfileAsync(
        "Player_Key"..player.UserId,
        "ForceLoad"
    )

    if profile ~= nil then
        profile:Reconcile()

        profile:ListenToRelease(function() --Try and use this instead of player removing
            PlayerProfilesService.Profiles[player] = nil
            player:Kick()
        end)

        if player:IsDescendantOf(Players) then
            profile.TempData = {}

            PlayerProfilesService.Profiles[player] = profile

            --Begin loading player

        else
           profile:Release() 
        end

    else
       player:Kick("Failed to load profile. Please rejoin.") 
    end

end


function PlayerProfilesService:KnitStart()
    

    --Connect profile stuff
    Players.PlayerAdded:connect(function(player)
        self:CreateProfile(player)
    end)

    Players.PlayerRemoving:connect(function(player)
        local profile = self.Profiles[player]

        if profile then
            profile:Release()
        end
    end)

    --Go through players that may have joined before these connections
    for _,player in pairs(Players:GetPlayers()) do
        if self.Profiles[player] == nil then
            self:CreateProfile(player)
        end
    end
end

return PlayerProfilesService