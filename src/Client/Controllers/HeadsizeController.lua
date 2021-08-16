--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)
local Sounds = require(Knit.Util.Sounds)
local Tween = require(Knit.Util.Tween)



--Variables
local Player = game.Players.LocalPlayer

local MaxHeadSize = 1300
local HeadsizeIncrement = 0.006

local Players = {}

--Knit Stuff
local HeadsizeController = Knit.CreateController {
    Name = "HeadsizeController";
}

function HeadsizeController:updatePlayerHeadSizes()
    for _, player in pairs(Players) do
        if player:GetAttribute("Headmuscle") ~= nil then
            local PlayerHeadmucle = player:GetAttribute("Headmuscle")

            if player.Character then
                if  player.Character:FindFirstChild("Humanoid") then
                    local Humanoid = player.Character:FindFirstChild("Humanoid")

                    if player.Character.Humanoid.Health > 0 then
                        if player.Character.Head ~= nil then
                            if player.Character.Head.CollisionGroupId == 1 then
                                local makeHeadSize = PlayerHeadmucle/10 * HeadsizeIncrement

                                if makeHeadSize < MaxHeadSize then
                                    Humanoid.HeadScale.Value = makeHeadSize
                                else
                                    Humanoid.HeadScale.Value = MaxHeadSize
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function HeadsizeController:KnitStart()
    --Get all the players in the game
    for _, v in pairs(game.Players:GetPlayers()) do
        if table.find(Players, v) == nil then
            table.insert(Players, v)
        end
    end

    game.Players.PlayerAdded:connect(function(newPlayer)
        if table.find(Players, newPlayer) == nil then
            table.insert(Players, newPlayer)
        end
    end)

    game.Players.PlayerRemoving:connect(function(oldPlayer)
        if table.find(Players, oldPlayer) ~= nil then
            local i = table.find(Players, oldPlayer)
            table.remove(Players, i)
        end
    end)

    --Bind function to renderstepped
    RunService.Heartbeat:connect(function()
        self:updatePlayerHeadSizes()
    end)
end

return HeadsizeController