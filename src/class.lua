-- look up for `k' in list of tables `plist'
local function search (k, plist)
    for i=1, table.getn(plist) do
        local v = plist[i][k]     -- try `i'-th superclass
        if v then return v end
    end
end

function createClass(...)
    local c = {}        -- new class

    -- class will search for each method in the list of its
    -- parents (`arg' is the list of parents)
    setmetatable(c, {__index = function (t, k)
        return search(k, arg)
    end})

    -- prepare `c' to be the metatable of its instances
    c.__index = c

    -- define a new constructor for this new class
    function c:new (o)
        o = o or {}
        setmetatable(o, c)
        return o
    end

    -- return new class
    return c
end



function deepcopy(orig, copies)
    copies = copies or {}
    if type(orig) ~= 'table' then return orig end
    if copies[orig] then return copies[orig] end
    local copy = {}
    copies[orig] = copy
    for orig_key, orig_value in pairs(orig) do
        copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
    end
    setmetatable(copy, deepcopy(getmetatable(orig), copies))
    return copy
end

