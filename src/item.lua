-- item.lua
local Item = {
    STATUS_EQUIPPED = 1,
    STATUS_NOT_EQUIP = 0,

    TYPE_ARMOR = 2,
    TYPE_WEAPONS = 3,
    TYPE_CONSUMABLE = 4,
}
Item.__index = Item

function Item.new(o)
    local self = setmetatable({}, Item)
    self.id = o.id
    self.name = o.name
    self.type = o.type
    self.price = o.price
    self.attrs = o.attrs
    self.status = o.status or self.STATUS_NOT_EQUIP
    return self
end

function Item:updateStatus(status)
    self.status = status
end

function Item:getStatus()
    local statuses = {
        [self.STATUS_EQUIPPED] = "Equipped",
            [self.STATUS_NOT_EQUIP] = "Not equip",
    }
    return statuses[self.status]
end

function Item:getType()
    local type = {
        [self.TYPE_ARMOR] = "Armor",
        [self.TYPE_WEAPONS] = "Weapons",
        [self.TYPE_CONSUMABLE] = "Consumable items",
    }
    return type[self.type]
end

function Item:displayAttributes()
    print(string.format("Name: %s (%s)", self.name, self.type))
    print("Price: " .. self.price)
    print("Status: " .. self:getStatus())
    for k, v in pairs(self.attrs) do
        print(k .. ": " .. v)
    end
end

return Item