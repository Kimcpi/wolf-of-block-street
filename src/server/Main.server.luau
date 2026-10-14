--!strict
-- Server entry point.

local Players = game:GetService("Players")

local Wallet = require(script.Parent.Wallet)
local Market = require(script.Parent.Market)

local TICK_SECONDS = 5

Players.PlayerAdded:Connect(function(player: Player)
	Wallet.open(player)
	print(string.format("%s joined with $%d", player.Name, Wallet.getBalance(player)))
end)

Players.PlayerRemoving:Connect(function(player: Player)
	Wallet.close(player)
end)

Market.start()

task.spawn(function()
	while true do
		task.wait(TICK_SECONDS)
		Market.tick()
	end
end)
