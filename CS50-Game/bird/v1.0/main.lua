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

-- background image
local background = love.graphics.newImage('image/background.png')
local backgroundScroll = 0
local BACKGROUND_SCROLL_SPEED = 30
local BACKGROUND_LOOPING_POINT = 413

-- ground image. ground should move faster than background
local ground = love.graphics.newImage('image/ground.png')
local groundScroll = 0
local GROUND_SCROLL_SPEED = BACKGROUND_SCROLL_SPEED * 2
local GROUND_LOOPING_POINT = ground:getWidth() / 2

-- bird sprite
local bird = Bird()


function love.load()
    -- sceme title, resolution
    love.window.setTitle('Fifty Bird')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
    })
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    -- scroll background by present speed * dt, looping back to 0 after the looping point
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    -- scroll ground by present speed * dt, looping back to 0 after the looping point
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT
end

function love.draw()
    Push:start()

    -- draw the background at the negative looping point
    love.graphics.draw(background, -backgroundScroll, 0)

    -- draw the ground on top of background, toward the bottom of the screen at the negative looping point
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - ground:getHeight())

    -- draw the bird sprite
    bird:render()

    Push:finish()
end
