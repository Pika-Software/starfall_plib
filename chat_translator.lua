--@name Chat Translator
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

--[[-----------------
    Configuration
-----------------]]--

-- Translate messages from other players
local TRANSLATE_OTHER_PLAYERS_MESSAGES = true
local TRANSLATE_FRIENDS_MESSAGES = false

-- Translate your chat messages
local TRANSLATE_YOUR_MESSAGES = false

-- The language in which your messages will be translated. (https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
local TRANSLATE_LANGUAGE = 'pl'

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - Chat Translator'
local string = string
local plib = plib
local hook = hook
local http = http
local net = net

if CLIENT and plib.PlayerIsOwner then

    local queue = {}
    hook.add('PlayerChat', chipName, function( ply, text )
        if !TRANSLATE_OTHER_PLAYERS_MESSAGES then return end
        if plib.IsOwner( ply ) then return end
        if string.IsURL( text ) then return end
        if !TRANSLATE_FRIENDS_MESSAGES and (ply:getFriendStatus() == 'friend') then return end
        local playerNick, playerColor = ply:getName(), plib.GetPlayerTeamColor( ply )

        local tbl = {
            ['ID'] = -1
        }

        tbl.Function = function()
            plib.TranslateText( text, TRANSLATE_LANGUAGE, plib.GetLanguage(), function( ok, result, languageCode )
                if (languageCode == plib.GetLanguage()) then return end
                plib.Log( 'Chat Translator', playerColor, playerNick, plib.White, ': ' .. result )
                if (tbl.ID != -1) then
                    table.remove( queue, tbl.ID )
                end

                timer.Simple(0.25, function()
                    local lastID = #queue
                    if (lastID > 0) then
                        local data = queue[ lastID ]
                        if (data) then
                            data.Function()
                        end
                    end
                end)
            end)
        end

        tbl.ID = table.insert( queue, tbl )
        if (tbl.ID == 1) then
            tbl.Function()
        end
    end)

    local messagesCache = {}
    net.receive(chipName, function()
        local text, isTeam = net.readString(), net.readBool()
        local textLower = string.lower( text )

        local cache = messagesCache[ textLower ]
        if (cache) then
            plib.Say( cache, isTeam )
            return
        end

        plib.TranslateText(text, nil, TRANSLATE_LANGUAGE, function( ok, result )
            local fullText = http.base64Encode( chipName .. ';' .. result )
            messagesCache[ textLower ] = fullText
            plib.Say( fullText, isTeam )
        end)
    end)

end

if (SERVER) then

    hook.add('OnPlayerSay', chipName, function( ply, text, isTeam )
        if !TRANSLATE_YOUR_MESSAGES then return end
        if plib.IsOwner( ply ) then
            if string.IsURL( text ) then return end
            local result = http.base64Decode( text )
            if (result) then
                local data = string.split( result, ';' )
                if (data[1] == chipName) then
                    return data[2]
                end
            end

            net.start( chipName )
            net.writeString( text )
            net.writeBool( isTeam )
            net.send( ply )
            return ''
        end
    end)

end