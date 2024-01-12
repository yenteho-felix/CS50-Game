--[[
    GD50 - Flappy Bird Remake
    
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
require 'StateMachine'
require 'states/BaseState'
require 'states/CountdownState'
require 'states/PlayState'
require 'states/TitleScreenState'
require 'states/ScoreState'

-- seed the RNG
math.randomseed(os.time())

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

-- globla variable we use to scroll the map
scrolling = true


------ MAIN ------
function love.load()
    -- sceme title, resolution
    love.window.setTitle('Fifty Bird')
    love.graphics.setDefaultFilter('nearest', 'nearest')
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
    })

    -- initialize text fonts
    smallFont = love.graphics.newFont('font/font.ttf', 8)
    mediumFont = love.graphics.newFont('font/flappy.ttf', 14)
    hugeFont = love.graphics.newFont('font/flappy.ttf', 56)
    titleFont = love.graphics.newFont('font/flappy.ttf', 28)
    love.graphics.setFont(titleFont)

    -- initialize state machine
    gStateMachine = StateMachine {
        ['title'] = function() return TitleScreenState() end,
        ['countdown'] = function() return CountdownState() end,
        ['play'] = function() return PlayState() end,
        ['score'] = function() return ScoreState() end,
    }
    gStateMachine:change('title')

    -- initialize sounds
    sounds = {
        ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
        ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static'),
    }
    sounds['music']:setLooping(true)
    sounds['music']:play()

    -- initialize input table 'keysPressed'
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push:resize(w, h)
end

-- function to check if a key is pressed in last frame
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    -- add to keysPressed table when keys pressed in this frame
    love.keyboard.keysPressed[key] = true
end

function love.update(dt)
    if scrolling then
        -- scroll background by present speed * dt, looping back to 0 after the looping point
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

        -- scroll ground by present speed * dt, looping back to 0 after the looping point
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT
    end

    -- update the state machine, which defers to the right state
    gStateMachine:update(dt)

    -- reset keysPressed table every frame
    love.keyboard.keysPressed = {}
end

function love.draw()
    Push:start()

    -- draw the background at the negative looping point
    love.graphics.draw(background, -backgroundScroll, 0)

    -- render other objects based on their state
    gStateMachine:render()

    -- draw the ground on top of background, toward the bottom of the screen at the negative looping point
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - ground:getHeight())

    Push:finish()
end