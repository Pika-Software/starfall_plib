--@name Respawn on Death Point
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

local chipName = 'PLib - Respawn on Death Point'

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local plib = plib

if (SERVER) then

    local lastDeathPosition = plib.Chip:getPos()
    local activeWeaponClass = nil
    local playerWeapons = {}

    hook.add('PlayerDeath', chipName, function( ply )
        if (ply:entIndex() == plib.OwnerIndex) then
            lastDeathPosition = ply:getPos()

            local activeWeapon = ply:getActiveWeapon()
            if isValid( activeWeapon ) then
                activeWeaponClass = activeWeapon:getClass()
            else
                activeWeaponClass = nil
            end

            for key, _ in pairs( playerWeapons ) do
                playerWeapons[ key ] = nil
            end

            for _, wep in ipairs( ply:getWeapons() ) do
                table.insert( playerWeapons, wep:getClass() )
            end
        end
    end)

    hook.add('PlayerSpawn', chipName, function( ply )
        if (ply:entIndex() == plib.OwnerIndex) then
            timer.simple(0.25, function()
                if isValid( ply ) and ply:isAlive() then
                    ply:setPos( lastDeathPosition )

                    for _, class in ipairs( playerWeapons ) do
                        concmd( 'gm_giveswep ' .. class )
                    end

                    if activeWeaponClass then
                        net.start( chipName )
                            net.writeString( activeWeaponClass )
                        net.send( ply )
                    end
                end
            end)
        end
    end)

end

if (CLIENT) then
    net.receive(chipName, function()
        local wep = ply:getWeapon( net.readString() )
        if isValid( wep ) then
            input.selectWeapon( wep )
        end
    end)
end