-- map.lua
require('dataloader')
require('class')
local Combat = require("combat")
local Monster = require("monster")
local Npc = require("npc")
local Map = {}
Map.__index = Map

function Map.new(id, player, store)
    math.randomseed(os.time())
    local self = setmetatable({}, Map)
    self.id = id

    local data = DataLoader:readMap(id)
    self.width = data.width
    self.height = data.height
    self.grids = {}
    self.store = store
    self.npcs = self:loadNpcs(data.npcs)
    for x = 1, self.width do
        self.grids[x] = self.grids[x] or {}
        for y = 1, self.height do
            for i, npc in ipairs(self.npcs) do
                if npc.type ~= "npc" and math.random(1,100) == 10 then
                    self.grids[x][y] = self.npcs[i]
                    table.remove(self.npcs, i)
                    break
                else
                    self.grids[x][y] = "."
                end
            end
        end
    end

    player.x, player.y = 1, 1
    self.player = player
    self.grids[player.x][player.y] = player
    for i, npc in ipairs(self.npcs) do
        self.grids[npc.x][npc.y] = npc
    end

    return self
end

function Map:loadNpcs(config)
    local npcs = {}
    for npcId, option in pairs(config) do
        local npc = DataLoader.npcs[npcId]
        if type(option) == "number" then
            for i = 1, option do
                local monster = Monster:new(deepcopy(npc))
                table.insert(npcs, monster)
            end
        else
            npc.x = option.x
            npc.y = option.y
            local object = Npc.new(npc)
            table.insert(npcs, object)
        end
    end
    return npcs
end

function Map:onPlayerMove(direction)
    local newX, newY = self.player.x, self.player.y
    if direction == "A" then
        newX = self.player.x - 1
    elseif direction == "D" then
        newX = self.player.x + 1
    elseif direction == "W" then
        newY = self.player.y - 1
    elseif direction == "S" then
        newY = self.player.y + 1
    end
    if newX >= 1 and newX <= self.width and newY >= 1 and newY <= self.height then
        self.grids[self.player.x][self.player.y] = "."
        local oldX, oldY = self.player.x, self.player.y
        self.player.x = newX
        self.player.y = newY
        if self.grids[newX][newY] ~= "." then
            if self.grids[newX][newY].type == "npc" then
                self:inStore()
                self.player.x, self.player.y = oldX, oldY
            elseif self.grids[newX][newY].type == "monster" then
                print("You have met the monster")
                local result, loser = Combat.performAttack(self.player, self.grids[newX][newY])
                if result then
                    self.player:addExp(self.grids[newX][newY].exp)
                    if self.grids[newX][newY].drops then
                        local drop = self.grids[newX][newY]:dropRate()
                        if drop.gold then
                            self.player:addGold(drop.gold)
                        elseif drop.item then
                            local item = self.store:getItemById(drop.item)
                            self.player:addItem(item)
                        end
                    end
                    if self.player.quest ~= nil and self.player.quest.conditions.monster == self.grids[newX][newY].name then
                        self.player.quest.conditions.require_num = self.player.quest.conditions.require_num - 1
                        self.grids[newX][newY] = self.player
                        if self.player.quest.conditions.require_num == 0 then
                            self.player:updateQuestStatus()
                            self:reward()
                        end
                    end
                else
                    if loser.attrs.hp == self.grids[newX][newY].attrs.hp then
                        self.player.x, self.player.y = oldX, oldY
                    else
                        self.player.x = 1
                        self.player.y = 1
                    end
                end
            elseif self.grids[newX][newY].type == "tree" then
                print("You picked up the "..self.grids[newX][newY].name)
                if self.player.quest ~= nil and self.player.quest.conditions.object == self.grids[newX][newY].name then
                    self.player.quest.conditions.require_num = self.player.quest.conditions.require_num - 1
                    self.grids[newX][newY] = self.player
                    if self.player.quest.conditions.require_num == 0 then
                        self.player:updateQuestStatus()
                        self:reward()
                    end
                end
            end
        end
        self.grids[self.player.x][self.player.y] = self.player
    else
        print("Can't move to this pos")
    end
end

function Map:display()
    print(string.rep("-", self.width + 2))
    for y = 1, self.height do
        io.write("|")
        for x = 1, self.width do
            if type(self.grids[x][y]) == "table" then
                io.write(string.sub(self.grids[x][y].name, 1 , 1))
            else
                io.write(self.grids[x][y])
            end
        end
        print("|")
    end
    print(string.rep("-", self.width + 2))
    if self.player.quest ~= nil and self.player.quest.status ~= COMPLETE then
        print(self.player:showQuest())
    end
end

-- Function display in Store
function Map:inStore()
    while true do
        self.store:displayMenu()
        local choice = tonumber(io.read())
        if choice == 1 then
            self.store:displayAllQuest()
            while true do
                print("Get the quest: ")
                local input = io.read():upper()
                if input == "Q" then
                    break
                end
                local quest = self.store:getQuestById(tonumber(input))
                if quest then
                    self.player:acceptQuest(quest)
                    break
                end
                print("No this quest")
            end
        elseif choice == 2 then
            self.store:displayAllItem()
            while true do
                print("You want to buy or sell item")
                print("1. Buy")
                print("2. Sell")
                print("3. Exit")
                local input = tonumber(io.read())
                if input == 1 then
                    self:buyItem()
                elseif input == 2 then
                    self:sellItem()
                elseif input == 3 then
                    break
                else
                    print("Invalid request")
                end
            end
            break
        elseif choice == 3 then
            print("Thanks you")
            break
        else
            print("Invalid request")
        end
    end
end

function Map:reward()
    print("You have completed the quest")
    print("You receive the quest reward: ")
    print(self.player:getReward())
end

function Map:buyItem()
    while true do
        print("You want to buy item: ")
        local input = tonumber(io.read())
        local item = self.store:getItemById(input)
        if item then
            if self.player.gold >= item.price then
                self.player:addItem(item)
                self.player.gold = self.player.gold - item.price
                print("You buy item successfully")
                break
            end
            print("You don't have enough gold")
            break
        end
        print("Item not found")
    end
end

function Map:sellItem()
    while true do
        print("Your inventory")
        if self.player:displayInventory() then
            print("You want to sell item: ")
            local input = tonumber(io.read())
            local id, item = self.player.inventory:find(input)
            if item then
                self.player.gold = self.player.gold + item.price
                self.player:removeItem(id)
                print("You sell item successfully")
                break
            end
            print("Item not found")
        end
        break
    end
end

return Map
