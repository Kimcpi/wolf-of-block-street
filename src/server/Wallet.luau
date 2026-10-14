--!strict
-- Server-authoritative player balances.
-- This module never leaves the server, so clients cannot read or modify it.

local Wallet = {}

local STARTING_BALANCE = 1000

local balances: { [Player]: number } = {}
local cashValues: { [Player]: IntValue } = {}

local function round2(n: number): number
	return math.floor(n * 100 + 0.5) / 100
end

local function syncDisplay(player: Player)
	local display = cashValues[player]
	if display ~= nil then
		-- leaderstats shows whole dollars; the balance itself keeps cents.
		display.Value = math.floor(balances[player] or 0)
	end
end

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
	cashValues[player] = cash
end

function Wallet.close(player: Player)
	balances[player] = nil
	cashValues[player] = nil
end

function Wallet.getBalance(player: Player): number
	return balances[player] or 0
end

-- Deducts amount only if the player can afford it. Returns whether the
-- charge went through. Refuses non-positive amounts so a negative cost
-- can never be used to add money.
function Wallet.trySpend(player: Player, amount: number): boolean
	local balance = balances[player]
	if balance == nil then
		return false
	end

	if amount <= 0 or amount > balance then
		return false
	end

	balances[player] = round2(balance - amount)
	syncDisplay(player)
	return true
end

-- Adds to the balance. Refuses non-positive amounts so it can never be
-- used in reverse to drain an account.
function Wallet.credit(player: Player, amount: number)
	local balance = balances[player]
	if balance == nil or amount <= 0 then
		return
	end

	balances[player] = round2(balance + amount)
	syncDisplay(player)
end

return Wallet
