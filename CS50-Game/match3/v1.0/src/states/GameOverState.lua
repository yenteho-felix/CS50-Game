--[[
    GD50 - Match3

    Game over sceen; display game over message, score and instruction

    Author: Felix Ho
]]

GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
    self.score = params.score
end

function GameOverState:update()
    -- keyboard support: enter to back to start
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('start')
    end
    -- keyboard support: escape to quit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function GameOverState:render()
    -- game over message on the center
    love.graphics.setFont(gFonts['large'])

    love.graphics.setColor(64/255, 64/255, 64/255, 192/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 80, 32, 160, 192, 4)

    love.graphics.setColor(99/255, 155/255, 255/255, 255/255)
    love.graphics.printf('GAME OVER', VIRTUAL_WIDTH / 2 - 64, 64, 128, 'center')
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Your Score: ' .. tostring(self.score), VIRTUAL_WIDTH / 2 - 64, 140, 128, 'center')
    love.graphics.printf('Press Enter', VIRTUAL_WIDTH / 2 - 64, 180, 128, 'center')
end