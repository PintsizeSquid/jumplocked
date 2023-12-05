-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Extend GameScene sprite subclass 
class('GameScene').extends(gfx.sprite)

-- Initialize GameScene
function GameScene:init()
    -- Create the player object
    self.player = Player(50, -360)
    -- Create the rain overlay
    Rain()
    -- Play Rain song
    pulp.audio.playSong("Rain")

    -- Enemy Spawning Values
    self.lastSpawnDistance = 0
    self.spawnGap = 1495
    self.spawnOffset = 300
    self.difficultyScale = 169

    -- Current State
    self.gameOver = false

    -- Add this scene (sprite) to the display list
    self:add()
end

-- Override sprite update function
function GameScene:update()
    self:scaleDifficulty()

    -- Get a multiple of the spawnGap from the player's current distance
    local spawnDistance = math.floor(self.player.x / self.spawnGap)
    -- If the new spawnDistance is ahead of the previous...
    if spawnDistance > self.lastSpawnDistance then
        -- ... Replace the old spawnDistance
        self.lastSpawnDistance = spawnDistance

        -- Get a random value within our difficulty scale
        local rand = math.random(0, self.difficultyScale)
        -- Use this value to decide which enemy to spawn
        if rand == 0 then
            -- Spawn a Lightning strike just in front of the player
            Lightning(self.player.x + self.spawnOffset/1.5, 97, self.player)
        elseif rand <= self.difficultyScale/3 then
            -- Spawn Albatross offscreen ahead of the player
            Albatross(self.player.x + self.spawnOffset, self.player)
        else
            -- Spawn Razorbill offscreen ahead of the player
            Razorbill(self.player.x + self.spawnOffset, self.player)
        end
    end

    -- If the player is touching the water...
    if self.player.touchingWater and self.gameOver == false then
        self:displayScore()
        self.gameOver = true
    end

    -- If the game is over...
    if self.gameOver == true then
        -- ... If the any button is pressed...
        local current = pd.getButtonState()
        if current ~= 0 then
            -- ... Stop the Rain song and switch back to the title scene
            pulp.audio.stopSong()
            SCENE_MANAGER:switchScene(GameTitleScene)
        end
    end
end

-- Difficulty scaler
function GameScene:scaleDifficulty()
    -- Grab the current difficulty
    local currentDifficulty = self.player.difficultyHUD.difficultyHUDAnimation.endFrame + 1 -
        self.player.difficultyHUD.difficultyHUDAnimation.frame
    -- Calculate the difficulty scale
    -- Spawning frequency essentially increases the chances of lightning striking the harder the difficulty
    self.difficultyScale = 13 * currentDifficulty
    -- Calculate the spawn gap ahead of the player
    -- Minimum 650, decreasing distance by mutiples of 65 the harder the difficulty
    self.spawnGap = 650 + (65 * currentDifficulty)
end

-- Score display function
function GameScene:displayScore()
    -- Create our score and game over texts
    local scoreText = " SCORE \n\n " .. tostring(self.player.score) .. " M"

    -- Load and set our game's font
    local font = gfx.font.new("fonts/jumpFont")
    gfx.setFont(font)

    -- Create an image with the size of the text
    local gameOverImage = gfx.image.new(gfx.getTextSize(scoreText))
    -- Push the image context
    gfx.pushContext(gameOverImage)
        -- Draw the text center of the image
        gfx.drawTextAligned(scoreText, gameOverImage.width / 2, 0, kTextAlignment.center)
    -- Pop the image context and restore its state
    gfx.popContext()

    -- Create a sprite with the now pushed text image
    local gameOverSprite = gfx.sprite.new(gameOverImage)
    -- Scale up the sprite size
    gameOverSprite:setScale(2)
    -- Make sure our sprite is unaffected by the drawOffset
    gameOverSprite:setIgnoresDrawOffset(true)
    -- Move the sprite to the center of the screen
    gameOverSprite:moveTo(200, 120)
    -- Add the text sprite to the display list
    gameOverSprite:add()
end