--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A Menu is simply a Selection layered onto a Panel, at least for use in this
    game. More complicated Menus may be collections of Panels and Selections that
    form a greater whole.
]]
Menu = Class {}

function Menu:init(def)
    self.isCursorOn = def.isCursorOn
    self.panel = Panel(def.x, def.y, def.width, def.height)

    self.selection = Selection {
        isCursorOn = def.isCursorOn == nil and true or def.isCursorOn,
        items = def.items,
        x = def.x,
        y = def.y,
        width = def.width,
        height = def.height
    }

    self.onSkip=def.onSkip
end

function Menu:update(dt)
    if self.isCursorOn == false and (love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter')) then
        self.onSkip()
        gSounds['blip']:play()
    end

    self.selection:update(dt)
end

function Menu:render()
    self.panel:render()
    self.selection:render()
end
