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
    Headmuscle = 0;
    Hammer = "Default";
    OwnedHammers = {"Default"};
}

local ProfileStore = ProfileService.GetProfileStore(
    "PlayerData_Version_1.0",
    ProfileTemplate
)

--Function Stuff

function PlayerProfilesService:EquipHammer(player)
    local HammerService = Knit.Services.HammerService

    if self.Profiles[player] then
        local Profile = self.Profiles[player]
        local ProfilePlayer = Profile._Player
        local EquippedHammer = Profile.Data.Hammer

        local newHammer = ReplicatedStorage:FindFirstChild("Hammer"):Clone()
        local HammerData = HammerService:GetHammerData(EquippedHammer)
    
        newHammer.Handle.Mesh.TextureId = "rbxassetid://"..HammerData.Texture
        newHammer.Parent = ProfilePlayer.Backpack

        if player.Character then
            if player.Character:FindFirstChild("Hammer") then
                player.Character:FindFirstChild("Hammer"):Remove()
            end
        end
    end
end

--Client change hammer stuff remote function
function PlayerProfilesService.Client:ChangeHammer(player, newHammer)
    if self.Profiles[player] then
        local Profile = self.Profiles[player]
        
        if Profile.Data.OwnedHammers[newHammer] then
          Profile:ChangeHammer(newHammer)
        end
    end
end

function PlayerProfilesService:LoadProfile(profile)
    local ProfileData = profile.Data
    local ProfilePlayer = profile._Player

    function profile:ChangeHammer(newHammer)
        self.Data.Hammer = newHammer
        self._Player:SetAttribute("Hammer", self.Data.Hammer)

        if self._Player.Character then
            self:EquipHammer(ProfilePlayer)
        end
    end

    ProfilePlayer:SetAttribute("Hammer", ProfileData.Hammer)
end

function PlayerProfilesService:LoadPlayerCharacter(player)
    if self.Profiles[player] then
        local Profile = self.Profiles[player]
        local Character = player.Character or player.CharacterAdded:Wait()

        self:EquipHammer(player)

        player.CharacterAdded:connect(function()
            self:LoadPlayerCharacter(player)
        end)
    end
end

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
            profile._Player = player

            PlayerProfilesService.Profiles[player] = profile
            self:LoadProfile(profile)
            self:LoadPlayerCharacter(player)
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