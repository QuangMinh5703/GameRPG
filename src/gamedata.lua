local dataloader = require("dataloader")

GameData = GameData or {}

function GameData:init()
    dataloader:init()
    self.data = dataloader.items
end
