-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Buoy sprite subclass 
class('Buoy').extends(gfx.sprite)

-- Initialize Buoy object
function Buoy:init(x, zHeight)
    -- Load the Buoy image
    local buoyImage = gfx.image.new("images/buoy")
    -- Push the cloud image context
    gfx.pushContext(buoyImage)
        -- Draw the text center of the image
        buoyImage:draw(0, 0)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self:setImage(buoyImage)
    -- Move the sprite to the given x
    self:moveTo(x, 250)

    -- Buoy Values
    self.timeAlive = 0
    self.waveFrequency = -.5
    self.waveRange = 10

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(zHeight)
end

function Buoy:update()
    -- Get a rotation for the Buoy and increment it's time alive
    local rotation = math.cos(self.timeAlive / self.waveRange) * self.waveFrequency
    self.timeAlive += 1
    -- Set the Buoy's rotation
    self:setRotation(self:getRotation() + rotation)

    -- Grab the current draw offset
    local camX, camY = gfx.getDrawOffset()
    -- If the Buoy is outside the left bounds of the screen...
    if self.x < -camX then
        -- ... Remove the sprite from the display list
        self:remove()
    end
end
