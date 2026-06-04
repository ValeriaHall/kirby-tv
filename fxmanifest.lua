fx_version 'cerulean'
game 'gta5'

author 'PiperNelson'
description 'TV Script for FiveM'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    '/server:5181',
    '/onesync'
}
