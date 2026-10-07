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

local function round2(n: number): number
	return math.floor(n * 100 + 0.5) / 100
end

function Market.start()
	for _, listing in Listings do
		prices[listing.id] = listing.basePrice
	end
end

-- The seam: the only place prices change.
-- Today this is a random walk. Later it reads live Roblox statistics.
function Market.tick()
	for id, price in prices do
		local move = rng:NextNumber(-MAX_MOVE, MAX_MOVE)
		prices[id] = math.max(MIN_PRICE, round2(price * (1 + move)))
	end
end

function Market.getPrice(id: string): number
	return prices[id] or 0
end

return Market
