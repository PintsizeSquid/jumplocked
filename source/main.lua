-- CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"

-- Scripts
import "scenes/sceneManager"
import "scenes/gameTitleScene"
import "scenes/gameScene"
import "scenes/gameOverScene"
import "objects/player"
import "hud/chargeHUD"
import "hud/difficultyHUD"

-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- SceneManager Singleton
SCENE_MANAGER = SceneManager()

-- Create Game Title Scene
GameTitleScene()

-- General Update on all objects
function pd.update()
	pd.timer.updateTimers()
	gfx.sprite.update()
end