--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Knit = require(ReplicatedStorage.Knit)
local ProfileService = Knit.GetService("PlayerProfilesService")

local MonetizationService = Knit.CreateService {
    Name = "MonetizationService",
    Client = {}
}

local GamepassFunctions = {
    ["ToolPurchase"] = function(ToolType, NameOfTool, Player)
        if ProfileService.Profiles[Player] then
            local Profile = ProfileService.Profiles[Player]

            if not Profile:OwnsTool(NameOfTool, ToolType) then
                Profile:PurchaseTool(NameOfTool, ToolType, 0)
            end
        end
    end;
}

local GamepassTable = {
    [7023843] = {
        Type = "ToolPurchase";
        NameOfTool = "Rainbow";
        TypeOfTool = "Hammer";
    };

    [7105809] = {
        Type = "ToolPurchase";
        NameOfTool = "Golden";
        TypeOfTool = "Hammer";
    };

    [20662654] = {
        Type = "ToolPurchase";
        NameOfTool = "Rainbow";
        TypeOfTool = "Bucket";
    };
}


function MonetizationService.ProcessPurchases(PurchaseInformation)
    print(PurchaseInformation)
end

function MonetizationService.ProcessGamepassPurchases(Player, Gamepass, Purchased)
    local GamepassData = GamepassTable[Gamepass]
    GamepassFunctions[GamepassData.Type](GamepassData.TypeOfTool, GamepassData.NameOfTool, Player)
end

function MonetizationService.CheckPlayerForPasses(player)

end

function MonetizationService:KnitInit()
    MarketplaceService.ProcessReceipt = self.ProcessPurchases
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(self.ProcessGamepassPurchases)





end

return MonetizationService