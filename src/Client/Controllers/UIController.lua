--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Knit)
local FormatLib = require(ReplicatedStorage.Modules.FormatLibrary)
local Maid = require(Knit.Util.Maid)

--Variables
local Player = game.Players.LocalPlayer

--Knit Stuff
local UIController = Knit.CreateController {
    Name = "UIController";
}

--PublicVariables
UIController.WindowOpen = nil

function UIController:LoadCurrencyHud(MainUI)
    local HUD = MainUI.UI.HUD

    local Currency = HUD.Currency

    Player:GetAttributeChangedSignal("Headmuscle"):Connect(function()
        local PlayerHeadmuscle = Player:GetAttribute("Headmuscle")
        local PlayerMaxHeadmuscle = Player:GetAttribute("MaxHeadmuscle")
        Currency.Backpack.Amount.Text = FormatLib.FormatCompact(PlayerHeadmuscle).."/"..FormatLib.FormatCompact(PlayerMaxHeadmuscle)
    end)

    Player:GetAttributeChangedSignal("Cash"):Connect(function()
        local PlayerCash = Player:GetAttribute("Cash")
        Currency.Money.Amount.Text = "$"..FormatLib.FormatCompact(PlayerCash)
    end)

    --Load Currency Hud
    local PlayerHeadmuscle = Player:GetAttribute("Headmuscle")
    local PlayerMaxHeadmuscle = Player:GetAttribute("MaxHeadmuscle")
    local PlayerCash = Player:GetAttribute("Cash")

    Currency.Backpack.Amount.Text = FormatLib.FormatCompact(PlayerHeadmuscle).."/"..FormatLib.FormatCompact(PlayerMaxHeadmuscle)
    Currency.Money.Amount.Text = "$"..FormatLib.FormatCompact(PlayerCash)
end

function UIController:OpenMenu(Menu)

end

function UIController:ConnectUI()
    local ButtonController = Knit.GetController("UI_ButtonController")

    local PlayerGui = Player.PlayerGui
    local MainUI = PlayerGui.Main

    --Connect HUD
   self:LoadCurrencyHud(MainUI)

end

function UIController:KnitStart()
    local ProfileService = Knit.GetService("PlayerProfilesService")
 
    ProfileService.LoadPlayerUI:Connect(function()
        self:ConnectUI()
    end)
end


return UIController