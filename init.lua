local isValid = isValid
local convar = convar
local SERVER = SERVER
local CLIENT = CLIENT
local timer = timer
local Color = Color
local pcall = pcall
local team = team
local math = math

-- Globals
IsValid = isValid

-- PLib
plib = {}
plib.Chip = chip()
plib.Owner = owner()
plib.AngleZero = Angle()
plib.VectorZero = Vector()
plib.OwnerIndex = plib.Owner:entIndex()

if (CLIENT) then

    plib.Player = player()
    plib.Color = Color( 255, 193, 7 )
    plib.PlayerIsOwner = plib.Player == plib.Owner

    local http = http
    local bass = bass

    function plib.PlayURL( url, flags, callback )
        pcall(bass.loadURL, url, flags, function( channel )
            if isValid( channel ) and isfunction( callback ) then
                callback( channel )
            end
        end)
    end

    function plib.PlayTTS( text, flags, callback )
        plib.PlayURL( string.format( "http://translate.google.com/translate_tts?tl=%s&ie=UTF-8&q=%s&client=tw-ob", convar.getString( "gmod_language" ), http.urlEncode( text ) ), flags or '', callback )
    end

    function plib.EnableHUD( onlyOwner )
        if onlyOwner and (plib.Player != plib.Owner) then
            return false
        end

        enableHud( plib.Player, true )
        return true
    end

end

if (SERVER) then

    plib.Color = Color( 40, 192, 252 )

    local prop = prop

    do
        local NULL = NULL
        function plib.CreateEntity( class, pos, ang, frozen, extraData )
            local ok, ent = pcall( prop.createSent, pos or plib.Chip:getPos(), ang or plib.Chip:getAngles(), class, frozen or false, extraData )
            return ok and ent or NULL
        end
    end

    function plib.TeleportOwner( pos, ang )
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
