# Standalone Armory for FiveM

This script is a standalone resource for FiveM that implements an armory system.

## Features

*   Allows players to access an armory to purchase or retrieve weapons and equipment.
*   User interface based on HTML/JS/CSS (NUI).
*   Flexible configuration via `config.lua`.
*   Client-side logic (`client/main.lua`) and server-side logic (`server/main.lua`).

## Configuration

The main configuration is located in the `config.lua` file. You can adjust:

*   Armory locations (coordinates).
*   Weapons and items available in each armory.
*   Prices of weapons and items.
*   Potential restrictions (by job, license, etc. - *to be adapted based on existing code*).

**Example (fictional) configuration in `config.lua`:**

```lua
Config = {}

Config.Locations = {
    {x = 100.0, y = 200.0, z = 30.0, heading = 90.0, name = "Main Armory"},
    -- Add other locations here
}

Config.ArmoryItems = {
    ["Main Armory"] = {
        { item = "weapon_pistol", price = 500, label = "Pistol" },
        { item = "weapon_carbinerifle", price = 5000, label = "Carbine Rifle" },
        { item = "ammo_pistol", price = 50, label = "Pistol Ammo (x50)"},
        -- Add other weapons/items here
    },
    -- Configure items for other armories if needed
}

-- Other possible configuration options
Config.EnableBlips = true -- Show blips on the map
Config.BlipSprite = 159 -- Sprite ID for the blip
Config.BlipScale = 0.8 -- Size of the blip
Config.BlipColour = 2 -- Color of the blip
```

## Installation

1.  Ensure you have a functional FiveM server base.
2.  Copy the `standalone_armory` folder into your server's `resources` directory.
3.  Add `ensure standalone_armory` to your `server.cfg` (or `resources.cfg`) file.
4.  Configure the script via `config.lua` according to your needs.
5.  Restart your FiveM server.

## Usage

Go to the locations defined in `config.lua` to interact with the armory. A user interface should appear allowing you to select and purchase items.

---

