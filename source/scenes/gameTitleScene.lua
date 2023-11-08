-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameTitleScene sprite subclass
class('GameTitleScene').extends(gfx.sprite)

-- Initialize
function GameTitleScene:init()
    -- Title screen sprite sheet
    local titleImageTable = gfx.imagetable.new("images/title-table-400-240")
    -- Create new animation loop with the title screen sprite sheet
    self.titleAnimation = gfx.animation.loop.new(100, titleImageTable, false)
    -- Make sure the start animation doesn't play yet
    self.titleAnimation.paused = true
    -- Center the sprite to the screen
    self:moveTo(200, 120)
    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function GameTitleScene:update()
    -- Set this sprite's image to the current title animation frame
    self:setImage(self.titleAnimation:image())

    -- If start button is pressed...
    if pd.buttonJustPressed(pd.kButtonB) then
        -- ...Play the animation
        self.titleAnimation.paused = false
    end

    -- If the animation is complete...
    if self.titleAnimation.frame >= self.titleAnimation.endFrame then
        -- ...Switch to the gameplay scene
        SCENE_MANAGER:switchScene(GameScene)
    end
end