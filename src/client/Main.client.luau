--!strict
-- Client UI: a panel showing the player's cash, live listing prices,
-- share counts, and a buy button per listing.
--
-- Built in code rather than drawn in Studio so it lives in Git and syncs
-- through Rojo like every other source file.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Listings = require(ReplicatedStorage.Shared.Listings)

local ROW_HEIGHT = 26
local BUTTON_WIDTH = 46
local BUTTON_GAP = 4

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- These are created at runtime by the server, so they may not exist yet
-- when this script first runs.
local marketState = ReplicatedStorage:WaitForChild("MarketState")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local buyRemote = remotes:WaitForChild("Buy") :: RemoteFunction
local sellRemote = remotes:WaitForChild("Sell") :: RemoteFunction

local portfolio = player:WaitForChild("Portfolio")
local cash = player:WaitForChild("leaderstats"):WaitForChild("Cash") :: IntValue

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MarketUI"
screenGui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(360, 0)
panel.AutomaticSize = Enum.AutomaticSize.Y
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = panel

local function makeLabel(parent: Instance, order: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Code
	label.TextSize = 16
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = ""
	label.LayoutOrder = order
	label.Parent = parent
	return label
end

local title = makeLabel(panel, 1, Color3.fromRGB(120, 200, 140))
title.Text = "WOLF OF BLOCK STREET"

local cashLabel = makeLabel(panel, 2, Color3.fromRGB(240, 240, 240))

local function updateCash()
	cashLabel.Text = string.format("CASH   $%d", cash.Value)
end

updateCash()
cash:GetPropertyChangedSignal("Value"):Connect(updateCash)

for index, listing in Listings do
	local price = marketState:WaitForChild(listing.id) :: NumberValue
	local owned = portfolio:WaitForChild(listing.id) :: IntValue

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
	row.BackgroundTransparency = 1
	row.LayoutOrder = index + 2
	row.Parent = panel

	local buttonsWidth = BUTTON_WIDTH * 2 + BUTTON_GAP

	local label = makeLabel(row, 1, Color3.fromRGB(200, 205, 215))
	label.Size = UDim2.new(1, -buttonsWidth - 8, 1, 0)

	local function makeButton(text: string, color: Color3, offsetFromRight: number): TextButton
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(BUTTON_WIDTH, 22)
		button.Position = UDim2.new(1, -offsetFromRight, 0, 2)
		button.BackgroundColor3 = color
		button.BorderSizePixel = 0
		button.Font = Enum.Font.Code
		button.TextSize = 14
		button.TextColor3 = Color3.fromRGB(245, 245, 245)
		button.Text = text
		button.Parent = row

		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 4)
		buttonCorner.Parent = button

		return button
	end

	local buyButton = makeButton("BUY", Color3.fromRGB(40, 120, 70), buttonsWidth)
	local sellButton = makeButton("SELL", Color3.fromRGB(140, 55, 55), BUTTON_WIDTH)

	local function update()
		label.Text = string.format("%-6s $%8.2f  x%d", listing.ticker, price.Value, owned.Value)
	end

	update()
	price:GetPropertyChangedSignal("Value"):Connect(update)
	owned:GetPropertyChangedSignal("Value"):Connect(update)

	-- Both buttons send only the listing and a quantity. The server looks
	-- up the price, checks the balance or holdings, and may refuse.
	local function trade(remote: RemoteFunction, verb: string)
		local ok, message = remote:InvokeServer(listing.id, 1)
		if not ok then
			warn(string.format("%s %s failed: %s", verb, listing.ticker, tostring(message)))
		end
	end

	buyButton.Activated:Connect(function()
		trade(buyRemote, "Buy")
	end)

	sellButton.Activated:Connect(function()
		trade(sellRemote, "Sell")
	end)
end

screenGui.Parent = playerGui
