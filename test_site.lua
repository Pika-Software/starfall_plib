--@name Test Site
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

--[[-----------------
    Configuration
-----------------]]--

-- Code refresh key code (16384 - '+alt1')
local REFRESH_KEY = 16384

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local CurTime = CurTime
local dofile = dofile
local plib = plib

do

    local chipName = 'Test Site'
    NextTestSiteRefrest = NextTestSiteRefrest or 0
    hook.add('KeyPress', chipName, function( ply, key )
        if plib.IsOwner( ply ) and (key == REFRESH_KEY) then
            if NextTestSiteRefrest < CurTime() then
                plib.Log( chipName, 'Lua code on ' .. (SERVER and 'server' or 'client') .. ' refreshed!' )
                plib.fcall( dofile, 'test_site.lua' )
            end

            NextTestSiteRefrest = CurTime() + 0.025
        end
    end)

end

--[[---------------------
        Test Site
  (Wire your code down)
---------------------]]--

do

    print( 'Hello World!' )

end