--@name Spawnpoint
--@author PrikolMen:-b
--@includedir starfall_plib
--@server

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - Spawnpoint'
local angOffset = Angle( 90 )
local IsValid = IsValid
local Vector = Vector
local pcall = pcall
local plib = plib

local chip = plib.Chip
if (chip:getChipName() == 'Spawnpoint') then
    chip:setCollisionGroup( 12 )
    chip:setNoDraw( true )
end

do

    local tr = plib.TraceLineUp( chip:getPos(), -100, chip )
    if tr.Hit then
        local ent = tr.Entity
        if IsValid( ent ) and (ent:getOwner() == plib.Owner) then
            chip:setMaterial( ent:getMaterial() )
            chip:setColor( ent:getColor() )
            chip:setParent( ent )
        end
    end

end

hook.Add('think', chipName, function()
    local ok, ent = pcall( prop.create, chip:getPos(), chip:getAngles() - angOffset, 'models/props_trainstation/trainstation_clock001.mdl' )
    if (ok) then
        hook.Remove('think', chipName)
        ent:setCollisionGroup( 12 )
        ent:setParent( chip )

        hook.Add('PlayerSpawn', chipName, function( ply )
            if plib.IsOwner( ply ) then
                plib.TeleportOwner( chip:getPos() - Vector( 0, 0, ply:obbMins()[3] ) )
            end
        end)
    end
end)