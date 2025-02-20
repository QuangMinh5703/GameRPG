-- combat.lua
local Combat = {}

function sleep(sec)
    local se = os.time() + sec
    while os.time() < se do
        io.write('\b','-')
        io.write('\b','\\')
        io.write('\b','|')
        io.write('\b','/')
        io.write('\b','-')
    end
end

function Combat.performAttack(attacker, defender)
    while true do
        YES = 1
        NO = 2
        print("Do you want to attack?")
        print("1. Yes")
        print("2. No")
        local choice = tonumber(io.read())
        if choice == NO then
            return false, defender
        elseif choice == YES then
            while true do
                sleep(1/attacker.attack_speed)
                local newDefender, atk1 = attacker:attack(defender)
                if newDefender.attrs.hp <= 0 then
                    print("You have killed the monster")
                    return true, newDefender
                end
                print("You attack monster "..atk1.." damage. Hp monster: "..newDefender.attrs.hp)
                sleep(1/defender.attack_speed)
                local newAttack, atk2 = defender:attack(attacker)
                if newAttack.attrs.hp <= 0 then
                    print("You were killed by the monster")
                    return false, newAttack
                end
                print("Monster attack you "..atk2.." damage. Hp you: "..newAttack.attrs.hp)
            end
        else
            print("Invalid request")
        end
    end

end

return Combat