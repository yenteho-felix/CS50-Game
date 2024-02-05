--[[
    GD50 2018
    Pong Remake

    Author: Felix Ho
]]

Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- velocity of paddle movement on y direction
    self.dy = 0
end

function Paddle:update(dt)
    -- make sure paddle stay within windows
    -- paddle moving upwards
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- paddle moving downwards
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end