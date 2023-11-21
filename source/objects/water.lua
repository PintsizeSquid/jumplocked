-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('Water').extends(gfx.sprite)

-- Initialize
function Water:init(x, offset)
    local waterImage
    -- Use the inserted value to determine which water image to use
    if x == 1 then
        waterImage = gfx.image.new("images/waterOne")
    else
        waterImage = gfx.image.new("images/waterTwo")
    end

    -- Push the image context
    gfx.pushContext(waterImage)
        -- Draw the text center of the image
        waterImage:draw(0, 0)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self:setImage(waterImage)
    -- Move the sprite to the center of the screen
    self:moveTo(200, 360)

    -- Save our x offset
    self.xOffset = offset

    -- Add this scene (sprite) to the display list
    self:add()
end

function Water:update()
    -- Grab our draw offset
    local camX, camY = gfx.getDrawOffset()

    -- Essentially, snap the image to multiples of 400,
    -- keeping the water moving beneath the player
    local moveX = -math.ceil(camX / 400) * 400 + 400
    self:moveTo(moveX - self.xOffset, 360)

end
