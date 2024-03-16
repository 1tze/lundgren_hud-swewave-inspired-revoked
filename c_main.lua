local isHudVisible = false
local hunger = -1
local thirst = -1

RegisterNUICallback('ready', function(data, callback)
    if data.show then 
        Wait(500)
        SendNUIMessage({
            action = 'show'
        })
        isHudVisible = true
    end
end)

local lastValues = {
    health = -1,
    armour = -1,
    hunger = -1,
    thirst = -1,
    fuel = -1,
    speed = -1,
    isPaused = false
}

if not Config.ESX then
    RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
        hunger = newHunger
        thirst = newThirst
    end)
end

Citizen.CreateThread(function()
    while true do
        if isHudVisible then
            local isPaused = IsPauseMenuActive()
            if isPaused ~= lastValues.isPaused then
                SendNUIMessage({action = 'hide', opacity = isPaused and 0 or 1})
                lastValues.isPaused = isPaused
            end

            local player = PlayerPedId()
            local health = math.max(GetEntityHealth(player) - 100, 0)
            local armour = GetPedArmour(player)

            if Config.ESX then
                hunger = exports["esx-qalle-foodmechanics"]:GetData("hunger")["current"] / 700000 * 100
                thirst = exports["esx-qalle-foodmechanics"]:GetData("thirst")["current"] / 700000 * 100
            end

            SendIfChanged('health', health, lastValues.health)
            SendIfChanged('armour', armour, lastValues.armour)
            SendIfChanged('hunger', hunger, lastValues.hunger)
            SendIfChanged('thirst', thirst, lastValues.thirst)
        end
        Citizen.Wait(1000)
    end
end)

function SendIfChanged(action, value, lastValue)
    if value ~= lastValue then
        SendNUIMessage({action = action, [action] = value})
        lastValues[action] = value
    end
end
