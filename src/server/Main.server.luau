--!strict
-- Server entry point.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Wallet = require(script.Parent.Wallet)
local Market = require(script.Parent.Market)
local Listings = require(ReplicatedStorage.Shared.Listings)

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

		for _, listing in Listings do
			print(string.format("%s $%.2f", listing.ticker, Market.getPrice(listing.id)))
		end
	end
end)
