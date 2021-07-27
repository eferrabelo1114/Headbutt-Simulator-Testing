--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Knit = require(ReplicatedStorage.Knit)
local Maid = require(Knit.Util.Maid)
local Thread = require(Knit.Util.Thread)
local Sounds = require(Knit.Util.Sounds)
local Tween = require(Knit.Util.Tween)

local ToolShopService = Knit.GetService("ToolShopService")
local ProfileService = Knit.GetService("PlayerProfilesService")

local FormatLib = require(ReplicatedStorage.Modules.FormatLibrary)
local HammerLib = require(ReplicatedStorage.Modules.HammerLibrary)
local BucketLib = require(ReplicatedStorage.Modules.BucketLibrary)
local LayoutUtil = require(ReplicatedStorage.Modules.LayoutUtil)

--Variables
local Player = game.Players.LocalPlayer

local PurchaseEquipDB = false

local UIMaid = Maid.new()

--Events


--Knit Stuff
local UIToolShopsController = Knit.CreateController {
    Name = "UIToolShopsController";
}


function UIToolShopsController:LoadShopsInfo(MainUI)
    local Pages = MainUI.UI.Pages
    
    local Shops = {
        ["Hammer"] = {
            ["UI"] = Pages:FindFirstChild("HammerShop");
            ["Data"] = HammerLib;
            ["StatType"] = "HM/Hit";
            ["DataType"] = "HeadmuscleGain";
            ["Attribute"] = "OwnedHammers";
        }
    }

    local function playerOwnsTool(ToolType, ToolName, PlayerOwnedHammers)
        local ownsTool = false

        for _,ownedTool in pairs(PlayerOwnedHammers) do
            if ownedTool == ToolName then
                ownsTool = true
            end
        end

        return ownsTool
    end

    for toolType,toolTypeData in pairs(Shops) do
        local mainScrollElements = toolTypeData.UI.Main.Scroll:GetChildren()
        local PlayerTools = HttpService:JSONDecode(Player:GetAttribute(Shops[toolType].Attribute))
        
        for _,element in pairs(mainScrollElements) do
            if element:GetAttribute(toolType) ~= nil then
                local ToolName = element:GetAttribute(toolType)
                local ToolData = toolTypeData.Data[ToolName]

                local OwnsTool = playerOwnsTool(toolType, ToolName, PlayerTools)

                if not OwnsTool then
                    element.Buy.Amount.Text = ToolData.Price
                else
                    element.Buy.Icon.Visible = false
                    element.Buy.Amount.TextColor3 = Color3.fromRGB(255, 228, 138)

                    if Player:GetAttribute(toolType) == ToolName then
                        --Player has the hammer equipped
                        element.Buy.BackgroundColor3 = Color3.fromRGB(206, 71, 71)
                        element.Buy.Amount.Text = "Unequip"
                    else
                        element.Buy.BackgroundColor3 = Color3.fromRGB(71, 206, 82)
                        element.Buy.Amount.Text = "Equip"
                    end
                end

                element.ToolName.Text = ToolName.." "..toolType
                element.ToolStat.Text = ToolData[toolTypeData.DataType].." "..toolTypeData.StatType

                --Setup buy/equip button
                UIMaid:GiveTask(element.Buy.MouseButton1Click:connect(function()
                    if not OwnsTool then
                        if not PurchaseEquipDB then
                            PurchaseEquipDB = true

                            local success, response = ToolShopService.PurchaseTool(Player, toolType, ToolName)
                            if not success then
                                Thread.Spawn(function()
                                    element.Buy.Icon.Visible = false
                                    element.Buy.Amount.Text = response
                                    wait(1.5)
                                    element.Buy.Icon.Visible = true
                                    element.Buy.Amount.Text = ToolData.Price
                                    PurchaseEquipDB = false
                                end)
                            else
                                PurchaseEquipDB = false
                            end
                        end
                    elseif OwnsTool == true then
                        if Player:GetAttribute(toolType) == ToolName then
                            local Success = ProfileService.ChangeTool(Player, toolType, "Default")
                        else
                            local Success = ProfileService.ChangeTool(Player, toolType, ToolName)
                        end
                    end
                end))

            end
        end

       -- local layout: LayoutUtil.List = LayoutUtil.new(toolTypeData.UI.Main.Scroll) -- could be a ScrollingFrame or UIListLayout
    end
end

function UIToolShopsController:KnitStart()
    local PlayerGui = Player.PlayerGui
    local MainUI = PlayerGui:WaitForChild("Main")

    Player.AttributeChanged:connect(function(attributeName)
        if attributeName == "OwnedHammers" or attributeName == "OwnedBuckets" or attributeName == "Hammer" or attributeName == "Bucket" then
            UIMaid:DoCleaning()
            self:LoadShopsInfo(MainUI)
        end
    end)

    self:LoadShopsInfo(MainUI)
end

return UIToolShopsController