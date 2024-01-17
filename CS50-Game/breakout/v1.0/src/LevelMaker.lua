--[[
    GD50 - Breakout

    Creates randomized levels for the game. Returns a table of bricks
    that the game can render, based on the current level player at in
    the game

    Author: Felix Ho
]]

LevelMaker = Class{}

-- creates a table of bricks to be returned to the main game, with different
-- possible ways of randomizing rows and columns of bricks. Calculates the 
-- brick colors and tiers to choose based on the level passed in.
function LevelMaker.createMap(level)
    local bricks = {}

    -- randomly choose the number of rows
    local numRows = math.random(5)

    -- randomly choose the number of columns
    local numCols = math.random(7, 13)

    -- lay out bricks such that they touch each other and fill the space
    for y = 1, numRows do
        for x = 1, numCols do
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

            table.insert(bricks, b)
        end
    end

    return bricks
end