-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend Player sprite subclass
class('Player').extends(gfx.sprite)

-- Player states
local PLAYER_STATES = {
    firing = 1,
    jumping = 2,
    gliding = 3,
    falling = 4
}
-- -- Start the player off falling
-- local playerState = PLAYER_STATES.falling

-- Initialize Player object with coordinates x and y
function Player:init(x, y)
    -- Set type
    self.type = "player"

    -- Load the falling animation sprite sheet
    local fallingImageTable = gfx.imagetable.new("images/player-falling-table-32-32")
    -- Create new animation loop with the falling image table
    self.fallingAnimation = gfx.animation.loop.new(100, fallingImageTable, true)

    -- Load the fire animation sprite sheet
    local fireImageTable = gfx.imagetable.new("images/player-fire-table-32-32")
    -- Create new animation loop with the fire image table
    self.fireAnimation = gfx.animation.loop.new(100, fireImageTable, false)
    -- Pause the animation so it doesn't play until needed
    self.fireAnimation.paused = true

    -- Load the jump animation sprite sheet
    local jumpImageTable = gfx.imagetable.new("images/player-jump-table-32-32")
    -- Create new animation loop with the fire image table
    self.jumpAnimation = gfx.animation.loop.new(100, jumpImageTable, false)
    -- Pause the animation so it doesn't play until needed
    self.jumpAnimation.paused = true

    -- Load the glide animation sprite sheet
    local glideImageTable = gfx.imagetable.new("images/player-glide-table-32-32")
    -- Create new animation loop with the glide image table
    self.glideAnimation = gfx.animation.loop.new(100, glideImageTable, false)

    -- Move the player to it's spawn location
    self:moveTo(x, y)
    -- Set the player's collision box
    self:setCollideRect(13, 12, 7, 12)
    -- Adjust the rotation of the player to match the current crank angle
    self:setRotation(self:getRotation() + pd.getCrankPosition())

    -- Camera properties
    self.cameraEase = 0.1

    -- Physics Properties
    -- Gravity is 9.8 (just like real life!)
    -- dividing by 30 here so it's per second (30 frames per second)
    self.gravity = 9.8/30
    self.airResistance = 0.15

    -- Player values
    self.xVelocity = 0.0
    self.yVelocity = 0.0
    self.jumpForce = -10.0
    self.fireForce = 15.0
    self.maxSpeed = 20.0
    self.charges = 5
    self.score = 0

    -- Current State
    self.fired = false
    self.jumped = false
    self.firstShot = false
    self.recharged = false
    self.wasGliding = false
    self.touchingWater = false

    -- Create a cloud sprite (This one under the player for layering)
    self.cloudOne = Cloud(-350, -1)
    -- Create a water sprite (This one under the player for layering)
    self.waterOne = Water(2, 50, -1)

    -- Make sure the player is started in the right state
    -- (Second time because it previously is only set the first time the player spawns)
    self.playerState = PLAYER_STATES.falling

    -- Add this sprite to the display list
    self:add()

    -- Create another water sprite (This one over the player for layering)
    self.waterTwo = Water(1, 0, 99)
    -- Create another clouds sprite (This one over the player for layering)
    self.cloudTwo = Cloud(-400, 99)

    -- Create the HUD overlays (After the player so the HUD is drawn on top)
    self.chargeHUD = ChargeHUD()
    self.rechargeHUD = RechargeHUD(self)
    self.difficultyHUD = DifficultyHUD()
end

-- Set the player's collision type to slide off of other colliders
function Player:collisionResponse()
    return gfx.sprite.kCollisionTypeOverlap
end

-- Override update function
function Player:update()
    self:updateRotation()
    self:handleState()

    -- Not sure why but math.clamp isn't working so this is here in the meantime to cap player speed
    if self.xVelocity > self.maxSpeed then self.xVelocity = self.maxSpeed
    elseif self.xVelocity < -self.maxSpeed then self.xVelocity = -self.maxSpeed
    end

    if self.yVelocity > self.maxSpeed then self.yVelocity = self.maxSpeed
    elseif self.yVelocity < -self.maxSpeed then self.yVelocity = -self.maxSpeed
    end

    self:handleMovementAndCollisions()
    self:handleCameraMovement()
    self:handleEnvironmentMovement()
    self:checkRecharge()
    self:calculateScore()

    -- If player falls below the waterline...
    if self.y > 320 then
        -- ...Touching water is true
        self.touchingWater = true
        -- Stop the recharge animation
        self.rechargeHUD.rechargeHUDAnimation.frame = 1
        self.rechargeHUD.rechargeHUDAnimation.paused = true
        -- Spawn a splash animation at the player's last location
        Splash(self.x, self.y - 60, 98)
        -- Remove the player
        self:remove()
    end
end

-- Helper function to rotate/animate the player
function Player:updateRotation()
    -- Adjust the rotation of the sprite to match the current crank angle
    self:setRotation(self:getRotation() + pd.getCrankChange())
end

-- Helper function to deal with player states
function Player:handleState()
    -- If player is falling...
    if self.playerState == PLAYER_STATES.falling then
        -- ... Set image to idle/falling animation
        self:setImage(self.fallingAnimation:image())
        -- Apply gravity
        self:applyGravity()
        -- Handle our inputs
        self:handleInput()
    -- If player wants to fire...
    elseif self.playerState == PLAYER_STATES.firing then
        -- ... Set image to firing animation
        self:setImage(self.fireAnimation:image())
        -- Apply gravity
        self:applyGravity()
        -- FIRE!!!
        self:handleFireInput()
    -- If player wants to jump...
    elseif self.playerState == PLAYER_STATES.jumping then
        -- ... Set image to jumping animation
        self:setImage(self.jumpAnimation:image())
        -- JUMP!!! (No gravity as this is more of a saving move)
        self:handleJumpInput()
    -- If player grabbed an Albatross...
    elseif self.playerState == PLAYER_STATES.gliding then
        -- ... Set image to gliding animation
        self:setImage(self.glideAnimation:image())
        -- Glide!!!
        self:handleGlideMovement()
        -- Handle any inputs
        self:handleInput()
    end
end

-- Movement Function
function Player:handleMovementAndCollisions()
    -- Move the player with collisions, grabbing a list of collisions and it's length
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    -- Make sure the player can't go too far above the clouds to avoid enemies/lightning
    if self.y < -400 then
        self.y = -400 -- math.clamp still not working :(
    end

    -- For each collision in the length of the list...
    for i=1, length do
        local collision = collisions[i]
        -- If colliding with an Albatross...
        if collision.other.enemyType == "Albatross" and self.playerState ~= PLAYER_STATES.gliding then
            -- ... 'Grab' the Albatross
            collision.other:remove()
            -- Play Grab sound
            pulp.audio.playSound("Grab")
            -- Make sure to clean up fire/jump animations here before swapping states
            if self.playerState == PLAYER_STATES.firing then
                -- Set the fire animation back to frame one
                self.fireAnimation.frame = 1
                -- Pause the fire animation until next time
                self.fireAnimation.paused = true
                -- Player hasn't fired
                self.fired = false
            elseif self.playerState == PLAYER_STATES.jumping then
                -- Set the jump animation back to frame one
                self.jumpAnimation.frame = 1
                -- Pause the jump animation until next time
                self.jumpAnimation.paused = true
                -- Player hasn't jumped
                self.jumped = false
            end
            -- Begin gliding
            self.playerState = PLAYER_STATES.gliding
            self.wasGliding = true
        end
    end
end

-- Camera (Draw offset) movement Function
function Player:handleCameraMovement()
    -- Grab current camera position (x,y)
    local camX, camY = gfx.getDrawOffset()
    -- Grab current player position (x,y)
    local playerX = -math.floor(self.x) + 50
    local playerY = -math.floor(self.y) + 120
    -- New camera position adds the difference between it and the player,
    -- applying a some easing to make it look like the player is
    -- in fact flying forward before recentering.
    local x = camX + (playerX - camX)*self.cameraEase
    local y = camY + (playerY - camY)*self.cameraEase
    if y < -60 then y = camY elseif y > 360 then y = camY end
    gfx.setDrawOffset(x, y)
end

-- Environment movement Function
function Player:handleEnvironmentMovement()
    self.cloudOne:followPlayer(self.x + 50) -- Little further ahead so both clouds don't look too identical
    self.cloudTwo:followPlayer(self.x)
end

-- Score Calculator
function Player:calculateScore()
    -- -50 so that falling at the start is recorded as 0
    self.score = math.floor(self.x) - 50
end

-- Check if the player has regained a fire charge
function Player:checkRecharge()
    -- If the RechargeHUD animation is finished...
    if self.rechargeHUD.rechargeHUDAnimation.frame == self.rechargeHUD.rechargeHUDAnimation.endFrame then
        -- ... Give the player another charge
        self:gainCharge()
        -- Reset the RechargeHUD animation
        self.rechargeHUD:resetRecharge()
    end
end

-- Handle Player Input
function Player:handleInput()
    -- If B is pressed, and we aren't firing / are off cooldown...
    if pd.buttonJustPressed(pd.kButtonB) and self.playerState ~= PLAYER_STATES.firing
        and self.fired == false and self.charges > 0 then
        -- ...Start firing
        self.playerState = PLAYER_STATES.firing
        -- Play the firing animation
        self.fireAnimation.paused = false
    -- If A is pressed...
    elseif pd.buttonJustPressed(pd.kButtonA) and self.playerState ~= PLAYER_STATES.jumping then
        -- ...Start jumping
        self.playerState = PLAYER_STATES.jumping
        -- Play the jumping animation
        self.jumpAnimation.paused = false
    end
end

-- Handle firing input
function Player:handleFireInput()
    -- If the player is on the right frame to fire, and hasn't fired yet...
    if self.fireAnimation.frame == 4 and self.fired == false then
        -- ...Grab the current angle of the crank and convert it to radians 
        -- (- 90 because 0 on the crank is straight up (90 on unit circle))
        local crankAngle = math.rad( pd.getCrankPosition() - 90)

        -- Calculate our horizontal and vertical forces using the crank angle
        local xFire = math.cos(crankAngle) * self.fireForce
        local yFire = math.sin(crankAngle) * self.fireForce

        -- Spawn a fireCharge in at player position moving with the opposite forces
        FireCharge(self.x, self.y, -xFire, -yFire, (self:getRotation() + pd.getCrankChange()), self, self.wasGliding)
        -- Play FireCharge sound
        pulp.audio.playSound("FireCharge")

        -- Add the x force to the current xVelocity
        self.xVelocity += xFire
        -- Set our yVelocity to the y force (Feels bad with gravity involved)
        self.yVelocity = yFire

        -- Player has fired
        self.fired = true
        -- If this is the players first shot...
        if self.firstShot == false then
            -- ... Start the RechargeHUD animation
            self.firstShot = true
            self.rechargeHUD:unpauseRecharge()
        end

        -- Shake the screen
        self:screenShake(250, 4)

        -- Decrease our charges, save it if we used a bird
        if self.wasGliding == false then
            self.chargeHUD:chargeFired()
        end
        -- Make sure the charge count doesn't fall into the negatives
        -- Again for some reason math.clamp is not working so this'll do
        if self.charges > 0 and self.wasGliding == false then
            self.charges -= 1
        end
        -- If the player was gliding they aren't anymore
        self.wasGliding = false
    end

    -- If the player has fired...
    if self.fireAnimation.frame >= 5 and self.fired == true then
        -- ... The player is now falling
        self.playerState = PLAYER_STATES.falling
        -- Set the fire animation back to frame one
        self.fireAnimation.frame = 1
        -- Reset the player image
        self:setImage(self.fallingAnimation:image())
        -- Pause the fire animation until next time
        self.fireAnimation.paused = true
        -- Player hasn't fired
        self.fired = false
    end
end

-- Handle jumping input
function Player:handleJumpInput()
    -- If the player is on the right frame to jump, and hasn't jumped yet...
    if self.jumpAnimation.frame == 3 and self.jumped == false then
        -- ... Set our yVelocity to the jump force
        self.yVelocity = self.jumpForce

        -- Play Jump sound
        pulp.audio.playSound("Jump")

        -- Player has jumped
        self.jumped = true

        -- Shake the screen
        self:screenShake(125, 2)

        -- Grab the current difficulty
        local currentDifficulty = self.difficultyHUD.difficultyHUDAnimation.endFrame + 1 -
            self.difficultyHUD.difficultyHUDAnimation.frame
        -- If the player is jumping while on max difficulty...
        if currentDifficulty == 1 then
            -- ... Instantly spawn a Lightning strike somewhere very close to the player >:)
            Lightning(self.x + math.random(0, 150), 97, self)
        end

        -- Increase difficulty
        self.difficultyHUD:playerJumped()
        -- If the player was gliding they aren't anymore
        if self.wasGliding then
            self.wasGliding = false
            -- Spawn a falling Albatross body
            FireCharge(self.x, self.y, self.xVelocity, 9.8, 0, self, true)
        end
    end

    -- If the player has jumped...
    if self.jumpAnimation.frame >= self.jumpAnimation.endFrame and self.jumped == true then
        -- ... The player is now falling
        self.playerState = PLAYER_STATES.falling
        -- Set the jump animation back to frame one
        self.jumpAnimation.frame = 1
        -- Reset the player image
        self:setImage(self.fallingAnimation:image())
        -- Pause the jump animation until next time
        self.jumpAnimation.paused = true
        -- Player hasn't jumped
        self.jumped = false
    end
end

-- Handle gliding movement
function Player:handleGlideMovement()
    -- Get the player's current rotation
    local rotation = self:getRotation() - 90
    local radRotation = math.rad(rotation)
    local glideForward = math.sqrt(self.xVelocity^2 + self.yVelocity^2)

    -- If rotation is between 0 and 90 degrees down...
    if rotation > 0 and rotation < 90 then
        -- ... Increase the glide force by gravity and convert it to the player's velocities
        glideForward += self.gravity
        self.xVelocity = math.cos(radRotation) * glideForward
        self.yVelocity = math.sin(radRotation) * glideForward
    -- If rotation is between 0 and 90 degrees up and is still moving...
    elseif rotation <= 0 and rotation > -90 and glideForward > 1 then
        -- ... Decrease the glide force by gravity and convert it to the player's velocities
        glideForward -= self.gravity
        self.xVelocity = math.cos(radRotation) * glideForward
        self.yVelocity = math.sin(radRotation) * glideForward
        -- print(self.xVelocity .. " , " .. self.yVelocity)
    -- Once the player stops moving or spins awkwardly...
    else
        -- ... Return to falling
        self.playerState = PLAYER_STATES.falling
        self.wasGliding = false
        -- Spawn a falling Albatross body
        FireCharge(self.x, self.y, self.xVelocity, 9.8, 0, self, true)
    end
end

-- Gravity Physics Helper Function
function Player:applyGravity()
    -- All of these if statements because math.clamp is still producing errors and I can't figure out why
    -- If the player is moving right...
    if self.xVelocity > 0 then 
        -- ...Slow down the xVelocity by airResistance
        self.xVelocity -= self.airResistance
        -- If the player is now moving left...
        if self.xVelocity < 0 then self.xVelocity = 0
        -- ...They should have just stopped
        end
    -- If the player is moving left...
    elseif self.xVelocity < 0 then 
        -- ...Slow down the xVelocity by airResistance
        self.xVelocity += self.airResistance
        -- If the player is now moving right...
        if self.xVelocity > 0 then self.xVelocity = 0
        -- ...They should have just stopped
        end
    end

    -- If the player is moving up...
    if self.yVelocity < 0 then
        -- ...Slow down the yVelocity by airResistance
        self.yVelocity += self.airResistance
    -- If the player is moving down...
    elseif self.yVelocity > 0 then
        -- ...Slow down the yVelocity by airResistance
        self.yVelocity -= self.airResistance
    end

    -- Apply gravity to yVelocity
    self.yVelocity += self.gravity
    -- If the player has hit water...
    if self.touchingWater then
        -- ...They should have stopped
        self.yVelocity = 0
    end
end

-- Gain Charge function
function Player:gainCharge()
    -- Give the player another charge
    self.charges += 1
    -- Make sure charges doesn't exceed five
    if self.charges > 5 then self.charges = 5 end
    -- Update the ChargeHUD to gain a charge
    self.chargeHUD:chargeGained()
end

-- Screen shake function
function Player:screenShake(shakeTime, shakeMagnitude)
    -- Creating a value timer that goes from shakeMagnitude to 0, over
    -- the course of 'shakeTime' milliseconds
    local shakeTimer = playdate.timer.new(shakeTime, shakeMagnitude, 0)
    -- Every frame when the timer is active, we shake the screen
    shakeTimer.updateCallback = function(timer)
        -- Using the timer value, so the shaking magnitude
        -- gradually decreases over time
        local magnitude = math.floor(timer.value)
        local shakeX = math.random(-magnitude, magnitude)
        local shakeY = math.random(-magnitude, magnitude)
        playdate.display.setOffset(shakeX, shakeY)
    end
    -- Resetting the display offset at the end of the screen shake
    shakeTimer.timerEndedCallback = function()
        playdate.display.setOffset(0, 0)
    end
end