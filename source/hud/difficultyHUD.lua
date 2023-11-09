-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('DifficultyHUD').extends(gfx.sprite)

-- Initialize
function DifficultyHUD:init()
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Charge HUD sprite sheet
    local difficultyImageTable = gfx.imagetable.new("images/HUD-difficulty-table-32-120")
    -- Create new animation loop with the charge hud sprite sheet
    self.difficultyHUDAnimation = gfx.animation.loop.new(100, difficultyImageTable, false)
    -- Make sure the start animation doesn't play yet
    self.difficultyHUDAnimation.paused = true
    -- Center the sprite to the screen
    self:moveTo(0, 180)

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function DifficultyHUD:update()
    -- Set this sprite's image to the current title animation frame
    self:setImage(self.difficultyHUDAnimation:image())
end

function DifficultyHUD:playerJumped()
    -- Update our HUD animation to show the player has jumped and difficulty increases
    if self.difficultyHUDAnimation.frame < self.difficultyHUDAnimation.endFrame then
        self.difficultyHUDAnimation.frame += 1
    end
end