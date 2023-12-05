-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Cloud sprite subclass
class('Cloud').extends(gfx.sprite)

-- Initialize Cloud object
function Cloud:init(y, zHeight)
    -- Load the cloud image
    local cloudImage = gfx.image.new("images/clouds")
    -- Push the cloud image context
    gfx.pushContext(cloudImage)
        -- Draw the text center of the image
        cloudImage:draw(0, 0)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self:setImage(cloudImage)
    -- Move the sprite to the x center of the screen with it's given y position
    self:moveTo(200, y)

    -- Record the y position for later
    self.yPos = y

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(zHeight)
end

-- Move function to follow player
function Cloud:followPlayer(x)
    -- Move to the given x position and remain locked in the y position
    self:moveTo(x, self.yPos)
end