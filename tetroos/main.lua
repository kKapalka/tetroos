function love.load()
    love.graphics.setBackgroundColor(255, 255, 255)
    require "pieces"
    require "statics"
    size = statics.getBoardSize()
    pieceStructures = pieces.get()
    
    gridXCount = size[1]
    gridYCount = size[2]

    pieceXCount = 4
    pieceYCount = 4

    timerLimit = 0.5

    savedBoard = statics.load()

    

    function canPieceMove(testX, testY, testRotation)
        for y = 1, pieceYCount do
            for x = 1, pieceXCount do
                local testBlockX = testX + x
                local testBlockY = testY + y

                if pieceStructures[pieceType][testRotation][y][x] ~= 0 and (
                    testBlockX < 1
                    or testBlockX > gridXCount
                    or testBlockY > gridYCount
                    or inert[testBlockY][testBlockX] ~= 0
                ) then
                    return false
                end
            end
        end

        return true
    end

    function newSequence()
        sequence = {}
        for pieceTypeIndex = 1, #pieceStructures do
            local position = love.math.random(#sequence + 1)
            table.insert(
                sequence,
                position,
                pieceTypeIndex
            )
        end
    end

    function newPiece()
        pieceX = 3
        pieceY = 0
        pieceRotation = 1
        pieceType = table.remove(sequence)

        if #sequence == 0 then
            newSequence()
        end
    end

    function reset()
        inert = {}
        for y = 1, gridYCount do
            inert[y] = {}
            for x = 1, gridXCount do
                inert[y][x] = 0
            end
        end
        newSequence()
        newPiece()
        timer = 0
    end
    if savedBoard then
        inert = savedBoard
        newSequence()
        newPiece()

        timer = 0
    else 
        reset()
    end
end

function love.update(dt)
    timer = timer + dt

    if love.keyboard.isDown('space') then
        timerLimit = 0.05
    else
        timerLimit = 0.5
    end

    if timer >= timerLimit then
        timer = 0

        local testY = pieceY + 1
        if canPieceMove(pieceX, testY, pieceRotation) then
            pieceY = testY
        else
            -- Add piece to inert
            for y = 1, pieceYCount do
                for x = 1, pieceXCount do
                    local block =
                        pieceStructures[pieceType][pieceRotation][y][x]
                    if block ~= 0 then
                        inert[pieceY + y][pieceX + x] = block
                    end
                end
            end

            -- Find complete rows
            for y = 1, gridYCount do
                local complete = true
                for x = 1, gridXCount do
                    if inert[y][x] == 0 then
                        complete = false
                        break
                    end
                end

                if complete then
                    for removeY = y, 2, -1 do
                        for removeX = 1, gridXCount do
                            inert[removeY][removeX] = inert[removeY - 1][removeX]
                        end
                    end

                    for removeX = 1, gridXCount do
                        inert[1][removeX] = 0
                    end
                end
            end

            newPiece()

            if not canPieceMove(pieceX, pieceY, pieceRotation) then
                reset()
            end
        end
    end
end

function love.keypressed(key)
    if key == 'x' then
        local testRotation = pieceRotation + 1
        if testRotation > #pieceStructures[pieceType] then
            testRotation = 1
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end

    elseif key == 'z' then
        local testRotation = pieceRotation - 1
        if testRotation < 1 then
            testRotation = #pieceStructures[pieceType]
        end

        if canPieceMove(pieceX, pieceY, testRotation) then
            pieceRotation = testRotation
        end

    elseif key == 'left' then
        local testX = pieceX - 1

        if canPieceMove(testX, pieceY, pieceRotation) then
            pieceX = testX
        end

    elseif key == 'right' then
        local testX = pieceX + 1

        if canPieceMove(testX, pieceY, pieceRotation) then
            pieceX = testX
        end

    elseif key == 's' then
        statics.save(inert)
        print("save complete")

    elseif key == 'c' then
        while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
            pieceY = pieceY + 1
            timer = timerLimit
        end
    end
end


function love.draw()
    local function drawBlock(block, x, y)
        local colors = {
            {.97, .97, .97},
            {.3, .6, .9},
            {.6, .9, .3},
            {.9, .3, .6},
            {.6, .3, .9},
            {.3, .9, .6},
            {.9, .6, .3},
            {5, .5, .9},
            {.9, .9, .9},
        }
        local color = colors[block+1]
        love.graphics.setColor(color)

        local blockSize = 20
        local blockDrawSize = blockSize - 1
        love.graphics.rectangle(
            'fill',
            (x - 1) * blockSize,
            (y - 1) * blockSize,
            blockDrawSize,
            blockDrawSize
        )
    end

    local offsetX = 2
    local offsetY = 5

    for y = 1, gridYCount do
        for x = 1, gridXCount do
            drawBlock(inert[y][x], x + offsetX, y + offsetY)
        end
    end

    for y = 1, pieceYCount do
        for x = 1, pieceXCount do
            local block = pieceStructures[pieceType][pieceRotation][y][x]
            if block ~= 0 then
                drawBlock(block, x + pieceX + offsetX, y + pieceY + offsetY)
            end
        end
    end

    for y = 1, pieceYCount do
        for x = 1, pieceXCount do
            local block = pieceStructures[sequence[#sequence]][1][y][x]
            if block ~= 0 then
                drawBlock(8, x + 5, y + 1)
            end
        end
    end
end
