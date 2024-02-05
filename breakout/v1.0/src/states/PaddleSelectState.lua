--[[
    GD50 - Breakout

    Author: Felix Ho
]]

PaddleSelectState = Class{__includes = BaseState}

function PaddleSelectState:enter(params)
    self.highScores = params.highScores
    self.currentPaddle = 1
end

function PaddleSelectState:update(dt)
    -- select paddle 
    if love.keyboard.wasPressed('left') then
        if self.currentPaddle == 1 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle - 1
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentPaddle == 4 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle + 1
        end
    end

    -- confirm paddle
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gSounds['confirm']:play()

        gStateMachine:change('serve',
            {
                highScores = self.highScores,
                level = 1,
                paddle = Paddle(self.currentPaddle),
                bricks = LevelMaker.createMap(1),
                health = 3,
                score = 0,
                skin = math.random(7),
            }
        )
    end

    -- quit
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PaddleSelectState:render()
    local message

    -- instructions
    message = 'Select your paddle with left and right!'
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    message = '(Press "Enter" to continue!)'
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

    -- arrow and paddle 
    local locY = VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3

    -- left arrow; tint color when currentPaddle is 1
    if self.currentPaddle == 1 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24, locY)
    love.graphics.setColor(1, 1, 1, 1)

    -- right arrow; tint color when currentPaddle is 4
    if self.currentPaddle == 4 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end
    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH * 3 / 4, locY)
    love.graphics.setColor(1, 1, 1, 1)

    -- paddle
    love.graphics.draw(gTextures['main'], gFrames['paddles'][2 + 4 * (self.currentPaddle - 1)], VIRTUAL_WIDTH / 2 - 64 / 2, locY)

end