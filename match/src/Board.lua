--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class {}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}

    self:initializeTiles(level)
end

function Board:initializeTiles(level)
    self.tiles = {}

    for tileY = 1, 8 do

        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do

            -- create a new tile at X,Y with a random color and variety
            local chance = math.random(1, 100)
            local isShiny = false
            if chance <= 15 then
                isShiny = true
            end
            local colors = { 1, 6, 7, 10, 11, 12, 14, 17 }
            local color = colors[math.random(#colors)]
            table.insert(self.tiles[tileY],
                Tile(tileX, tileY, color, math.min(6, math.random(level)), isShiny))
        end
    end

    while self:calculateMatches() do

        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles(level)
    end
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local function tableContains(tbl, x)
        local found = false
        for _, v in pairs(tbl) do
            if v == x then
                found = true
            end
        end
        return found
    end

    local horizontalMatches = {}
    local verticalMatches = {}

    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        matchNum = 1

        -- every horizontal tile
        for x = 2, 8 do

            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else

                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do

                        -- add each tile to the match that's in that match
                        table.insert(match, self.tiles[y][x2])
                    end

                    -- add this match to our total matches table
                    table.insert(horizontalMatches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            -- go backwards from end of last row by matchNum
            for x = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(horizontalMatches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(verticalMatches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(verticalMatches, match)
        end
    end

    -- check for shiny tiles in matches
    local matchRows = {}
    local matchCols = {}
    -- determihe match rows
    for k, match in pairs(horizontalMatches) do
        for l, tile in pairs(match) do
            if tile.isShiny then
                table.insert(matchRows, tile.gridY)
                break
            end
        end
    end
    -- determihe match columns
    for k, match in pairs(verticalMatches) do
        for l, tile in pairs(match) do
            if tile.isShiny then
                table.insert(matchCols, tile.gridX)
                break
            end
        end
    end
    -- insert regular matches in rows
    for k, match in pairs(horizontalMatches) do
        local isRegular = true
        for l, tile in pairs(match) do
            if tableContains(matchRows, tile.gridY) then
                isRegular = false
                break
            end
        end
        if isRegular then
            table.insert(matches, match)
        end
    end
    -- insert regular matches in cols
    for k, match in pairs(verticalMatches) do
        local isRegular = true
        for l, tile in pairs(match) do
            if tableContains(matchCols, tile.gridX) then
                isRegular = false
                break
            end
        end
        if isRegular then
            table.insert(matches, match)
        end
    end

    -- insert rows
    for y = 1, 8 do
        if tableContains(matchRows, y) then
            local match = {}
            for x = 1, 8 do
                table.insert(match, self.tiles[y][x])
            end
            table.insert(matches, match)
        end
    end

    -- insert columns
    for x = 1, 8 do
        if tableContains(matchCols, x) then
            local match = {}
            for y = 1, 8 do
                table.insert(match, self.tiles[y][x])
            end
            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles(level)
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do

            -- if our last tile was a space...
            local tile = self.tiles[y][x]

            if space then

                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then

                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety and shininess
                local chance = math.random(1, 100)
                local isShiny = false
                if chance <= 15 then
                    isShiny = true
                end
                local colors = { 1, 6, 7, 10, 11, 12, 14, 17 }
                local color = colors[math.random(#colors)]
                local tile = Tile(x, y, color, math.min(6, math.random(level)), isShiny)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:swapTiles(x1, y1, x2, y2)
    local tempTile = {}
    for k, v in pairs(self.tiles[y1][x1]) do
        tempTile[k] = v
    end
    for k, v in pairs(self.tiles[y2][x2]) do
        self.tiles[y1][x1][k] = v
    end
    for k, v in pairs(tempTile) do
        self.tiles[y2][x2][k] = v
    end
end

function Board:hasMoves()
    for y = 1, 8 do
        for x = 1, 8 do
            -- check left tile
            if x > 1 then
                self:swapTiles(x, y, x - 1, y)
                local matches = self:calculateMatches()
                self:swapTiles(x, y, x - 1, y)
                if matches then
                    return true
                end
            end

            -- check right tile
            if x < 8 then
                self:swapTiles(x, y, x + 1, y)
                local matches = self:calculateMatches()
                self:swapTiles(x, y, x + 1, y)
                if matches then
                    return true
                end
            end

            -- check up tile
            if y > 1 then
                self:swapTiles(x, y, x, y - 1)
                local matches = self:calculateMatches()
                self:swapTiles(x, y, x, y - 1)
                if matches then
                    return true
                end
            end

            -- check down tile
            if y < 8 then
                self:swapTiles(x, y, x, y + 1)
                local matches = self:calculateMatches()
                self:swapTiles(x, y, x, y + 1)
                if matches then
                    return true
                end
            end
        end
    end
    return false
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end
