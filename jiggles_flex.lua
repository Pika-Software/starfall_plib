--@name Jiggles Flex
--@author Angel & PrikolMen:-b
--@includedir starfall_plib
--@client

--[[-----------------
    Configuration
-----------------]]--
local ONLY_OWNER = true
local FULL_BODY = false

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local string = string
local ipairs = ipairs
local plib = plib

local function Update( bool )
    local legBones = { 'l_thigh', 'l_calf', 'l_foot', 'l_toe', 'r_thigh', 'r_calf', 'r_foot', 'r_toe' }
    for _, ply in ipairs( find.allPlayers() ) do
        if !ONLY_OWNER or plib.IsOwner( ply ) then
            for bone = 0, ply:getBoneCount() - 1 do
                local boneName = string.lower( ply:getBoneName( bone ) )
                if boneName and (boneName ~= nil) then
                    local allowed = true
                    if !FULL_BODY then
                        for _, tag in ipairs( legBones ) do
                            if boneName:find( tag ) then
                                allowed = false
                                break
                            end
                        end
                    end

                    if allowed then
                        ply:manipulateBoneJiggle( bone, bool or false )
                        continue
                    end
                end

                ply:manipulateBoneJiggle( bone, false )
            end
        end
    end
end

Update( true )

hook.add('Removed', 'Jiggle Flex', function()
    Update( false )
end)
