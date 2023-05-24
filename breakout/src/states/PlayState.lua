--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class { __includes = BaseState }

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
    self.recoverPoints = 5000
    self.growPoints = 3000
    self.ballsNumber = 1
    self.balls = {}
    self.balls[0] = params.ball

    self.powerups = {}

    -- true if key is already picked
    self.unlocked = false

    -- give ball random starting velocity
    self.balls[0].dx = math.random(-200, 200)
    self.balls[0].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for k, ball in pairs(self.balls) do
        ball:update(dt)
    end

    -- for all balls

    for k, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

                -- else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                if brick.locked then
                    if self.unlocked then
                        self.score = self.score + 1000
                        brick.inPlay = false
                    end
                    brick:hit()
                else
                    -- add to score
                    self.score = self.score + (brick.tier * 200 + brick.color * 25)

                    -- trigger the brick's hit function, which removes it from play
                    brick:hit()
                end



                if self.score >= self.growPoints then
                    if self.paddle.size < 4 then
                        self.paddle:grow()
                        self.growPoints = self.growPoints + math.min(50000, self.growPoints * 2)
                    end
                end

                -- if we have enough points, recover a point of health
                if self.score > self.recoverPoints then
                    -- can't go above 3 health
                    self.health = math.min(3, self.health + 1)

                    -- multiply recover points by 2
                    self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                    -- play recover sound effect
                    gSounds['recover']:play()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    -- determine one inPlay ball
                    local ballIndex = 0
                    for k, b in pairs(self.balls) do
                        if b.inPlay == true then
                            ballIndex = k
                            break
                        end
                    end

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.balls[ballIndex],
                        recoverPoints = self.recoverPoints
                    })
                end

                -- spawn powerup with some chance
                if math.random() <= 0.375 then
                    -- 10% chance to get each type of powerups
                    local p = PowerUp(brick.x + brick.width / 2, brick.y)
                    p.type = math.random(10)
                    -- more chances for multiple balls powerup
                    if p.type == 7 or p.type == 8 then
                        p.type = 9
                    end
                    -- adjust to align center of the brick
                    p.x = p.x - p.width / 2
                    table.insert(self.powerups, p)
                end


                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right, and offset the check by a couple of pixels
                -- so that flush corner hits register as Y flips, not X flips
                if ball.x + 2 < brick.x and ball.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8

                    -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
                    -- so that flush corner hits register as Y flips, not X flips
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32

                    -- top edge if no X collisions, always check
                elseif ball.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8

                    -- bottom edge if no X collisions or top collision, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game, capping at +- 150
                if math.abs(ball.dy) < 150 then
                    ball.dy = ball.dy * 1.02
                end

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- detect paddle collision with powerups
    for k, powerup in pairs(self.powerups) do
        if powerup:collides(self.paddle) then
            if powerup.type == 1 then
                -- shrink paddle
                self.paddle:shrink()
            elseif powerup.type == 2 then
                -- grow paddle
                self.paddle:grow()
            elseif powerup.type == 3 then
                -- gain life
                self.health = math.min(3, self.health + 1)
            elseif powerup.type == 4 then
                -- lose life
                self.health = self.health - 1
                gSounds['hurt']:play()
                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                end
                self.paddle:shrink()
            elseif powerup.type == 5 then
                -- increase balls' speed
                for k, ball in pairs(self.balls) do
                    if math.abs(ball.dy) < 125 then
                        ball.dy = ball.dy * 1.25
                        ball.dx = ball.dx * 1.25
                    end
                end
            elseif powerup.type == 6 then
                -- decrease balls' speed
                for k, ball in pairs(self.balls) do
                    ball.dy = ball.dy * 0.75
                    ball.dx = ball.dx * 0.75
                end
            elseif powerup.type == 7 then
            elseif powerup.type == 8 then

            elseif powerup.type == 9 then
                -- add two balls
                local newBall1 = Ball()
                local newBall2 = Ball()
                newBall1.skin = math.random(7)
                newBall2.skin = math.random(7)
                newBall1.dx = math.random(-200, 200)
                newBall1.dy = math.random(-50, -60)
                newBall2.dx = math.random(-200, 200)
                newBall2.dy = math.random(-50, -60)

                newBall1.x = self.paddle.x + (self.paddle.width / 2) - 4
                newBall1.y = self.paddle.y - 8
                newBall2.x = self.paddle.x + (self.paddle.width / 2) - 4
                newBall2.y = self.paddle.y - 8

                table.insert(self.balls, newBall1)
                table.insert(self.balls, newBall2)

            elseif powerup.type == 10 then
                -- open locked bricks
                self.unlocked = true
            end


            table.remove(self.powerups, k)
        end
        if powerup.y >= VIRTUAL_HEIGHT then
            table.remove(self.powerups, k)
        end
    end

    -- if last ball goes below bounds, revert to serve state and decrease health
    for k, ball in pairs(self.balls) do
        if ball.y >= VIRTUAL_HEIGHT then
            table.remove(self.balls, k)
            if #self.balls == 0 then
                self.health = self.health - 1
                gSounds['hurt']:play()
                if self.paddle.size > 1 then
                    self.paddle.size = self.paddle.size - 1
                    self.paddle.width = self.paddle.width - 32
                end

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        level = self.level,
                        recoverPoints = self.recoverPoints
                    })
                end
            end
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    -- update all powerups
    for k, powerup in pairs(self.powerups) do
        powerup:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end
    -- self.ball:render()

    -- render all powerups
    for k, powerup in pairs(self.powerups) do
        powerup:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
