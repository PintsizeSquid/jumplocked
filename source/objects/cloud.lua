-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('Cloud').extends(gfx.sprite)

-- Initialize
function Cloud:init(y)
    local cloudImage = gfx.image.new("images/clouds")
    -- Push the image context
    gfx.pushContext(cloudImage)
        -- Draw the text center of the image
        cloudImage:draw(0, 0)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self:setImage(cloudImage)
    -- Move the sprite to the center of the screen
    self:moveTo(200, y)

    self.yPos = y

    -- Add this scene (sprite) to the display list
    self:add()
end

function Cloud:followPlayer(x)
    self:moveTo(x, self.yPos)
end