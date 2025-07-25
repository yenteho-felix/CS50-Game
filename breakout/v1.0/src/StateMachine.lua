--[[
    GD50 - Breakout

    a basic StateMachine class which will allow us to transition to and from
    game states smoothly and avoid monolithic code in one file
]]
StateMachine = Class{}

function StateMachine:init(states)
    self.empty = {
        render = function() end,
        update = function() end,
        enter = function() end,
        exit = function() end,
    }
    self.states = states or {}
    self.current = self.empty
end

function StateMachine:change(stateName, enterParams)
    assert(self.states[stateName])                  -- state mus exist, otherwise assert an error
    self.current:exit()                             -- exit current state
    self.current = self.states[stateName]()         -- change state
    self.current:enter(enterParams)                 -- enter new state
end

function StateMachine:update(dt)
    self.current:update(dt)
end

function StateMachine:render()
    self.current:render()
end