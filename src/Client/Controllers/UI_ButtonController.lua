--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Knit = require(ReplicatedStorage.Knit)
local maid = require(Knit.Util.Maid)

--Knit Stuff
local UI_ButtonController = Knit.CreateController {
    Name = "UI_ButtonController";
}


return UI_ButtonController