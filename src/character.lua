-- character.lua
require('class')
require('dataloader')
local Inventory = require('inventory')
local Attacker = require('attacker')

IN_PROGRESS = "in_progress"
COMPLETE = "complete"
EQUIP = "Equipped"
NOT_EQUIP = "Not equip"
ARMOR = 2
WEAPONS = 3
CONSUMABLE_ITEMS = 4

local Character = Attacker.new()
Character.__index = Character



function Character.new(name, data)
    local self = setmetatable({}, Character)
    self.name = data.name or name
    self.attrs = data.attrs
    self.level = data.level or 1
    self.exp = data.exp or 0
    self.gold = data.gold or 0
    self.attack_speed = data.attack_speed
    self.inventory = Inventory.new()
    self.quest = nil
    return self
end

function Character:displayInfo()
    print("Exp: " .. self.exp)
    print("Gold: " .. self.gold)
    Attacker.displayInfo(self)
end

function Character:acceptQuest(quest)
    self.quest = quest
    self.quest.status = IN_PROGRESS
end

function Character:showQuest()
    print((self.quest:description()))
end

function Character:displayInventory()
    if self.inventory:showAllItems() then
        return true
    end
    return false
end


function Character:removeItem(id)
    self.inventory:pop(id)
end

function Character:addItem(item)
    self.inventory:put(item)
end

function Character:useItem(i)
    local id, item = self.inventory:find(i)
    if item then
        if item.type == ARMOR or item.type == WEAPONS then
            for i in ipairs(self.inventory) do
                if item.type == self.inventory[i].type and self.inventory[i].status == EQUIP then
                    self.inventory[i]:updateStatus(0)
                end
            end
            item:updateStatus(1)
            self.attrs.atk = self.attrs.atk + (item.attrs.atk or 0)
            self.attrs.def = self.attrs.def + (item.attrs.def or 0)
            self.attrs.hp = self.attrs.hp + (item.attrs.hp or 0)
            print("You have successfully equipped the item")
            return true
        elseif item.type == CONSUMABLE_ITEMS then
            if self.hp ~= (100 + self.level * 20) then
                self.hp = self.hp + item.attrs.recover_hp
            end
            print("You use " .. item.name .. " successfully")
            table.remove(self.inventory, id)
            return true
        end
    end
    print("Item not found")
    return false
end

function Character:onExpChange()
    if self.exp >= 100 then
        self.level = self.level + 1
        self.attrs.hp = self.attrs.hp + 20
        self.attrs.atk = self.attrs.atk + 5
        self.attrs.speed = self.attrs.speed + 0.1
        self.attrs.def = self.attrs.def + 3
        self.exp = self.exp % 100
        print("You have leveled up")
    end
end

function Character:addExp(nExp)
    self.exp = self.exp + nExp
    self:onExpChange()
end

function Character:addGold(nGold)
    self.gold = self.gold + nGold
end

function Character:getReward()
   local exp, gold, idItem = self.quest:returnReward()
    self.exp = self.exp + exp
    self.gold = self.gold + gold
    self:onExpChange()
    if idItem ~= 0 then
        DataLoader:loadItems()
        self:addItem(DataLoader.items[idItem])
        return string.format("Exp: "..self.exp..", Gold: "..self.gold.." Item: "..DataLoader.items[idItem].name)
    end
    return string.format("Exp: "..self.exp..", Gold: "..self.gold)
end

function Character:updateQuestStatus()
    self.quest.status = COMPLETE
end

return Character