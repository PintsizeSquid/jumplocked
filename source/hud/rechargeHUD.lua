-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('RechargeHUD').extends(gfx.sprite)

-- Initialize
function RechargeHUD:init()
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Recharge HUD sprite sheet
    local rechargeImageTable = gfx.imagetable.new("images/HUD-recharge-table-5-120")
    -- Create new animation loop with the recharge hud sprite sheet
    self.rechargeHUDAnimation = gfx.animation.loop.new(750, rechargeImageTable, true)
    -- Make sure the start animation doesn't play yet
    self.rechargeHUDAnimation.paused = true
    -- Center the sprite to the screen
    self:moveTo(19, 60)

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function RechargeHUD:update()
    -- Set this sprite's image to the current title animation frame
    self:setImage(self.rechargeHUDAnimation:image())
end

function RechargeHUD:unpauseRecharge()
    self.rechargeHUDAnimation.paused = false
end

function RechargeHUD:resetRecharge()
    self.rechargeHUDAnimation.frame = 1
end