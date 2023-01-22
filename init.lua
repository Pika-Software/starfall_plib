if plib then return end
local isValid = isValid
local convar = convar
local SERVER = SERVER
local CLIENT = CLIENT
local string = string
local timer = timer
local Color = Color
local pcall = pcall
local table = table
local team = team
local math = math
local http = http
local json = json

-- Globals
IsValid = isValid
http.Post = http.post
http.Fetch = http.get
PrintTable = printTable
CurTime = timer.curtime
SysTime = timer.systime
timer.Simple = timer.simple
SHARED = CLIENT or SERVER

do

    local debug_getinfo = debug.getinfo
    local error = error
    local type = type

    function ArgAssert( value, argNum, argType, errorlevel )
        local valueType = string.lower( type( value ) )
        if (valueType == argType) then return end

        local dinfo = debug_getinfo( 2, 'n' )
        local fname = dinfo and dinfo.name or 'func'
        error( string.format( 'bad argument #%d to \'%s\' (%s expected, got %s)', argNum, fname, argType, valueType ), errorlevel or 3)
    end

end

do
    local concmd = concmd
    function RunConsoleCommand( cmd, ... )
        ArgAssert( cmd, 1, 'string' )
        local args = {...}
        if (#args > 0) then
            concmd( cmd .. ' "' .. table.concat( args, '" "' ) .. '"' )
        else
            concmd( cmd )
        end
    end
end

local RunConsoleCommand = RunConsoleCommand
local ArgAssert = ArgAssert

function string.IsURL( str )
    ArgAssert( str, 1, 'string' )
    return string.match( str, '^https?://.*' ) ~= nil
end

-- PLib
plib = {}
plib.Chip = chip()
plib.Owner = owner()
plib.AngleZero = Angle()
plib.VectorZero = Vector()
plib.OwnerIndex = plib.Owner:entIndex()
plib.ChipName = 'PLib - ' .. plib.Chip:getChipName()
plib.ChipAuthor = plib.Chip:getChipAuthor()

function plib.IsOwner( ent )
    return ent:entIndex() == plib.OwnerIndex
end

if (CLIENT) then

    local render = render

    plib.Player = player()
    plib.Color = Color( 255, 193, 7 )
    plib.PlayerIsOwner = plib.Player == plib.Owner

    do

        local select = select

        function ScrW()
            return select( 1, render.getGameResolution() )
        end

        function ScrH()
            return select( -1, render.getGameResolution() )
        end

    end

    do

        local bass = bass

        function plib.PlayURL( url, flags, callback )
            pcall(bass.loadURL, url, flags, function( channel )
                if isValid( channel ) and isfunction( callback ) then
                    callback( channel )
                end
            end)
        end

    end

    function plib.GetLanguage()
        return convar.getString( 'gmod_language' )
    end

    function plib.PlayTTS( text, flags, callback )
        ArgAssert( text, 1, 'string' )
        ArgAssert( flags, 2, 'string' )
        plib.PlayURL( string.format( 'https://translate.google.com/translate_tts?tl=%s&ie=UTF-8&q=%s&client=tw-ob', plib.GetLanguage(), http.urlEncode( text ) ), flags or '', callback )
    end

    function plib.EnableHUD( onlyOwner )
        if onlyOwner and (plib.Player != plib.Owner) then
            return false
        end

        enableHud( plib.Player, true )
        return true
    end

    function plib.Say( text, teamChat )
        ArgAssert( text, 1, 'string' )
        RunConsoleCommand( teamChat and 'say_team' or 'say', text )
    end

end

if (SERVER) then

    plib.Color = Color( 40, 192, 252 )

    local prop = prop

    do
        local NULL = NULL
        function plib.CreateEntity( class, pos, ang, frozen, extraData )
            ArgAssert( class, 1, 'string' )
            local ok, ent = pcall( prop.createSent, pos or plib.Chip:getPos(), ang or plib.Chip:getAngles(), class, frozen or false, extraData )
            return ok and ent or NULL
        end
    end

    function plib.TeleportOwner( pos, ang )
        ArgAssert( pos, 1, 'vector' )

        if pcall( plib.Owner.setPos, plib.Owner, pos ) then
            if !ang then return end
            pcall( plib.Owner.setAngles, plib.Owner, ang )
        else
            local ent = plib.CreateEntity( 'Seat_Airboat', pos, ang, true, {['PLib - Teleporter'] = true} )
            if isValid( ent ) then
                ent:setNoDraw( true )
                ent:use()

                timer.simple(0, function()
                    if isValid( ent ) then
                        ent:ejectDriver()
                        ent:remove()
                    end
                end)
            end
        end
    end

    hook.add('PlayerSay', 'PLib - Core', function( ply, text, isTeam )
        local prePlayerSay = hook.run( 'PrePlayerSay', ply, text, isTeam )
        if (prePlayerSay == false) or (prePlayerSay == '') then
            return ''
        end

        local onPlayerSay = hook.run( 'OnPlayerSay', ply, prePlayerSay or text, isTeam )
        if (onPlayerSay == false) or (onPlayerSay == '') then
            return ''
        end

        return hook.run( 'PostPlayerSay', ply, onPlayerSay or prePlayerSay or text, isTeam )
    end)

    do

        plib.Commands = plib.Commands or {}

        function plib.ChatCommandAdd( cmd, callback )
            ArgAssert( cmd, 1, 'string' )
            ArgAssert( callback, 2, 'function' )
            plib.Commands[ string.lower( cmd ) ] = callback
        end

        function plib.ChatCommandExists( cmd )
            ArgAssert( cmd, 1, 'string' )
            return plib.Commands[ string.lower( cmd ) ] != nil
        end

        function plib.ChatCommandRemove( cmd )
            ArgAssert( cmd, 1, 'string' )
            plib.Commands[ string.lower( cmd ) ] = nil
        end

        hook.add('PrePlayerSay', 'PLib - Chat Commands', function( ply, text, isTeam )
            if isTeam then return end
            local args = string.split( text, ' ' )
            local cmd = args[1]
            if (cmd) then
                cmd = string.lower( cmd )
                local func = plib.Commands[ cmd ]
                if (func) then
                    table.remove( args, 1 )
                    pcall( func, ply, cmd, args, table.concat( args, ' ' ) )
                    return ''
                end
            end
        end)

    end

    do

        local buttonClasses = {
            ['momentary_rot_button'] = true,
            ['func_rot_button'] = true,
            ['func_button'] = true,
            ['gmod_button'] = true
        }

        function plib.IsButton( ent )
            if buttonClasses[ ent:getClass() ] then
                return true
            end

            return false
        end

    end

end

do

    local propClasses = {
        ['prop_detail'] = true,
        ['prop_static'] = true,
        ['prop_physics'] = true,
        ['prop_ragdoll'] = true,
        ['prop_dynamic'] = true,
        ['prop_physics_override'] = true,
        ['prop_dynamic_override'] = true,
        ['prop_physics_multiplayer'] = true
    }

    function plib.IsProp( ent )
        if propClasses[ ent:getClass() ] then
            return true
        end

        return false
    end

end

do

    local doorClasses = {
        ['prop_testchamber_door'] = true,
        ['prop_door_rotating'] = true,
        ['func_door_rotating'] = true,
        ['func_door'] = true
    }

    function plib.IsDoor( ent )
        if doorClasses[ ent:getClass() ] then
            return true
        end

        return false
    end

end

function plib.GiveOwnerWeapon( class )
    ArgAssert( class, 1, 'string' )
    RunConsoleCommand( 'gm_giveswep', class )
end

plib.White = Color( 255, 255, 255 )
function plib.Log( title, ... )
    print( plib.Color, '[' .. title .. '] ', plib.White, ... )
end

function plib.LerpColor( frac, a, b )
    return Color( math.lerp( frac, a.r, b.r ), math.lerp( frac, a.g, b.g ), math.lerp( frac, a.b, b.b ) )
end

function plib.GetPlayerTeamColor( ply )
    return team.getColor( ply:getTeam() )
end

function plib.GetPlayerCenterPos( ply )
    return ply:localToWorld( ply:obbCenter() )
end

do

    local url = 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s'
    local translateCache = {}

    function plib.TranslateText( text, fromLanguageCode, toLanguageCode, callback )
        ArgAssert( text, 1, 'string' )
        ArgAssert( fromLanguageCode, 2, 'string' )
        ArgAssert( toLanguageCode, 3, 'string' )
        ArgAssert( callback, 4, 'function' )

        local lowerText = string.lower( text )
        local cached = translateCache[ lowerText ]
        if (cached) then
            callback( true, cached[1], cached[2] )
            return
        end

        http.get(string.format( url, fromLanguageCode or 'auto', toLanguageCode, http.urlEncode( text ) ), function( body, len, headers, code )
            if (code == 200) then
                local data = json.decode( body )
                if (data) then
                    local level0 = data[1]
                    if (level0) then
                        local level1 = level0[1]
                        if (level1) then
                            local result = level1[1]
                            if (result) then
                                callback( true, result, data[2] )
                                translateCache[ lowerText ] = { result, data[2] }
                                return
                            end
                        end
                    end
                end
            end

            callback( false, text )
        end)
    end

end

function plib.LookClear()
    RunConsoleCommand( '-right' )
    RunConsoleCommand( '-left' )
end

function plib.LookLeft()
    RunConsoleCommand( '+left' )
    RunConsoleCommand( '-right' )
    timer.Simple(0, plib.LookClear)
end

function plib.LookRight()
    RunConsoleCommand( '-left' )
    RunConsoleCommand( '+right' )
    timer.Simple(0, plib.LookClear)
end

function plib.KillOwner()
    RunConsoleCommand( 'kill' )
end