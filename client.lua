local isPlaying = false
local tvUrl = ""
local scaleformHandle = nil
local targetEntity = nil
local playbackTime = 0
local videoDuration = 0

-- Function to extract YouTube video ID
function GetYouTubeVideoId(url)
    if not url then return nil end
    
    local id = string.match(url, "youtu%.be/([a-zA-Z0-9_-]+)")
    if id then return id end
    
    id = string.match(url, "youtube%.com/watch%?v=([a-zA-Z0-9_-]+)")
    if id then return id end
    
    id = string.match(url, "youtube%.com/embed/([a-zA-Z0-9_-]+)")
    if id then return id end
    
    return nil
end

-- Function to find nearby TV props
function FindNearbyTVProps()
    local entities = {}
    for _, prop in ipairs(Config.Props) do
        local hash = GetHashKey(prop)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(0)
        end
        
        local handle, entity = FindFirstObject(hash)
        local success = false
        
        if handle ~= -1 then
            repeat
                if DoesEntityExist(entity) then
                    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity))
                    if dist < 50 then
                        table.insert(entities, entity)
                    end
                end
                success, entity = FindNextObject(handle)
            until not success
            EndFindObject(handle)
        end
        
        ReleaseModel(hash)
    end
    
    return entities
end

-- Function to play YouTube video on TV props
function PlayYouTubeOnTVs(url)
    if not url or url == "" then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Invalid URL provided!^7"},
            color = {255, 0, 0}
        })
        return
    end
    
    local videoId = GetYouTubeVideoId(url)
    if not videoId then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Invalid YouTube URL!^7"},
            color = {255, 0, 0}
        })
        return
    end
    
    tvUrl = url
    isPlaying = true
    playbackTime = 0
    
    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^2Now playing YouTube video!^7"},
        color = {0, 255, 0}
    })
    
    -- Sync with server
    TriggerServerEvent('tvscript:syncTVStream', url, true)
end

-- Function to pause playback
function PauseDevice()
    if not isPlaying then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Nothing is playing!^7"},
            color = {255, 0, 0}
        })
        return
    end
    
    isPlaying = false
    
    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^3Paused^7"},
        color = {255, 165, 0}
    })
    
    TriggerServerEvent('tvscript:syncTVStream', tvUrl, false)
end

-- Function to stop playback
function StopDevice()
    isPlaying = false
    tvUrl = ""
    playbackTime = 0
    targetEntity = nil
    
    if scaleformHandle then
        SetScaleformMovieAsNoLongerNeeded(scaleformHandle)
        scaleformHandle = nil
    end
    
    TriggerEvent('chat:addMessage', {
        args = {"Screen", "^1Stopped^7"},
        color = {255, 0, 0}
    })
    
    TriggerServerEvent('tvscript:syncTVStream', "", false)
end

-- Chat Commands
RegisterCommand('tvplay', function(source, args, rawCommand)
    local url = table.concat(args, " ")
    if not url or url == "" then
        TriggerEvent('chat:addMessage', {
            args = {"Screen", "^1Usage: /tvplay {youtube_url}^7"},
            color = {255, 0, 0}
        })
        return
    end
    PlayYouTubeOnTVs(url)
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
        playbackTime = 0
    else
        isPlaying = false
        tvUrl = ""
    end
end)

-- Main render loop to display video on props
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if isPlaying and tvUrl ~= "" then
            local entities = FindNearbyTVProps()
            
            if #entities > 0 then
                -- Draw on first entity found for now
                local entity = entities[1]
                local coords = GetEntityCoords(entity)
                
                -- Create scaleform if needed
                if not scaleformHandle then
                    scaleformHandle = GetScaleformMovie("YOUTUBE")
                    if scaleformHandle ~= 0 then
                        local videoId = GetYouTubeVideoId(tvUrl)
                        PushScaleformMovieFunctionVoid(scaleformHandle, "SET_VIDEO_ID")
                        PushScaleformMovieFunctionString(scaleformHandle, videoId)
                        PopScaleformMovieFunctionVoid()
                    end
                end
                
                if scaleformHandle ~= 0 then
                    -- Render scaleform on screen (simplified approach)
                    DrawScaleformMovieFullScreen(scaleformHandle, 255, 255, 255, 255, 0)
                end
            end
        else
            if scaleformHandle then
                SetScaleformMovieAsNoLongerNeeded(scaleformHandle)
                scaleformHandle = nil
            end
        end
    end
end)
