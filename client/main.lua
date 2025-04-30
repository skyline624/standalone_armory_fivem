-- client/main.lua
local nearArmory = false
local currentArmory = nil
local isMenuOpen = false

-- Function to draw 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale) -- Adjust size here
        SetTextFont(4) -- Chalet London font
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255) -- White
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- Main client loop
Citizen.CreateThread(function()
    -- Create Blips for armories on the map
    for _, armory in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(armory.coords)
        SetBlipSprite(blip, 110) -- Ammu-Nation sprite
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 0) -- Default red
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(armory.name)
        EndTextCommandSetBlipName(blip)
    end

    while true do
        Citizen.Wait(1) -- Wait 1ms to avoid overload

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local isInMarker = false
        local closestArmory = nil

        -- Check proximity to armories
        for i, armory in ipairs(Config.Locations) do
            local distance = #(playerCoords - armory.coords) -- Vector distance calculation

            if distance < Config.InteractionDistance then
                isInMarker = true
                closestArmory = armory
                currentArmory = i -- Store the index of the nearby armory
                -- Display a marker on the ground (optional)
                DrawMarker(1, armory.coords.x, armory.coords.y, armory.coords.z - 0.98, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 100, false, true, 2, nil, nil, false)
                -- Display interaction text
                DrawText3D(armory.coords.x, armory.coords.y, armory.coords.z + 0.5, "Press [E] to open the armory") -- Translated text

                -- Check if the player presses the interaction key
                if IsControlJustReleased(0, Config.InteractionKey) and not isMenuOpen then
                    OpenArmoryMenu()
                end
                break -- Exit the loop if near an armory
            end
        end

        nearArmory = isInMarker

        -- If the player moves away and the menu is open, close it
        if not nearArmory and isMenuOpen then
            CloseArmoryMenu()
        end

        -- Disable shooting if the menu is open
        if isMenuOpen then
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 25, true) -- Aim
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
        end
    end
end)

-- Function to open the NUI menu
function OpenArmoryMenu()
    isMenuOpen = true
    SetNuiFocus(true, true) -- Give focus to the NUI interface (mouse control)
    -- Send items to the NUI interface
    SendNUIMessage({
        action = "open",
        items = Config.Items
    })
end

-- Function to close the NUI menu
function CloseArmoryMenu()
    isMenuOpen = false
    SetNuiFocus(false, false) -- Give focus back to the game
    SendNUIMessage({
        action = "close"
    })
end

-- NUI Callback to handle actions from the interface (e.g., purchase)
RegisterNUICallback('buyItem', function(data, cb)
    -- data contains the item index purchased (as sent initially by JS, 0-based)
    local jsIndex = data.itemIndex
    if jsIndex == nil then
        print("Error: Item index not received from NUI.") -- Translated log
        cb('error')
        return
    end

    -- Convert JS index (0-based) to Lua index (1-based)
    local luaIndex = jsIndex + 1

    -- Check if the Lua index is valid in our Config.Items table
    if Config.Items[luaIndex] then
        -- Send the event to the server to process the purchase WITH THE CORRECT LUA INDEX
        TriggerServerEvent('armory:buyItem', luaIndex)
        -- We could add visual feedback here (e.g., "Purchase in progress...")
        cb('ok') -- Respond to NUI that the action was received
    else
        -- Display a more detailed error for debugging
        print("Error: Invalid item index received from NUI. JS index received: " .. tostring(jsIndex) .. ", Lua index attempted: " .. tostring(luaIndex)) -- Translated log
        cb('error')
    end
end)

-- NUI Callback to close the menu from the interface (e.g., close button or Escape key)
RegisterNUICallback('closeMenu', function(data, cb)
    CloseArmoryMenu()
    cb('ok')
end)

-- Event received from the server to confirm the purchase and give the item
RegisterNetEvent('armory:giveItem')
AddEventHandler('armory:giveItem', function(itemIndex) -- itemIndex received from server is already the correct Lua index (1-based)
    local item = Config.Items[itemIndex]
    if not item then
        print("Client Error: Attempted to give an invalid item (index: " .. tostring(itemIndex) .. ")") -- Translated log
        return
    end

    local playerPed = PlayerPedId()

    if item.weapon then -- It's a weapon
        GiveWeaponToPed(playerPed, item.weapon, 100, false, true) -- Give weapon with 100 initial ammo (adjustable)
        print("Weapon purchased: " .. item.name) -- Translated log
        -- Add a notification to the player (optional)
        -- ShowNotification("You purchased: " .. item.name)
    elseif item.ammoFor and item.ammoCount then -- It's ammunition
        AddAmmoToPed(playerPed, item.ammoFor, item.ammoCount)
        print("Ammo purchased for: " .. item.name) -- Translated log
        -- Add a notification to the player (optional)
        -- ShowNotification("You purchased: " .. item.name)
    end
end)

-- Simple function to display a notification (requires a notification resource or implementation)
-- function ShowNotification(message)
--     SetNotificationTextEntry("STRING")
--     AddTextComponentString(message)
--     DrawNotification(false, true)
-- end

-- Handle Escape key to close the menu
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isMenuOpen and IsControlJustReleased(0, 200) then -- 200 = INPUT_FRONTEND_CANCEL (Escape)
            CloseArmoryMenu()
        end
    end
end)