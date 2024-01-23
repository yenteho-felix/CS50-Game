--[[
    GD50 - Breakout

    Author: Felix Ho
]]

StartState = Class{__includes = BaseState}

local highlighted = 1

function StartState:enter(params)
    self.highScores = params.highScores
end

function StartState:update(dt)
    keyboardHandling(self)
end

function StartState:render()
    -- game title
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')

    -- render blue color on option selected
    -- game option 1
    love.graphics.setFont(gFonts['medium'])
    if highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)

    -- game option 2
    if highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(1, 1, 1, 1)
end

function keyboardHandling(self)
    -- toggle highlighted option if we press an arrow key up or down
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        highlighted = highlighted == 1 and 2 or 1
        gSounds['paddle-hit']:play()
    end

    -- enter the game option when 'enter' or 'return' key wasPressed
    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['confirm']:play()

        -- play game; enter serve state
        if highlighted == 1 then
            gStateMachine:change('paddle-select',
                {
                    highScores = self.highScores
                }
            )
        end

        -- see score; enter high-score state
        if highlighted == 2 then
            gStateMachine:change('high-score',
                {
                    highScores = self.highScores
                }
            )
        end
    end

    -- quit if we press an escape key
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end