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

    self.matches = {}

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
            -- Keep empty if tile being removed
            if self.tiles[row][col] then
                self.tiles[row][col]:render(self.x, self.y)
            end
        end
    end
end

-- Goes left to right, top to bottom in the board, calculate matches by couting consecutive
-- tiles of the same color. Doesn't need to check the last tile in every row or column if the 
-- last two haven't been a match.
-- 
-- If we have any matches, remove them and tween the falling blocks that result
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for row = 1, 8 do
        local col = 1
        if not self.tiles[row][col] then
            error('self.tiles[' .. row .. '][' .. col .. '] is nil')
        end
        local colorToMatch = self.tiles[row][col].color

        matchNum = 1
        
        -- every horizontal tile
        for col = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if not self.tiles[row][col] then
                error('self.tiles[' .. row .. '][' .. col .. '] is nil')
            end
            if self.tiles[row][col].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[row][col].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for col2 = col - 1, col - matchNum, -1 do
                        
                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[row][col2])
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if col >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for col = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[row][col])
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for col = 1, 8 do
        local row = 1
        if not self.tiles[row][col] then
            error('self.tiles[' .. row .. '][' .. col .. '] is nil')
        end
        local colorToMatch = self.tiles[row][col].color

        matchNum = 1

        -- every vertical tile
        for row = 2, 8 do
            if not self.tiles[row][col] then
                error('self.tiles[' .. row .. '][' .. col .. '] is nil')
            end

            if self.tiles[row][col].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[row][col].color

                if matchNum >= 3 then
                    local match = {}

                    for row2 = row - 1, row - matchNum, -1 do
                        table.insert(match, self.tiles[row2][col])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if row >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for row = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[row][col])
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

-- Remove any tiles that matched from the board, making empty spaces
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.row][tile.col] = nil
            self.tiles[tile.row][tile.col] = Tile(tile.row, tile.col)
        end
    end

    self.matches = nil
end

-- Return a table with tween values for tiles that should now fall
function Board:getFallingTiles()
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.row = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.row - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(18), math.random(6))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.row - 1) * 32
                }
            end
        end
    end

    return tweens
end