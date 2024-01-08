--[[
    GD50 2018
    Pong Remake

    Lecture's Scope:
    -- Define shape of the screen
    -- Control 2D position of paddles based on input
    -- Collision detection between paddles and ball to deflect ball back toward opponent
    -- Collision detection between ball and map boundaries
    -- Scorekeeping to determine winner
    -- Sound effects when ball hits paddles/walls or when a point is scored for flavor

    Author: Felix Ho
]]

-- https://github.com/Ulydev/push
push = require 'push'

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
require 'Paddle'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- size of actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 320
VIRTUAL_HEIGHT = 180

-- paddle movement speed
PADDLE_SPEED = 200

--[[
    Called exactly once at the begining of the game;
    Set up game objects, variables,etc. and prepare the game world
]]
function love.load()
end

--[[
    Callback function used to update the state of the game every frame.
    'dt' is the time since the last update in seconds.
]]
function love.update(dt)
end

--[[
    Callback function used to draw on the screen every frame;
]]
function love.draw()
end

--[[
    Callback function triggered when a key is pressed
]]
function love.keypressed(key)
end

--[[
    Called whenever we change the dimensions of the window.
]]
function love.resize(w, h)
    push:resize(w, h)
end