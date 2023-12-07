-- CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"

-- Audio Files
import "pulp-audio"
-- Scripts
import "scenes/sceneManager"
import "scenes/gameTitleScene"
import "scenes/gameScene"
import "entities/player"
import "entities/albatross"
import "entities/razorbill"
import "entities/lightning"
import "objects/fireCharge"
import "objects/water"
import "objects/cloud"
import "objects/rain"
import "objects/splash"
import "objects/buoy"
import "objects/title/controls"
import "objects/title/scores"
import "objects/title/title"
import "hud/chargeHUD"
import "hud/difficultyHUD"
import "hud/rechargeHUD"

-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Initialize Audio Source
pulp.audio.init()

-- SceneManager Singleton
SCENE_MANAGER = SceneManager()

-- Create Game Title Scene, beginning the game loop
GameTitleScene()

-- General Update on all objects
function pd.update()
	pd.timer.updateTimers()
	pulp.audio.update()
	gfx.sprite.update()
end