--[[
    GD50 - Match3

    The board is an arrnagement of tiles with which we must try to find
    matching sets of three or more horizontally or vertically 

    Author: Felix Ho
]]

Board = Class()

function Board:init(x, y)
    -- X and Y position of the board on the upper/left corner
    self.x = x
    self.y = y

    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for row = 1, 8 do
        -- Create an empty table as a new row
        table.insert(self.tiles, {})
        for col = 1, 8 do
            -- Create a new tile at matrixX, matrixY with a random color and patterns
            table.insert(self.tiles[row], Tile(row, col))
        end
    end

    -- -- Recursively initialize if a match happens
    -- while self:calculateMatches() do
    --     self:initializeTiles()
    -- end
end

function Board:update(dt)
end

function Board:render()
    for row = 1, #self.tiles do
        for col = 1, #self.tiles[1] do
            self.tiles[row][col]:render(self.x, self.y)
        end
    end
end