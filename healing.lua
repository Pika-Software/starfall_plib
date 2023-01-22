--@name Healing
--@author PrikolMen:-b
--@includedir starfall_plib
--@server

--[[-----------------
    Configuration
-----------------]]--

local HEALTH_GIVE = true
local HEALTH_CLASS = 'item_healthkit'
local HEALTH_USE = false

local ARMOR_GIVE = true
local ARMOR_CLASS = 'item_battery'
local ARMOR_USE = false

local REMOVE_DELAY = 1

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local prop_spawnRate = prop.spawnRate
local isValid = isValid
local timer = timer
local plib = plib
local math = math
local hook = hook

local chipName = 'PLib - Healing'
local healthHookName = chipName .. ' / HEALTH'
local armorHookName = chipName .. ' / ARMOR'

hook.add('EntityTakeDamage', chipName, function( ply )
    if plib.IsOwner( ply ) and ply:isAlive() then
        timer.simple(0, function()
            if isValid( ply ) and ply:isAlive() then
                if HEALTH_GIVE then
                    local nextHealthSpawnTime = 0
                    hook.add('think', healthHookName, function()
                        if nextHealthSpawnTime > timer.curtime() then return end
                        nextHealthSpawnTime = timer.curtime() + (1 / prop_spawnRate()) + math.rand( 0, 2 )

                        if isValid( ply ) and ply:isAlive() and (ply:getHealth() < ply:getMaxHealth()) then
                            local pos = HEALTH_USE and plib.Chip:getPos() or ply:getPos()
                            local ent = plib.CreateEntity( HEALTH_CLASS, pos, plib.AngleZero, false )
                            if isValid( ent ) then
                                if HEALTH_USE then
                                    ent:use()
                                end

                                timer.simple(REMOVE_DELAY, function()
                                    if isValid( ent ) then
                                        ent:remove()
                                    end
                                end)
                            end

                            return
                        end

                        hook.remove('think', healthHookName)
                    end)
                end

                if ARMOR_GIVE then
                    local nextArmorSpawnTime = 0
                    hook.add('think', armorHookName, function()
                        if nextArmorSpawnTime > timer.curtime() then return end
                        nextArmorSpawnTime = timer.curtime() + (1 / prop_spawnRate()) + math.rand( 0, 2 )

                        if isValid( ply ) and ply:isAlive() and (ply:getArmor() < ply:getMaxArmor()) then
                            local pos = ARMOR_USE and plib.Chip:getPos() or ply:getPos()
                            local ent = plib.CreateEntity( ARMOR_CLASS, pos, plib.AngleZero, false )
                            if isValid( ent ) then
                                if ARMOR_USE then
                                    ent:use()
                                end

                                timer.simple(REMOVE_DELAY, function()
                                    if isValid( ent ) then
                                        ent:remove()
                                    end
                                end)
                            end

                            return
                        end

                        hook.remove('think', armorHookName)
                    end)
                end
            end
        end)
    end
end)
