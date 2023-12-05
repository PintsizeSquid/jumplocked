-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Rain sprite subclass
class('Rain').extends(gfx.sprite)

-- Initialize Rain object
function Rain:init()
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Load the Rain sprite sheet
    local rainImageTable = gfx.imagetable.new("images/rain-table-384-240")
    -- Create new animation loop with the Rain image table
    self.rainAnimation = gfx.animation.loop.new(50, rainImageTable, true)

    -- Move the sprite to the top left of the screen, just right of the HUD
    self:moveTo(216, 120)

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(97)
end

-- Override update function
function Rain:update()
    -- Set this sprite's image to the current animation frame
    self:setImage(self.rainAnimation:image())
end