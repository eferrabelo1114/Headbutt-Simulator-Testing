local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Knit = require(ReplicatedStorage.Knit)

Knit.AddControllers(script.Parent:WaitForChild("Controllers"))
print("[CLIENT] Finished loading...")

Knit.Start():Catch(warn)