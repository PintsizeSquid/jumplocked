-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Water sprite subclass 
class('Water').extends(gfx.sprite)

-- Initialize Water object
function Water:init(imageNumber, offset, zHeight)
    -- Load in the water image depending on the given image number
    local waterImage                                    -- ANIMATE THE WAVES SO THEY DONT LOOK LIKE MOUNTAINS
    if imageNumber == 1 then
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
    -- Move the sprite to the water location
    self:moveTo(200, 360)

    -- Save the x offset
    self.xOffset = offset

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(zHeight)
end

function Water:update()
    -- Grab the draw offset
    local camX, camY = gfx.getDrawOffset()

    -- Essentially, snap the image to multiples of 400,
    -- keeping the water moving beneath the player 
    -- as the camera (draw offset) moves
    local moveX = -math.ceil(camX / 400) * 400 + 400
    self:moveTo(moveX - self.xOffset, 360)
end
