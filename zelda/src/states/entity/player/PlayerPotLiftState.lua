--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]
PlayerPotLiftState = Class { __includes = BaseState }

function PlayerPotLiftState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    -- create hitbox based on where the player is and facing
    local direction = self.player.direction
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight

    if direction == 'left' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x - hitboxWidth
        hitboxY = self.player.y + 2
    elseif direction == 'right' then
        hitboxWidth = 8
        hitboxHeight = 16
        hitboxX = self.player.x + self.player.width
        hitboxY = self.player.y + 2
    elseif direction == 'up' then
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y - hitboxHeight
    else
        hitboxWidth = 16
        hitboxHeight = 8
        hitboxX = self.player.x
        hitboxY = self.player.y + self.player.height
    end

    self.armsHitbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)
end

function PlayerPotLiftState:enter(params)
    local potFound = false
    -- check if hitbox collides with any pots in the scene
    for k, object in pairs(self.dungeon.currentRoom.objects) do
        if not potFound and object.solid and object:collides(self.armsHitbox) and object.state == 'intact' then
            potFound = true

            object.x = self.player.x
            object.y = self.player.y - 10

            self.player.pot = object

            self.player:changeAnimation('pot-lift-' .. self.player.direction)
            self.player.currentAnimation:refresh()
        end
    end

    if not potFound then
        self.player:changeState('idle')
        self.player.pot = nil
    end
end

function PlayerPotLiftState:update(dt)
    if self.player.currentAnimation:isLastFrame() then
        self.player:changeState('pot-idle')
    end
end

function PlayerPotLiftState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture],
        gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x - self.player.offsetX),
        math.floor(self.player.y - self.player.offsetY))

    --
    -- debug for player and hurtbox collision rects VV
    --

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    -- love.graphics.rectangle('line', self.swordHurtbox.x, self.swordHurtbox.y,
    --     self.swordHurtbox.width, self.swordHurtbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end
