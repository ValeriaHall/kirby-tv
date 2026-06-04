local isPlaying = false
local tvUrl = ""
local targetedEntity = nil

-- Function to play TV/Device
function PlayDevice(url, entity)
    if not url or url == "" then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Invalid URL provided!^7"},
            color = {255, 0, 0}
        })
        return
    end

    if not entity or not DoesEntityExist(entity) then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Invalid screen!^7"},
            color = {255, 0, 0}
        })
        return
    end

    tvUrl = url
    targetedEntity = entity
    isPlaying = true
    
    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^2Now playing: ^7" .. url},
        color = {0, 255, 0}
    })

    -- Sync with server - only this specific entity
    TriggerServerEvent('tvscript:syncTVStream', url, true, entity)
end

-- Function to pause device
function PauseDevice(entity)
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

    TriggerServerEvent('tvscript:syncTVStream', tvUrl, false, entity)
end

-- Function to stop device
function StopDevice(entity)
    if not isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Nothing is playing!^7"},
            color = {255, 0, 0}
        })
        return
    end

    isPlaying = false
    tvUrl = ""
    targetedEntity = nil

    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^1Stopped^7"},
        color = {255, 0, 0}
    })

    TriggerServerEvent('tvscript:syncTVStream', "", false, entity)
end

-- Add target option for TV props
if GetResourceState('ox_target') == 'started' then
    exports.ox_target:addModel(Config.Props, {
        {
            name = 'tvplay',
            label = '📺 Play Video',
            icon = 'fa-solid fa-play',
            onSelect = function(data)
                TriggerEvent('tvscript:openInputDialog', data.entity)
            end
        },
        {
            name = 'tvpause',
            label = '⏸ Pause',
            icon = 'fa-solid fa-pause',
            onSelect = function(data)
                PauseDevice(data.entity)
            end
        },
        {
            name = 'tvstop',
            label = '⏹ Stop',
            icon = 'fa-solid fa-stop',
            onSelect = function(data)
                StopDevice(data.entity)
            end
        }
    })
elseif GetResourceState('qb-target') == 'started' then
    for _, prop in ipairs(Config.Props) do
        exports['qb-target']:AddTargetModel(GetHashKey(prop), {
            options = {
                {
                    type = "client",
                    event = "tvscript:openInputDialog",
                    icon = "fa-solid fa-play",
                    label = "📺 Play Video"
                },
                {
                    type = "client",
                    event = "tvscript:pauseTV",
                    icon = "fa-solid fa-pause",
                    label = "⏸ Pause"
                },
                {
                    type = "client",
                    event = "tvscript:stopTV",
                    icon = "fa-solid fa-stop",
                    label = "⏹ Stop"
                }
            },
            distance = 2.5
        })
    end
end

-- Input dialog event
RegisterNetEvent('tvscript:openInputDialog')
AddEventHandler('tvscript:openInputDialog', function(entity)
    -- For ox_target with built-in input
    if GetResourceState('ox_lib') == 'started' then
        local input = exports.ox_lib:inputDialog('Play Video', {
            {
                type = 'input',
                label = 'Video URL',
                placeholder = 'https://example.com/video.mp4',
                required = true
            }
        })
        
        if input then
            PlayDevice(input[1], entity)
        end
    else
        -- Fallback to chat command
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^3Enter URL: ^7/tvplayurl {url}^7"},
            color = {255, 165, 0}
        })
    end
end)

RegisterNetEvent('tvscript:pauseTV')
AddEventHandler('tvscript:pauseTV', function(entity)
    PauseDevice(entity)
end)

RegisterNetEvent('tvscript:stopTV')
AddEventHandler('tvscript:stopTV', function(entity)
    StopDevice(entity)
end)

-- Fallback commands
RegisterCommand('tvplay', function(source, args, rawCommand)
    local url = args[1]
    if not url then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Usage: /tvplay {url}^7"},
            color = {255, 0, 0}
        })
        return
    end
    PlayDevice(url, targetedEntity)
end, false)

RegisterCommand('tvpause', function(source, args, rawCommand)
    PauseDevice(targetedEntity)
end, false)

RegisterCommand('tvstop', function(source, args, rawCommand)
    StopDevice(targetedEntity)
end, false)

-- Handle server events
RegisterNetEvent('tvscript:updateTV')
AddEventHandler('tvscript:updateTV', function(url, playing, entity)
    if playing and url ~= "" then
        isPlaying = true
        tvUrl = url
        targetedEntity = entity
    else
        isPlaying = false
        tvUrl = ""
        targetedEntity = nil
    end
end)
