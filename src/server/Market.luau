--!strict
-- Server-authoritative share prices.
--
-- Prices live here and nowhere else. Clients are told values later via a
-- replicated copy, but never write to this table.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Listings = require(ReplicatedStorage.Shared.Listings)

local Market = {}

local MAX_MOVE = 0.03 -- most a price can move in one tick, as a fraction
local MIN_PRICE = 1

local prices: { [string]: number } = {}
local rng = Random.new()

-- Display mirrors in ReplicatedStorage, readable by clients.
-- A client can edit its local copy, but that only changes what it draws:
-- every trade is priced from the server table above.
local priceValues: { [string]: NumberValue } = {}

local function round2(n: number): number
	return math.floor(n * 100 + 0.5) / 100
end

function Market.start()
	local folder = Instance.new("Folder")
	folder.Name = "MarketState"

	for _, listing in Listings do
		prices[listing.id] = listing.basePrice

		local value = Instance.new("NumberValue")
		value.Name = listing.id
		value.Value = listing.basePrice
		value.Parent = folder

		priceValues[listing.id] = value
	end

	-- Parented last, after its children exist, so the whole folder
	-- replicates in one go rather than child by child.
	folder.Parent = ReplicatedStorage
end

-- The seam: the only place prices change.
-- Today this is a random walk. Later it reads live Roblox statistics.
function Market.tick()
	for id, price in prices do
		local move = rng:NextNumber(-MAX_MOVE, MAX_MOVE)
		prices[id] = math.max(MIN_PRICE, round2(price * (1 + move)))
		priceValues[id].Value = prices[id]
	end
end

function Market.getPrice(id: string): number
	return prices[id] or 0
end

return Market
