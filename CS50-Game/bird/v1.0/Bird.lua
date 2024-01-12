--[[
    GD50 - Flappy Bird Remake

    Bird Class

    The Bird is what we control in the game via clicking or the space bar; whenever we press either,
    the bird will flap and go up a little bit, where it will then be affected by gravity. If the bird hits
    the ground or a pipe, the game is over.

    Author: Felix Ho
]]

Bird = Class{}

local GRAVITY = 20
local BURST = 5

function Bird:init()
    -- set bird image, widht and height
    self.image = love.graphics.newImage('image/bird.png')
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    -- set bird dropping location at middle of the screen
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2

    -- set bird velocity on y-axis
    self.dy = 0
end

function Bird:collides(pipe)
    -- Shrink bird by few pixels to give the player a little leeway with the collision
    local leeway = 3
    if (self.x + self.width - leeway) >= pipe.x and (self.x + leeway) <= (pipe.x + pipe.width) then
        if (self.y + self.height - leeway) >= pipe.y and (self.y + leeway) <= (pipe.y + pipe.height) then
            return true
        end
    end
    return false
end

function Bird:update(dt)
    -- Implement gravity, makes velocity increases as bird moving down
    self.dy = self.dy + GRAVITY * dt

    -- add a burst of negative gravity if we hit space
    if love.keyboard.wasPressed('space') then
        self.dy = -BURST
        sounds['jump']:play()
    end

    -- apply current velocity to y-axis
    self.y = self.y + self.dy
end

function Bird:render()
    love.graphics.draw(self.image, self.x, self.y)
end