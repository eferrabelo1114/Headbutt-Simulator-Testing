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

    ["PassPurchase"] = function(DataType, Player)
        if ProfileService.Profiles[Player] then
            local Profile = ProfileService.Profiles[Player]

            if not Profile.TempData[DataType] then
                Profile.TempData[DataType] = true
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

    [20662661] = {
        Type = "PassPurchase";
        DataType = "CanSellAnywhere"
    };
}


function MonetizationService.ProcessPurchases(PurchaseInformation)
    print(PurchaseInformation)
end

function MonetizationService.ProcessGamepassPurchases(Player, Gamepass, Purchased)
    local GamepassData = GamepassTable[Gamepass]
    if GamepassData ~= nil then
        if GamepassData.Type == "ToolPurchase" then
            GamepassFunctions[GamepassData.Type](GamepassData.TypeOfTool, GamepassData.NameOfTool, Player)
        elseif GamepassData.Type == "PassPurchase" then
            GamepassFunctions[GamepassData.Type](GamepassData.DataType, Player)
        end
    end
end

function MonetizationService.CheckPlayerForPasses(player)
    local Profile = ProfileService.Profiles[player]

    for GamepassID, GamepassData in pairs(GamepassTable) do
        if MarketplaceService:UserOwnsGamePassAsync(player.UserId, GamepassID) then
            if GamepassData.Type == "ToolPurchase" then
                if Profile:OwnsTool(GamepassData.NameOfTool, GamepassData.TypeOfTool) == false then
                    GamepassFunctions["ToolPurchase"](GamepassData.TypeOfTool, GamepassData.NameOfTool, player)
                end
            end
        end
    end
end

function MonetizationService:KnitInit()
    MarketplaceService.ProcessReceipt = self.ProcessPurchases
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(self.ProcessGamepassPurchases)

    for _, player in pairs(game.Players:GetPlayers()) do
        self.CheckPlayerForPasses(player)
    end

    game.Players.PlayerAdded:connect(function(player)
        self.CheckPlayerForPasses(player)
    end)
end

return MonetizationService