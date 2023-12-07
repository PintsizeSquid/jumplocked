-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend GameTitleScene sprite subclass
class('GameTitleScene').extends(gfx.sprite)

-- Initialize GameTitleScene
function GameTitleScene:init()
    -- Load title screen animation sprite sheet
    local titleImageTable = gfx.imagetable.new("images/title-table-400-240")
    -- Create a new animation loop with the title screen sprite sheet
    self.titleAnimation = gfx.animation.loop.new(100, titleImageTable, false)
    -- Make sure the animation doesn't play yet
    self.titleAnimation.paused = true

    -- Center the sprite to the screen
    self:moveTo(200, 120)

    -- Move Values
    self.camSpeed = 20.0

    -- Add this scene (sprite) to the display list
    self:add()

    self.title = Title()
    self.controls = Controls()
    self.scores = Scores()
end

-- Override sprite update function
function GameTitleScene:update()
    -- Set this sprite's image to the current title animation frame
    self:setImage(self.titleAnimation:image())

    -- If start button is pressed and on main screen...
    if pd.buttonJustPressed(pd.kButtonB) then
        -- ...Play the animation
        self.titleAnimation.paused = false
    end

    -- If up button is pressed and on main screen and title is down...
    if pd.buttonJustPressed(pd.kButtonUp) and self.title.down and self.title.animating == false then
        -- ...Play the animation
        self.title:bringUp(false)
        self.controls:bringDown(false)
    end

    -- If up button is pressed and on main screen and title is up...
    if pd.buttonJustPressed(pd.kButtonUp) and self.title.up and self.title.animating == false 
        and self.scores.down == false then
        -- ...Play the animation
        self.title:bringDown(false)
        self.controls:bringUp(false)
    end

    -- If right button is pressed and on main screen and title is left...
    if pd.buttonJustPressed(pd.kButtonRight) and self.title.down and self.title.animating == false then
        -- ...Play the animation
        self.title:bringUp(true)
        self.scores:bringDown(true)
    end

    -- If up button is pressed and on main screen and title is right...
    if pd.buttonJustPressed(pd.kButtonRight) and self.title.up and self.title.animating == false 
        and self.controls.down == false then
        -- ...Play the animation
        self.title:bringDown(true)
        self.scores:bringUp(true)
    end

    -- If the animation is complete...
    if self.titleAnimation.frame >= self.titleAnimation.endFrame then
        -- ...Switch to the gameplay scene
        SCENE_MANAGER:switchScene(GameScene)
    end
end