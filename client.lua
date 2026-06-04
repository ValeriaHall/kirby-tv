local isPlaying = false
local tvUrl = ""
local activeDevices = {}
local nearbyDevices = {}

-- Function to get nearby TV/Computer/Tablet devices
function GetNearbyDevices()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    nearbyDevices = {}
    local searchDistance = Config.InteractionDistance
    
    -- Create a prop hash lookup table for faster search
    local propHashes = {}
    for _, propName in ipairs(Config.Props) do
        propHashes[GetHashKey(propName)] = propName
    end
    
    -- Check all objects using EntityEnumerator
    local handle = FindFirstObject()
    local success = true
    
    if handle ~= -1 then
        repeat
            if DoesEntityExist(handle) then
                local entityCoords = GetEntityCoords(handle)
                local distance = #(pedCoords - entityCoords)
                
                if distance < searchDistance then
                    local entityModel = GetEntityModel(handle)
                    
                    -- Check if this model is in our prop list
                    if propHashes[entityModel] then
                        table.insert(nearbyDevices, {
                            entity = handle,
                            model = propHashes[entityModel],
                            coords = entityCoords,
                            distance = distance
                        })
                    end
                end
            end
            success, handle = FindNextObject(handle)
        until not success
    end
    
    return nearbyDevices
end

-- Function to draw 3D text
function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(0, 255, 0, 215)
        SetTextOutline()
        BeginTextCommandDisplayText("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

-- Function to play TV/Device
function PlayDevice(url, deviceEntity)
    if isPlaying then
        if Config.EnableNotifications then
            TriggerEvent('chat:addMessage', {
                args = {"Screen", "^1Already playing something!^7"},
                color = {255, 0, 0}
            })
        end
        return
    end

    if not url or url == "" then
        if Config.EnableNotifications then
            TriggerEvent('chat:addMessage', {
                args = {"Screen", "^1Invalid URL provided!^7"},
                color = {255, 0, 0}
            })
        end
        return
    end

    tvUrl = url
    isPlaying = true
    
    if deviceEntity then
        activeDevices[deviceEntity] = {
            url = url,
            playing = true
        }
    end
    
    if Config.EnableNotifications then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^2Now playing: ^7" .. url},
            color = {0, 255, 0}
        })
    end

    -- Sync with server
    TriggerServerEvent('tvscript:syncTVStream', url, true, deviceEntity)
end

-- Function to pause device
function PauseDevice(deviceEntity)
    if not isPlaying then
        if Config.EnableNotifications then
            TriggerEvent('chat:addMessage', {
                args = {"Screen", "^1Nothing is playing!^7"},
                color = {255, 0, 0}
            })
        end
        return
    end

    if Config.EnableNotifications then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^3Paused^7"},
            color = {255, 165, 0}
        })
    end

    if deviceEntity and activeDevices[deviceEntity] then
        activeDevices[deviceEntity].playing = false
    end

    TriggerServerEvent('tvscript:syncTVStream', tvUrl, false, deviceEntity)
end

-- Function to stop device
function StopDevice(deviceEntity)
    if not isPlaying then
        if Config.EnableNotifications then
            TriggerEvent('chat:addMessage', {
                args = {"Screen", "^1Nothing is playing!^7"},
                color = {255, 0, 0}
            })
        end
        return
    end

    isPlaying = false
    tvUrl = ""

    if deviceEntity then
        activeDevices[deviceEntity] = nil
    end

    if Config.EnableNotifications then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Stopped^7"},
            color = {255, 0, 0}
        })
    end

    TriggerServerEvent('tvscript:syncTVStream', "", false, deviceEntity)
end

-- Commands
RegisterCommand('tvplay', function(source, args, rawCommand)
    local url = args[1]
    if not url then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Usage: /tvplay {url}^7"},
            color = {255, 0, 0}
        })
        return
    end
    
    -- Get nearby devices and play on closest
    local devices = GetNearbyDevices()
    if #devices > 0 then
        table.sort(devices, function(a, b) return a.distance < b.distance end)
        PlayDevice(url, devices[1].entity)
    else
        if Config.EnableNotifications then
            TriggerEvent('chat:addMessage', {
                args = {"Screen", "^1No nearby screens found! Try getting closer (within 3 meters).^7"},
                color = {255, 0, 0}
            })
        end
    end
end, false)

RegisterCommand('tvpause', function(source, args, rawCommand)
    local devices = GetNearbyDevices()
    if #devices > 0 then
        table.sort(devices, function(a, b) return a.distance < b.distance end)
        PauseDevice(devices[1].entity)
    else
        PauseDevice(nil)
    end
end, false)

RegisterCommand('tvstop', function(source, args, rawCommand)
    local devices = GetNearbyDevices()
    if #devices > 0 then
        table.sort(devices, function(a, b) return a.distance < b.distance end)
        StopDevice(devices[1].entity)
    else
        StopDevice(nil)
    end
end, false)

-- Main loop to show device labels
Citizen.CreateThread(function()
    while true do
        Wait(100)
        
        local devices = GetNearbyDevices()
        
        if #devices > 0 then
            -- Sort by distance
            table.sort(devices, function(a, b) return a.distance < b.distance end)
            
            -- Show nearby devices (max 5 at a time)
            for i = 1, math.min(5, #devices) do
                local device = devices[i]
                local label = "[" .. i .. "] " .. device.model .. " - " .. string.format("%.2f", device.distance) .. "m"
                Draw3DText(device.coords.x, device.coords.y, device.coords.z + 0.5, label)
            end
        end
    end
end)

-- Handle server events
RegisterNetEvent('tvscript:updateTV')
AddEventHandler('tvscript:updateTV', function(url, playing, deviceEntity)
    if playing and url ~= "" then
        isPlaying = true
        tvUrl = url
        if deviceEntity then
            activeDevices[deviceEntity] = {
                url = url,
                playing = true
            }
        end
    else
        isPlaying = false
        tvUrl = ""
        if deviceEntity then
            activeDevices[deviceEntity] = nil
        end
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        activeDevices = {}
        nearbyDevices = {}
    end
end)
