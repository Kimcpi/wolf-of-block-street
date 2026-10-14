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

-- Shared gate for every trade. On success returns the validated listing
-- id, quantity and the server's own price; on failure a reason string.
local function validateTrade(listingId: unknown, quantity: unknown): (string?, number?, number?, string?)
	if typeof(listingId) ~= "string" or not validIds[listingId] then
		return nil, nil, nil, "Unknown listing"
	end

	if typeof(quantity) ~= "number" then
		return nil, nil, nil, "Invalid quantity"
	end

	-- Rejects fractions, zero and negatives. A negative quantity would
	-- otherwise invert the arithmetic and pay the player.
	if quantity ~= math.floor(quantity) or quantity < 1 or quantity > MAX_QUANTITY_PER_TRADE then
		return nil, nil, nil, "Invalid quantity"
	end

	local price = Market.getPrice(listingId)
	if price <= 0 then
		return nil, nil, nil, "No price available"
	end

	return listingId, quantity, price, nil
end

local function onBuy(player: Player, listingId: unknown, quantity: unknown): (boolean, string)
	local id, qty, price, reason = validateTrade(listingId, quantity)
	if id == nil or qty == nil or price == nil then
		return false, reason or "Invalid trade"
	end

	if not Wallet.trySpend(player, price * qty) then
		return false, "Not enough cash"
	end

	Holdings.add(player, id, qty)
	return true, "OK"
end

local function onSell(player: Player, listingId: unknown, quantity: unknown): (boolean, string)
	local id, qty, price, reason = validateTrade(listingId, quantity)
	if id == nil or qty == nil or price == nil then
		return false, reason or "Invalid trade"
	end

	-- Shares come out first. Only a confirmed removal earns a payout, so
	-- selling what you do not own can never produce cash.
	if not Holdings.tryRemove(player, id, qty) then
		return false, "You do not own that many shares"
	end

	Wallet.credit(player, price * qty)
	return true, "OK"
end

function Trading.start()
	local remotes = Instance.new("Folder")
	remotes.Name = "Remotes"

	local buy = Instance.new("RemoteFunction")
	buy.Name = "Buy"
	buy.OnServerInvoke = onBuy
	buy.Parent = remotes

	local sell = Instance.new("RemoteFunction")
	sell.Name = "Sell"
	sell.OnServerInvoke = onSell
	sell.Parent = remotes

	remotes.Parent = ReplicatedStorage
end

return Trading
