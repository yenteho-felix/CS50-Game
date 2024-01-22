--[[
    GD50 - Breakout

    Author: Felix Ho
]]

HighScoreState = Class{__includes = BaseState}

function HighScoreState:enter(params)
    self.highScores = params.highScores
end

function HighScoreState:update(dt)
    -- return to start screen if we press escape
    if love.keyboard.wasPressed('escape') then
        gSounds['wall-hit']:play()
        gStateMachine:change('start',
            {
                highScores = self.highScores
            }
        )
    end
end

function HighScoreState:render()
    local message = ''

    -- title
    message = 'High Scores'
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf(message, 0, 20, VIRTUAL_WIDTH, 'center')

    -- iterate over high score indices
    love.graphics.setFont(gFonts['medium'])
    for i = 1, 10 do
        local name = self.highScores[i].name or '----'
        local score = self.highScores[i].score or '----'

        local locY = 60 + i * 13
        local locX
        -- rank
        locX = VIRTUAL_WIDTH / 4
        love.graphics.printf(tostring(i) .. '.', locX, locY, 50, 'left')

        -- name
        locX = VIRTUAL_WIDTH / 4 + 38
        love.graphics.printf(name, locX, locY, 50, 'right')

        -- score
        locX = VIRTUAL_WIDTH / 2
        love.graphics.printf(tostring(score), locX, locY, 100, 'right')
    end

    -- intruction
    message = 'Press "Escape" to return to the main menu!'
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')
end