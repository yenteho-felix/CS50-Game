--[[
    GD50 - Match3

    The individual tiles taht make up the game board. Each tile can have a
    color and pattern, with the patterns adding extra points to the matches.

    Author: Felix Ho
]]

Tile = Class()

function Tile:init(row, col)
    -- Tile row and col in the board
    self.row = row
    self.col = col

    -- Tile coordinate of x and y
    self.x = (self.col - 1) * 32
    self.y = (self.row - 1) * 32

    -- Tile color and pattern, generated randomly
    self.color = math.random(TILE_COLORS)
    self.pattern = math.random(1)
    -- self.pattern = math.random(TILE_PATTERNS)
end

function Tile:render(boardX, boardY)
    -- Find tile index in gFrames based on color and pattern
    local index = (self.color - 1) * TILE_PATTERNS + self.pattern
    local tileX = boardX + self.x
    local tileY = boardY + self.y
    
    -- -- Draw tile shadow
    -- love.graphics.setColor(34/255,32/255,52/255,255/255)
    -- love.graphics.draw(gTextures['main'], gFrames['tiles'][index], tileX + 5, tileY + 5)

    -- Draw tile itself
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][index], tileX, tileY)
end