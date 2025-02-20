require('dataloader')

local Store = {
    quests = {},
    items = {},
}
Store.__index = Store

function Store.new(name)
    local self = setmetatable({}, Store)
    self.name = name or "S"
    self.x = 1
    self.y = 2
    return self
end

-- Function display menu
function Store:displayMenu()
    print("\n==== STORE ====")
    print("1. Quests")
    print("2. Items")
    print("3. Exit")
    print("Enter your choice: ")
end

-- Function display all quest
function Store:displayAllQuest()
    for i, quest in ipairs(DataLoader.quests) do
        print("Quest " .. i .. ": ")
        display(quest, " ")
    end
end

-- Function display all item
function Store:displayAllItem()
    for i, item in ipairs(DataLoader.items) do
        print("Item " .. i .. ": ")
        display(item, " ")
    end
end

-- Function get quest by id
function Store:getQuestById(i)
    for _, quest in ipairs(DataLoader.quests) do
        if quest.id == i then
            return quest
        end
    end
    return false
end

-- Function get quest by name
function Store:getQuestByName(name)
    for i, quest in ipairs(DataLoader.quests) do
        if quest.name == name then
            return quest
        end
    end
    return false
end

-- Function get item by name
function Store:getItemByName(name)
    for _, quest in ipairs(DataLoader.items) do
        if quest.name == name then
            return quest
        end
    end
    print("Item not found")
end

-- Function get item by id
function Store:getItemById(i)
    for _, item in ipairs(DataLoader.items) do
        if item.id == i then
            return item
        end
    end
    return false
end


return Store