--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local ProfileService = require(ReplicatedStorage.ProfileService)
local RemoteSignal = require(Knit.Util.Remote.RemoteSignal)


--Main Knit service
local PlayerProfilesService = Knit.CreateService {
    Name = "PlayerProfilesService";
    Client = {};
}


--Variables
local Players = game:GetService("Players")

PlayerProfilesService.Profiles = {}

--Events
PlayerProfilesService.Client.PlayerEquippedHammer = RemoteSignal.new()
PlayerProfilesService.Client.ClientHeadmusclePopup = RemoteSignal.new()

local ProfileTemplate = {
    Cash = 0;
    Headmuscle = 0;
    Hammer = "Default";
    OwnedHammers = {"Default"};
    Bucket = "Default";
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
        local EquippedHammer = Profile.Data.Hammer
        local HammerData = HammerService:GetHammerData(EquippedHammer)
    
        local newHammer = nil

        if player.Character then
            if player.Character:FindFirstChild("Hammer") then
                newHammer = player.Character:FindFirstChild("Hammer")
            end
        end

        if player.Backpack:FindFirstChild("Hammer") and newHammer == nil then
            newHammer = player.Backpack:FindFirstChild("Hammer")
        end

        if newHammer == nil then
            newHammer = game.ReplicatedStorage:FindFirstChild("Hammer"):Clone()
            newHammer.Parent = player.Backpack
            self.Client.PlayerEquippedHammer:Fire(player, newHammer)
        end

        newHammer.Handle.Mesh.TextureId = "rbxassetid://"..HammerData.Texture
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
    local HammerService = Knit.Services.HammerService
    local BucketService = Knit.Services.BucketService

    local ProfileData = profile.Data
    local ProfilePlayer = profile._Player

    function profile:ChangeHammer(newHammer)
        self.Data.Hammer = newHammer
        self._Player:SetAttribute("Hammer", self.Data.Hammer)

        if self._Player.Character then
            self:EquipHammer(ProfilePlayer)
        end
    end

    function profile:AddHeadmuscleNormal()
        local HammerData = HammerService:GetHammerData(self.Data.Hammer)
        local MaxHeadmuscle = self.TempData.MaxHeadmuscle
        local CurrentHeadmuscule = self.Data.Headmuscle

        local currentStorageSpace = MaxHeadmuscle - CurrentHeadmuscule
        local headmuscleGained = 0

        headmuscleGained = headmuscleGained + HammerData.HeadmuscleGain

        --Check for stats, pets, etc

        if CurrentHeadmuscule + headmuscleGained <= currentStorageSpace then
            self.Data.Headmuscle = CurrentHeadmuscule + headmuscleGained
        elseif CurrentHeadmuscule + headmuscleGained > currentStorageSpace then
            headmuscleGained = MaxHeadmuscle - CurrentHeadmuscule
            self.Data.Headmuscle = CurrentHeadmuscule + headmuscleGained
        end

        PlayerProfilesService.Client.ClientHeadmusclePopup:Fire(self._Player, headmuscleGained)
        ProfilePlayer:SetAttribute("Headmuscle",  self.Data.Headmuscle)
    end

    --Load Max Headmuscle
    local Bucket = BucketService:GetBucketData(ProfileData.Bucket)

    profile.TempData.MaxHeadmuscle = profile.TempData.MaxHeadmuscle + Bucket.HeadmuscleStorage

    --Set Attributes
    ProfilePlayer:SetAttribute("MaxHeadmuscle", profile.TempData.MaxHeadmuscle)
    ProfilePlayer:SetAttribute("Headmuscle", ProfileData.Headmuscle)
    ProfilePlayer:SetAttribute("Hammer", ProfileData.Hammer)
    ProfilePlayer:SetAttribute("Bucket", ProfileData.Bucket)
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
            profile.TempData.LastHammerHead = tick()
            profile.TempData.MaxHeadmuscle = 0

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