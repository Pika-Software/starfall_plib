--@name Chip Manager
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

dofile( 'starfall_plib/init.lua' )
--[[-----------------
    Configuration
-----------------]]--

local CHIPS = {
    ['chat_translator'] = { SHARED, true },
    ['jiggles_flex'] = { CLIENT, false },
    ['wall_watcher'] = { SHARED, true },
    ['auto_respawn'] = { SERVER, true },
    ['test_site'] = { SHARED, false },
    ['prop_gun'] = { SERVER, false },
    ['healing'] = { SERVER, true },
    ['respawn'] = { SHARED, true },
    ['shield'] = { SERVER, false },
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