local Attacker = {}
Attacker.__index = Attacker

function Attacker.new(o)
    o = o or {}
    local self = setmetatable({}, Attacker)
    self.name = o.name
    self.attrs = o.attrs or {
        hp = 1,
        atk = 1,
        def = 1,
    }
    self.attack_speed = o.attack_speed or 1
    self.level = o.level or 1
    self.hp = self.attrs.hp
    self.x = o.x or -1
    self.y = o.y or -1
    return self
end

function Attacker:attack(target)
    local atk = self.attrs.atk - target.attrs.def
    if atk <= 0 then
        atk = 0
        return target, atk
    end
    target.attrs.hp = target.attrs.hp - atk
    return target, atk
end

function Attacker:displayInfo()
    print("Name: " .. self.name)
    print("Level: " .. self.level)
    print("Current HP: " .. self.hp)
    print("Attack speed: " .. self.attack_speed)
    for k, v in pairs(self.attrs) do
        print(k..": " .. v)
    end
end

return Attacker
