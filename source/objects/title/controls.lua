-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Controls sprite subclass 
class('Controls').extends(gfx.sprite)

-- Initialize Controls object
function Controls:init()
    -- Load the Controls image
    local controlsImage = gfx.image.new("images/controls")
    -- Set this sprite's image
    self:setImage(controlsImage)

    -- Add this sprite to the display list
    self:add()

    -- Start position
    self.startX = 314
    self.startY = -240

    -- Move the sprite to the start position
    self:moveTo(self.startX, self.startY)

    -- Make the start and end points for the animator
    self.startPoint = pd.geometry.point.new(self.startX, self.startY)
    self.endPoint = pd.geometry.point.new(314, 56)

    -- Current State
    self.animating = false
    self.down = false
    self.up = true

    -- For now no animator
    self.animator = nil

    -- Set Z-index high to display above other objects
    self:setZIndex(100)
end

function Controls:update()
    -- If animating...
    if self.animating then
        -- ... Move to the current animator position
        self:moveTo(self.animator:currentValue())
    end

    -- If the animation has ended...
    if self.animator ~= nil and self.animator:ended() then
        -- ... Done animating
        self.animating = false
        if self.animator:currentValue() == self.startPoint then
            self.up = true
            self.down = false
        elseif self.animator:currentValue() == self.endPoint then
            self.up = false
            self.down = true
        end

    end
end

function Controls:bringDown()
    self.animator = gfx.animator.new(1000, self.startPoint, self.endPoint, pd.easingFunctions.inOutBack)
    self.animating = true
end

function Controls:bringUp()
    self.animator = gfx.animator.new(1000, self.endPoint, self.startPoint, pd.easingFunctions.inOutBack)
    self.animating = true
end