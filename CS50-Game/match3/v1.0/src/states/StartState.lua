--[[
    GD50 - Match3

    Game start screen with a game title and two options: start and quit game

    Author: Felix Ho
]]

-- Include necessary libraries
StartState = Class{__includes = BaseState}

-- Initialization function for the StartState
function StartState:init()
    -- Initialize current menu item (1: start game, 2: quit game)
    self.currentMenuItem = 1

    -- Colors used to change the title text
    self.colors = {
        {217/255, 87/255, 99/255, 1},
        {95/255, 205/255, 228/255, 1},
        {251/255, 242/255, 54/255, 1},
        {118/255, 66/255, 138/255, 1},
        {153/255, 229/255, 80/255, 1},
        {223/255, 113/255, 38/255, 1}
    }

    -- Letters of MATCH 3 and their spacing relative to the center
    self.letterTable = {
        {'M', -108},
        {'A', -64},
        {'T', -28},
        {'C', 2},
        {'H', 40},
        {'3', 112}
    }

    -- Timer to change colors every 0.075 seconds
    self.colorTimer = Timer.every(0.075, function()
        self:shiftColors()
    end)

    -- Create a match board on the center of the screen
    self.board = Board((VIRTUAL_WIDTH - 8 * 32) / 2, 16)

    -- Initialize alpha as fully transparanet at the begining
    self.alpha = 0

    -- if we've selected an option, we need to pause input while we animate out
    self.pauseInput = false
end

-- Update function for the StartState
function StartState:update(dt)
    -- Check for quit input
    self:checkQuitInput()

    -- Only allow menu interaction if not in a transition
    if not self.pauseInput then
        -- Update menu selection based on 'Up' and 'Down' keys
        self:updateMenuSelection()

        -- Handle menu option selection when 'Enter' or 'Return' is pressed
        self:handleMenuSelection()
    end

    -- Update Timer for fade transitions
    Timer.update(dt)
end

-- Render function for the StartState
function StartState:render()
    -- self.board:render()
    self:renderMatch3Title(-16)
    self:renderOptions(16)
    self:renderTransitionEffect()
end

-- Draw the title text "MATCH 3" with changing colors
function StartState:renderMatch3Title(y)
    local width, height = 150, 58
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y - height, width, height, 6)

    local textY = VIRTUAL_HEIGHT / 2 + y - height / 2 - 16
    love.graphics.setFont(gFonts['large'])
    self:renderTextShadow('MATCH 3', textY)

    for i = 1, 6 do
        love.graphics.setColor(self.colors[i])
        love.graphics.printf(self.letterTable[i][1], 0, textY, VIRTUAL_WIDTH + self.letterTable[i][2], 'center')
    end
end

-- Draw the start and quit game options
function StartState:renderOptions(y)
    local width, height = 150, 58

    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y, width, height, 6)

    love.graphics.setFont(gFonts['medium'])
    self:renderTextShadow('Start', VIRTUAL_HEIGHT / 2 + y + 8)
    self:renderMenuItem('Start', 1, VIRTUAL_HEIGHT / 2 + y + 8)

    self:renderTextShadow('Quit Game', VIRTUAL_HEIGHT / 2 + y + 33)
    self:renderMenuItem('Quit Game', 2, VIRTUAL_HEIGHT / 2 + y + 33)
end

-- Draw text shadow for a given text at y position
function StartState:renderTextShadow(text, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    for dx = -1, 1 do
        for dy = -1, 1 do
            love.graphics.printf(text, dx, y + dy, VIRTUAL_WIDTH, 'center')
        end
    end
end

-- Draw a menu item with the specified text, item index, and y position
function StartState:renderMenuItem(text, itemIndex, y)
    local isSelected = self.currentMenuItem == itemIndex
    local alpha = isSelected and 1 or 0.5
    local color = isSelected and {99/255, 155/255, 1, alpha} or {48/255, 96/255, 130/255, alpha}

    love.graphics.setColor(unpack(color))
    love.graphics.printf(text, 0, y, VIRTUAL_WIDTH, 'center')
end

-- Transition effeect
function StartState:renderTransitionEffect()
    -- Set to fully transparent, and tween it to full opaque
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

-- Check for quit input
function StartState:checkQuitInput()
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

-- Update menu selection based on 'Up' and 'Down' keys
function StartState:updateMenuSelection()
    if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
        self:toggleMenuItem()
        gSounds['select']:play()
    end
end

-- Handle the toggle of a menu item
function StartState:toggleMenuItem()
    local totalItems = 2

    if love.keyboard.wasPressed('up') then
        self.currentMenuItem = self.currentMenuItem - 1
        if self.currentMenuItem < 1 then
            self.currentMenuItem = totalItems
        end
    elseif love.keyboard.wasPressed('down') then
        self.currentMenuItem = self.currentMenuItem + 1
        if self.currentMenuItem > totalItems then
            self.currentMenuItem = 1
        end
    end
end

-- Handle menu option selection when 'Enter' or 'Return' is pressed
function StartState:handleMenuSelection()
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        if self.currentMenuItem == 1 then
            self:transitionToBeginGame()
        else
            love.event.quit()
        end
    end
end

-- Transition to the 'Begin Game' state
function StartState:transitionToBeginGame()
    -- Transition alpha to 1 over 1 second
    Timer.tween(1, { [self] = {alpha = 1} })

    -- After alpha transition, move to begin-game state
    :finish(function()
        gStateMachine:change('begin-game', { level = 1 })
        self.colorTimer:remove()
    end)

    self.pauseInput = true  -- Turn off input during transition
end

-- Change color of MATCH 3
function StartState:shiftColors()
    self.colors[0] = self.colors[6]
    for i = 6, 1, -1 do
        self.colors[i] = self.colors[i - 1]
    end
end