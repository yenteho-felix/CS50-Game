--[[
    GD50 - Flappy Bird

    PlayState Class

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.  

    Author: Felix Ho
]]

PlayState = Class{__includes = BaseState}

-- include classes
require 'Bird'
require 'Pipe'
require 'PipePair'

-- local variables to display scoring medal
local medal = love.graphics.newImage('image/medal.png')
local scored = false
local count = 0

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.spawnTimer = 0
    self.spawnInterval = 2
    self.score = 0

    -- record Y-axis of the new pipe
    -- we like to place the top pipe at 0 y-axis plus some random distance between 0 to 200
    -- location of the pipePairs needed to be adjusted by the pipe height (minus) since we mirrored the top pipe
    self.lastY = math.random(150) - PIPE_HEIGHT

end

function Dead(number)
    scrolling = false
    gStateMachine:change('score', {score = number})
    sounds['explosion']:play()
    sounds['hurt']:play()
end

function CollideWithPipe(bird, pipePairs, number)
    for k, pair in pairs(pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if bird:collides(pipe) then
                Dead(number)
            end
        end
    end
end

function CollideWithGround(bird, number)
    local leeway = 2
    local groundHeight = 16
    if bird.y > VIRTUAL_HEIGHT - bird.height - groundHeight + leeway then
        Dead(number)
    end
end

function PlayState:update(dt)
    if scrolling then
        -- update timer
        self.spawnTimer = self.spawnTimer + dt

        -- spawn pipe every 2 or 3 seconds
        if self.spawnTimer > self.spawnInterval then
            -- the maximum delta height between two continuous pipePairs
            local delta = math.random(40, 60)
            if math.random(-1,1) < 0 then
                delta = 0 - delta
            end

            -- opening of the pipe (GAP) should be 0 pixel below top screen and PIPE_GAP above bottom screen
            local minY = -PIPE_HEIGHT
            local maxY = VIRTUAL_HEIGHT - PipePair(0).gap - PIPE_HEIGHT
            local y = math.max(minY, math.min(self.lastY + delta, maxY))
            self.lastY = y
            table.insert(self.pipePairs, PipePair(y))

            self.spawnTimer = 0
            self.spawnInterval = math.floor(math.random(2,3) + 0.5)
        end

        -- for every pair of pipes
        for k, pair in pairs(self.pipePairs) do
            -- score a point if the pipe has gone past the bird to the left all the way
            -- be sure to ignore it if it's already been scored
            if not pair.scored then
                if pair.x + PIPE_WIDTH < self.bird.x then
                    self.score = self.score + 1
                    pair.scored = true
                    sounds['score']:play()

                    scored = true
                end
            end

            -- update position of pipePairs
            pair:update(dt)
        end

        -- remove any flagged pipes
        for k, pair in pairs(self.pipePairs) do
            if pair.remove then
                table.remove(self.pipePairs, k)
            end
        end

        -- update bird's location
        self.bird:update(dt)

        -- check collision between bird and pipes
        CollideWithPipe(self.bird, self.pipePairs, self.score)

        -- reset game if bird gets to the ground
        CollideWithGround(self.bird, self.score)
    end

    -- pause game
    if love.keyboard.wasPressed('insert') then
        scrolling = not scrolling
    end
end

function PlayState:render()
    -- render pipes
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    -- render bird
    self.bird:render()

    -- render score

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 8, 8, VIRTUAL_WIDTH, 'left')

    -- render medal when scroing, disply for 30 frame (about 0.5s)
    if scored then      
        love.graphics.draw(medal, self.bird.x + (self.bird.width - medal:getWidth()) / 2, self.bird.y - self.bird.height - 5)
        count = count + 1
        if count > 30 then
            scored = false
            count = 0
        end
    end

    -- render instruction
    love.graphics.printf('Enter "Insert" to Pause Game!', 8, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'left')

    -- pause message
    if scrolling == false then
        love.graphics.setFont(hugeFont)
        love.graphics.printf('Game Paused', 0, 120, VIRTUAL_WIDTH, 'center')
    end
end

-- called when this state is transitioned from another state
function PlayState:enter()
    scrolling = true
end

-- called when this state changes to another state
function PlayState:exit()
    scrolling = false
end