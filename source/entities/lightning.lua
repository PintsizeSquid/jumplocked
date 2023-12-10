-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Lightning sprite subclass 
class('Lightning').extends(gfx.sprite)

-- Player states
local PLAYER_STATES = {
    firing = 1,
    jumping = 2,
    gliding = 3,
    falling = 4
}

-- Initialize Lightning object
function Lightning:init(x, zHeight, player)
    -- Load the Lightning animation sprite sheet
    local lightningImageTable = gfx.imagetable.new("images/lightning-table-64-800")
    -- Create new animation loop with the Lightning image table
    self.lightningAnimation = gfx.animation.loop.new(100, lightningImageTable, false)

    -- Set the sprite's image
    self:setImage(self.lightningAnimation:image())
    -- Move the sprite to the given x, y
    self:moveTo(x, 0)
    -- Set the Lightning's collision box
    self:setCollideRect(16, 0, 32, 800)

    -- Lightning values
    self.impactForce = 20.0

    -- Reference to the player
    self.playerObject = player

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above/below objects in the scene
    self:setZIndex(zHeight)

    -- Play Lightning sound
    pulp.audio.playSound("Lightning")
end

-- Set the Lightning's collision type to overlap other colliders
function Lightning:collisionResponse()
    return gfx.sprite.kCollisionTypeOverlap
end

-- Override update function
function Lightning:update()
    -- Set the sprite's image
    self:setImage(self.lightningAnimation:image())

    self:handleCollisions()

    -- Remove the sprite once the animation is complete
    if self.lightningAnimation.frame >= self.lightningAnimation.endFrame then
        self:remove()
    end
end

-- Collision Function
function Lightning:handleCollisions()
    -- Grab a list of collisions and it's length
    local _, _, collisions, length = self:checkCollisions(self.x, self.y)

    -- Only collide if within the correct frames
    if self.lightningAnimation.frame >= 4 and self.lightningAnimation.frame <= 8 then
        -- For each collision in the length of the list...
        for i=1, length do
            local collision = collisions[i]
            -- If colliding with the player...
            if collision.other.type == "player" then
                -- ... Strike the player down
                collision.other.yVelocity = self.impactForce
                -- Play Hit sound
                pulp.audio.playSound("Hit")
                -- If the player is currently gliding...
                if collision.other.wasGliding then
                    -- ... The player is falling now
                    collision.other.wasGliding = false
                    collision.other.playerState = PLAYER_STATES.falling
                    -- Spawn a falling Albatross body
                    FireCharge(collision.other.x, collision.other.y,
                        collision.other.xVelocity, 9.8 + self.impactForce, 0, collision.other, true)
                end
            end
        end
    end
end