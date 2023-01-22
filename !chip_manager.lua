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
    ['wall_watcher'] = { SHARED, true },
    ['auto_respawn'] = { SERVER, true },
    ['test_site'] = { SHARED, false },
    ['healing'] = { SERVER, true },
    ['respawn'] = { SHARED, true },
    ['blink'] = { SERVER, true },
    ['tts'] = { SHARED, true }
}

--[[-----------------
         Code
-----------------]]--
local dofile = dofile
local plib = plib

for fileName, data in pairs( CHIPS ) do
    if data[2] then
        if data[1] then
            plib.Log( 'Chip Manager', fileName .. ': ' .. ( plib.fcall( dofile, fileName .. '.lua' ) and 'OK' or 'FAILED' ) )
        end
    else
        plib.Log( 'Chip Manager', fileName .. ': ' .. 'OFF' )
    end
end