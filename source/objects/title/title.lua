-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Title sprite subclass 
class('Title').extends(gfx.sprite)

-- Initialize Title object
function Title:init()
    -- Load the title image
    local titleImage = gfx.image.new("images/title")
    -- Set this sprite's image
    self:setImage(titleImage)

    -- Add this sprite to the display list
    self:add()

    -- Start position
    self.startX = 314
    self.startY = -240

    -- Move the sprite to the start position
    self:moveTo(self.startX, self.startY)

    -- Make the start and end points for the animator
    self.upPoint = pd.geometry.point.new(self.startX, self.startY)
    self.rightPoint = pd.geometry.point.new(500, 56)
    self.endPoint = pd.geometry.point.new(314, 56)

    -- Current State
    self.animating = false
    self.down = false
    self.up = true

    -- Make the animator for bringing in the sprite
    self:bringDown(false)

    -- Set Z-index high to display above other objects
    self:setZIndex(100)
end

function Title:update()
    -- If animating...
    if self.animating then
        -- ... Move to the current animator position
        self:moveTo(self.animator:currentValue())
    end

    -- If the animation has ended...
    if self.animator:ended() then
        -- ... Done animating
        self.animating = false
        if self.animator:currentValue() == self.upPoint or self.animator:currentValue() == self.rightPoint then
            self.up = true
            self.down = false
        elseif self.animator:currentValue() == self.endPoint then
            self.up = false
            self.down = true
        end

    end
end

function Title:bringDown(score)
    if score then
        self.animator = gfx.animator.new(1000, self.rightPoint, self.endPoint, pd.easingFunctions.inOutBack)
    else
        self.animator = gfx.animator.new(1000, self.upPoint, self.endPoint, pd.easingFunctions.inOutBack)
    end
    self.animating = true
end

function Title:bringUp(score)
    if score then
        self.animator = gfx.animator.new(1000, self.endPoint, self.rightPoint, pd.easingFunctions.inOutBack)
    else
        self.animator = gfx.animator.new(1000, self.endPoint, self.upPoint, pd.easingFunctions.inOutBack)
    end
    self.animating = true
end
