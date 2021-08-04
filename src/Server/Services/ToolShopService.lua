--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local HammerLibrary = require(ReplicatedStorage.Modules.HammerLibrary)
local BucketLibrary = require(ReplicatedStorage.Modules.BucketLibrary)

local ProfileService = Knit.GetService("PlayerProfilesService")

--Variables
local ToolShopService = Knit.CreateService {
    Name = "ToolShopService",
    Client = {}
}

local ToolTypeData = {
    ["Hammer"] = HammerLibrary;
    ["Bucket"] = BucketLibrary;

}

--Events


--Functions



function ToolShopService.Client:PurchaseTool(player, toolType, toolName)
    local Success, Response = false, "Failed to purchase."

    if ProfileService.Profiles[player] then
        local Profile = ProfileService.Profiles[player]

        if ToolTypeData[toolType][toolName] then
            local tool = ToolTypeData[toolType][toolName]

            if not Profile:OwnsTool(toolName, toolType) then

                if Profile.Data.Cash >= tool.Price then

                    Profile:PurchaseTool(toolName, toolType, tool.Price)
                    Success = true
                    Response = "Purchased"
                else
                    Response = "Cannot Afford!"
                end

            end

        end
    end

    return Success, Response
end








return ToolShopService