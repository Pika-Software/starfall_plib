--@name Chip Manager
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

dofile( 'starfall_plib/init.lua' )
--[[-----------------
    Configuration
-----------------]]--
local CHIPS = {
    ['entity_teleporter'] = { SERVER, false },
    ['chat_translator'] = { SHARED, true },
    ['jiggles_flex'] = { CLIENT, true },
    ['auto_respawn'] = { SERVER, false },
    ['wall_watcher'] = { SHARED, false },
    ['anti_blind'] = { CLIENT, false },
    ['test_site'] = { SHARED, false },
    ['reflection'] = { SERVER, false },
    ['prop_gun'] = { SERVER, false },
    ['healing'] = { SERVER, false },
    ['respawn'] = { SHARED, false },
    ['shield'] = { SERVER, false },
    ['aimbot'] = { CLIENT, false },
    ['blink'] = { SERVER, true },
    ['tts'] = { SHARED, true }
}

--[[-----------------
         Code
-----------------]]--
local dofile = dofile
local pcall = pcall
local plib = plib

for fileName, data in pairs( CHIPS ) do
    if data[2] then
        if data[1] then
            local ok, err = pcall( dofile, fileName .. '.lua' )
            plib.Log( 'Chip Manager', fileName .. ': ' .. ( ok and 'OK' or 'FAILED' ) )
            if ok then continue end
            plib.Log( fileName .. '.lua', err )
        end
    else
        plib.Log( 'Chip Manager', fileName .. ': ' .. 'OFF' )
    end
end