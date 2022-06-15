function love.conf(t)
    require "statics"
    size = statics.getBoardSize()
    t.window.width = 20 * (size[1] + 4)
    t.window.height = 20 * (size[2] + 7)
end
