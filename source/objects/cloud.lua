-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('Cloud').extends(gfx.sprite)

-- Initialize
function Cloud:init()
    local cloudImage = gfx.image.new(800, 240)
    -- Push the image context
    gfx.pushContext(cloudImage)
        -- Draw the text center of the image
        gfx.fillRect(0, 0, 800, 240)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self:setImage(cloudImage)
    -- Scale up the sprite size
    --  waterSprite:setScale(1)
    -- Move the sprite to the center of the screen
    self:moveTo(200, 360)


    -- -- Center the sprite to the screen
    -- self:moveTo(0, 60)

    -- Add this scene (sprite) to the display list
    self:add()
end

function Cloud:followPlayer(x)
    self:moveTo(x, -180)
end