--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, isShiny)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- tile is shiny
    self.isShiny = isShiny
end

function Tile:render(x, y)
    if self.isShiny == false then
        -- draw shadow
        love.graphics.setColor(34, 32, 52, 255)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2)  
    end

    -- draw tile itself
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    -- draw another tile inside if shiny
    if self.isShiny == true then
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 1, self.y + y + 1, 0, 0.9375, 0.9375)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 2, self.y + y + 2, 0, 0.875, 0.875)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 4, self.y + y + 4, 0, 0.75, 0.75)
        love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
            self.x + x + 8, self.y + y + 8, 0, 0.5, 0.5)

        -- make shiny
        love.graphics.setBlendMode('add')
        love.graphics.setColor(1, 215/255, 0, 30 / 255)
        love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32, 8)
        love.graphics.setBlendMode('alpha')
    end
end