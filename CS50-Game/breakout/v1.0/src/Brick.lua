--[[
    GD50 - Breakout

    Represent a brick in the world space that the ball can collide with;
    differently colored bricks have different point value. On collision,
    the ball will bounce away depending on the angle of collision. When all
    bricks are cleared in the current map, the player should be taken to a 
    new layout of bricks

    Author: Felix Ho
]]

Brick = Class{}

function Brick:init(x, y)
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    -- used for coloring the score calculations
    self.tier = 0                                   -- each color has 4 tiers from 0 to 3
    self.color = 1                                  -- total 6 colors from 1 to 6

    -- used to determine whether this brick should be rendered
    self.inPlay = true
end

function Brick:update(dt)
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(
            gTextures['main'],
            gFrames['bricks'][(self.color - 1) * 4 + 1 + self.tier],
            self.x,
            self.y
        )
    end
end

-- triggers a hit on the brick, taking it out of play if at 0 health
-- or changing its color otherwise.
function Brick:hit()
    self.inPlay = false

    gSounds['brick-hit-2']:play()
end