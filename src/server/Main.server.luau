--!strict
-- Server entry point.

local Players = game:GetService("Players")

local Wallet = require(script.Parent.Wallet)
local Market = require(script.Parent.Market)
local Holdings = require(script.Parent.Holdings)
local Trading = require(script.Parent.Trading)

local TICK_SECONDS = 5

-- This is a terminal, not a world. No avatar is ever spawned.
Players.CharacterAutoLoads = false

Players.PlayerAdded:Connect(function(player: Player)
	Wallet.open(player)
	Holdings.open(player)
	print(string.format("%s joined with $%d", player.Name, Wallet.getBalance(player)))
end)

Players.PlayerRemoving:Connect(function(player: Player)
	Wallet.close(player)
	Holdings.close(player)
end)

Market.start()
Trading.start()

task.spawn(function()
	while true do
		task.wait(TICK_SECONDS)
		Market.tick()
	end
end)
