local tvState = {
    isPlaying = false,
    url = "",
    entity = nil
}

-- Handle TV stream sync from client
RegisterServerEvent('tvscript:syncTVStream')
AddEventHandler('tvscript:syncTVStream', function(url, playing, entity)
    tvState.isPlaying = playing
    tvState.url = url
    tvState.entity = entity

    -- Broadcast to all clients with entity info
    TriggerClientEvent('tvscript:updateTV', -1, url, playing, entity)
end)

-- Provide initial state to newly joined players
AddEventHandler('playerConnecting', function()
    if tvState.isPlaying then
        TriggerClientEvent('tvscript:updateTV', source, tvState.url, tvState.isPlaying, tvState.entity)
    end
end)
