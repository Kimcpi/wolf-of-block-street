--!strict
-- Server-authoritative share ownership.
--
-- The holdings table is the truth. The Portfolio folder parented to each
-- Player is a display mirror, replicated so the client can draw counts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Listings = require(ReplicatedStorage.Shared.Listings)

local Holdings = {}

local holdings: { [Player]: { [string]: number } } = {}
local displays: { [Player]: { [string]: IntValue } } = {}

function Holdings.open(player: Player)
	local owned: { [string]: number } = {}
	local mirror: { [string]: IntValue } = {}

	local folder = Instance.new("Folder")
	folder.Name = "Portfolio"

	for _, listing in Listings do
		owned[listing.id] = 0

		local value = Instance.new("IntValue")
		value.Name = listing.id
		value.Value = 0
		value.Parent = folder

		mirror[listing.id] = value
	end

	holdings[player] = owned
	displays[player] = mirror
	folder.Parent = player
end

function Holdings.close(player: Player)
	holdings[player] = nil
	displays[player] = nil
end

function Holdings.get(player: Player, listingId: string): number
	local owned = holdings[player]
	if owned == nil then
		return 0
	end
	return owned[listingId] or 0
end

function Holdings.add(player: Player, listingId: string, quantity: number)
	local owned = holdings[player]
	if owned == nil then
		return
	end

	owned[listingId] = (owned[listingId] or 0) + quantity

	local mirror = displays[player]
	if mirror ~= nil and mirror[listingId] ~= nil then
		mirror[listingId].Value = owned[listingId]
	end
end

return Holdings
