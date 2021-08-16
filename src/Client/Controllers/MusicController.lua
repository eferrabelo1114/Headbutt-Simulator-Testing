--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
 
local Knit = require(ReplicatedStorage.Knit)
local tween = require(Knit.Util.Tween)
local maid = require(Knit.Util.Maid)

--Variables
local Player = game.Players.LocalPlayer

local currentSongObject

-- Number of other songs required to play before the same song can play again
local MININUM_SONGS_REQUIRED_BETWEEN_REPEATS = 3
local DEFAULT_VOLUME = 0.3
 
local random = Random.new()
local recentlyPlayedSoundObjects = {}

local songs = {
	"rbxassetid://3544838748",
	"rbxassetid://3544822176",
	"rbxassetid://3544841210",
    "rbxassetid://3544831131",
}

local soundObjects = {}

--Knit Stuff
local MusicController = Knit.CreateController {
    Name = "MusicController";
}


local function shuffleInPlace(array)
	for index1 = #array, 2, -1 do
		local index2 = random:NextInteger(1, index1)
		array[index1], array[index2] = array[index2], array[index1]
	end
end

function MusicController:BeginCycle()
    while true do
        if not ReplicatedStorage.Music.Value then return end

        -- Randomly shuffle the given array in place (modifies the original array)
        shuffleInPlace(soundObjects)
    
        -- Enforce minimum song count required between repeated songs
        for recentlyPlayedIndex = 1, #recentlyPlayedSoundObjects do
            local recentlyPlayedSound = recentlyPlayedSoundObjects[recentlyPlayedIndex]
    
            for futureSongIndex = 1, #recentlyPlayedSoundObjects do
                local futureSoundObject = soundObjects[futureSongIndex]
    
                if recentlyPlayedSound == futureSoundObject then
                    local numIndexesToMoveForward = math.max(MININUM_SONGS_REQUIRED_BETWEEN_REPEATS - futureSongIndex - recentlyPlayedIndex + 2, 0)
    
                    if numIndexesToMoveForward > 0 then
                        table.remove(soundObjects, futureSongIndex)
                        table.insert(soundObjects, math.min(#soundObjects + 1, futureSongIndex + numIndexesToMoveForward), futureSoundObject)
                    end
                end
            end
        end
    
        -- Play all songs in the newly shuffled and constrained song array
        for currentSongIndex = 1, #soundObjects do
            currentSongObject = soundObjects[currentSongIndex]
    
            -- Play song
            
            currentSongObject:Play()
            
            currentSongObject.Ended:Wait()
        end
    
        -- Update the recently played sound objects array with the most recently played songs
        recentlyPlayedSoundObjects = {}
        for i = #soundObjects, #soundObjects - MININUM_SONGS_REQUIRED_BETWEEN_REPEATS + 1, -1 do
            table.insert(recentlyPlayedSoundObjects, soundObjects[i])
        end
    end
end

function MusicController:KnitStart()
    for _, songID in ipairs(songs) do
        local soundObject = Instance.new("Sound")
        soundObject.SoundId = songID
        soundObject.Volume = DEFAULT_VOLUME
        soundObject.Parent = SoundService
        table.insert(soundObjects, soundObject)
    end

    ReplicatedStorage.Music.Changed:connect(function()
        if not ReplicatedStorage.Music.Value then
            currentSongObject.Volume = 0
        else
            currentSongObject.Volume = DEFAULT_VOLUME
        end
    end)

    self:BeginCycle()
end

return MusicController