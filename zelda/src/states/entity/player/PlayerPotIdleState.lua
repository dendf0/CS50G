--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

PlayerPotIdleState = Class{__includes = EntityIdleState}

function PlayerPotIdleState:init(player)
    self.entity = player

    self.entity:changeAnimation('pot-idle-' .. self.entity.direction)

    -- render offset for spaced character sprite; negated in render function of state
    self.entity.offsetY = 5
    self.entity.offsetX = 0
end


function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk')
    end

    if love.keyboard.wasPressed('return') then
        self.entity:changeState('idle')

        -- throw pot
        self.entity.pot:fire(self.entity.direction)
        self.entity.pot = nil
    end
end