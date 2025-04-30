-- server/main.lua

-- Event received from the client when they attempt to buy an item
RegisterNetEvent('armory:buyItem')
AddEventHandler('armory:buyItem', function(itemIndex)
    local _source = source -- ID of the player who sent the event
    local item = Config.Items[itemIndex]

    if not item then
        print("Player " .. _source .. " attempted to buy an invalid item (index: " .. tostring(itemIndex) .. ")")
        return
    end

    print("Player " .. _source .. " is attempting to buy: " .. item.name .. " for " .. item.price)

    -- !!! MISSING MONEY LOGIC !!!
    -- Here, you should check if the player has enough money.
    -- Since there's no framework, this part needs to be implemented
    -- according to your own money system if you have one.
    -- For example:
    -- local playerMoney = GetPlayerMoney(_source) -- Hypothetical function
    -- if playerMoney >= item.price then
    --     RemovePlayerMoney(_source, item.price) -- Hypothetical function
    --     -- If money was successfully removed:
           TriggerClientEvent('armory:giveItem', _source, itemIndex) -- Inform the client to give the item
           print("Purchase validated for player " .. _source)
    -- else
    --     print("Player " .. _source .. " does not have enough money to buy " .. item.name)
    --     -- Inform the player they don't have enough money (optional)
    --     -- TriggerClientEvent('armory:showNotification', _source, "You don't have enough money.")
    -- end

    -- For this script WITHOUT a framework, we always validate the purchase for testing
    TriggerClientEvent('armory:giveItem', _source, itemIndex)
    print("Purchase validated (without money check) for player " .. _source)

end)