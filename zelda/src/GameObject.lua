--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]
GameObject = Class {}

function GameObject:init(def, x, y)
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.consumable = def.consumable

    self.projectile = def.projectile
    self.speed = 80
    self.distance = 0
    self.direction = 'down'
    self.dx = def.dx
    self.dy = def.dy
    self.shatterTime = 0
    self.shatterTimeLimit = 1

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    -- default empty callback
    self.onCollide = function()
    end
    self.onConsume = function()
    end
    self.onShatter = function()
    end
end

function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
        self.y + self.height < target.y or self.y > target.y + target.height)
end

function GameObject:fire(direction)
    self.direction = direction
    if direction == 'down' then
        self.dx = 0
        self.dy = self.speed
    elseif direction == 'up' then
        self.dx = 0
        self.dy = -self.speed
    elseif direction == 'left' then
        self.dx = -self.speed
        self.dy = 0
    elseif direction == 'right' then
        self.dx = self.speed
        self.dy = 0
    end
    self.projectile = true
end

function GameObject:update(dt)
    if not self.projectile then
        return
    end
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self.distance = self.distance + self.speed * dt


    -- assume we didn't hit a wall
    self.bumped = false
    if self.direction == 'left' then
        if self.x <= MAP_RENDER_OFFSET_X + TILE_SIZE then
            self.x = MAP_RENDER_OFFSET_X + TILE_SIZE
            self.bumped = true
        end
    elseif self.direction == 'right' then
        if self.x + self.width >= VIRTUAL_WIDTH - TILE_SIZE * 2 then
            self.x = VIRTUAL_WIDTH - TILE_SIZE * 2 - self.width
            self.bumped = true
        end
    elseif self.direction == 'up' then
        if self.y <= MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2 then
            self.y = MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height / 2
            self.bumped = true
        end
    elseif self.direction == 'down' then
        local bottomEdge = VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE)
            + MAP_RENDER_OFFSET_Y - TILE_SIZE

        if self.y + self.height >= bottomEdge then
            self.y = bottomEdge - self.height
            self.bumped = true
        end
    end
    if self.bumped then
        self.onShatter()
    end
end

function GameObject:fall()
    return self.distance > 64
end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
end
