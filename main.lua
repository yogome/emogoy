------------------------------- Main entry point
math.randomseed( os.time() ) -- Random seed every time, disable if you want to reproduce same conditions every time
system.setIdleTimer( false ) -- disable device sleep mode
display.setStatusBar( display.HiddenStatusBar ) -- Hide status bar

local storyboard = require("composer")
local sounds = require("sounds")

local launchArgs = ...
------------------------------- Initialize and Settings
------------------------------- Other stuff
sounds.initialize()
------------------------------- Notifications

------------------------------- Memory handler
local function handleLowMemory( event )
	print( "memory warning received! will atempt to purge inactive scenes." )
	storyboard.removeHidden()
end

------------------------------- Error listener
------------------------------- Key Listener
local function onKeyEvent( event )
	local handled = false
	local phase = event.phase
	local keyName = event.keyName

	if "back" == keyName and phase == "up" then
		local sceneName = storyboard.getCurrentSceneName()
		local currentScene = storyboard.getScene(sceneName)
		if currentScene.backAction ~= nil then
			handled = currentScene.backAction()
		else
			handled = false
		end
	end
	return handled
end

Runtime:addEventListener( "key", onKeyEvent )
Runtime:addEventListener( "memoryWarning", handleLowMemory )

storyboard.gotoScene("scenes.home")

