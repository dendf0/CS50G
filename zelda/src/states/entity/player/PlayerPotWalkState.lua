--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]
PlayerPotWalkState = Class { __includes = EntityWalkState }

function PlayerPotWalkState:init(player, dungeon)
    self.entity = player
    self.dungeon = dungeon
    self.entity:changeAnimation('pot-walk-down')

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end

function PlayerPotWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('pot-walk-left')
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('pot-walk-right')
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('pot-walk-up')
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('pot-walk-down')
    else
        self.entity:changeState('pot-idle')
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)
    
    self.entity.pot.x = self.entity.x
    self.entity.pot.y = self.entity.y - 10

    if love.keyboard.wasPressed('return') then
        self.entity:changeState('idle')
        -- throw pot
        self.entity.pot:fire(self.entity.direction)
        self.entity.pot = nil
    end

end
