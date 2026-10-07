--!strict
-- Server entry point.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Wallet = require(script.Parent.Wallet)
local Listings = require(ReplicatedStorage.Shared.Listings)

Players.PlayerAdded:Connect(function(player: Player)
	Wallet.open(player)
	print(string.format("%s joined with $%d", player.Name, Wallet.getBalance(player)))
end)

Players.PlayerRemoving:Connect(function(player: Player)
	Wallet.close(player)
end)

for _, listing in Listings do
	print(string.format("Listing: %s (%s) at $%d", listing.name, listing.ticker, listing.basePrice))
end
