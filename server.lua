local tvState = {
    isPlaying = false,
    url = ""
}

-- Handle TV stream sync from client
RegisterServerEvent('tvscript:syncTVStream')
AddEventHandler('tvscript:syncTVStream', function(url, playing)
    tvState.isPlaying = playing
    tvState.url = url

    -- Broadcast to all clients
    TriggerClientEvent('tvscript:updateTV', -1, url, playing)
end)

-- Provide initial state to newly joined players
AddEventHandler('playerConnecting', function()
    if tvState.isPlaying then
        TriggerClientEvent('tvscript:updateTV', source, tvState.url, tvState.isPlaying)
    end
end)
