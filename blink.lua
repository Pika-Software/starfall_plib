--@name Blink
--@author PrikolMen:-b
--@includedir starfall_plib
--@server

--[[-----------------
    Configuration
-----------------]]--

-- Maximum Blink Distance
local MAX_DIST = 100000

-- Bind - bind t +grenade1
local BIND = 8388608

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local Vector = Vector
local plib = plib

local chipName = 'PLib - Blink'

do

    local util_TraceLine = trace.trace

    local downOffset = Vector( 0, 0, -100 )
    local upOffset = Vector( 0, 0, 5 )

    hook.add('KeyPress', chipName, function( ply, key )
        if plib.IsOwner( ply ) and (key == BIND) and ply:isAlive() then
            local eyePos, aimVector, onlyWorld = ply:getEyePos(), ply:getAimVector(), ply:keyDown( 262144 )
            local forwardTrace = util_TraceLine( eyePos, eyePos + ( aimVector * MAX_DIST ), ply, onlyWorld and 81931 or 33570827, onlyWorld and 1 or 0 )
            if forwardTrace.Hit then
                local pos = forwardTrace.HitPos + forwardTrace.Normal * ply:obbMins()
                local downTrace = util_TraceLine( pos, pos + downOffset, ply, 81931, 1 )
                if downTrace.Hit then
                    pos = downTrace.HitPos + aimVector * -10 + upOffset
                end

                plib.TeleportOwner( pos )
            end
        end
    end)

end

do

    local isstring = isstring
    local ipairs = ipairs
    local find = find

    local offset = 40
    local tpOffsets = {
        Vector( offset, 0, 0 ),
        Vector( -offset, 0, 0 ),
        Vector( 0, offset, 0 ),
        Vector( 0, -offset, 0 )
    }

    hook.add('PrePlayerSay', chipName, function( ply, text, isTeam )
        if isTeam then return end
        if plib.IsOwner( ply ) then
            local args = string.split( text, ' ' )
            if (args[1] == '/ptp') then
                if ply:isAlive() then
                    if isstring( args[2] ) then
                        local plys = find.playersByName( args[2] )
                        if (plys) then
                            local target = find.closest( plys, plib.Owner:getPos() )
                            if isValid( target ) then
                                if target:isAlive() then
                                    for _, vec in ipairs( tpOffsets ) do
                                        local pos = target:localToWorld( vec )
                                        if pos:isInWorld() then
                                            plib.TeleportOwner( pos, target:getEyeAngles() )
                                            plib.Log( chipName, 'Teleported to: ' .. target:getName() )
                                            break
                                        end
                                    end
                                else
                                    plib.Log( chipName, target:getName() .. ' is dead!' )
                                end
                            end
                        end
                    end
                else
                    plib.Log( chipName, 'You cannot teleport while dead!' )
                end

                return ''
            end
        end
    end)

end
