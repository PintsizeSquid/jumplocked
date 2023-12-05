-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Splash sprite subclass 
class('Splash').extends(gfx.sprite)

-- Initialize Splash object
function Splash:init(x, y, zHeight)
    -- Load the splash animation sprite sheet
    local splashImageTable = gfx.imagetable.new("images/splash-table-32-32")
    -- Create new animation loop with the splash image table
    self.splashAnimation = gfx.animation.loop.new(50, splashImageTable, false)

    -- Set the sprite's image
    self:setImage(self.splashAnimation:image())
    -- Move the sprite to the given x, y
    self:moveTo(x, y)

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above/below other objects
    self:setZIndex(zHeight)

    -- Play Splash sound
    pulp.audio.playSound("Splash")
end

function Splash:update()
    -- Set the sprite's image
    self:setImage(self.splashAnimation:image())

    -- Remove the sprite once the animation is complete
    if self.splashAnimation.frame >= self.splashAnimation.endFrame then
        self:remove()
    end
end
