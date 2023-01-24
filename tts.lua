--@name Text-To-Speech
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

--[[-----------------
    Configuration
-----------------]]--

-- Audio volume in %
local VOLUME = 100

-- TTS hear distantion in hammer units
local HEAR_DIST = 1024

-- All chat messages will be converted to tts
local AUTO_TTS = false

-- TTS by chat command
local CHAT_COMMAND = '/ptts'

-- Dead Palyers can't talk?
local DEAD_CANT_TALK = true

-- Dead Palyers can't hear?
local DEAD_CANT_HEAR = true

-- Hide messages in chat
local HIDE_CHAT_MESSAGES = true

--[[-----------------
         Code
-----------------]]--

dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - TTS'
local ipairs = ipairs
local table = table
local plib = plib
local hook = hook
local net = net

if (CLIENT) then

    local phrases = {}

    net.receive( chipName, function()
        local ply = net.readEntity()
        if !isValid( ply ) then return end
        plib.PlayTTS(net.readString(), '3d', function( channel )
            table.insert( phrases, channel )
            channel:setPos( plib.GetEntityCenterPos( ply ) )
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
                            channel:setPos( plib.GetEntityCenterPos( owner ) )
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

    function TTS( ply, text, isTeam )
        local whoHear = {}
        local playerTeam = ply:getTeam()
        for _, pl in ipairs( find.inSphere( ply:getEyePos(), HEAR_DIST ) ) do
            if pl:isPlayer() and ( !DEAD_CANT_HEAR or ply:isAlive()) and (!isTeam or pl:getTeam() == playerTeam) then
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
    end

    hook.add('PostPlayerSay', chipName, function( ply, text, isTeam )
        if !plib.IsOwner( ply ) then return end
        if !AUTO_TTS or string.startWith( text, '/' ) then
            return
        end

        return TTS( ply, text, isTeam )
    end)

    plib.ChatCommandAdd(CHAT_COMMAND, function( ply, _, __, text, isTeam )
        if !plib.IsOwner( ply ) then return end
        TTS( ply, text, isTeam )
    end)

end
