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
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()

    -- check color and tier at the same time
    -- go down the color when color is not based color
    -- when color is based color and tier is not the base, go down tier
    if self.color == 1 then
        if self.tier == 0 then
            self.inPlay = false
        else
            self.tier = self.tier - 1
        end
    else
        if self.tier == 0 then
            self.color = self.color - 1
        else
            self.tier = self.tier - 1
        end
    end

    -- play a second layer sound if the birck is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()   
    end
end