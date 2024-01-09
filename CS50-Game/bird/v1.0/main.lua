--[[
    GD50
    Flappy Bird Remake
    
    A mobile game by Dong Nguyen that went viral in 2013, utilizing a very simple 
    but effective gameplay mechanic of avoiding pipes indefinitely by just tapping 
    the screen, making the player's bird avatar flap its wings and move upwards slightly. 
    A variant of popular games like "Helicopter Game" that floated around the internet
    for years prior. Illustrates some of the most basic procedural generation of game
    levels possible as by having pipes stick out of the ground by varying amounts, acting
    as an infinitely generated obstacle course for the player.

    Lecture's Scope:
    -- Images (Sprites)
    -- Infinite Scrolling
    -- Games Are Illusions
    -- Procedural Generation
    -- State Machines
    -- Mouse Input

    Author: Felix Ho
]]

-- include packages
Push = require 'package/push'
Class = require 'package/class'

-- include classes
require 'Bird'

-- define screen resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

function love.load()
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
end

function love.update(dt)
end

function love.draw()
end
