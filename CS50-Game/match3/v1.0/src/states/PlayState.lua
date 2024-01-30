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
    self.timer = 20
    self.paused = false

    self:timerCountDown()
end

function PlayState:enter(params)
    self.level = params.level

    -- Continue the board from previous level or generate new
    self.board = params.board or Board(VIRTUAL_WIDTH - 8 * 32 - 16, 16)

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
        self:playGame()
        self:enterGameOver()
        self:enterNextLevel()

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
end

-- Play game
function PlayState:playGame()
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