--[[
    GD50

    Helper functions for general utilities

    Author: Felix Ho
]]




--[[
    Sprite sheets related functions
]]

-- Generate quads for a sprite sheet with specified tile dimensions
function GenerateQuads(atlas, tileWidth, tileHeight)
    -- Calculate the number of tiles in the sheet both horizontally and vertically
    local sheetWidth = atlas:getWidth() / tileWidth
    local sheetHeight = atlas:getHeight() / tileHeight

    -- Store the generated quads in this table
    local quads = {}

    -- Iterate over each row (y) and column (x) in the sprite sheet
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            -- Calculate the position and size of the current tile
            local quadX = x * tileWidth
            local quadY = y * tileHeight

            -- Create a new quad for the current tile and add it to the quads table
            local quad = love.graphics.newQuad(
                quadX, quadY, tileWidth, tileHeight, atlas:getDimensions()
            )
            table.insert(quads, quad)
        end
    end

    -- Return the generated quads
    return quads
end

-- Generate quads for tiles with default dimensions
function GenerateTileQuads(atlas)
    return GenerateQuads(atlas, 32, 32)
end


--[[
    render related functions
]]
-- function RenderHealth(health)
--     local healthX = VIRTUAL_WIDTH - 100
--     local healthY = 4
--     local healthInterval = 11

--     -- render active health
--     for i = 1, health do
--         love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, healthY)
--         healthX = healthX + healthInterval
--     end

--     -- render missing health
--     for i = 1, 3 - health do
--         love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, healthY)
--         healthX = healthX + healthInterval
--     end
-- end

-- function RenderScore(score)
--     love.graphics.setFont(gFonts['small'])
--     love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
--     love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
-- end

function RenderFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 5, 5, VIRTUAL_WIDTH, 'left')
end


