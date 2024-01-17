--[[
    GD50 - Breakou
    
    Represent a paddle that can move left and right. Used in the main
    program to deflect the ball toward the bricks; if the ball passes
    the paddle, the player loses one heart. The paddle can have a skin,
    which the player gets to choose upon starting the game.

    Author: Felix Ho
]]

Paddle = Class()

function Paddle:init()
    -- paddle skin
    self.skin = 1

    -- paddle size. there are 4 sizes to choose from and default to the medium size
    self.size = 2

    -- paddle dimensions
    self.width = 64
    self.height = 16

    -- paddle local. place paddle in the mid bottom edge of the screen
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - self.height * 2

    -- paddle velocity. no velocity at the begining
    self.dx = 0
end

function Paddle:update(dt)
    -- paddle movement based on the 'left' and 'right' keyboard
    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    -- paddle does not go beyong the screen when paddle hits the edge of the screen
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

function Paddle:render()
    -- get proper sprite from atlas
    love.graphics.draw(
        gTextures['main'],
        gFrames['paddles'][(self.skin - 1) * 4 + self.size],
        self.x,
        self.y
    )
end