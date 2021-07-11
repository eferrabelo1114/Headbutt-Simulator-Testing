--Services
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Maid = require(Knit.Util.Maid)

--Knit Stuff
local GunshopController = Knit.CreateController {
    Name = "GunshopController";
    GunshopMaid = Maid.new();
}

--Variables
local Player = game.Players.LocalPlayer
local UIOpen = false

function GunshopController:ToggleUI(toggle)
    if toggle then
        for _, element in pairs(GunshopController.UIContainer) do
            if element:GetAttribute("MainUI") then
                element.Visible = true 
            else
               element.Visible = false 
            end
        end
    else
        for _, element in pairs(GunshopController.UIContainer) do
            if element:GetAttribute("MainUI") then
                element.Visible = false 
            end
        end

        GunshopController.UIContainer["OpenButton"].Visible = true
    end
end

function GunshopController:CreateUIConnections()
    local PlayerGui = Player.PlayerGui
    local GunshopUI = PlayerGui:WaitForChild("Gun Shop")

    --Different UI aspects
    GunshopController.UIContainer = {}
    for _,uiElement in pairs(GunshopUI:GetChildren()) do
        GunshopController.UIContainer[uiElement.Name] = uiElement
    end

    --Create Connections
    GunshopController.GunshopMaid:GiveTask(GunshopController.UIContainer["OpenButton"].MouseButton1Click:connect(function()
        if not UIOpen then
            UIOpen = true
            GunshopController:ToggleUI(true)
        end
    end))

    GunshopController.GunshopMaid:GiveTask(GunshopController.UIContainer["BackButton"].MouseButton1Click:connect(function()
        if UIOpen then
            GunshopController:ToggleUI(false)
            UIOpen = false
        end
    end))
end





function GunshopController:KnitStart()
    

    Player.CharacterAppearanceLoaded:Connect(function()
        GunshopController:CreateUIConnections()
    end)

    GunshopController:CreateUIConnections()
end

return GunshopController