local isPlaying = false
local tvUrl = ""
local tvHandle = nil

-- Function to play TV
function PlayTV(url)
    if isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"TV", "^1Already playing something!^7"},
            color = {255, 0, 0}
        })
        return
    end

    if not url or url == "" then
        TriggerEvent('chat:addMessage', {
            args = {"TV", "^1Invalid URL provided!^7"},
            color = {255, 0, 0}
        })
        return
    end

    tvUrl = url
    isPlaying = true

    -- Request the TV model
    RequestModel(GetHashKey("v_res_m_tv"))
    while not HasModelLoaded(GetHashKey("v_res_m_tv")) do
        Wait(0)
    end

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    -- Spawn TV in front of player
    tvHandle = CreateObject(GetHashKey("v_res_m_tv"), pedCoords.x, pedCoords.y, pedCoords.z - 1, false, false, false)
    
    -- Set TV to play
    SetBlockingOfNonTemporaryEvents(tvHandle, true)
    
    -- Display notification
    TriggerEvent('chat:addMessage', {
        args = {"TV", "^2Now playing: ^7" .. url},
        color = {0, 255, 0}
    })

    -- Stream the video
    TriggerServerEvent('tvscript:syncTVStream', url, true)
end

-- Function to pause TV
function PauseTV()
    if not isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"TV", "^1Nothing is playing!^7"},
            color = {255, 0, 0}
        })
        return
    end

    TriggerEvent('chat:addMessage', {
        args = {"TV", "^3TV paused^7"},
        color = {255, 165, 0}
    })

    TriggerServerEvent('tvscript:syncTVStream', tvUrl, false)
end

-- Function to stop TV
function StopTV()
    if not isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"TV", "^1Nothing is playing!^7"},
            color = {255, 0, 0}
        })
        return
    end

    isPlaying = false
    tvUrl = ""

    if tvHandle ~= nil then
        DeleteEntity(tvHandle)
        tvHandle = nil
    end

    TriggerEvent('chat:addMessage', {
        args = {"TV", "^1TV stopped^7"},
        color = {255, 0, 0}
    })

    TriggerServerEvent('tvscript:syncTVStream', "", false)
end

-- Commands
RegisterCommand('tvplay', function(source, args, rawCommand)
    local url = args[1]
    if not url then
        TriggerEvent('chat:addMessage', {
            args = {"TV", "^1Usage: /tvplay {url}^7"},
            color = {255, 0, 0}
        })
        return
    end
    PlayTV(url)
end, false)

RegisterCommand('tvpause', function(source, args, rawCommand)
    PauseTV()
end, false)

RegisterCommand('tvstop', function(source, args, rawCommand)
    StopTV()
end, false)

-- Handle server events
RegisterNetEvent('tvscript:updateTV')
AddEventHandler('tvscript:updateTV', function(url, playing)
    if playing and url ~= "" then
        isPlaying = true
        tvUrl = url
    else
        isPlaying = false
        tvUrl = ""
        if tvHandle ~= nil then
            DeleteEntity(tvHandle)
            tvHandle = nil
        end
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if tvHandle ~= nil then
            DeleteEntity(tvHandle)
            tvHandle = nil
        end
    end
end)
