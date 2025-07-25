--[[
    GD50 - Breakout Remake

    Reference: https://github.com/games50/breakout/tree/master

    Originally developed by Atari in 1976. An effective evolution of
    Pong, Breakout ditched the two-player mechanic in favor of a single-
    player game where the player, still controlling a paddle, was tasked
    with eliminating a screen full of differently placed bricks of varying
    values by deflecting a ball back at them.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.

    Credit for graphics (amazing work!):
    https://opengameart.org/users/buch

    Credit for music (great loop):
    http://freesound.org/people/joshuaempyre/sounds/251461/
    http://www.soundcloud.com/empyreanma

    Author: Felix Ho
]]

-- enable local lua debugger in debug mode
if pcall(require, "lldebugger") then
    require("lldebugger").start()
end

require 'src/Dependencies'

function love.load()
    -- initialize resolution
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Breakout')
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- initialize retro text font
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])

    -- initialize images
    gTextures = {
        ['background'] = love.graphics.newImage('images/background.png'),
        ['main'] = love.graphics.newImage('images/breakout.png'),
        ['arrows'] = love.graphics.newImage('images/arrows.png'),
        ['hearts'] = love.graphics.newImage('images/hearts.png'),
        ['particle'] = love.graphics.newImage('images/particle.png'),
    }

    -- Quads we will generate for all of our textures
    gFrames = {
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    }

    -- initialize sounds
    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
        ['music'] = love.audio.newSource('sounds/music.wav', 'static')
    }

    -- initialize state machines
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['high-score'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['paddle-select'] = function() return PaddleSelectState() end,
    }
    gStateMachine:change('start',
        {
            highScores = loadHighScores()
        }
    )

    -- backgound music
    gSounds['music']:play()
    gSounds['music']:setLooping(true)

    -- seed the RNG
    math.randomseed(os.time())

    -- a table to store keys pressed
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push:resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)

    -- reset keys pressed
    love.keyboard.keysPressed = {}
end

function love.draw()
    Push:apply('start')

    -- background
    renderBackground()

    -- defer rendering to state machines
    gStateMachine:render()

    -- FPS
    RenderFPS()

    Push:apply('end')
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function renderBackground()
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(
        gTextures['background'],
        0, 0,                                       -- x, y coordinate
        0,                                          -- no rotation
        VIRTUAL_WIDTH / (backgroundWidth - 1),      -- scale factors on x
        VIRTUAL_HEIGHT / (backgroundHeight - 1)     -- scale factors on y
    )
end

function loadHighScores()
    -- set folder
    love.filesystem.setIdentity(SCORE_FOLDER)

    -- if the file doesn't exist, initialize it with some default scores
    if not love.filesystem.getInfo(SCORE_FILE) then
        local scoresStr = ''
        for i = 10, 1, -1 do
            scoresStr = scoresStr .. 'CTO\n'
            scoresStr = scoresStr .. tostring(i * 100) .. '\n'
        end
        love.filesystem.write(SCORE_FILE, scoresStr)
    end

    -- initialize scores table with 10 blank entries
    local scores = {}
    for i = 1, 10 do
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    -- read name and score from scoreFile
    -- iterate over each line in the file, filling the names and scores to table
    local name = true
    local counter = 1

    for line in love.filesystem.lines(SCORE_FILE) do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end
        name = not name
    end

    return scores
end