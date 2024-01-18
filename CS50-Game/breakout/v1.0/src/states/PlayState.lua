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

    -- use createMap function to generate a bricks table
    self.bricks = LevelMaker.createMap()
end

-- return string of either one of 'top', 'bottom', 'left', 'right'
function CollideEdge(ball, target)
    local edge = ''

    if ball.x < target.x then
        edge = 'left'
    elseif ball.x + ball.width > target.x + target.width then
        edge = 'right'
    elseif ball.y < target.y then
        edge = 'top'
    else
        edge = 'bottom'
    end

    return edge
end

-- ball bounce back when collides with paddle
function BallCollideWithPaddle(self)
    if self.ball:collides(self.paddle) then
        gSounds['paddle-hit']:play()

        -- determine the ball behavior based on paddle side it hits
        local edge = CollideEdge(self.ball, self.paddle)
        if edge == 'top' then
            -- 
            -- tweak angle of the founce based on where it hits the paddle
            -- 
            local bounceForce = 10
            local distFromMid = self.ball.x - (self.paddle.x + self.paddle.width / 2)
            -- when the ball hits the paddle on its left side while moving left
            if distFromMid < 0 and (self.paddle.dx < 0) then
                self.ball.dx = -50 + distFromMid * bounceForce
            -- when the ball hits the paddle on its right side while moving right
            elseif distFromMid > 0 and (self.paddle.dx > 0) then
                self.ball.dx = 50 + distFromMid * bounceForce
            end

            self.ball.y = self.paddle.y - self.ball.height
            self.ball.dy = -self.ball.dy * 1.1
        elseif edge == 'left' then
            self.ball.x = self.paddle.x - self.ball.width
            self.ball.dx = -self.ball.dx * 1.1
        elseif edge == 'right' then
            self.ball.x = self.paddle.x + self.paddle.width
            self.ball.dx = -self.ball.dx * 1.1
        end
    end
end

function BallCollideWithBrick(self)
    -- ball collision across all bricks
    -- only check collision when the brick is inPlay
    for k, brick in pairs(self.bricks) do
        if brick.inPlay and self.ball:collides(brick) then
            brick:hit()

            -- 
            -- Collision code for bricks
            -- 
            local edge = CollideEdge(self.ball, brick)
            if edge == 'left' then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            end
            if edge == 'right' then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width                
            end
            if edge == 'top' then
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            end
            if edge == 'bottom' then
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end

            -- slightly scale the y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02

            -- break the look when ball collides with a brick
            break
        end
    end
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

    -- Collision
    BallCollideWithPaddle(self)
    BallCollideWithBrick(self)

end

function PlayState:render()
    self.paddle:render()

    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- pause text
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end