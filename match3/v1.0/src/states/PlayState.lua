--[[
    GD50 - Match3

    Play game with score board on the left and board on the right 

    Author: Felix Ho
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.level = 1
    self.score = 0
    self.scoreGoal = 0
    self.timer = INIT_TIMER
    self.paused = false

    -- position of the board
    self.boardX = VIRTUAL_WIDTH - 8 * 32 - 16
    self.boardY = 16

    -- position in the grid which we're highlighting
    self.currentTileX = 0
    self.currentTileY = 0

    -- tile object highlighted to be swap
    self.highlightedTile = nil

    -- Flag to show whether we're able to process input
    self.canInput = true

    -- timer count down
    self:timerCountDown()
end

function PlayState:enter(params)
    self.level = params.level

    -- Continue the board from previous level or generate new
    self.board = params.board or Board(self.boardX, self.boardY)

    -- Continue the score from previous level or start with to 0
    self.score = params.score or 0

    -- Score we should reach to get to next level
    self.scoreGoal = self.level * 1.25 * 1000
end

function PlayState:update(dt)
    -- Keyboard support; escape to exit
    self:checkQuitInput()

    -- Keybaord support; space to pause
    self:checkPausedInput()

    -- Game loop
    if not self.paused then
        -- Check if matches happened at the begining of the game
        -- self:calculateMatches()

        -- Not in match calaulation/annimation stage
        if self.canInput then
            self:playGame()
            self:enterGameOver()
            self:enterNextLevel()
        end

        Timer.update(dt)
    end
end

function PlayState:render()
    -- score board on the left
    self:renderScoreBoard()

    -- play board on the right
    self.board:render()

    -- pause
    self:renderPaused()

    -- cursor movement
    self:renderCursor()

    -- highted tile
    self:renderTileSelected()
end

-- Play game
function PlayState:playGame()
    -- cursor movement
    self:moveCursor()

    -- select tiles and do swap
    self:tileSelected()

    -- calculate matches after the swap
    self:calculateMatches()
end

-- User move cursor up/down/left/right to move between tiles
-- If a tile being selected previously, restrict the movement to its neighboring only
function PlayState:moveCursor()
    -- Define the boundaries of the game board
    local boardMinX, boardMinY = 0, 0
    local boardMaxX, boardMaxY = 7 * 32, 7 * 32

    -- Function to update cursor position and play sound
    local function updatePositionAndPlaySound(newX, newY)
        if self:isValid(newX, newY) then
            self.currentTileX, self.currentTileY = newX, newY
            gSounds['select']:play()
        else
            gSounds['error']:play()
        end
    end

    -- Define direction offsets for each key
    local dir = {up = {0, -32}, down = {0, 32}, left = {-32, 0}, right = {32, 0}}

    -- When any movement key is pressed, calculate new position based on the direction offset
    for key, offset in pairs(dir) do
        if love.keyboard.wasPressed(key) then
            local newX = math.max(boardMinX, math.min(boardMaxX, self.currentTileX + offset[1]))
            local newY = math.max(boardMinY, math.min(boardMaxY, self.currentTileY + offset[2]))
            updatePositionAndPlaySound(newX, newY)
            -- Exit the loop after the first key press is detected
            break
        end
    end
end

-- Check if this movement if valid or not; Always valid when tile not highlighted
function PlayState:isValid(nextX, nextY)
    if not self.highlightedTile then
        return true
    else
        return math.abs(nextX - self.highlightedTile.x) + math.abs(nextY - self.highlightedTile.y) <= 32
    end
end

-- User press 'enter' to select tile; Select neighboring tile to do tile swap
function PlayState:tileSelected()
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        local row = self.currentTileY / 32 + 1      -- 1 index
        local col = self.currentTileX / 32 + 1      -- 1 index

        -- If nothing is highlighted, highlight current tile
        if not self.highlightedTile then
            self.highlightedTile = self.board.tiles[row][col]
        
        -- If a tile is highlighted and current tile is the highted one, remove highlight
        elseif self.highlightedTile == self.board.tiles[row][col] then
            self.highlightedTile = nil

        -- If a tile is highlighted and current tile is not the highted one, do swap
        else
            self:swapTiles(self.highlightedTile, self.board.tiles[row][col])
        end
    end
end

--[[
    Calculates whether any matches were found on the board and tweens the needed
    tiles to their new destinations if so. Also removes tiles from the board that
    have matched and replaces them with new randomized tiles, deferring most of this
    to the Board class.
]]
function PlayState:calculateMatches()
    -- calculate score
    local function calculateScore(matches)
        local score = 0
        for k, match in pairs(matches) do
            score = score + #match * 50
        end
        return score
    end

    -- check matches
    local matches = self.board:calculateMatches()
    if matches then
        -- self.canInput = false
        
        gSounds['match']:stop()
        gSounds['match']:play()

        self.score = self.score + calculateScore(matches)

        self.board:removeMatches()

        -- -- Tween new tiles that spawn from the ceiling over 0.25s, 
        -- local tilesToFall = self.board:getFallingTiles()
        -- Timer.tween(0.25, tilesToFall)
        -- :finish(function()

        --     -- Call calculateMatches recursively
        --     self:calculateMatches()
        -- end)
    else
        -- self.canInput = true
    end
end

-- Swap the location of tile1 and tile2
function PlayState:swapTiles(tile1, tile2)

    -- Create a temporary tile to store the properties of tile1
    local tempTile = Tile(tile1.row, tile1.col)
    tempTile.row, tempTile.col = tile1.row, tile1.col
    tempTile.x, tempTile.y = tile1.x, tile1.y

    -- Update tile1's properties with tile2's properties
    tile1.row, tile1.col = tile2.row, tile2.col
    self.board.tiles[tile1.row][tile1.col] = tile1
    Timer.tween(0.1, {[tile1] = {x = tile2.x, y = tile2.y}})

    -- Update tile2's properties with the temporary tile's properties
    tile2.row, tile2.col = tempTile.row, tempTile.col
    self.board.tiles[tile2.row][tile2.col] = tile2
    Timer.tween(0.1, {[tile2] = {x = tempTile.x, y = tempTile.y}})

    -- un-highlight after tile swap
    self.highlightedTile = nil
end

-- Enter to game over
function PlayState:enterGameOver()
    if self.timer <= 0 then
        Timer.clear()
        gSounds['game-over']:play()
        gStateMachine:change('game-over', {score = self.score})
    end
end

-- Enter to next level
function PlayState:enterNextLevel()
    if self.score >= self.scoreGoal then
        Timer.clear()
        gSounds['next-level']:play()
        gStateMachine:change('begin-game', {level = self.level + 1, score = self.score})
    end
end

-- Subtract 1 from timer every second
function PlayState:timerCountDown()
    Timer.every(1, function()
        self.timer = self.timer - 1

        -- play warning sound on timer if we get low
        if self.timer <= 10 then
            gSounds['clock']:play()
        end
    end)
end

-- Check for quit input
function PlayState:checkQuitInput()
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

-- Check for pause input
function PlayState:checkPausedInput()
    if love.keyboard.wasPressed('space') then
        self.paused = not self.paused
        gSounds['select']:play()
    end
end

--  Render Score board
function PlayState:renderScoreBoard()
    -- GUI background
    love.graphics.setColor(64/255, 64/255, 64/255, 192/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    -- GUI text
    love.graphics.setColor(99/255, 155/255, 1, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
end

-- Render Pause
function PlayState:renderPaused()
    local alpha = self.paused and 0.5 or 0

    love.graphics.setColor(1,1,1, alpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf('Game Paused', 0, 120, VIRTUAL_WIDTH, 'center')
    end
end

-- Render cursor on the board; A rectangle shape follows user movement 
-- to indicate which tile user is at in the game play
function PlayState:renderCursor()
    local recX = self.boardX + self.currentTileX
    local recY = self.boardY + self.currentTileY

    love.graphics.setColor(217/255, 87/255, 99/255, 1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', recX, recY, 32, 32, 4)
end

-- Render tiles which are selected; The selected tile is brighter
function PlayState:renderTileSelected()
    if self.highlightedTile then
        local recX = self.boardX + self.highlightedTile.x
        local recY = self.boardY + self.highlightedTile.y

        love.graphics.setBlendMode('add')
        love.graphics.setColor(1,1,1, 96/255)
        love.graphics.rectangle('fill', recX, recY, 32, 32, 4)
        love.graphics.setBlendMode('alpha')
    end
end