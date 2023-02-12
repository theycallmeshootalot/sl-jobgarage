fx_version 'cerulean'
game 'gta5'

author 'Shootalot#5812'
description 'sl-jobgarage: Job Garage | Started Development: Feb. 6th, 2023'
version '1.0'

shared_script 'config.lua'

client_scripts {
    'client/cl_police.lua',
    'client/cl_ems.lua',
    'client/cl_mechanic.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_main.lua'
}

lua54 'yes'