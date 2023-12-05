-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend FireCharge sprite subclass 
class('FireCharge').extends(gfx.sprite)

-- Initialize FireCharge object
function FireCharge:init(x, y, xVel, yVel, rotation, player, bird)
    -- Default bird parameter to false
    bird = bird or false

    -- Set type
    self.type = "object"

    -- Load the FireCharge animation sprite sheet
    local fireChargeImageTable = gfx.imagetable.new("images/fireCharge-table-32-32")
    -- Create new animation loop with the FireCharge image table
    self.fireChargeAnimation = gfx.animation.loop.new(100, fireChargeImageTable, false)

    -- Load the dead Albatross image
    self.albatrossImage = gfx.image.new("images/albatross-dead")

    -- Load and set our game's font
    local font = gfx.font.new("fonts/jumpFont")
    gfx.setFont(font)

    -- Make a +1 fire charge text
    local text = "HIT!"

    -- Create an image with the size of the text
    self.plusOneImage = gfx.image.new(gfx.getTextSize(text))
    -- Push the image context
    gfx.pushContext(self.plusOneImage)
        -- Draw the text center of the image
        gfx.drawTextAligned(text, self.plusOneImage.width / 2, 0, kTextAlignment.center)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Move the sprite to the center of the screen
    self:moveTo(x, y)

    -- Set this sprites collision box
    self:setCollideRect(13, 20, 8, 10)

    -- Adjust the rotation of the sprite to match the player's rotation
    self:setRotation(rotation)

    -- Physics values
    self.xVelocity = xVel
    self.yVelocity = yVel

    -- Current State
    self.bird = bird
    self.hit = false

    -- Reference to the player
    self.playerObject = player

    -- Add this sprite to the display list
    self:add()
end

-- Set the FireCharge's collision type to overlap other colliders
function FireCharge:collisionResponse()
    return gfx.sprite.kCollisionTypeOverlap
end

-- Override update function
function FireCharge:update()
    -- If the firing off an Albatross...
    if self.bird == true then
        -- ... Display dead Albatross image
        self:setImage(self.albatrossImage)
    -- If the charge hasn't hit anything...
    elseif self.hit == false then
        -- ... Continue through the animation
        self:setImage(self.fireChargeAnimation:image())
    else
        -- Otherwise display +1 FireCharge text
        self:setImage(self.plusOneImage)
    end

    self:handleMovementAndCollisions()

    -- Grab the current draw offset
    local camX, camY = gfx.getDrawOffset()
    -- If the FireCharge is outside the bounds of the screen...
    if self.x < -camX or self.x > -camX + 400 or self.y > 320 or self.y < -400 then
        -- Check if the FireCharge fell below the waterline...
        if self.y > 320 then
            -- ... Spawn a splash animation at the FireCharge's last location
            Splash(self.x, self.y - 60, 98)
        end
        -- Remove the sprite from the display list
        self:remove()
    end
end

-- Movement Function
function FireCharge:handleMovementAndCollisions()
    -- Move the FireCharge with collisions according to it's velocity values, grabbing a list of collisions
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    -- For each collision in the length of the list...
    for i=1, length do
        local collision = collisions[i]
        -- If colliding...
        if collision.other.type == "enemy" then
            -- ... Hit!
            self.hit = true
            -- Play Hit sound
            pulp.audio.playSound("Hit")
            -- Destroy the other sprite
            collision.other:remove()
            -- Give the player a charge back
            self.playerObject:gainCharge()
            -- Adjust the rotation back to level
            self:setRotation(0)
            -- Display +1 FireCharge text
            self:setImage(self.plusOneImage)
            -- Scale up the sprite size
            self:setScale(1.5)
            -- Stop moving
            self.xVelocity = 0
            self.yVelocity = 0

            -- Shake the screen just a little
            self.playerObject:screenShake(150, 2)
        end
    end
end
