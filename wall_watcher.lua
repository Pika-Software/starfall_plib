--@name Wall Watcher
--@author PrikolMen:-b
--@includedir starfall_plib
--@shared

--[[-----------------
    Configuration
-----------------]]--

if (CLIENT) then

    -- Low Health Color
    CLIENT_DEATH_COLOR = Color( 250, 50, 50 )

    -- Friend Filter
    CLIENT_REMOVE_FRIENDS = true

    -- Update Time
    CLIENT_UPDATE_TIME = 0.025

end

if (SERVER) then

    -- Player Filters
    SERVER_IGNORE_SUPERADMINS = false
    SERVER_IGNORE_ADMINS = false
    SERVER_IGNORE_NOCLIP = false
    SERVER_IGNORE_DEAD = true
    SERVER_IGNORE_GOD = true

    -- CFC Starfall Ext
    SERVER_IGNORE_BUILDERS = true
    SERVER_IGNORE_PVPERS = false

    -- Update Time
    SERVER_UPDATE_TIME = 1

end

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local ipairs = ipairs
local table = table
local plib = plib
local net = net

local chipName = 'PLib - Wall Watcher'

if (CLIENT) then

    local hudEnabled = plib.EnableHUD( true )
    if (hudEnabled) then
        local isValid = isValid
        local pairs = pairs

        local players = {}
        local playersRender = {}
        local function updatePlayerRender()
            for key, _ in pairs( playersRender ) do
                playersRender[ key ] = nil
            end

            for _, ply in ipairs( players ) do
                if !isValid( ply ) then continue end
                local pos = ply:getPos()
                local screenData = pos:toScreen()
                if (screenData) then
                    table.insert(playersRender, {
                        ply:getName(),
                        plib.LerpColor( 1 - ( ply:getHealth() / ply:getMaxHealth() ), plib.GetPlayerTeamColor( ply ), CLIENT_DEATH_COLOR ),
                        pos,
                        ply:getAngles(),
                        ply:obbMins(),
                        ply:obbMaxs(),
                        screenData.x,
                        screenData.y,
                        screenData.visible
                    })
                end
            end
        end

        net.receive(chipName, function()
            for key, _ in pairs( players ) do
                players[ key ] = nil
            end

            for _, ply in ipairs( net.readTable() ) do
                table.insert( players, ply )
            end

            updatePlayerRender()
        end)

        timer.create(chipName, CLIENT_UPDATE_TIME, 0, updatePlayerRender)

        --[[------------------
                Render
        ------------------]]--

        do

            local render = render

            hook.add('postdrawtranslucentrenderables', chipName, function()
                for _, info in ipairs( playersRender ) do
                    render.clearDepth()
                    render.setColor( info[2] )
                    render.draw3DWireframeBox( info[3], info[4], info[5], info[6] )
                end
            end)

            hook.add('drawhud', chipName, function()
                for _, info in ipairs( playersRender ) do
                    if (info[9]) then
                        render.setColor( info[2] )
                        render.drawSimpleText( info[7], info[8], info[1], 1, 2 )
                    end
                end
            end)

        end

    end

end

if (SERVER) then

    local find_allPlayers = find.allPlayers
    timer.create(chipName, SERVER_UPDATE_TIME, 0, function()
        local players = {}
        for _, ply in ipairs( find_allPlayers() ) do
            if plib.IsOwner( ply ) then continue end
            if !ply:isAlive() and SERVER_IGNORE_DEAD then continue end
            if ply:isAdmin() and SERVER_IGNORE_ADMINS then continue end
            if ply.isInBuild and ply:isInBuild() and SERVER_IGNORE_BUILDERS then continue end
            if ply.isInPvp and ply:isInPvp() and SERVER_IGNORE_PVPERS then continue end
            if ply:isSuperAdmin() and SERVER_IGNORE_SUPERADMINS then continue end
            if ply:isNoclipped() and SERVER_IGNORE_NOCLIP then continue end
            if ply:hasGodMode() and SERVER_IGNORE_GOD then continue end
            table.insert( players, ply )
        end

        if (#players < 1) then return end
        net.start( chipName )
        net.writeTable( players )
        net.send( plib.Owner )
    end)

end
