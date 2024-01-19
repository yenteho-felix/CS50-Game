--[[
    GD50 - Breakout

    Main play state in state machine.

    Author: Felix Ho
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paused = false
end

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.ball = params.ball
end

-- ball bounce back when collides with paddle
function ballCollideWithPaddle(self)
    local collide, shiftX, shiftY = self.ball:collides(self.paddle)
    if collide then
        gSounds['paddle-hit']:play()

        local minShift = math.min(math.abs(shiftX), math.abs(shiftY))

        -- When shiftX is smaller, we assume ball hits paddle from x direction
        -- When shiftY is smaller, we assume ball hits paddle from y direction
        -- check shiftX and shiftY to see which one is smaller, then reset other one to zero
        if math.abs(shiftX) == minShift then
            shiftY = 0
        else
            shiftX = 0
        end

        -- reposition ball to edge of paddle
        self.ball.x = self.ball.x + shiftX
        self.ball.y = self.ball.y + shiftY

        -- ball hits paddle from top
        if shiftX == 0 then
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
            
            self.ball.dy = -self.ball.dy * 1.1
        -- ball hits paddle from left or right
        else
            self.ball.dx = -self.ball.dx * 1.1
        end
    end
end

function ballCollideWithBrick(self)
    -- ball collision across all bricks
    -- only check collision when the brick is inPlay
    for k, brick in pairs(self.bricks) do
        local collide, shiftX, shiftY = self.ball:collides(brick)

        if brick.inPlay and collide then
            brick:hit()
            self.score = self.score + 10

            -- 
            -- Collision code for bricks
            -- 
            local minShift = math.min(math.abs(shiftX), math.abs(shiftY))

            -- When shiftX is smaller, we assume ball hits paddle from x direction
            -- When shiftY is smaller, we assume ball hits paddle from y direction
            -- check shiftX and shiftY to see which one is smaller, then reset other one to zero
            if math.abs(shiftX) == minShift then
                shiftY = 0
            else
                shiftX = 0
            end
    
            -- reposition ball to edge of paddle
            self.ball.x = self.ball.x + shiftX
            self.ball.y = self.ball.y + shiftY
    
            -- ball hits paddle from top or bottom
            if shiftX == 0 then
                self.ball.dy = -self.ball.dy * 1.02
            -- ball hits paddle from left or right
            else
                self.ball.dx = -self.ball.dx * 1.02
            end

            -- break the look when ball collides with a brick
            break
        end
    end
end

function ballCollideWithBottom(self)
    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {score = self.score})
        else
            gStateMachine:change('serve',
                {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    skin = self.ball.skin
                }
            )
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
    ballCollideWithPaddle(self)
    ballCollideWithBrick(self)
    ballCollideWithBottom(self)

end

function PlayState:render()
    self.paddle:render()

    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    RenderScore(self.score)

    RenderHealth(self.health)

    -- pause text
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSED', 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end