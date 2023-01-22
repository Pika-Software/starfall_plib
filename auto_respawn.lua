--@name Auto Respawn
--@author PrikolMen:-b
--@includedir starfall_plib
--@server

--[[-----------------
    Configuration
-----------------]]--

-- Respawn Delay in Seconds
local RESPAWN_DELAY = 3

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - Auto Respawn'

hook.add('PlayerDeath', chipName, function( ply )
    if plib.IsOwner( ply ) then
        timer.simple(RESPAWN_DELAY, function()
            if !isValid( ply ) then return end
            concmd( '+jump' )
            timer.simple(0, function()
                if !isValid( ply ) then return end
                concmd( '-jump' )

                timer.simple(0.5, function()
                    if isValid( ply ) and ply:isAlive() then
                        plib.Log( chipName, 'User has successfully resurrected!' )
                    else
                        plib.Log( chipName, 'User revival was a failure...' )
                    end
                end)
            end)
        end)
    end
end)