-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Scores sprite subclass 
class('Scores').extends(gfx.sprite)

-- Initialize Scores object
function Scores:init()
    -- Load the title image
    local scoresImage = gfx.image.new("images/scores")
    -- Set this sprite's image
    self:setImage(scoresImage)

    -- Load and set our game's font
    local font = gfx.font.new("fonts/jumpFont")
    gfx.setFont(font)

    -- Read in the user's highscore data
    highscore = pd.datastore.read("highscore")

    -- Make text out of the user's scores
    local scoresText = ""
    if highscore == nil then
        scoresText = scoresText .. "1 ~ 0 M\n2 ~ 0 M\n3 ~ 0 M\n"
    else
        for i=1,3 do
            scoresText = scoresText .. tostring(i) .. ": " .. tostring(highscore[i]) .. " M\n"
        end
    end

    -- Push the image context
    gfx.pushContext(scoresImage)
        -- Draw the text center of the image
        gfx.drawTextAligned(scoresText, scoresImage.width / 2, 20, kTextAlignment.center)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Add this sprite to the display list
    self:add()

    -- Start position
    self.startX = 500
    self.startY = 56

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

function Scores:update()
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

function Scores:bringDown()
    self.animator = gfx.animator.new(1000, self.startPoint, self.endPoint, pd.easingFunctions.inOutBack)
    self.animating = true
end

function Scores:bringUp()
    self.animator = gfx.animator.new(1000, self.endPoint, self.startPoint, pd.easingFunctions.inOutBack)
    self.animating = true
end