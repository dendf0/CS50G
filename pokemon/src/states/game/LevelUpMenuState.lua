--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]
LevelUpMenuState = Class { __includes = BaseState }

function LevelUpMenuState:init(def)
    self.levelUpMenu = Menu {
        isCursorOn = false,
        x = 0,
        y = VIRTUAL_HEIGHT - 64,
        width = 96,
        height = 64,
        onSkip = function()
            gStateStack:pop()
            Timer.after(0.5, function()
                gStateStack:push(FadeInState({
                        r = 1, g = 1, b = 1
                    }, 1,
                    function()
                        gSounds['victory-music']:stop()
                        gSounds['field-music']:play()
                        gStateStack:pop()
                        gStateStack:push(FadeOutState({
                            r = 1, g = 1, b = 1
                        }, 1, function()
                        end))
                    end))
            end)
        end,
        items = {
            {
                text = 'HP'
            },
            {
                text = 'Attack'
            },
            {
                text = 'Defense'
            },
            {
                text = 'Speed'
            }
        }
    }

    self.levelUpStats = Menu {
        isCursorOn = false,
        x = 96,
        y = VIRTUAL_HEIGHT - 64,
        width = VIRTUAL_WIDTH - 96,
        height = 64,
        items = {
            {
                text = def.curHP .. ' + ' .. def.incHP .. ' = ' .. (def.curHP + def.incHP)
            },
            {
                text = def.curAttack .. ' + ' .. def.incAttack .. ' = ' .. (def.curAttack + def.incAttack)
            },
            {
                text = def.curDefense .. ' + ' .. def.incDefense .. ' = ' .. (def.curDefense+def.incDefense)
            },
            {
                text = def.curSpeed .. ' + ' .. def.incSpeed .. ' = ' .. (def.curSpeed+def.incSpeed)
            }
        }
    }
end

function LevelUpMenuState:update(dt)
    self.levelUpMenu:update(dt)
end

function LevelUpMenuState:render()
    self.levelUpMenu:render()
    self.levelUpStats:render()
end
