-- Scripts
-- import "gameTitleScene"

-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameOverScene sprite subclass 
class('GameOverScene').extends(gfx.sprite)

function GameOverScene:init(scoreText)
    -- Game Over text + the passed in score
    local text = "GAME OVER\n\n" .. scoreText

    -- Load in our game's textfont
    local font = gfx.font.new("fonts/jumpFont")
    gfx.setFont(font)
    
    -- Create an image with the size of the text
    local gameOverImage = gfx.image.new(gfx.getTextSize(text))
    -- Push the image context
    gfx.pushContext(gameOverImage)
        -- Apply drawing functions to the image
        gfx.drawText(text, 0, 0)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    local gameOverSprite = gfx.sprite.new(gameOverImage)
    -- Scale up the sprite size
    gameOverSprite:setScale(2)
    -- Move the sprite to the center of the screen
    gameOverSprite:moveTo(200, 120)
    -- Add the text image to the display list
    gameOverSprite:add()

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function GameOverScene:update()
    -- FOR NOW If button is pressed...
    if pd.buttonJustPressed(pd.kButtonB) then
        -- ...Switch back to the title scene
        SCENE_MANAGER:switchScene(GameTitleScene)
    end
end