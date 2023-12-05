-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend DifficultyHUD sprite subclass 
class('DifficultyHUD').extends(gfx.sprite)

-- Initialize DifficultyHUD
function DifficultyHUD:init()
    -- Make sure our HUD is drawn in screen coordinates, and is unaffected by the drawOffset
    self:setIgnoresDrawOffset(true)

    -- Load the DifficultyHUD animation sprite sheet
    local difficultyImageTable = gfx.imagetable.new("images/HUD-difficulty-table-32-120")
    -- Create new animation loop with the DifficultyHUD sprite sheet
    self.difficultyHUDAnimation = gfx.animation.loop.new(100, difficultyImageTable, false)
    -- Make sure the animation doesn't play yet
    self.difficultyHUDAnimation.paused = true
    -- Move to 0, 180 (Bottom left of the screen)
    self:moveTo(0, 180)

    -- Add this sprite to the display list
    self:add()

    -- Set Z-index high to display above other objects
    self:setZIndex(100)
end

-- Override update function
function DifficultyHUD:update()
    -- Set this sprite's image to the current animation frame
    self:setImage(self.difficultyHUDAnimation:image())
end

-- Increase difficulty function
function DifficultyHUD:playerJumped()
    -- Update the DifficultyHUD animation to show the player has jumped and difficulty increases
    if self.difficultyHUDAnimation.frame < self.difficultyHUDAnimation.endFrame then
        self.difficultyHUDAnimation.frame += 1
    end
end