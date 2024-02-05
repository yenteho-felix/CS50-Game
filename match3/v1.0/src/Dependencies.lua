--[[
    GD50 - Match3

    Libraries, Classes and Files needed for the program

    Author: Felix Ho
]]

-- Libraries
Class = require 'lib/class'
Push = require 'lib/push'
Timer = require 'lib/knife.timer'

-- Classes and Files
require 'src/Utils'
require 'src/constants'

-- Game modules
require 'src/Tile'
require 'src/Board'

-- Game states
require 'src/StateMachine'
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/BeginGameState'
require 'src/states/PlayState'
require 'src/states/GameOverState'