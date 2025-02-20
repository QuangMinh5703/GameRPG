-- monster.lua
require('class')
local Attacker = require('attacker')
local Npc = require('npc')
local Monster = createClass(Npc.new(), Attacker.new())
Monster.__index = Monster

function Monster:new(o)
    o = o or {}
    local self = setmetatable(o, Monster)
    return self
end

function Monster:dropRate()
    math.randomseed(os.time())
    math.random(1,100)
    local r = math.random(1,100)
    local totalRate = 0
    for i, drop in ipairs(self.drops) do
        local rate = totalRate + drop.rate * 100/100
        if rate <= r then
            return drop
        end
    end
end

return Monster
