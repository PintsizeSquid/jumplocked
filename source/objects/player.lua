-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create Player sprite subclass
class('Player').extends(gfx.sprite)

-- Player states
local PLAYER_STATES = {
    firing = 1,
    jumping = 2,
    flying = 3,
    falling = 4
}
local playerState = PLAYER_STATES.falling

-- Initialize with coordinates
function Player:init(x, y)
    -- Load an image of the player                              (FOR NOW IN PLACE OF AN IDLE/FALLING ANIMATION)
    self.playerImage = gfx.image.new("images/player")

    -- Load the fire animation sprite sheet
    local fireImageTable = gfx.imagetable.new("images/fire-table-16-16")
    -- Create new animation loop with the fire image table
    self.fireAnimation = gfx.animation.loop.new(100, fireImageTable, false)
    -- Pause the animation so it doesn't play until needed
    self.fireAnimation.paused = true

    -- Set the sprite
    self:setImage(self.playerImage)
    -- Move the sprite to it's spawn location
    self:moveTo(x, y)
    -- Set this sprites collision box                           (THESE VALUES MAY NEED CHANGING FOR COLLISION BOX)
    self:setCollideRect(6, 4, 6, 13)
    -- Grab the current angle of the crank and convert it to radians
    local crankAngle = math.rad( pd.getCrankPosition() )
    -- Adjust the rotation of the sprite to match the current crank angle
    self:setRotation(self:getRotation() + pd.getCrankPosition())

    -- Camera properties
    self.cameraEase = 0.1

    -- Physics Properties
    -- Gravity is 9.8 (just like real life!)
    -- dividing by 30 here so it's per second (30 frames per second)
    self.gravity = 9.8/30
    self.airResistance = 0.2

    -- Player values
    self.xVelocity = 0.0
    self.yVelocity = 0.0
    self.jumpForce = -10.0
    self.fireForce = 15.0
    self.maxSpeed = 20.0
    self.charges = 5

    -- Current Action
    self.fired = false

    -- Add this sprite to the display list
    self:add()

    -- Create the HUD overlays (After the player so the HUD is drawn on top)
    self.chargeHUD = ChargeHUD()
    self.difficultyHUD = DifficultyHUD()
end

-- FOR NOW Set the player's collision type to slide off of other colliders
function Player:collisionResponse()
    return gfx.sprite.kCollisionTypeSlide
end

-- Override update function
function Player:update()
    self:updateAnimation()

    self:handleState()

    -- Not sure why but math.clamp wasn't working so this is here in the meantime to cap speed
    if self.xVelocity > self.maxSpeed then self.xVelocity = self.maxSpeed
    elseif self.xVelocity < -self.maxSpeed then self.xVelocity = -self.maxSpeed
    end

    self:handleMovementAndCollisions()
    self:handleCameraMovement()

    -- If player falls below the waterline...
    if self.y > 400 then
        -- ...Touching water is true                            (PLAY DEATH ANIMATION HERE (TERMINATOR THUMBS UP))
        self.touchingWater = true
    end
end

-- Helper function to rotate/animate the player                 (STILL NEED IDLE/FALLING/FLYING ANIMATIONS)
function Player:updateAnimation()
    -- Grab the current angle of the crank and convert it to radians
    local crankAngle = math.rad( pd.getCrankPosition() )
    -- Adjust the rotation of the sprite to match the current crank angle
    self:setRotation(self:getRotation() + pd.getCrankChange())
end

-- Helper function to deal with player states
function Player:handleState()
    -- If player is falling...
    if playerState == PLAYER_STATES.falling then
        -- ... Set image to idle/falling animation
        self:setImage(self.playerImage)
        -- Apply gravity
        self:applyGravity()
        -- Handle our inputs
        self:handleInput()
    -- If player wants to fire...
    elseif playerState == PLAYER_STATES.firing then
        -- ... Set image to firing animation
        self:setImage(self.fireAnimation:image())
        -- Apply gravity
        self:applyGravity()
        -- FIRE!!!
        self:handleFireInput()
    -- If player wants to jump...
    elseif playerState == PLAYER_STATES.jumping then
        -- ... JUMP!!! (No gravity as this is more of a saving move)
        self:handleJumpInput()

        -- ADD CURSE LOGIC TO INCREASE DIFFICULTY ONCE YOU WORK OUT HOW THAT WILL WORK
    end
end

-- Movement Function (There isn't anything to collide with, nor is there ground so I don't think I need this)
function Player:handleMovementAndCollisions()
    -- Technically all I need is this part \/ (moveWithCollisions())
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    self.touchingWater = false
    for i=1, length do
        local collision = collisions[i]
        if collision.normal.y == -1 then
            self.touchingWater = true
        end
    end
end

-- Camera movement Function
function Player:handleCameraMovement()
    -- Grab current camera position (x,y)
    local camX, camY = gfx.getDrawOffset()
    -- Grab current player position (x,y)
    local playerX = -math.floor(self.x) + 50
    local playerY = -math.floor(self.y)
    -- New camera position adds the difference between it and the player,
    -- applying a some easing to make it look like the player is
    -- in fact flying forward before recentering.
    local x = camX + (playerX - camX)*self.cameraEase
    local y = camY + (playerY - camY)*self.cameraEase
    gfx.setDrawOffset(x, 0)
end

-- Handle Player Input
function Player:handleInput()
    -- If B is pressed, and we aren't firing / are off cooldown...
    if pd.buttonJustPressed(pd.kButtonB) and playerState ~= PLAYER_STATES.firing and self.fired == false and self.charges > 0 then
        -- ...Start firing
        playerState = PLAYER_STATES.firing
        -- Play the firing animation
        self.fireAnimation.paused = false
    -- If A is pressed...
    elseif pd.buttonJustPressed(pd.kButtonA) then
        -- ...Start jumping
        playerState = PLAYER_STATES.jumping
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

        -- Add the x force to the current xVelocity
        self.xVelocity += xFire
        -- Set our yVelocity to the y force (Feels bad with gravity involved)
        self.yVelocity = yFire

        -- Player has fired
        self.fired = true

        -- Shake the screen
        self:screenShake(250, 4)

        -- Decrease our charges
        self.chargeHUD:chargeFired()
        if self.charges > 0 then
            self.charges -= 1
        end
    end

    -- If the player has fired...
    if self.fireAnimation.frame >= 5 and self.fired == true then
        -- ... The player is now falling
        playerState = PLAYER_STATES.falling
        -- Set the fire animation back to frame one
        self.fireAnimation.frame = 1
        -- Reset the player image
        self:setImage(self.fireAnimation:image())
        -- Pause the fire animation until next time
        self.fireAnimation.paused = true
        -- Player hasn't fired
        self.fired = false
    end
end

-- Handle jumping input
function Player:handleJumpInput()
    -- WILL NEED TO ACCOUNT FOR A JUMP ANIMATION ONCE I'VE DRAWN ONE, SHOULD LOOK LIKE ABOVE FUNCTION

    -- Set our yVelocity to the jump force
    self.yVelocity = self.jumpForce
    -- Player is now falling
    playerState = PLAYER_STATES.falling

    -- Shake the screen
    self:screenShake(125, 2)

    -- Increase difficulty (MAKE A VALUE FOR THIS LATER WHEN ENEMIES/SPAWNERS EXIST (For now just update HUD scale))
    self.difficultyHUD:playerJumped()
end

-- Gravity Physics Helper Function
function Player:applyGravity()
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