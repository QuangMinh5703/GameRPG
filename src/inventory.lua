local Inventory = {
    items = {}
}
Inventory.__index = Inventory

function Inventory.new()
    local self = setmetatable({}, Inventory)
    return self
end

function Inventory:put(item)
    table.insert(self.items, item)
end

function Inventory:find(item)
    local id = type(item) == 'table' and item.id or item
    for i, v in ipairs(self.items) do
        if v.id == tonumber(id) or v == id then
            return i, v
        end
    end
    return nil
end

function Inventory:pop(i)
    local id = self:find(i)
    table.remove(self.items, id)
end

function Inventory:showAllItems()
    if #(self.items) == 0 then
        print("Inventory not found")
        return false
    end
    for i, item in ipairs(self.items) do
        print("Item " .. item.id .. ":")
        item:displayAttributes()
    end
    return true
end

return Inventory