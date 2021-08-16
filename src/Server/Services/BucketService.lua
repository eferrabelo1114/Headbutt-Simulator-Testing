--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Knit)
local BucketLibrary = require(ReplicatedStorage.Modules.BucketLibrary)

local BucketService = Knit.CreateService {
    Name = "BucketService",
    Client = {}
}

function BucketService:GetBucketData(bucketName)
    return BucketLibrary[bucketName]
end



return BucketService