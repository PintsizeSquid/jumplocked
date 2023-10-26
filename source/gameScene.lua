-- Scripts
-- import "gameOverScene"
-- import "player"

-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('GameScene').extends(gfx.sprite)

-- Initialize
function GameScene:init()
    -- Do background when you make one!!!
    -- local backgroundImage = gfx.image.new("images/background")
    -- gfx.sprite.setBackgroundDrawingCallback(function()
    --     backgroundImage:draw(0,0)
    -- end)
    -- self:add()

    -- Create the player object
    self.player = Player(50, 0)

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function GameScene:update()
    -- FOR NOW If button is pressed...
    if self.player.touchingWater then
        -- ...Switch to the game over scene, passing the player's score
        SCENE_MANAGER:switchScene(GameOverScene, "SCORE : 0")
    end
end