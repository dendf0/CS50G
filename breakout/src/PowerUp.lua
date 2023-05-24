PowerUp = Class {}

function PowerUp:init(x, y, type)

    self.x = x
    self.y = y
    self.dy = POWERUP_SPEED
    self.width = 16
    self.height = 16
    -- type
    self.type = type
end

function PowerUp:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end
    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end
    return true
end

function PowerUp:update(dt)
    self.y = self.y + self.dy * dt
end

function PowerUp:render()
    love.graphics.draw(gTextures['powerups'], gFrames['powerups'][self.type], self.x, self.y)
end
