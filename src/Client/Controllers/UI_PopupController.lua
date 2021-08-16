--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Knit)
local FormatLib = require(ReplicatedStorage.Modules.FormatLibrary)
local Maid = require(Knit.Util.Maid)
local Thread = require(Knit.Util.Thread)

--Variables
local Player = game.Players.LocalPlayer

--Public Variables
local popup_time = 1

--Tween Stuff
local r = Random.new()
local tweenInformation = TweenInfo.new(popup_time, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    

--Knit Stuff
local UI_PopupController = Knit.CreateController {
    Name = "UI_PopupController";
}

local function GetRandomPosition(Frame)
    return UDim2.new(r:NextNumber(0,Frame.Size.X.Scale),0,r:NextNumber(0,Frame.Size.Y.Scale),0)
end

function UI_PopupController:PopUp(amount)
    local PlayerGui = Player.PlayerGui
    local MainPopupFrame = PlayerGui.Main.PopupFrame

    if MainPopupFrame then
        local text = Instance.new("TextLabel")
        text.Font = Enum.Font.GothamBold
        text.Text = "+"..(FormatLib.FormatStandard(amount)).." HM"
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(0.15,0,0.1,0)
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        --text.TextStrokeColor3 = Color3.fromRGB(122, 122, 122)
        --text.TextStrokeTransparency = 0
        text.Position = GetRandomPosition(MainPopupFrame)
        text.TextScaled = true
        
        text.Parent = MainPopupFrame
        
        Thread.SpawnNow(function()
            local tween = TweenService:Create(text, tweenInformation, {TextStrokeTransparency = 1, TextTransparency = 1, Position = UDim2.new(text.Position.X.Scale, text.Position.X.Offset, text.Position.Y.Scale, text.Position.Y.Offset - 30)})
            tween:Play()
            tween.Completed:Wait()
            
            text:Remove()
        end)
    end
end

function UI_PopupController:KnitStart()
    local PlayerProfileService = Knit.GetService("PlayerProfilesService")

    PlayerProfileService.ClientHeadmusclePopup:Connect(function(amount)
        self:PopUp(amount)
    end)
end

return UI_PopupController