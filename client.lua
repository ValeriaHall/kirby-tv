local isPlaying = false
local tvUrl = ""

-- Function to play TV/Device
function PlayDevice(url)
    if not url or url == "" then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Invalid URL provided!^7"},
            color = {255, 0, 0}
        })
        return
    end

    tvUrl = url
    isPlaying = true
    
    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^2Now playing: ^7" .. url},
        color = {0, 255, 0}
    })

    -- Sync with server
    TriggerServerEvent('tvscript:syncTVStream', url, true)
end

-- Function to pause device
function PauseDevice()
    if not isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Nothing is playing!^7"},
            color = {255, 0, 0}
        })
        return
    end

    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^3Paused^7"},
        color = {255, 165, 0}
    })

    TriggerServerEvent('tvscript:syncTVStream', tvUrl, false)
end

-- Function to stop device
function StopDevice()
    if not isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Nothing is playing!^7"},
            color = {255, 0, 0}
        })
        return
    end

    isPlaying = false
    tvUrl = ""

    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^1Stopped^7"},
        color = {255, 0, 0}
    })

    TriggerServerEvent('tvscript:syncTVStream', "", false)
end

-- Chat Commands
RegisterCommand('tvplay', function(source, args, rawCommand)
    local url = args[1]
    if not url then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Usage: /tvplay {url}^7"},
            color = {255, 0, 0}
        })
        return
    end
    PlayDevice(url)
end, false)

RegisterCommand('tvpause', function(source, args, rawCommand)
    PauseDevice()
end, false)

RegisterCommand('tvstop', function(source, args, rawCommand)
    StopDevice()
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
    end
end)
