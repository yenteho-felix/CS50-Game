--[[
    GD50 - Breakout

    Author: Felix Ho
]]

GameOverState = Class{__includes = BaseState}

-- pass in parameter 'score'
function GameOverState:enter(params)
    self.highScores = params.highScores
    self.score = params.score
end

function GameOverState:update(dt)
    -- enter next state
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- flag if score is higher than any in the high scores table
        local highScore = false

        -- keep track of what high score ours overwrites, if any
        local highScoreIndex = 11

        for i = 10, 1, -1 do
            local score = self.highScores[i].score or 0
            if self.score > score then
                highScoreIndex = i
                highScore = true
            end
        end

        -- enter high-score state or start state
        if highScore then
            gSounds['high-score']:play()
            gStateMachine:change('enter-high-score',
                {
                    highScores = self.highScores,
                    score = self.score,
                    scoreIndex = highScoreIndex,
                }
            )
        else
            gStateMachine:change('start',
                {
                    highScores = self.highScores
                }
            )
        end
    end

    -- quit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function GameOverState:render()
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Final Score: ' .. tostring(self.score), 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press "Enter"', 0, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
end