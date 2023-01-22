--@name Jiggles Flex
--@author Angel
--@client

--[[-----------------
         Code
-----------------]]--
local string = string
local ipairs = ipairs

local legBones = { 'l_thigh', 'l_calf', 'l_foot', 'l_toe', 'r_thigh', 'r_calf', 'r_foot', 'r_toe' }
for _, pl in ipairs( find.allPlayers() ) do
    for i = 0, pl:getBoneCount() - 1 do
        local boneName = string.lower( pl:getBoneName( i ) )
        if boneName and (boneName ~= nil) then
            local allowed = true
            for _, tag in ipairs( legBones ) do
                if boneName:find( tag ) then
                    allowed = false
                    break
                end
            end

            if allowed then
                pl:manipulateBoneJiggle( i, true )
                continue
            end
        end

        pl:manipulateBoneJiggle( i, false )
    end
end
