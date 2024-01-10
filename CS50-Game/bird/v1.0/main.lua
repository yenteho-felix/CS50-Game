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
require 'Pipe'
require 'PipePair'

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

-- bird sprite
local bird = Bird()

-- table of spawning PipePairs
local pipePairs = {}

-- timer of spawning Pipes
local spawnTimer = 0

-- initialize input table 'keysPressed'
love.keyboard.keysPressed = {}

-- record Y-axis of the new pipe
-- we like to place the top pipe at 0 y-axis plus some random distance between 0 to 200
-- location of the pipePairs needed to be adjusted by the pipe height (minus) since we mirrored the top pipe
local lastY = math.random(150) - PIPE_HEIGHT

------ FUNCTIONS ------
--[[
    function to check if a key is pressed in last frame
]]
function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

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
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    -- add to keysPressed table when keys pressed in this frame
    love.keyboard.keysPressed[key] = true
end

function love.update(dt)
    -- scroll background by present speed * dt, looping back to 0 after the looping point
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt) % BACKGROUND_LOOPING_POINT

    -- scroll ground by present speed * dt, looping back to 0 after the looping point
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt) % GROUND_LOOPING_POINT

    -- update bird's location
    bird:update(dt)

    -- reset keysPressed table every frame
    love.keyboard.keysPressed = {}

    -- spawn pipe every 2 seconds
    spawnTimer = spawnTimer + dt
    if spawnTimer > 2 then

        -- opening of the pipe (GAP) should be 0 pixel below top screen and PIPE_GAP above bottom screen
        local minY = -PIPE_HEIGHT
        local maxY = VIRTUAL_HEIGHT - PIPE_GAP - PIPE_HEIGHT
        local y = lastY + math.random(-PIPE_DELTA/2, PIPE_DELTA/2)

        if y < minY then
            y = minY
        end
        if y > maxY then
            y = maxY
        end
        lastY = y

        table.insert(pipePairs, PipePair(y))
        print('Added new pipePair!')
        spawnTimer = 0
    end

    -- update pipePairs location
    for k, pipePair in pairs(pipePairs) do
        pipePair:update(dt)
    end

    -- remove any flagged pipes
    for k, pipePair in pairs(pipePairs) do
        if pipePair.remove then
            table.remove(pipePair, k)
        end
    end
end

function love.draw()
    Push:start()

    -- draw the background at the negative looping point
    love.graphics.draw(background, -backgroundScroll, 0)

    -- render all the pipePairs
    for k, pipePair in pairs(pipePairs) do
        pipePair:render()
    end

    -- draw the ground on top of background, toward the bottom of the screen at the negative looping point
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - ground:getHeight())

    -- draw the bird sprite
    bird:render()

    Push:finish()
end