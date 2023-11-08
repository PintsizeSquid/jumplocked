-- Performance Savers
local pd <const> = playdate
local gfx <const> = pd.graphics

-- Create SceneManager base class
class('SceneManager').extends()

-- Function to swap the current scene with a new one
function SceneManager:switchScene(scene, ...)
    -- Set new scene
    self.newScene = scene
    -- Pass any needed info to the new scene (Score)
    self.sceneArgs = ...
    -- Load the new scene
    self:loadNewScene()
end

-- Function to wipe the current scene and load the new one
function SceneManager:loadNewScene()
    -- Cleanup the current scene
    self:cleanupScene()
    -- Initialize the new scene, passing forward needed info
    self.newScene(self.sceneArgs)
end

-- Function to cleanup the current scene
function SceneManager:cleanupScene()
    -- Wipe all sprites
    gfx.sprite.removeAll()
    -- Reset all timers
    self:removeAllTimers()
    -- Recenter Draw
    gfx.setDrawOffset(0, 0)
end

-- Function to remove every timer
function SceneManager:removeAllTimers()
    local allTimers = pd.timer.allTimers()
    for _, timer in ipairs(allTimers) do
        timer:remove()
    end
end