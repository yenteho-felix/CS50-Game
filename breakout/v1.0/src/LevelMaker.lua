--[[
    GD50 - Breakout

    Creates randomized levels for the game. Returns a table of bricks
    that the game can render, based on the current level player at in
    the game

    Author: Felix Ho
]]

LevelMaker = Class{}


-- random pattern generation based on given level
-- game starts at level 1, tier increases every 5 levels
-- ex:
--      level 1  : 3 color and 0 tier
--      level 2  : 4 color and 0 tier
--      level 5  : 3 color and 1 tier
--      level 10 : 3 color and 2 tier
function genPattern(level)
    -- color level range from 1 to 6, but we dont use 6 since
    -- 6 is reserved to be used as a wall brick
    -- maximum 3 colors at level 1
    local highestColor = math.min(5, level % 5 + 2)

    -- tier level range from 0 to 3
    -- increases one tier every 5 levels
    local highestTier = math.min(3, math.floor(level / 5))

    -- Enable alternate column skipping for a row or not
    local skipPattern = math.random(1, 2) == 1 and true or false            -- true=enalbe alternate column skipping
    local skipFlag = math.random(1, 2) == 1 and true or false               -- true=skip from 1st column, false=skip from 2nd column

    -- Enable color alternate for the entire row or not
    local alternatePattern = math.random(1, 2) == 1 and true or false       -- true=enable color and tier alternate
    local alternateFlag = math.random(1, 2) == 1 and true or false          -- flag to switch between color1 and color2

    -- choose two colors to alternate between
    local alternateColor1 = math.random(1, highestColor)
    local alternateColor2 = math.random(1, highestColor)
    local alternateTier1 = math.random(0, highestTier)
    local alternateTier2 = math.random(0, highestTier)

    -- solid color we'll use if we're not alternating
    local solidColor = math.random(1, highestColor)
    local solidTier = math.random(0, highestTier)

    return {
        ['skipPattern'] = skipPattern,
        ['skipFlag'] = skipFlag,
        ['alternatePattern'] = alternatePattern,
        ['alternateFlag'] = alternateFlag,
        ['alternateColor1'] = alternateColor1,
        ['alternateColor2'] = alternateColor2,
        ['alternateTier1'] = alternateTier1,
        ['alternateTier2'] = alternateTier2,
        ['solidColor'] = solidColor,
        ['solidTier'] = solidTier,
    }
end


-- creates a table of bricks to be returned to the main game, with different
-- possible ways of randomizing rows and columns of bricks. Calculates the 
-- brick colors and tiers to choose based on the level passed in.
function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(1, 5)

    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do

        local pattern = genPattern(level)

        for x = 1, numCols do
            -- 
            -- define the pattern style of the bricks
            -- 
            -- if we want to do alternate column skipping or not
            -- when skipFlag is true, skip first column
            if pattern['skipPattern'] then
                if pattern['skipFlag'] then
                    pattern['skipFlag'] = not pattern['skipFlag']
                    goto continue
                else
                    pattern['skipFlag'] = not pattern['skipFlag']
                end
            end

            -- create brick
            b = Brick(
                -- x-coordinate
                (x-1)                       -- table is 1-indexed but brick coords are 0
                * 32                        -- brick width
                + 8                         -- the screen should have 8 pixels of padding; we can fit 13 cols + 16 pixel total (432)
                + (13 - numCols) * 16,      -- left-side padding when there are fewer than 13 columns      

                -- y-coordinate
                (y-1)                       -- table is 1-indexed but brick coords are 0
                * 16                        -- brick height
                + 16                        -- top-side padding 
            )

            -- 
            -- define the color and tier of the bricks
            -- 
            -- alternate color and tier for the entire row
            if pattern['alternatePattern'] then
                if pattern['alternateFlag'] then
                    b.color = pattern['alternateColor1']
                    b.tier = pattern['alternateTier1']
                else
                    b.color = pattern['alternateColor2']
                    b.tier = pattern['alternateTier2'] 
                end
                pattern['alternateFlag'] = not pattern['alternateFlag']
            -- uses the same color and tier for the entire row
            else
                b.color = pattern['solidColor']
                b.tier = pattern['solidTier']
            end

            --  add brick to table
            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end

    return bricks
end