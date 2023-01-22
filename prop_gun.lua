--@name Prop Gun
--@author PrikolMen:-b
--@includedir starfall_plib
--@server

--[[-----------------
    Configuration
-----------------]]--

-- Bind - bind k +grenade2
local BIND = 16777216

-- Prop Model
local PROP_MODEL = 'models/props_c17/oildrum001_explosive.mdl'

-- Prop pushing speed
local PROP_FORCE = 1000000

-- Prop Mass
local PROP_MASS = 1000000

-- Prop Ignite
local PROP_IGNITE = true

--[[-----------------
         Code
-----------------]]--
dofile( 'starfall_plib/init.lua' )
local chipName = 'PLib - Prop Gun'
local timer_simple = timer.simple
local isValid = isValid
local CurTime = CurTime
local plib = plib

hook.add('KeyPress', chipName, function(ply, key)
    if plib.IsOwner( ply ) and (key == BIND) then
        if (ply[ chipName ] or 0) > CurTime() then return end
        ply[ chipName ] = CurTime() + 0.025

        local pos = ply:localToWorld( Vector( 0, 0, ply:obbMaxs()[3] + 20 ) )
        local ang = ply:getEyeAngles()
        if ply:inVehicle() then
            ang[1] = ang[1] + 25
        end

        local ok, ent = pcall( prop.create, pos, ang, PROP_MODEL )
        if (ok) then
            timer_simple(0.025, function()
                if isValid( ent ) then
                    if PROP_IGNITE then
                        ent:ignite( 128, 0 )
                    end

                    local phys = ent:getPhysicsObject()
                    if isValid( phys ) then
                        phys:setMass( PROP_MASS )
                        phys:addGameFlags( FVPHYSICS.DMG_DISSOLVE )
                        phys:addVelocity( ang:getForward() * PROP_FORCE )
                    end
                end
            end)
        end
    end
end)

