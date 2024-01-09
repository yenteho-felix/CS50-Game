--[[
    GD50 2018
    Pong Remake

    Author: Felix Ho
]]

Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- velocity of ball movement on x, y direction
    self.dx = 0
    self.dy = 0
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

--[[
    paddle as an argument and returns true or false depending on whether their rectangles overlap.
]]
function Ball:collides(paddle)

    -- check x coordinates
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    -- check y coordinates
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    return true
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2
    self.y = VIRTUAL_HEIGHT / 2 - BALL_HEIGHT / 2
end