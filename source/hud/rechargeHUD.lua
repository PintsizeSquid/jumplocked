-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend RechargeHUD sprite subclass 
class('RechargeHUD').extends(gfx.sprite)

-- Initialize RechargeHUD
function RechargeHUD:init(player)
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Load the RechargeHUD animation sprite sheet
    local rechargeImageTable = gfx.imagetable.new("images/HUD-recharge-table-5-120")
    -- Create new animation loop with the RechargeHUD sprite sheet
    self.rechargeHUDAnimation = gfx.animation.loop.new(500, rechargeImageTable, true)
    -- Make sure the animation doesn't play yet
    self.rechargeHUDAnimation.paused = true
    -- Move to 19, 60 (Just to the right of the ChargeHUD)
    self:moveTo(19, 60)

    -- Reference to player
    self.playerObject = player

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(100)
end

-- Override update function
function RechargeHUD:update()
    -- Set this sprite's image to the current animation frame
    self:setImage(self.rechargeHUDAnimation:image())
    if self.playerObject.charges == 5 then
        self.rechargeHUDAnimation.paused = true
    else
        self.rechargeHUDAnimation.paused = false
    end
end

-- Unpause animation function
function RechargeHUD:unpauseRecharge()
    self.rechargeHUDAnimation.paused = false
end

-- Restart animation function
function RechargeHUD:resetRecharge()
    self.rechargeHUDAnimation.frame = 1
end