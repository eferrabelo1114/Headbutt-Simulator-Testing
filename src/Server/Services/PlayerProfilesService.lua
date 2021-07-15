--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")

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

--Public Variables
local Default_Hitspeed = 0.3

--Events
PlayerProfilesService.Client.PlayerEquippedHammer = RemoteSignal.new()
PlayerProfilesService.Client.ClientHeadmusclePopup = RemoteSignal.new()

local ProfileTemplate = {
    Cash = 0;
    Headmuscle = 0;
    TotalHeadmuscle = 0;
    Hammer = "Default";
    OwnedHammers = {"Default"};
    Bucket = "Default";
    Rebirth = 0;
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

--Function Stuff
function PlayerProfilesService:EquipBucket(player)
    local HammerService = Knit.Services.BucketService

    if self.Profiles[player] then
        local Profile = self.Profiles[player]
        local EquippedBucket = Profile.Data.Bucket
        local BucketData = HammerService:GetBucketData(EquippedBucket)
    
        local newBucket = nil

        if player.Character then
            if player.Character:FindFirstChild("Bucket") then
                newBucket = player.Character:FindFirstChild("Bucket")
            end
        end

        if newBucket == nil then
            newBucket = game.ReplicatedStorage:FindFirstChild("Bucket"):Clone()
            player.Character.Humanoid:AddAccessory(newBucket)
        end

        newBucket.Handle.Mesh.TextureId = "rbxassetid://"..BucketData.Texture
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

    function profile:GiveCash(amount)
        self.Data.Cash = self.Data.Cash + amount
        self._Player:SetAttribute("Cash", self.Data.Cash)
    end

    function profile:SellHeadmuscle()
        if self.Data.Headmuscle > 0 then
            local rewardCash = 0

            --Check if there are any selling bonus
            
            rewardCash = self.Data.Headmuscle
            self.Data.Headmuscle = 0

            self._Player:SetAttribute("Headmuscle", self.Data.Headmuscle)
            self:GiveCash(rewardCash)
        end
    end

    function profile:AddHeadmuscleNormal()
        local HammerData = HammerService:GetHammerData(self.Data.Hammer)
        local MaxHeadmuscle = self.TempData.MaxHeadmuscle
        local CurrentHeadmuscule = self.Data.Headmuscle

        local currentStorageSpace = MaxHeadmuscle - CurrentHeadmuscule
        local headmuscleGained = 0

        if currentStorageSpace >= 0 then
            headmuscleGained = headmuscleGained + HammerData.HeadmuscleGain

            --Check for stats, pets, etc

            if CurrentHeadmuscule + headmuscleGained <= MaxHeadmuscle then
                self.Data.Headmuscle = CurrentHeadmuscule + headmuscleGained
            elseif CurrentHeadmuscule + headmuscleGained > MaxHeadmuscle then
                headmuscleGained = headmuscleGained - ((CurrentHeadmuscule + headmuscleGained) - MaxHeadmuscle)

                if headmuscleGained > 0 then
                    self.Data.Headmuscle = CurrentHeadmuscule + headmuscleGained
                end
            end

            if headmuscleGained > 0 then
                PlayerProfilesService.Client.ClientHeadmusclePopup:Fire(self._Player, headmuscleGained)
                self.Data.TotalHeadmuscle = self.Data.TotalHeadmuscle + headmuscleGained
                ProfilePlayer:SetAttribute("Headmuscle",  self.Data.Headmuscle)
            end
        else
           warn(self._Player.Name.." fired addheadmuscle event with full inventory") 
        end
    end

    --Load Max Headmuscle
    local Bucket = BucketService:GetBucketData(ProfileData.Bucket)

    profile.TempData.MaxHeadmuscle = profile.TempData.MaxHeadmuscle + Bucket.HeadmuscleStorage

    --Set Attributes
    ProfilePlayer:SetAttribute("MaxHeadmuscle", profile.TempData.MaxHeadmuscle)
    ProfilePlayer:SetAttribute("Headmuscle", ProfileData.Headmuscle)
    ProfilePlayer:SetAttribute("Hammer", ProfileData.Hammer)
    ProfilePlayer:SetAttribute("Bucket", ProfileData.Bucket)
    ProfilePlayer:SetAttribute("Cash", ProfileData.Cash)
    ProfilePlayer:SetAttribute("Rebirths", ProfileData.Rebirth)
    ProfilePlayer:SetAttribute("TotalHeadmuscle", profile.TempData.MaxHeadmuscle)
    ProfilePlayer:SetAttribute("HammerDelay", profile.TempData.HammerDelay)

    --Leaderboards
    local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = ProfilePlayer

    local TotalHeadmuscleLEaderstat = Instance.new("IntValue")
    TotalHeadmuscleLEaderstat.Value = ProfilePlayer:GetAttribute("TotalHeadmuscle")
    TotalHeadmuscleLEaderstat.Name = "Total Headmuscle"
    TotalHeadmuscleLEaderstat.Parent = leaderstats

    ProfilePlayer:GetAttributeChangedSignal("TotalHeadmuscle"):connect(function()
        TotalHeadmuscleLEaderstat.Value = ProfilePlayer:GetAttribute("TotalHeadmuscle")
    end)

    local CashLeaderstat = Instance.new("IntValue")
    CashLeaderstat.Value = ProfilePlayer:GetAttribute("Cash")
    CashLeaderstat.Name = "Cash"
    CashLeaderstat.Parent = leaderstats

    ProfilePlayer:GetAttributeChangedSignal("Cash"):connect(function()
        CashLeaderstat.Value = ProfilePlayer:GetAttribute("Cash")
    end)

    local RebirthLeaderstat = Instance.new("IntValue")
    RebirthLeaderstat.Value = ProfilePlayer:GetAttribute("Rebirths")
    RebirthLeaderstat.Name = "Rebirths"
    RebirthLeaderstat.Parent = leaderstats

    ProfilePlayer:GetAttributeChangedSignal("Rebirths"):connect(function()
        RebirthLeaderstat.Value = ProfilePlayer:GetAttribute("Rebirths")
    end)

 
end

function PlayerProfilesService:LoadPlayerCharacter(player)
    if self.Profiles[player] then
        local Profile = self.Profiles[player]
        local Character = player.Character or player.CharacterAdded:Wait()

        PhysicsService:SetPartCollisionGroup(Character.Head, "Heads")

        self:EquipHammer(player)
        self:EquipBucket(player)

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
            profile.TempData.HammerDelay = Default_Hitspeed

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