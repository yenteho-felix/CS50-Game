--[[
    GD50 - Breakout

    Author: Felix Ho
]]

EnterHighScoreState = Class{__includes = BaseState}

-- default to char 'A' in ASCII code as play name
local nameChars = {
    [1] = 65,
    [2] = 65,
    [3] = 65
}

-- char we're currently changing
local highlightedChar = 1

function EnterHighScoreState:enter(params)
    self.highScores = params.highScores
    self.score = params.score
    self.scoreIndex = params.scoreIndex
end

function EnterHighScoreState:update(dt)
    -- player scroll through characters
    if love.keyboard.wasPressed('up') then
        nameChars[highlightedChar] = nameChars[highlightedChar] + 1
        if nameChars[highlightedChar] > 90 then
            nameChars[highlightedChar] = 65
        end
    elseif love.keyboard.wasPressed('down') then
        nameChars[highlightedChar] = nameChars[highlightedChar] - 1
        if nameChars[highlightedChar] < 65 then
            nameChars[highlightedChar] = 90
        end        
    end

    -- player scroll through character slots
    if love.keyboard.wasPressed('left') and highlightedChar > 1 then
        highlightedChar = highlightedChar - 1
        gSounds['select']:play()
    elseif love.keyboard.wasPressed('right') and highlightedChar < 3 then
        highlightedChar = highlightedChar + 1
        gSounds['select']:play()
    end

    -- player finished name enter; update score table
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- player name
        local name = string.char(nameChars[1]) .. string.char(nameChars[2]) .. string.char(nameChars[3])

        -- go backwards through high scores table to find right index
        -- shift index of player name by 1 for players who score lower than current one
        for i = 10, self.scoreIndex, -1 do
            self.highScores[i + 1] = {
                name = self.highScores[i].name,
                score = self.highScores[i].score
            }
        end
        self.highScores[self.scoreIndex].name = name
        self.highScores[self.scoreIndex].score = self.score

        -- write scores to file
        local scoresStr = ''
        for i = 1, 10 do
            scoresStr = scoresStr .. self.highScores[i].name .. '\n'
            scoresStr = scoresStr .. tostring(self.highScores[i].score) .. '\n'
        end
        love.filesystem.write(SCORE_FILE, scoresStr)

        -- back to high-score state
        gStateMachine:change('high-score',
            {
                highScores = self.highScores
            }
        )

    end
end

function EnterHighScoreState:render()
    local message

    -- score
    message = 'Your score: ' .. tostring(self.score)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf(message, 0, 30, VIRTUAL_WIDTH, 'center')

    -- player name
    love.graphics.setFont(gFonts['large'])

    if highlightedChar == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.print(string.char(nameChars[1]), VIRTUAL_WIDTH / 2 - 36, VIRTUAL_HEIGHT / 2)
    love.graphics.setColor(1, 1, 1, 1)

    if highlightedChar == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.print(string.char(nameChars[2]), VIRTUAL_WIDTH / 2 - 8, VIRTUAL_HEIGHT / 2)
    love.graphics.setColor(1, 1, 1, 1)

    if highlightedChar == 3 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.print(string.char(nameChars[3]), VIRTUAL_WIDTH / 2 + 20, VIRTUAL_HEIGHT / 2)
    love.graphics.setColor(1, 1, 1, 1)

    -- instruction
    love.graphics.setFont(gFonts['small'])
    message = 'Press "Enter" to confirm!'
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')

end