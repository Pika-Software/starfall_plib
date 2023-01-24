--@name Shield
--@author PrikolMen:-b
--@includedir starfall_plib
--@server

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - Shield'
local pcall = pcall
local plib = plib
local hook = hook

hook.add('think', chipName, function()
    local ok, ent = pcall( prop.create, plib.GetEntityCenterPos( plib.Owner ), plib.Owner:getAngles(), 'models/hunter/blocks/cube6x6x6.mdl', true )
    if (ok) then
        hook.remove( 'think', chipName )
        hook.add( 'think', chipName, function()
            ent:setNoDraw( true )
            ent:setCollisionGroup( 11 )
            ent:setAngles( plib.Owner:getAngles() )
            ent:setPos( plib.GetEntityCenterPos( plib.Owner ) )
        end)
    end
end)