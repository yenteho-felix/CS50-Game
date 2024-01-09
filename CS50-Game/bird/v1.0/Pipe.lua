--[[
    Pipe Class

    The Pipe class represents the pipes that randomly spawn in our game, which act as our primary obstacles.
    The pipes can stick out a random distance from the top or bottom of the screen. When the player collides
    with one of them, it's game over. Rather than our bird actually moving through the screen horizontally,
    the pipes themselves scroll through the game to give the illusion of player movement.

    Author: Felix Ho
]]

Pipe = Class{}

-- image defined here will be loaded once, not per instantiation to save memory
local PIPE_IMAGE = love.graphics.newImage('image/pipe.png')

local PIPE_SCROLL = -60

function Pipe:init()
    -- pipe should be spawn outside the sceme
    self.x = VIRTUAL_WIDTH
    self.y = math.random(VIRTUAL_HEIGHT / 4, (VIRTUAL_HEIGHT / 4 ) * 3)
    self.width = PIPE_IMAGE:getWidth()
end

function Pipe:update(dt)
    self.x = self.x + PIPE_SCROLL * dt
end

function Pipe:render()
    love.graphics.draw(PIPE_IMAGE, math.floor(self.x + 0.5), math.floor(self.y))
end