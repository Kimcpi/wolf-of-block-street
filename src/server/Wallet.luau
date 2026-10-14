--!strict
-- Server-authoritative player balances.
-- This module never leaves the server, so clients cannot read or modify it.

local Wallet = {}

local STARTING_BALANCE = 1000

local balances: { [Player]: number } = {}

function Wallet.open(player: Player)
	balances[player] = STARTING_BALANCE

	-- Display mirror. A Folder named exactly "leaderstats" is rendered by
	-- Roblox in the player list. The table above stays authoritative.
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = STARTING_BALANCE
	cash.Parent = leaderstats

	leaderstats.Parent = player
end

function Wallet.close(player: Player)
	balances[player] = nil
end

function Wallet.getBalance(player: Player): number
	return balances[player] or 0
end

return Wallet
