--[[
Eventually re-write to have every single UI element in a table as an object.
Each object will hold the Element's current connections with a maid.
This will maximize efficency.

But this will work for now :)
--]]

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Knit)
local FormatLib = require(ReplicatedStorage.Modules.FormatLibrary)
local Maid = require(Knit.Util.Maid)
local Tween = require(Knit.Util.Tween)
local Sounds = require(Knit.Util.Sounds)

--Variables
local Player = game.Players.LocalPlayer
local UIMaid = Maid.new()

local ActiveElements = {}
local UIPages = {}

--Tweems
local UIHoverTween = TweenInfo.new(0)

--Knit Stuff
local UIController = Knit.CreateController {
    Name = "UIController";
}

--PublicVariables
UIController.WindowOpen = nil

function UIController:CreateHovertype(UIElement) 
    ActiveElements[UIElement] = {}
    ActiveElements[UIElement].OriginalPosition = UIElement.Position
    ActiveElements[UIElement].MouseIn = false
    ActiveElements[UIElement].MouseClicked = false
    ActiveElements[UIElement].Maid = Maid.new()

    local function connectHoverAnims()
        --Mouse Enters Task
        ActiveElements[UIElement].Maid:GiveTask(UIElement.MouseEnter:connect(function()
            if not ActiveElements[UIElement].MouseIn then
                Tween:tween(UIElement, {"Position"}, {UDim2.new(ActiveElements[UIElement].OriginalPosition.X.Scale, ActiveElements[UIElement].OriginalPosition.X.Offset, ActiveElements[UIElement].OriginalPosition.Y.Scale, ActiveElements[UIElement].OriginalPosition.Y.Offset - 3)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                Sounds:PlaySound("Hover", Player)
                ActiveElements[UIElement].MouseIn = true
            end
        end))

        --Mouse Leaves Task
        ActiveElements[UIElement].Maid:GiveTask(UIElement.MouseLeave:connect(function()
            if ActiveElements[UIElement].MouseIn then
                Tween:tween(UIElement, {"Position"}, {ActiveElements[UIElement].OriginalPosition}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                ActiveElements[UIElement].MouseIn = false
            end
        end))

        --Mouse Click Task
        ActiveElements[UIElement].Maid:GiveTask(UIElement.MouseButton1Down:connect(function()
            if ActiveElements[UIElement].MouseIn and not ActiveElements[UIElement].MouseClicked then
                ActiveElements[UIElement].MouseClicked = true
                local tweenDown = Tween:tween(UIElement, {"Position"}, {UDim2.new(ActiveElements[UIElement].OriginalPosition.X.Scale, ActiveElements[UIElement].OriginalPosition.X.Offset, ActiveElements[UIElement].OriginalPosition.Y.Scale, ActiveElements[UIElement].OriginalPosition.Y.Offset + 3)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                Sounds:PlaySound("Click", Player)
                tweenDown.Completed:Wait()
                Tween:tween(UIElement, {"Position"}, {UDim2.new(ActiveElements[UIElement].OriginalPosition.X.Scale, ActiveElements[UIElement].OriginalPosition.X.Offset, ActiveElements[UIElement].OriginalPosition.Y.Scale, ActiveElements[UIElement].OriginalPosition.Y.Offset - 3)}, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                ActiveElements[UIElement].MouseClicked = false
            end
        end))
    end

    connectHoverAnims()
end

function UIController:LoadUIAnimations(MainUI)
    for _,UIElement in pairs(MainUI:GetDescendants()) do
        if UIElement:IsA("ImageButton") or UIElement:IsA("TextButton") then
            if UIElement:GetAttribute("Hover_Type") ~= nil then
                self:CreateHovertype(UIElement)
            end
        elseif UIElement.Parent.Name == "Pages" then
            UIPages[UIElement.Name] = UIElement
            UIElement.Visible = false
        end
    end
end

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

    Currency.Backpack.Amount.Text = FormatLib.FormatCompact(PlayerHeadmuscle).."/"..FormatLib.FormatCompact(PlayerMaxHeadmuscle)
    Currency.Money.Amount.Text = "$"..FormatLib.FormatCompact(PlayerCash)
end

function UIController:CloseMenu()
    if UIController.WindowOpen then
        Sounds:PlaySound("Slide2", Player)
        UIController.WindowOpen.Visible = false
    end

    UIMaid.CurrentCloseConnection:Disconnect()
    UIController.WindowOpen = nil
end

function UIController:OpenMenu(Menu)
    if UIController.WindowOpen then
        UIController.WindowOpen.Visible = false
    end

    local Element = UIPages[Menu]
    UIController.WindowOpen = Element

    local function findCloseButton(UI)
        for _,v in pairs(UI:GetDescendants()) do
            if v.Name == "Close" then
                return v
            end
        end
    end
    local CloseButton = findCloseButton(Element)

    if CloseButton then
       UIMaid.CurrentCloseConnection = CloseButton.MouseButton1Click:connect(function()
           self:CloseMenu()
       end)
    end

    Sounds:PlaySound("Slide1", Player)
    UIController.WindowOpen.Visible = true
end

function UIController:ResetUI()
    if UIController.WindowOpen then
        UIController.WindowOpen.Visible = false
        UIController.WindowOpen = nil
    end
end

function UIController:ConnectUI()
    local ButtonController = Knit.GetController("UI_ButtonController")

    local PlayerGui = Player.PlayerGui
    local MainUI = PlayerGui:WaitForChild("Main")

    for element,elementData in pairs(ActiveElements) do
        elementData.Maid:DoCleaning()
    end
    ActiveElements = {}

    self:LoadUIAnimations(MainUI)

    --Connect HUD
   self:LoadCurrencyHud(MainUI)
end

function UIController:KnitStart()
    self:ConnectUI()

    Player.CharacterAdded:connect(function()
        Player.Character:WaitForChild("Humanoid")
        Player.Character.Humanoid.Died:connect(function()
            self:ResetUI()
        end)
    end)
end


return UIController