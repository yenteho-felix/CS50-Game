--[[
    GD50 - Flappy Bird Remake

    PipePair Class

    Used to represent a pair of pipes that stick together as they scroll, providing an opening
    for the player to jump through in order to score a point.

    Author: Felix Ho
]]

PipePair = Class{}

-- y variable defines the y-axis of pipePair
function PipePair:init(y)
    -- pipe pair should be initialized outside of the right edge of the screen
    -- x value is the width of screen
    -- y value is the topmost pipe
    self.x = VIRTUAL_WIDTH
    self.y = y

    -- size of the gap between tio and bottom pipes
    self.gap = math.random(90, 120)

    -- create pipe pairs
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + self.gap + PIPE_HEIGHT)
    }

    -- whether this pipe pair is ready to be removed fromt he scene
    self.remove = false

    -- flag to hold whether this pair has been scored
    self.score = false
end

function PipePair:update(dt)
    -- remove the pipe from the scene if it's beyong the left edge of the screen
    -- else move it from right to left
    if self.x > 0 - PIPE_WIDTH then
        self.x = self.x - GROUND_SCROLL_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end