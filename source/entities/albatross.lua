-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Albatross sprite subclass
class('Albatross').extends(gfx.sprite)

-- Initialize Albatross object with coordinates x and y
function Albatross:init(x, player)
    -- Set type
    self.type = "enemy"
    self.enemyType = "Albatross"

    -- Load the flying animation sprite sheet
    local flyingImageTable = gfx.imagetable.new("images/Albatross-fly-table-32-32")
    -- Create new animation loop with the flying image table
    self.flyingAnimation = gfx.animation.loop.new(100, flyingImageTable, true)
    -- Pause the animation so it doesn't play until needed
    self.flyingAnimation.paused = true

    -- Get a random height distance near the player
    local randHeight = player.y - math.random(-150, 50)
    -- Move the Albatross to it's spawn distance with the random height
    self:moveTo(x, randHeight)
    -- Set the Razorbill's collision box
    self:setCollideRect(0, 0, 32, 32)

    -- Razorbill values
    self.startX = x
    self.startY = player.y - randHeight
    self.xVelocity = 10.0
    self.yVelocity = 0.0
    self.waveRange = 100
    self.waveFrequency = 200

    -- Add this sprite to the display list
    self:add()
end

-- Set the Albatross's collision type to overlap other colliders
function Albatross:collisionResponse()
    return gfx.sprite.kCollisionTypeOverlap
end

-- Override update function
function Albatross:update()
    -- Set image to flying animation
    self:setImage(self.flyingAnimation:image())
    self:handleAnimation()
    self:handleMovementAndCollisions()

    -- Grab the current draw offset
    local camX, camY = gfx.getDrawOffset()
    -- If the Albatross is outside the bounds of the screen...
    if self.x < -camX - 400 or self.x > -camX + 800 or self.y > 360 or self.y < -400 then
        -- ... Remove the sprite from the display list
        self:remove()
    end
end

-- Handle Flight path
function Albatross:handleAnimation()
    -- Get the Albatross's distance travelled (theta)
    local distanceTravelled = (self.x - self.startX) / self.waveFrequency
    local height = -math.cos(distanceTravelled)

    -- Handle the current animation frame
    -- Checking where the Albatross lies on a cosine graph -1 < height < 1
    if height >= .8 then
        self.flyingAnimation.frame = 1
    elseif height <= -.8 then
        self.flyingAnimation.frame = 4
    elseif height == 0 and self.flyingAnimation.frame == 2 then
        self.flyingAnimation.frame = 3
    elseif height >= -.8 and self.flyingAnimation.frame == 4 then
        self.flyingAnimation.frame = 5
    elseif height >= .5 and height <= .8 and self.flyingAnimation.frame == 1 then
        self.flyingAnimation.frame = 2
    elseif height >= .5 and self.flyingAnimation.frame == 5 then
        self.flyingAnimation.frame = 6
    end

end

-- Movement Function
function Albatross:handleMovementAndCollisions()
    -- Get the Albatross's distance travelled (theta)
    local distanceTravelled = (self.x - self.startX) / self.waveFrequency
    local height = math.cos(distanceTravelled) - 1
    -- Calculate the yVelocity of the Albatross
    self.yVelocity = (height * self.waveRange)

    -- Move the Albatross with collisions
    self:moveWithCollisions(self.x + self.xVelocity, self.startY + self.yVelocity)
end