-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create GameScene sprite subclass 
class('GameScene').extends(gfx.sprite)

-- Initialize
function GameScene:init()
    -- Create the player object
    self.player = Player(50, 0)

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override update function
function GameScene:update()
    -- If the player touches the water...
    if self.player.touchingWater then
        -- ...Switch to the game over scene, passing the player's score
        SCENE_MANAGER:switchScene(GameOverScene, "SCORE : 0")
    end
end