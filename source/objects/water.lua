-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('Water').extends(gfx.sprite)

-- Initialize
function Water:init()
    -- -- Charge HUD sprite sheet
    -- local chargeImageTable = gfx.imagetable.new("images/HUD-charges-table-32-120")
    -- -- Create new animation loop with the charge hud sprite sheet
    -- self.chargeHUDAnimation = gfx.animation.loop.new(100, chargeImageTable, false)
    -- -- Make sure the start animation doesn't play yet
    -- self.chargeHUDAnimation.paused = true

    local waterImage = gfx.image.new(800, 240)
    -- Push the image context
    gfx.pushContext(waterImage)
        -- Draw the text center of the image
        gfx.fillRect(0, 0, 800, 240)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self:setImage(waterImage)
    -- Scale up the sprite size
    --  waterSprite:setScale(1)
    -- Move the sprite to the center of the screen
    self:moveTo(200, 360)


    -- -- Center the sprite to the screen
    -- self:moveTo(0, 60)

    -- Add this scene (sprite) to the display list
    self:add()
end

function Water:followPlayer(x, y)
    self:moveTo(x, 360)
end