--[[
    GD50 - Flappy Bird Remake

    TileScreenState Class

    The TitleScreenState is the starting screen of the game, shown on startup. It should
    display "Press Enter" and also our highest score.

    Author: Felix Ho
]]

TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
    scrolling = true
end

function TitleScreenState:render()
    love.graphics.setFont(titleFont)
    love.graphics.printf('Fifty Bird', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press "Enter" to Start Game', 0, 100, VIRTUAL_WIDTH, 'center')
end