--[[
    GD50 - Breakout

    Author: Felix Ho
]]

VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.health = params.health
    self.paddle = params.paddle
    self.ball = params.ball
end

function VictoryState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('serve',
            {
                level = self.level + 1,
                bricks = LevelMaker.createMap(self.level + 1),
                paddle = self.paddle,
                health = self.health,
                score = self.score,
                skin = self.ball.skin,
            }
        )
    end
end

function VictoryState:render()
    RenderHealth(self.health)
    RenderScore(self.score)

    local message = ''
    -- level complete text
    message = 'Level ' .. tostring(self.level) .. ' complete'
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    -- instrunctions text
    message = 'Press "Enter" to sereve!'
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
end