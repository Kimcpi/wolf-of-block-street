--!strict
-- Client UI: a panel showing the player's cash and live listing prices.
--
-- Built in code rather than drawn in Studio so it lives in Git and syncs
-- through Rojo like every other source file.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Listings = require(ReplicatedStorage.Shared.Listings)

local ROW_HEIGHT = 26

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- MarketState is created at runtime by the server, so it may not exist
-- yet when this script first runs.
local marketState = ReplicatedStorage:WaitForChild("MarketState")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MarketUI"
screenGui.ResetOnSpawn = false

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(260, 0)
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

local function makeRow(order: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, ROW_HEIGHT)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Code
	label.TextSize = 16
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = ""
	label.LayoutOrder = order
	label.Parent = panel
	return label
end

local title = makeRow(1, Color3.fromRGB(120, 200, 140))
title.Text = "WOLF OF BLOCK STREET"

local cashLabel = makeRow(2, Color3.fromRGB(240, 240, 240))

local cash = player:WaitForChild("leaderstats"):WaitForChild("Cash") :: IntValue

local function updateCash()
	cashLabel.Text = string.format("CASH   $%d", cash.Value)
end

updateCash()
cash:GetPropertyChangedSignal("Value"):Connect(updateCash)

for index, listing in Listings do
	local value = marketState:WaitForChild(listing.id) :: NumberValue
	local row = makeRow(index + 2, Color3.fromRGB(200, 205, 215))

	local function update()
		row.Text = string.format("%-6s $%.2f", listing.ticker, value.Value)
	end

	update()
	value:GetPropertyChangedSignal("Value"):Connect(update)
end

screenGui.Parent = playerGui
