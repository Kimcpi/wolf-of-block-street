--!strict
-- Server-authoritative player balances.
-- This module never leaves the server, so clients cannot read or modify it.

local Wallet = {}

local STARTING_BALANCE = 1000

local balances: { [Player]: number } = {}

function Wallet.open(player: Player)
	balances[player] = STARTING_BALANCE
end

function Wallet.close(player: Player)
	balances[player] = nil
end

function Wallet.getBalance(player: Player): number
	return balances[player] or 0
end

return Wallet
