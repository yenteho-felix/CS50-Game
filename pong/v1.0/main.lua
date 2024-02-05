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
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle definition
PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20
PADDLE_SPEED = 200

-- ball definition
BALL_WIDTH = 4
BALL_HEIGHT = 4

-- define text fonts
local smallFont = love.graphics.newFont('font.ttf', 8)
local largeFont = love.graphics.newFont('font.ttf', 16)
local scoreFont = love.graphics.newFont('font.ttf', 32)

--[[
    Called exactly once at the begining of the game;
    Set up game objects, variables,etc. and prepare the game world
]]
function love.load()
    -- no filtering of pixels which enables nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set title
    love.window.setTitle('Pong')

    -- set text fonts
    love.graphics.setFont(smallFont)

    -- sound effects
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit']   = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['score']      = love.audio.newSource('sounds/score.wav', 'static')
    }

    -- initialize resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    -- initialize player location
    local paddle_x = 10
    local paddle_y = 30

    player1 = Paddle(paddle_x, paddle_y, PADDLE_WIDTH, PADDLE_HEIGHT)
    player2 = Paddle(VIRTUAL_WIDTH - paddle_x, VIRTUAL_HEIGHT - paddle_y, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- initialize ball location
    ball = Ball(VIRTUAL_WIDTH / 2 - BALL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - BALL_HEIGHT / 2, BALL_WIDTH, BALL_HEIGHT)

    -- initialize player score
    player1Score = 0
    player2Score = 0

    -- define servering player; either 1 or 2
    servingPlayer = 1

    -- define which player wins
    winningPlayer = 0

    -- define game state
    gameState = 'start'

    -- seed the RNG
    math.randomseed(os.time())
end

--[[
    Callback function used to update the state of the game every frame.
    'dt' is the time since the last update in seconds.
    update attributes of game objects, sound effects
]]
function love.update(dt)
    -- ball update
    if gameState == 'serve' then
        -- At serve stage, we need to determine who shoot the ball
        -- serveringPlayer is 1, shoot the ball to right
        -- servingPlayer is 2, shoot the ball to left
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)     
        else
            ball.dx = -math.random(140,200)
        end
        ball.dy = math.random(-50, 50)
    elseif gameState == 'play' then
        -- At play stage, we need to determine
        --      1. ball collides with paddles
        --      2. ball bounce from top/bottom boundaries
        --      3. ball move passes player1 or player2

        -- ball collides with paddle of player1
        if ball:collides(player1) then
            -- ball x coordinate reverse and slightly increse its velocity by 3%
            ball.x = player1.x + PADDLE_WIDTH / 2
            ball.dx = -ball.dx * 1.03

            -- ball y coordinate keep going in the same direction but randomize the velocity
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            -- play a sound
            sounds['paddle_hit']:play()
        end

        -- ball collides with paddle of player2
        if ball:collides(player2) then
            -- ball x coordinate reverse and slightly increse its velocity by 3%
            ball.x = player2.x - BALL_WIDTH
            ball.dx = -ball.dx * 1.03

            -- ball y coordinate keep going in the same direction but randomize the velocity
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            -- play a sound
            sounds['paddle_hit']:play()            
        end

        -- ball bounce from top boundries
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- ball bounce from bottom boundries
        if ball.y >= VIRTUAL_HEIGHT - BALL_HEIGHT then
            ball.y = VIRTUAL_HEIGHT - BALL_HEIGHT
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- ball move passes player1 and hits left boundary (player2 win)
        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            -- check if player wins
            if player2Score == 10 then
                gameState = 'done'
                winningPlayer = 2
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        -- ball move passes player2 and hits right boundary (player1 win)
        if ball.x > VIRTUAL_WIDTH - BALL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()
            
            -- check if player wins
            if player1Score == 10 then
                gameState = 'done'
                winningPlayer = 1
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    -- player1 update
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end
    player1:update(dt)

    -- player2 update
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end
    player2:update(dt)
end

--[[
    Callback function used to draw on the screen every frame;
    Handle UI messages, location of game objects
]]
function love.draw()
    -- begin drawing with push
    push:start()

    -- background color
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    -- render UI messages based on game state
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. (servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. (servingPlayer) .. "'s play!", 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. (winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- render score
    displayScore()

    -- render players and ball
    player1:render()
    player2:render()
    ball:render()

    -- render other info
    displayFPS()

    -- end drawing with push
    push:finish()
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0, 255, 255, 255)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(255, 255, 255, 255)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    --love.graphics.print('State: ' .. tostring(gameState), 10, 20)
    love.graphics.setColor(255, 255, 255, 255)
end


--[[
    Callback function triggered when a key is pressed;
    Handle activities when key pressed
]]
function love.keypressed(key)
    -- exit application
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        -- update state machine
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'

            -- re-initialize ball and score
            ball:reset()
            player1Score = 0
            player2Score = 0

            -- change servingPlayer to player who loses the game
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

--[[
    Called whenever we change the dimensions of the window.
]]
function love.resize(w, h)
    push:resize(w, h)
end