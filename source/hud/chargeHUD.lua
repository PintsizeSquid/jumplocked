-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend ChargeHUD sprite subclass 
class('ChargeHUD').extends(gfx.sprite)

-- Initialize ChargeHUD
function ChargeHUD:init()
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Load the ChargeHUD sprite sheet
    local chargeImageTable = gfx.imagetable.new("images/HUD-charges-table-32-120")
    -- Create new animation loop with the ChargeHUD sprite sheet
    self.chargeHUDAnimation = gfx.animation.loop.new(100, chargeImageTable, false)
    -- Make sure the animation doesn't play yet
    self.chargeHUDAnimation.paused = true
    -- Move to 0, 60 (Top left of the screen)
    self:moveTo(0, 60)

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(100)
end

-- Override update function
function ChargeHUD:update()
    -- Set this sprite's image to the current animation frame
    self:setImage(self.chargeHUDAnimation:image())
end

-- Lower Charge Count function
function ChargeHUD:chargeFired()
    -- Update the ChargeHUD animation to show the player has fired
    if self.chargeHUDAnimation.frame < self.chargeHUDAnimation.endFrame then
        self.chargeHUDAnimation.frame += 1
    end
end

-- Increase Charge Count function
function ChargeHUD:chargeGained()
    -- Update the ChargeHUD animation to show the player has gained a charge
    if self.chargeHUDAnimation.frame > 1 then
        self.chargeHUDAnimation.frame -= 1
    end
end