--[[
    GD50 - Breakout

    Main play state in state machine.

    Author: Felix Ho
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paddle = Paddle()
    self.ball = Ball(1)         -- initialze ball with skin 1
    self.paused = false

    -- initialize ball at the center
    -- give ball random starting velocity toward bricks
    self.ball.x = VIRTUAL_WIDTH / 2 - self.ball.width / 2
    self.ball.y = VIRTUAL_HEIGHT / 2 - self.ball.height / 2
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
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

    -- update object position
    self.paddle:update(dt)
    self.ball:update(dt)

    -- ball bounce back when collides with paddle
    if self.ball:collides(self.paddle) then
        self.ball.dy = -self.ball.dy
        gSounds['paddle-hit']:play()
    end
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()

    -- pause text
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end