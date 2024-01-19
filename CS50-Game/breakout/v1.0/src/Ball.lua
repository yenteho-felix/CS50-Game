--[[
    GD50 - Breakout

    Represents a ball which will bounce back and force between the sides
    of the world space, the player's paddle, and the bricks laid out above
    the paddle. The ball have a skin, which is chosen at random.

    Author: Felix Ho
]]

Ball = Class{}

function Ball:init(skin)
    -- ball width and height
    self.width = 8
    self.height = 8

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- skin number
    self.skin = skin
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- ball to bounce off walls (left, right, and top)
    if self.x <= 0 then
        self.x = 0
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.x >= VIRTUAL_WIDTH - self.width then
        self.x = VIRTUAL_WIDTH - self.width
        self.dx = -self.dx
        gSounds['wall-hit']:play()
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        gSounds['wall-hit']:play()
    end
end

function Ball:render()
    love.graphics.draw(
        gTextures['main'],
        gFrames['balls'][self.skin],
        self.x,
        self.y
    )
end

-- expects an argument with a bounding box, be a paddle or a brick,
-- and returns true ifthe bounding boxes of this and the argument overlap.
function Ball:collides(target)
    local overlap = true
    local shiftX = 0
    local shiftY = 0

    -- check left and right edge
    if self.x > target.x + target.width or target.x > self.x + self.width then
        overlap = false
    end
    -- check top and bottom edge
    if self.y > target.y + target.height or target.y > self.y + self.height then
        overlap = false
    end

    -- calculate shiftX and shiftY of ball to move it toward edge of the paddle
    -- ball hits left side of target
    if (self.x + self.width / 2) < (target.x + target.width / 2) then
        shiftX = target.x - self.x - self.width
    -- ball hits right side of target 
    else
        shiftX = target.x + target.width - self.x
    end
    -- ball hits top side of target
    if (self.y + self.height / 2) < (target.y + target.y / 2) then
        shiftY = target.y - self.y - self.height
    else
        shiftY = target.y + target.height - self.y
    end

    return overlap, shiftX, shiftY
end

-- place the ball in the middle of the screen
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
    self.dx = 0
    self.dy = 0
end