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

    -- Load and set our game's font
    local font = gfx.font.new("fonts/jumpFont")
    gfx.setFont(font)

    -- Make the controls menu text
    local controlsText = "CRANK TO ROTATE\n" ..
                        "B ~ CAST A FIREBALL\n" ..
                        "A ~ JUMP UPWARD \n    (INCREASES BAD LUCK)"

    -- Create an image with the size of the text
    local controlsImage = gfx.image.new(gfx.getTextSize(controlsText .. "      "))
    -- Push the image context
    gfx.pushContext(controlsImage)
        -- Draw the text center of the image
        gfx.drawTextAligned(controlsText, 10, 0, kTextAlignment.left)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    self.controlsSprite = gfx.sprite.new(controlsImage)
    -- Scale up the sprite size
    self.controlsSprite:setScale(2)
    -- Move the sprite to the center of the screen
    self.controlsSprite:moveTo(250, -120)
    -- Add the text sprite to the display list
    self.controlsSprite:add()

    -- Center the sprite to the screen
    self:moveTo(200, 120)

    -- Move Values
    self.camSpeed = 30.0

    -- Current State
    self.controls = false

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override sprite update function
function GameTitleScene:update()
    -- Set this sprite's image to the current title animation frame
    self:setImage(self.titleAnimation:image())

    -- If start button is pressed and controls aren't down...
    if pd.buttonJustPressed(pd.kButtonB) and self.controls == false then
        -- ...Play the animation
        self.titleAnimation.paused = false
    end

    -- If up button is pressed and controls aren't down...
    if pd.buttonJustPressed(pd.kButtonUp) and self.controls == false then
        -- ... Controls was pressed
        self.controls = true
    end

    -- If up button is pressed and controls are down...
    if pd.buttonJustPressed(pd.kButtonDown) and self.controls == true then
        -- ... Back to main
        self.controls = false
    end

    -- If controls was pressed...
    if self.controls then
        local camX, camY = gfx.getDrawOffset()
        -- Move up the draw offset to see the controls text
        if camY < 240 then gfx.setDrawOffset(camX, camY + self.camSpeed) end
    else
        local camX, camY = gfx.getDrawOffset()
        -- Move up the draw offset to see the controls text
        if camY > 0 then gfx.setDrawOffset(camX, camY - self.camSpeed) end
    end

    -- If the animation is complete...
    if self.titleAnimation.frame >= self.titleAnimation.endFrame then
        -- ...Switch to the gameplay scene
        SCENE_MANAGER:switchScene(GameScene)
    end
end