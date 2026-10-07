--!strict
-- The tradeable listings: real Roblox experiences.
--
-- Static metadata only. Current prices are NOT here -- they live on the
-- server so clients cannot modify them. basePrice is only a starting value.

export type Listing = {
	id: string,
	name: string,
	ticker: string,
	basePrice: number,
}

local Listings: { Listing } = {
	{ id = "brookhaven", name = "Brookhaven RP", ticker = "BRKH", basePrice = 120 },
	{ id = "adoptme", name = "Adopt Me!", ticker = "ADPT", basePrice = 95 },
	{ id = "stealanegg", name = "Steal an Egg", ticker = "EGG", basePrice = 40 },
}

return Listings
