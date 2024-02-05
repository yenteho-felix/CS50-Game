--[[
    GD50 - Match3

    Transition between start sceen to play sceen
    1. fade in, display a drop-down "Level X" message

    Author: Felix Ho
]]

BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
    -- start our transition alpha at full
    self.alpha = 0

    -- start the level label Y location off-screen
    self.levelLabelY = -64
end

function BeginGameState:enter(params)
    self.level = params.level
    self.score = params.score

    -- Transition alpha to 1 over 1 second
    Timer.tween(1, { [self] = {alpha = 1} })
    :finish(function()

        -- Transition alpha to 0 over 1 second
        Timer.tween(1, {[self] = {alpha = 0}})

        -- After alpha transition, move the text label to the center of the screen over 0.25 seconds
        :finish(function()
            Timer.tween(0.25, {[self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}})

            -- Pause for one second with Timer.after
            :finish(function()
                Timer.after(1, function()

                    -- Animate the label going down past the bottom edge over 0.25 seconds
                    Timer.tween(0.25, {[self] = {levelLabelY = VIRTUAL_HEIGHT + 64}})

                    -- Once animation is complete, change to 'play' state
                    :finish(function()
                        gStateMachine:change('play', {level = self.level, score = self.score})
                    end)
                end)
            end)
        end)
    end)

end

function BeginGameState:update(dt)
    Timer.update(dt)
end

function BeginGameState:render()
    -- Render Level label and background rectangle
    local labelWidth = VIRTUAL_WIDTH
    local labelHeight = 48
    love.graphics.setColor(95/255, 205/255, 228/255, 200/255)
    love.graphics.rectangle('fill', 0, self.levelLabelY - 8, labelWidth, labelHeight)

    -- Render the Level label at the specified position and center it
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, self.levelLabelY, VIRTUAL_WIDTH, 'center')

    -- Render the transition foreground rectangle
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end