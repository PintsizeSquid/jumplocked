-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('ChargeHUD').extends(gfx.sprite)

-- Initialize
function ChargeHUD:init()
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Charge HUD sprite sheet
    local chargeImageTable = gfx.imagetable.new("images/HUD-charges-table-16-120")
    -- Create new animation loop with the charge hud sprite sheet
    self.chargeHUDAnimation = gfx.animation.loop.new(100, chargeImageTable, false)
    -- Make sure the start animation doesn't play yet
    self.chargeHUDAnimation.paused = true
    -- Center the sprite to the screen
    self:moveTo(8, 60)

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function ChargeHUD:update()
    -- Set this sprite's image to the current title animation frame
    self:setImage(self.chargeHUDAnimation:image())
end

function ChargeHUD:chargeFired()
    -- Update our HUD animation to show the player has fired
    if self.chargeHUDAnimation.frame < self.chargeHUDAnimation.endFrame then
        self.chargeHUDAnimation.frame += 1
    end
end

function ChargeHUD:chargeGained()
    -- Update our HUD animation to show the player has gained another charge
    if self.chargeHUDAnimation.frame > 1 then
        self.chargeHUDAnimation.frame -= 1
    end
end