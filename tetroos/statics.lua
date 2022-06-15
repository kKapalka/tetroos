statics = {}
local json = require "json"

function statics.getBoardSize()
    return {15, 20}
end

function statics.save(board)
    local test = love.filesystem.newFile("save.ttr")
    test:open("w")
    local result = json.encode(board)
    test:write(result)
    test:close()
end

function statics.load()
    local test, err = love.filesystem.newFile("save.ttr")
    if test then
        test:open("r")
        local data = test:read()
        test:close()
        love.filesystem.remove("save.ttr")
        if data then
            return json.decode(data)
        else
            return nil
        end
    else
        print(err)
    end
    return nil
end