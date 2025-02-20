local Npc = {
    attrs = {},
    drops = {}
}
Npc.__index = Npc

function Npc.new(o)
    o = o or {}
    local self = setmetatable({}, Npc)
    self.id = o.id
    self.type = o.type
    self.name = o.name
    self.level = o.level or 1
    self.exp = o.exp or 0
    self.attrs = o.attrs or {}
    self.drops = o.drops or {}
    self.x = o.x or -1
    self.y = o.y or -1
    return self
end

return Npc
