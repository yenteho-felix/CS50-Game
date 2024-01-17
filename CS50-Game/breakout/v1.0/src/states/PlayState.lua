--[[
    GD50 - Breakout

    Main play state in state machine.

    Author: Felix Ho
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paddle = Paddle()
    self.paused = false
end

function PlayState:update(dt)
    -- handle pause event before other updates
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    else
        if love.keyboard.wasPressed('space') then
            self.paused = true
            gSounds['pause']:play()
            return
        end
    end

    -- exit event
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    -- update paddle position
    self.paddle:update(dt)
end

function PlayState:render()
    self.paddle:render()

    -- pause text
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end