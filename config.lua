-- config.lua
Config = {}

-- List of Ammu-Nation locations (x, y, z coordinates)
-- You can find these coordinates in-game or online
Config.Locations = {
    { name = "Ammu-Nation Pillbox Hill", coords = vector3(21.85, -1106.7, 29.8) },
    { name = "Ammu-Nation Chumash", coords = vector3(-330.4, 6083.8, 31.45) },
    { name = "Ammu-Nation La Mesa", coords = vector3(810.7, -2157.0, 29.6) },
    { name = "Ammu-Nation Tataviam Mountains", coords = vector3(2568.8, 293.3, 108.7) },
    { name = "Ammu-Nation Paleto Bay", coords = vector3(-1117.9, 2696.9, 18.55) },
    { name = "Ammu-Nation Sandy Shores", coords = vector3(1693.0, 3759.5, 34.7) },
    -- Add other locations if needed
}

-- List of available weapons and ammunition
-- 'name' is the displayed name, 'weapon' is the weapon hash (findable online), 'price' is the price
-- For ammo, 'ammoFor' specifies the weapon hash it's for, 'ammoCount' the quantity
Config.Items = {
    -- Weapons
    { name = "Pistol", weapon = `WEAPON_PISTOL`, price = 500 },
    { name = "Pump Shotgun", weapon = `WEAPON_PUMPSHOTGUN`, price = 1500 },
    { name = "Carbine Rifle", weapon = `WEAPON_CARBINERIFLE`, price = 5000 },

    -- Ammunition
    { name = "Pistol Ammo (x24)", ammoFor = `WEAPON_PISTOL`, ammoCount = 24, price = 50 },
    { name = "Shotgun Ammo (x16)", ammoFor = `WEAPON_PUMPSHOTGUN`, ammoCount = 16, price = 80 },
    { name = "Rifle Ammo (x60)", ammoFor = `WEAPON_CARBINERIFLE`, ammoCount = 60, price = 120 },
}

-- Distance at which the player can interact
Config.InteractionDistance = 2.0

-- Key to interact
Config.InteractionKey = 38 -- E key by default (see https://docs.fivem.net/docs/game-references/controls/)