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
    -- Create an image of the player
    self.playerImage = gfx.image.new("images/player")

    -- Fire animation sprite sheet
    local fireImageTable = gfx.imagetable.new("images/fire-table-16-16")
    -- Create new animation loop with the title screen sprite sheet
    self.fireAnimation = gfx.animation.loop.new(100, fireImageTable, false)
    self.fireAnimation.paused = true

    -- Set the sprite
    self:setImage(self.playerImage)
    -- Move the sprite to it's assigned location
    self:moveTo(x, y)
    -- Set this sprites collision box
    self:setCollideRect(6, 4, 6, 13)
    -- Grab the current angle of the crank and convert it to radians
    local crankAngle = math.rad( pd.getCrankPosition() )
    -- Adjust the rotation of the sprite to match the current crank angle
    self:setRotation(self:getRotation() + pd.getCrankPosition())

    -- Physics Properties
    self.xVelocity = 0.0
    self.yVelocity = 0.0
    self.gravity = .98
    self.airResistance = 0.2
    self.jumpForce = -10.0
    self.fireForce = 15.0
    self.maxSpeed = 20.0

    -- Current Action
    self.fired = false

    -- Add this sprite to the display list
    self:add()
end

function Player:collisionResponse()
    return gfx.sprite.kCollisionTypeSlide
end

-- Override update function
function Player:update()
    self:updateAnimation()

    self:handleState()

    if self.xVelocity > self.maxSpeed then self.xVelocity = self.maxSpeed
    elseif self.xVelocity < -self.maxSpeed then self.xVelocity = -self.maxSpeed
    end

    self:handleMovementAndCollisions()

    if self.y > 400 then
        self.touchingWater = true
        self.yVelocity = 0
    end
end

function Player:updateAnimation()
    -- Grab the current angle of the crank and convert it to radians
    local crankAngle = math.rad( pd.getCrankPosition() )
    -- Adjust the rotation of the sprite to match the current crank angle
    self:setRotation(self:getRotation() + pd.getCrankChange())
end

function Player:handleState()
    if playerState == PLAYER_STATES.falling then
        self:setImage(self.playerImage)
        self:applyGravity()
        self:handleInput()
    elseif playerState == PLAYER_STATES.firing then
        self:setImage(self.fireAnimation:image())
        self:applyGravity()
        self:handleFireInput()
    elseif playerState == PLAYER_STATES.jumping then
        self:handleJumpInput()
    end
end

function Player:handleMovementAndCollisions()
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    self.touchingWater = false
    for i=1, length do
        local collision = collisions[i]
        if collision.normal.y == -1 then
            self.touchingWater = true
        end
    end
end

function Player:handleInput()
    if pd.buttonJustPressed(pd.kButtonB) and playerState ~= PLAYER_STATES.firing and self.fired == false then
        playerState = PLAYER_STATES.firing
        self.fireAnimation.paused = false
    elseif pd.buttonJustPressed(pd.kButtonA) then
        playerState = PLAYER_STATES.jumping
    end
end

function Player:handleFireInput()
    -- Grab the current angle of the crank and convert it to radians 
    -- (- 90 because 0 on the crank is straight up (90 on unit circle))
    if self.fireAnimation.frame == 4 and self.fired == false then
        local crankAngle = math.rad( pd.getCrankPosition() - 90)

        local xFire = math.cos(crankAngle) * self.fireForce
        local yFire = math.sin(crankAngle) * self.fireForce

        self.xVelocity += xFire
        self.yVelocity = yFire

        self.fired = true
    end

    if self.fireAnimation.frame >= 5 and self.fired == true then
        playerState = PLAYER_STATES.falling
        self.fireAnimation.frame = 1
        self:setImage(self.fireAnimation:image())
        self.fireAnimation.paused = true
        self.fired = false
    end
end

function Player:handleJumpInput()
    self.yVelocity = self.jumpForce

    playerState = PLAYER_STATES.falling
end

-- Physics Helper Functions
function Player:applyGravity()
    if self.xVelocity > 0 then 
        self.xVelocity -= self.airResistance
        if self.xVelocity < 0 then self.xVelocity = 0
        end
    elseif self.xVelocity < 0 then 
        self.xVelocity += self.airResistance
        if self.xVelocity > 0 then self.xVelocity = 0
        end
    end

    self.yVelocity += self.gravity
    if self.touchingWater then
        self.yVelocity = 0
    end
end