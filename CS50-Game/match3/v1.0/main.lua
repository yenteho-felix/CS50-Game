--[[
    GD50 - Match3 Remake

    Reference: https://github.com/games50/match3/tree/master/match-3

    Match-3 has taken several forms over the years, with its roots in games
    like Tetris in the 80s. Bejeweled, in 2001, is probably the most recognized
    version of this game, as well as Candy Crush from 2012, though all these
    games owe Shariki, a DOS game from 1994, for their inspiration.

    The goal of the game is to match any three tiles of the same variety by
    swapping any two adjacent tiles; when three or more tiles match in a line,
    those tiles add to the player's score and are removed from play, with new
    tiles coming from the ceiling to replace them.

    As per previous projects, we'll be adopting a retro, NES-quality aesthetic.

    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch

    Credit for music (awesome track):
    http://freemusicarchive.org/music/RoccoW/

    Cool texture generator, used for background:
    http://cpetry.github.io/TextureGenerator-Online/

    Author: Felix Ho
]]

-- Enable local Lua debugger in debug mode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

-- Initialize our nearest-neighbor filter
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Default settings for the project
require 'src/Dependencies'

-- Roll the background image. Need to track the location on X-axis
local backgroundX = 0

function love.load()
    -- Title
    love.window.setTitle('Match 3')

    -- Seed the RNG
    math.randomseed(os.time())

    -- Initialize virtual resolution
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    -- Music
    gSounds['music']:setLooping(true)
    -- gSounds['music']:play()

    -- State machines
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    -- Initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    -- Add to our table of keys pressed this frame
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key] or false
end

function love.update(dt)
    -- Background location update
    backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt
    if backgroundX <= -gTextures['background']:getWidth() + VIRTUAL_WIDTH then
        backgroundX = 0
    end

    -- Update based on the state of the game
    gStateMachine:update(dt)

    -- Initialize input table
    love.keyboard.keysPressed = {}
end

function love.draw()
    Push:start()

    -- Scrolling background
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    -- Make the background a little darker than normal
    love.graphics.setColor(0, 0, 0, 128/255)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    -- Render based on the state of the game
    gStateMachine:render()

    -- Render FPS
    RenderFPS()

    Push:finish()
end