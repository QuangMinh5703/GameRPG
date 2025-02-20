local json = {}
-- Function read file
function json.readFile(name)
    local file = io.open(name, "r")
    if not file then
        -- If file doesn't exist, create file
        file = io.open(name, "w")
        file:write('{}')
        if not file then
            error("Không thể tạo file: " .. name)
        end

        file:close()
        return "{}"
    else
        -- If file already exist, read file
        local content = file:read("*a")
        file:close()
        return content
    end
end

-- Function save file
function json.saveFile(name, table)
    local jsonResult = json.convertJson(table)
    io.output(name)
    io.write(jsonResult)
    io.close()
end

-- Function convert table to json
function json.convertJson(T)
    -- Check if type data is not table
    if type(T) ~= "table" then
        return tostring(T)
    end

    local isArray = #T > 0
    local result = {}

    -- Check if type data is array
    if isArray then
        for _, value in ipairs(T) do
            table.insert(result, json.convertJson(value))
        end

        return "[" .. table.concat(result, ",") .. "]"
    else
        for key, value in pairs(T) do
            -- Check if type value is string
            if type(value) == "string" then
                table.insert(result, string.format("\"%s\":\"%s\"", key, value))
            else
                table.insert(result, string.format("\"%s\":%s", key, json.convertJson(value)))
            end
        end

        return "{" .. table.concat(result, ",") .. "}"
    end
end

function parseString(str, pos)
    local t = pos
    while pos <= #str do
        local char = str:sub(pos, pos)
        if char == '"' then
            return str:sub(t, pos - 1), pos + 1
        elseif char == '\\' then
            -- TODO: support utf8
        end
        pos = pos + 1
    end
    error("Chuoi loi tai vi tri " .. pos)
end

function parseObject(str, pos)
    local obj = {}
    local k, v
    local needKey = true
    while pos <= #str do
        local char = str:sub(pos, pos)
        if char:match("%s") then
            pos = pos + 1
        elseif char == '"' then
            if needKey then
                k, pos = parseString(str, pos + 1)
                needKey = false
            else
                v, pos = parseValue(str, pos)
                obj[k] = v
                needKey = true
            end
        elseif char == ":" then
            pos = pos + 1
            needKey = false
        elseif char == "," then
            pos = pos + 1
            needKey = true
        elseif char == "}" then
            return obj, pos + 1
        else
            -- array or object
            v, pos = parseValue(str, pos)
            obj[k] = v
            needKey = true
        end
    end
    error("Parse Object Error at pos: " .. pos)
end

function parseNumber(str, pos)
    local num = ""
    while pos <= #str do
        local char = str:sub(pos, pos)
        if char:match("[%+%-%.%deE]") then
            num = num .. char
            pos = pos + 1
        else
            break
        end
    end
    return tonumber(num), pos
end

function parseArray(str, pos)
    local arr = {}
    local index = 1
    while pos <= #str do
        local char = str:sub(pos, pos)
        if char == ']' then
            return arr, pos + 1
        elseif char:match("%s") or char == "," then
            pos = pos + 1
        else
            local value
            value, pos = parseValue(str, pos)
            arr[index] = value
            index = index + 1
        end
    end
    error("Parse Array Error at pos: " .. pos)
end

function parseValue(str, pos)
    local char = str:sub(pos, pos)
    if char == "{" then
        return parseObject(str, pos + 1)
    elseif tonumber(char) ~= nil or char == "-" then
        return parseNumber(str, pos)
    elseif char == "[" then
        return parseArray(str, pos + 1)
    elseif char == '"' then
        return parseString(str, pos + 1)
    elseif char == "t" then
        return true, pos + 4
    elseif char == "f" then
        return false, pos + 5
    elseif char == "n" then
        return nil, pos + 4
    elseif char:match("%s") then
        pos = pos + 1
    else
        error("loi ky tu " .. char .. " khong hop le, pos = " .. pos)
    end
end

function json.parse(content)
    local result, pos = parseValue(content, 1);
    if pos <= #content then
        error("Error at pos: " .. pos)
    end
    return result
end

function json.parse(content)
    local result, pos = parseValue(content, 1);
    if pos <= #content then
        error("Error at pos: " .. pos)
    end
    return result
end

function json.load(file)
    return json.parse(json.readFile(file))
end

function display(data, indent)
    indent = indent or ""
    --Kiểm tra xem data được truyền vào có kiểu gì
    if type(data) == "table" then
        for k, v in pairs(data) do
            if type(v) == "table" then
                print(indent .. tostring(k) .. ":")
                display(v, indent .. "  ")
            else
                print(indent .. tostring(k) .. ": " .. tostring(v))
            end
        end
    else
        print(indent .. tostring(data))
    end
end

return json