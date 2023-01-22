--@name Text-To-Speech
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

dofile( 'starfall_plib/init.lua' )
local ipairs = ipairs
local table = table
local plib = plib
local net = net

--[[-----------------
    Configuration
-----------------]]--

-- Audio volume in %
local VOLUME = 100

-- TTS hear distantion in hammer units
local HEAR_DIST = 1024

-- Dead Palyers can't talk?
local DEAD_CANT_TALK = true

-- Dead Palyers can't hear?
local DEAD_CANT_HEAR = true

-- Hide messages in chat
local HIDE_CHAT_MESSAGES = true

--[[-----------------
         Code
-----------------]]--

local chipName = 'PLib - TTS'

if (CLIENT) then

    local phrases = {}

    net.receive( chipName, function()
        local ply = net.readEntity()
        if !isValid( ply ) then return end
        plib.PlayTTS(net.readString(), '3d', function( channel )
            table.insert( phrases, channel )
            channel:setPos( plib.GetPlayerCenterPos( ply ) )
            channel:setFade( 200, HEAR_DIST * 2 )
            channel:setVolume( VOLUME / 100 )
            channel:play()
        end)
    end)

    local localPlayer = plib.Player
    local owner = plib.Owner

    hook.add('think', chipName, function()
        if isValid( owner ) then
            for num, channel in ipairs( phrases ) do
                if isValid( channel ) then
                    if ( !DEAD_CANT_TALK or owner:isAlive() ) then
                        if ( !DEAD_CANT_HEAR or localPlayer:isAlive() ) then
                            channel:setPos( plib.GetPlayerCenterPos( owner ) )
                            channel:setVolume( VOLUME / 100 )
                        else
                            channel:setVolume( 0 )
                        end
                    else
                        table.remove( phrases, num )
                        channel:stop()
                        break
                    end
                else
                    table.remove( phrases, num )
                    break
                end
            end
        else
            hook.remove( 'think', chipName )
        end
    end)

end

if (SERVER) then

    local find = find

    hook.add('PlayerSay', chipName, function( ply, text, isTeam )
        if isTeam or !plib.IsOwner( ply ) then return end
        if string.startWith( text, '/' ) then return end

        local whoHear = {}
        for _, pl in ipairs( find.inSphere( ply:getEyePos(), HEAR_DIST ) ) do
            if pl:isPlayer() and ( !DEAD_CANT_HEAR or ply:isAlive()) then
                table.insert( whoHear, pl )
            end
        end

        net.start( chipName )
            net.writeEntity( ply )
            net.writeString( text )
        net.send( whoHear )

        if HIDE_CHAT_MESSAGES then
            return ''
        end
    end)

end
