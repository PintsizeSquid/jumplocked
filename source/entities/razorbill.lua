-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Razorbill sprite subclass
class('Razorbill').extends(gfx.sprite)

-- Razorbill states
local RAZORBILL_STATES = {
    flying = 1,
    diving = 2,
    grabbed = 3
}

-- Initialize Razorbill object with coordinates x and y
function Razorbill:init(x, player)
    -- Set type
    self.type = "enemy"
    self.enemyType = "razorbill"

    -- Load the flying animation sprite sheet
    local flyingImageTable = gfx.imagetable.new("images/razorbill-fly-table-16-16")
    -- Create new animation loop with the flying image table
    self.flyingAnimation = gfx.animation.loop.new(100, flyingImageTable, true)

    -- Load the dive image
    self.diveImage = gfx.image.new("images/razorbill-dive")

    -- Get a random height distance and make sure it isn't too high in the clouds
    local randHeight = player.y - math.random(-50, 150)
    if randHeight < -350 then randHeight += 50 end
    -- Move the Razorbill to it's spawn distance with the random height
    self:moveTo(x, randHeight)
    -- Set the Razorbill's collision box
    self:setCollideRect(0, 0, 16, 16)

    -- Razorbill values
    self.xVelocity = 10.0
    self.yVelocity = 0.0
    self.maxSpeed = 20.0
    self.impactForce = 5.0

    -- Reference to the player
    self.playerObject = player

    -- Make sure the Razorbill is started in the right state
    -- (Second time because it previously is only set the first time the Razorbill script is made)
    self.razorbillState = RAZORBILL_STATES.flying

    -- Add this sprite to the display list
    self:add()
end

-- Set the Razorbill's collision type to overlap other colliders
function Razorbill:collisionResponse()
    return gfx.sprite.kCollisionTypeOverlap
end

-- Override update function
function Razorbill:update()
    self:handleAnimation()

    -- Not sure why but math.clamp isn't working so this is here in the meantime to cap player speed
    if self.xVelocity > self.maxSpeed then self.xVelocity = self.maxSpeed
    elseif self.xVelocity < -self.maxSpeed then self.xVelocity = -self.maxSpeed
    end
    if self.yVelocity > self.maxSpeed then self.yVelocity = self.maxSpeed
    elseif self.yVelocity < -self.maxSpeed then self.yVelocity = -self.maxSpeed
    end

    self:handleMovementAndCollisions()

    -- Grab the current draw offset
    local camX, camY = gfx.getDrawOffset()
    -- If the Razorbill is outside the bounds of the screen...
    if self.x < -camX - 400 or self.x > -camX + 800 or self.y > 360 or self.y < -400 then
        -- ... Remove the sprite from the display list
        self:remove()
    end
end

-- Helper function to deal with Razorbill states
function Razorbill:handleAnimation()
    -- If Razorbill is flying...
    if self.razorbillState == RAZORBILL_STATES.flying then
        -- ... Set image to flying animation
        self:setImage(self.flyingAnimation:image())
        -- Fly normally
        self:handleFlying()
    -- If Razorbill wants to dive...
    elseif self.razorbillState == RAZORBILL_STATES.diving then
        -- ... Set image to diving animation
        self:setImage(self.diveImage)
        -- DIVE!!!
        self:handleDiving()
    end
end

-- Movement Function
function Razorbill:handleMovementAndCollisions()
    -- Move the Razorbill with collisions, grabbing a list of collisions and it's length
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

     -- For each collision in the length of the list...
     for i=1, length do
        local collision = collisions[i]
        -- If colliding with the player...
        if collision.other.type == "player" then
            -- ... Knock the player down a bit
            collision.other.yVelocity = self.impactForce
            -- Play Hit sound
            pulp.audio.playSound("Hit")
        end
     end
end

-- Handle Flight path
function Razorbill:handleFlying()
    -- Grab current camera position (x,y)
    local camX, camY = gfx.getDrawOffset()
    -- If the Razorbill is above and behind the player within screen space...
    if self.x < self.playerObject.x - 50 and self.y < self.playerObject.y - 50 and self.y < 325 and self.y > -camY then
        -- ... Start diving
        self.razorbillState = RAZORBILL_STATES.diving
        -- ... Set image to diving animation
        self:setImage(self.diveImage)

        -- Calculate the angle to the player
        local angleToPlayer = math.atan((self.y - self.playerObject.y), (self.x - self.playerObject.x))
        -- Adjust the rotation of the sprite to aim at the player
        self:setRotation(self:getRotation() + math.deg(angleToPlayer))

        -- Set the Razorbill's velocities to dive at the player
        self.xVelocity = self.maxSpeed
        self.yVelocity = math.abs(self.xVelocity / math.tan(math.deg(angleToPlayer)))
    end
end

-- Handle Player Input
function Razorbill:handleDiving()
    -- If the Razorbill dives beneath the player...
    if self.y > self.playerObject.y + 50 or self.y > 325 then
        -- ... Return to flying
        self.razorbillState = RAZORBILL_STATES.flying

        -- Adjust the rotation back to level
        self:setRotation(0)

        -- Set the flying animation back to frame one
        self.flyingAnimation.frame = 1

        -- Set the Razorbill's velocities back
        self.xVelocity = 12.5
        self.yVelocity = 0.0
    end
end