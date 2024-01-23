--[[
    GD50

    Helper functions for general utilities

    Author: Felix Ho
]]

-- Given an "atlas" (a texture with multiple sprites), as well as a width and height
-- for the tiles therein, split the texture into all of the quads by simply dividing
-- it evenly
function GenerateQuads(atlas, tileWidth, tileHeight)
    local sheetWidth = atlas:getWidth() / tileWidth
    local sheetHeight = atlas:getHeight() / tileHeight

    local sheetCounter = 1
    local spriteSheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spriteSheet[sheetCounter] = love.graphics.newQuad(
                                            x * tileWidth,
                                            y * tileHeight,
                                            tileWidth,
                                            tileHeight,
                                            atlas:getDimensions()
                                        )
            sheetCounter = sheetCounter + 1
        end
    end

    return spriteSheet
end

-- Slicing tables and return subset
function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

-- This function is specially made to piece out the bricks from the sprite sheet.
-- Since bricks are positioned from 0,0 and they are regular in sizes so we can 
-- use different way to extract them
function GenerateQuadsBricks(atlas)
    return table.slice(GenerateQuads(atlas, 32, 16), 1, 21)
end

-- This function is specially made to piece out the paddles from the sprite sheet.
-- For this, we have to piece out the paddles manually since they are all different sizes
function GenerateQuadsPaddles(atlas)
    local x = 0         -- x location of targeted paddle in atlas
    local y = 64        -- y location of targeted paddle in atlas
                        -- each row is 16 pixel and the first paddle(blue) is on the 5'th row

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        -- small
        quads[counter] = love.graphics.newQuad(x, y, 32, 16, atlas:getDimensions())
        counter = counter + 1
        -- medium
        x = x + 32
        quads[counter] = love.graphics.newQuad(x, y, 64, 16, atlas:getDimensions())
        counter = counter + 1
        -- large
        x = x + 64
        quads[counter] = love.graphics.newQuad(x, y, 96, 16, atlas:getDimensions())
        counter = counter + 1
        -- huge
        x = 0
        y = y + 16
        quads[counter] = love.graphics.newQuad(x, y, 128, 16, atlas:getDimensions())
        counter = counter + 1
        -- nxet set of paddles
        x = 0
        y = y + 16
    end
    
    return quads
end

-- This function is specially made to piece out the balls from the sprite sheet.
-- For this, we have to piece out the balls manually by their location
function GenerateQuadsBalls(atlas)
    local x = 32 * 3    -- x location of targeted ball in atlas
    local y = 16 * 3    -- y location of targeted ball in atlas
                        -- initialize x, y by the location of first ball (upper-left)

    local counter = 1
    local quads = {}

    -- first row of the ball
    local ballWidth = 8
    local ballHeight = 8
    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, ballWidth, ballHeight, atlas:getDimensions())
        x = x + ballWidth
        counter = counter + 1
    end

    -- second row of the ball
    x = 32 * 3
    y = 16 * 3 + ballHeight
    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, ballWidth, ballHeight, atlas:getDimensions())
        x = x + ballWidth
        counter = counter + 1
    end

    return quads
end

function RenderHealth(health)
    local healthX = VIRTUAL_WIDTH - 100
    local healthY = 4
    local healthInterval = 11

    -- render active health
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, healthY)
        healthX = healthX + healthInterval
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, healthY)
        healthX = healthX + healthInterval
    end
end

function RenderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function RenderFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.printf('FPS: ' .. tostring(love.timer.getFPS()), 5, 5, VIRTUAL_WIDTH, 'left')
end