--[[
    GD50 - Breakout

    a basic StateMachine class which will allow us transition to and from
    game states smoothly and avoid monolithic code in one file
]]
StateMachine = Class{}

function StateMachine:init(states)
    -- Define an empty state with default functions
    self.empty = {
        render = function() end,
        update = function() end,
        enter = function() end,
        exit = function() end
    }

    -- Store the available states (if any)
    self.states = states or {}

    -- Initialize the current state as empty
    self.current = self.empty
end

function StateMachine:change(stateName, params)
    -- Check if the specified state exists
    if not self.states[stateName] then
        error("State does not exist: " .. stateName)
    end

    -- Exit the current state
    self.current:exit()

    -- Update the current state based on the specified stateName
    self.current = self.states[stateName]()

    -- Enter the new state with optional parameters
    self.current:enter(params)
end

function StateMachine:update(dt)
    -- Update the current state
    self.current:update(dt)
end

function StateMachine:render()
    -- Render the current state
    self.current:render()
end