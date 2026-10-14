--!strict
-- The client-facing trade API.
--
-- Everything arriving here came from a player machine and is untrusted.
-- Argument types, ranges and affordability are all checked server side,
-- and the price is looked up here rather than accepted from the caller.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Listings = require(ReplicatedStorage.Shared.Listings)
local Market = require(script.Parent.Market)
local Wallet = require(script.Parent.Wallet)
local Holdings = require(script.Parent.Holdings)

local MAX_QUANTITY_PER_TRADE = 100

local Trading = {}

local validIds: { [string]: boolean } = {}
for _, listing in Listings do
	validIds[listing.id] = true
end

local function onBuy(player: Player, listingId: unknown, quantity: unknown): (boolean, string)
	if typeof(listingId) ~= "string" or not validIds[listingId] then
		return false, "Unknown listing"
	end

	if typeof(quantity) ~= "number" then
		return false, "Invalid quantity"
	end

	-- Rejects fractions, zero and negatives. A negative quantity would
	-- otherwise produce a negative cost and pay the player.
	if quantity ~= math.floor(quantity) or quantity < 1 or quantity > MAX_QUANTITY_PER_TRADE then
		return false, "Invalid quantity"
	end

	local price = Market.getPrice(listingId)
	if price <= 0 then
		return false, "No price available"
	end

	local cost = price * quantity

	if not Wallet.trySpend(player, cost) then
		return false, "Not enough cash"
	end

	Holdings.add(player, listingId, quantity)
	return true, "OK"
end

function Trading.start()
	local remotes = Instance.new("Folder")
	remotes.Name = "Remotes"

	local buy = Instance.new("RemoteFunction")
	buy.Name = "Buy"
	buy.OnServerInvoke = onBuy
	buy.Parent = remotes

	remotes.Parent = ReplicatedStorage
end

return Trading
