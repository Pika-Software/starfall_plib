--@name Respawn
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

local chipName = 'PLib - Respawn'

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local isValid = isValid
local net = net

if (SERVER) then

    local table_insert = table.insert
    local timer_simple = timer.simple
    local ipairs = ipairs
    local pairs = pairs
    local plib = plib

    local lastDeathPosition = plib.Chip:getPos()
    local playerWeapons = {}

    local lastActiveWeaponClass = nil

    do
        local wep = plib.Owner:getActiveWeapon()
        if isValid( wep ) then
            lastActiveWeaponClass = wep:getClass()
        end
    end

    hook.add('PlayerSwitchWeapon', chipName, function( ply, _, wep )
        if plib.IsOwner( ply ) and ply:isAlive() then
            if ply[ chipName ] then return end
            lastActiveWeaponClass = wep:getClass()
        end
    end)

    hook.add('PlayerDeath', chipName, function( ply )
        if plib.IsOwner( ply ) then
            plib.Log( chipName, 'User is dead collecting information...' )
            lastDeathPosition = ply:getPos()

            for key, _ in pairs( playerWeapons ) do
                playerWeapons[ key ] = nil
            end

            for _, wep in ipairs( ply:getWeapons() ) do
                table_insert( playerWeapons, wep:getClass() )
            end
        end
    end)

    hook.add('PlayerSpawn', chipName, function( ply )
        if plib.IsOwner( ply ) then
            plib.Log( chipName, 'Restoring a position...' )
            ply[ chipName ] = true

            timer_simple(0, function()
                if isValid( ply ) and ply:isAlive() then
                    plib.TeleportOwner( lastDeathPosition )

                    plib.Log( chipName, 'Weapons preparation...' )
                    for _, class in ipairs( playerWeapons ) do
                        plib.GiveOwnerWeapon( class )
                    end

                    if lastActiveWeaponClass then
                        timer_simple(0.25, function()
                            if isValid( ply ) then
                                net.start( chipName )
                                net.writeString( lastActiveWeaponClass )
                                net.send( ply )

                                ply[ chipName ] = false
                                plib.Log( chipName, 'Completed!' )
                            end
                        end)
                    end
                end
            end)
        end
    end)

end

if (CLIENT) then

    local input_selectWeapon = input.selectWeapon

    net.receive(chipName, function()
        local wep = plib.Player:getWeapon( net.readString() )
        if isValid( wep ) then
            input_selectWeapon( wep )
        end
    end)

end