--[[
    GD50 - Flappy Bird Remake

    ScoreState Class    

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe. 

    Author: Felix Ho    
]]

ScoreState = Class{__includes = BaseState}

function ScoreState:init()
    self.score = 0
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- render the score to the middle of the screen
    love.graphics.setFont(titleFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    local medal = love.graphics.newImage('image/medal.png')
    local medalX = VIRTUAL_WIDTH / 2 - medal:getWidth() / 2 - self.score * 5 / 2
    for i=1, self.score do 
        love.graphics.draw(medal, medalX , 120)
        medalX = medalX + 5
    end

    love.graphics.printf('Press "Enter" to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')



end

-- when we enter the score state, we expect to receive the score
-- from the play state so we know what to render
function ScoreState:enter(params)
    self.score = params.score
end