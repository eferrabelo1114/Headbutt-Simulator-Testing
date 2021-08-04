--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")


local Knit = require(ReplicatedStorage.Knit)
local maid = require(Knit.Util.Maid)

local Player = game.Players.LocalPlayer

local ProfileService = Knit.GetService("PlayerProfilesService")

local DB = false

--Knit Stuff
local UI_SellMenuController = Knit.CreateController {
    Name = "UI_SellMenuController";
}


function UI_SellMenuController:LoadSellMenu(MainUI)
    local SellHMUI = MainUI.UI.Pages.SellHM
    local UIController = Knit.GetController("UIController")

    SellHMUI.RemoteSell.MouseButton1Click:connect(function()
        if not DB then
            DB = true

            local success = ProfileService:SellAnywhere()

            if success then
                UIController:CloseMenu()
            end

            DB = false
        end
    end)

end

function UI_SellMenuController:KnitStart()
    local PlayerGui = Player.PlayerGui
    local MainUI = PlayerGui:WaitForChild("Main")

    self:LoadSellMenu(MainUI)
end


return UI_SellMenuController