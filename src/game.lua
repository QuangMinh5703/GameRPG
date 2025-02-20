-- game.lua
require("dataloader")
local Map = require("map")
local Store = require("store")
local character = require("character")
local json = require("json")

EXPLORER = 1
CHAR_INFO = 2
INVENTORY = 3
QUEST = 4
EXIT = 5

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.player = character.new("P", json.load('settings/new_player.json'))
    self.store = Store.new()
    return self
end

function Game:onStartUp()
    DataLoader:init()
    print("Do you want to continue playing or start a new game?")
    print("1. Continue")
    print("2. New game")
    while true do
        local choice = tonumber(io.read())
        if choice == 1 then
            self:loadLastPlayerData()
            break
        elseif choice == 2 then
            self:resetPlayerData()
            break
        else
            print("Invalid request")
        end

    end
end

function Game:loadLastPlayerData()
    self.player = character.new("",json.load("settings/character.json"))
end

function Game:resetPlayerData()

end

function Game:run()
    self:onStartUp()
    while true do
        self:displayMainMenu()
        local choice = tonumber(io.read())
        if choice == EXPLORER then
            self:explore()
        elseif choice == CHAR_INFO then
            self:showCharacterInfo()
        elseif choice == INVENTORY then
            self:manageInventory()
        elseif choice == QUEST then
            self:viewQuests()
        elseif choice == EXIT then
            self:save()
            print("Thank you!")
            break
        else
            print("Invalid request")
        end
    end
end

function Game:displayMainMenu()
    print("\n==== SIMPLE RPG ====")
    print("1. Explorer")
    print("2. Char info")
    print("3. Inventory")
    print("4. Quest")
    print("5. Exit")
    print("Enter your choice: ")
end

function Game:explore()
    local map = Map.new("old_town", self.player, self.store)

    while true do
        map:display()
        print("Input move: ")
        local input = io.read():upper()
        if input == "Q" then
            break
        end
        map:onPlayerMove(input)
    end
end

function Game:showCharacterInfo()
    self.player:displayInfo()
end

function Game:manageInventory()
    if self.player:displayInventory() then
        while true do
            print("You want to use item: ")
            local input = io.read():upper()
            if input == "Q" then
                break
            end
            self.player:useItem(input)
            break
        end
    end
end

function Game:viewQuests()
    self.store:displayAllQuest()
end

function Game:save()
    json.saveFile("settings/character.json", self.player)
end

return Game