-- quest.lua
local Quest = {
    conditions = {},
    data = {}
}
Quest.__index = Quest

function Quest.new(o)
    local self = setmetatable({}, Quest)
    self.id = o.id
    self.name = o.name
    self.type = o.type
    self.conditions = o.conditions
    return self
end

function Quest:description()
    if self.type == "kill" then
        return string.format("Goto %s and kill %d %s", self.conditions.map, self.conditions.require_num, self.conditions.monster)
    elseif self.type == "collect" then
        return string.format("Goto %s and collect %d %s", self.conditions.map, self.conditions.require_num, self.conditions.object)
    end
end

function Quest:displayReward()
    if self.conditions.reward then
        for k, v in pairs(self.conditions.reward) do
            print(k..": "..v)
        end
    end
end

function Quest:returnReward()
    if self.conditions.reward then
        local exp = self.conditions.reward.exp or 0
        local gold = self.conditions.reward.gold or 0
        local idItem = self.conditions.reward.item or 0
        return exp, gold, idItem
    end
    return nil
end

return Quest