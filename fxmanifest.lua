-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

author 'Alex Skyline'
description 'Simple armory script without framework'
version '1.0.0'

-- Shared configuration files
shared_script 'config.lua'

-- Client-side files
client_scripts {
    'client/main.lua'
}

-- Server-side files
server_scripts {
    'server/main.lua'
}

-- Files for the NUI interface
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}