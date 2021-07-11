local Knit = require(game:GetService("ReplicatedStorage").Knit)

local TestService = Knit.CreateService {
    Name = "TestService";
}

function TestService:KnitStart()
    print("Test")
end

return TestService