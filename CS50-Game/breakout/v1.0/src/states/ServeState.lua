--[[
    GD50 - Breakout

    Author: Felix Ho
]]

ServeState = Class{__includes = BaseState}

-- requires parameters 'paddle, bricks, health, score'
function ServeState:enter(params)
    self.level = params.level
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score

    -- init new ball
    self.ball = Ball()
    self.ball.skin = params.skin
end

function ServeState:update(dt)
    -- initialize 

    -- goto 'play' state
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play',
        {
            level = self.level,
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            ball = self.ball
        }
        )
    end

    -- quit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    self.paddle:render()

    self.ball:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    RenderScore(self.score)

    RenderHealth(self.health)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press "Enter" to serve!', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
end