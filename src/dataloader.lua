local json = require('json')
local Quest = require('quest')
local Item = require('item')
local Npc = require('npc')

DataLoader = DataLoader or {
    quests = {},
    items = {},
    npcs = {},
    maps = {},
}
DataLoader.__index = DataLoader

function DataLoader:loadQuests()
    local quests = json.parse(json.readFile("settings/quest.json"))
    for i, quest in ipairs(quests) do
        table.insert(self.quests, Quest.new(quest))
    end
end

function DataLoader:loadItems()
    local items = json.parse(json.readFile("settings/item.json"))
    for i, item in ipairs(items) do
        table.insert(self.items, Item.new(item))
    end
end

function DataLoader:loadNpcs()
    local npcs = json.parse(json.readFile("settings/npcs.json"))
    for i, npc in pairs(npcs) do
        npc.id = i
        self.npcs[i] = Npc.new(npc)
    end
end

function DataLoader:loadMaps()
    local maps = json.parse(json.readFile("settings/maps.json"))
    for id, map in pairs(maps) do
        self.maps[id] = map
    end
end

function DataLoader:readMap(id)
    return self.maps[id]
end

function DataLoader:init()
    self:loadNpcs()
    self:loadQuests()
    self:loadItems()
    self:loadMaps()
end
