--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Knit)
local FormatLib = require(ReplicatedStorage.Modules.FormatLibrary)
local Maid = require(Knit.Util.Maid)

--Variables
local Player = game.Players.LocalPlayer
local UIMaid = Maid.new()

--Knit Stuff
local UIController = Knit.CreateController {
    Name = "UIController";
}

--PublicVariables
UIController.WindowOpen = nil

function UIController:LoadCurrencyHud(MainUI)
    local HUD = MainUI:FindFirstChild("UI"):FindFirstChild("HUD")
    local Currency = HUD:WaitForChild("Currency")

    UIMaid:GiveTask(Player:GetAttributeChangedSignal("Headmuscle"):Connect(function()
        local PlayerHeadmuscle = Player:GetAttribute("Headmuscle")
        local PlayerMaxHeadmuscle = Player:GetAttribute("MaxHeadmuscle")
        Currency.Backpack.Amount.Text = FormatLib.FormatCompact(PlayerHeadmuscle).."/"..FormatLib.FormatCompact(PlayerMaxHeadmuscle)
    end))

    UIMaid:GiveTask(Player:GetAttributeChangedSignal("Cash"):Connect(function()
        local PlayerCash = Player:GetAttribute("Cash")
        Currency.Money.Amount.Text = "$"..FormatLib.FormatCompact(PlayerCash)
    end))

    --Load Currency Hud
    local PlayerHeadmuscle = Player:GetAttribute("Headmuscle")
    local PlayerMaxHeadmuscle = Player:GetAttribute("MaxHeadmuscle")
    local PlayerCash = Player:GetAttribute("Cash")

    print(Currency:GetChildren())
    print(Currency.Backpack.Amount.Text)

    Currency.Backpack.Amount.Text = FormatLib.FormatCompact(PlayerHeadmuscle).."/"..FormatLib.FormatCompact(PlayerMaxHeadmuscle)
    Currency.Money.Amount.Text = "$"..FormatLib.FormatCompact(PlayerCash)
end

function UIController:OpenMenu(Menu)

end

function UIController:ConnectUI()
    local ButtonController = Knit.GetController("UI_ButtonController")

    local PlayerGui = Player.PlayerGui
    local MainUI = PlayerGui:WaitForChild("Main")

    --Connect HUD
   self:LoadCurrencyHud(MainUI)
end

function UIController:KnitStart()
    self:ConnectUI()
end


return UIController