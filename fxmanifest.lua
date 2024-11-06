fx_version 'cerulean'

game "gta5"

author "Byte Labs"
version '1.0.69'
description 'Byte Labs Ped Dialog.'
repository 'https://github.com/Byte-Labs-Project/bl_dialog'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

ui_page 'build/index.html'
-- ui_page 'http://localhost:3000/' --for dev

client_script {
    'data/config.lua',
    'client/**.lua',
    '@bl_bridge/imports/client.lua',
}

server_script{
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_script '@ox_lib/init.lua'

files {
    'build/**',
}

dependency{
    'ox_lib',
    'oxmysql'
}