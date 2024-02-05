--[[
    GD50 - Flappy Bird Remake
    
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

-- define global variables to be used by other classes
PIPE_HEIGHT = PIPE_IMAGE:getHeight()
PIPE_WIDTH = PIPE_IMAGE:getWidth()

-- two variables
-- 1. orientation of the pipe
-- 2. y-axis of the pipe
function Pipe:init(orientation, y)
    self.x = VIRTUAL_WIDTH
    self.y = y
    self.width = PIPE_WIDTH
    self.height = PIPE_HEIGHT
    self.orientation = orientation
end

function Pipe:update(dt)
end

function Pipe:render()
    love.graphics.draw(
        PIPE_IMAGE,
        self.x,
        (self.orientation == 'top' and self.y + self.height or self.y),     -- set y-axis based on whether the pipe is on top or bottom
                                                                            -- since top pipe will be mirrored so its y-axis should be adjusted by pipe height
        0,                                                                  -- orientation
        1,                                                                  -- scale factor x-axis
        (self.orientation == 'top' and -1 or 1)                             -- scale factor y-axis. mirror the top pipe by setting -1.
    )
end