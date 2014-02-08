------------------------------- Main entry point
local cacharro = require("vendor.cacharro.cacharro")
math.randomseed( os.time() ) -- Random seed every time, disable if you want to reproduce same conditions every time
system.setIdleTimer( false ) -- disable device sleep mode
display.setStatusBar( display.HiddenStatusBar ) -- Hide status bar

local storyboard = require("storyboard")
local sounds = require("sounds")
local dbconfig = require ( "vendor.dbconfig.dbconfig" )
if not dbconfig.inited then
	dbconfig.init{ name = "yogodb", debug = false }
end


local facebook = require("facebook")
facebook.publishInstall("205715149612858")

local launchArgs = ...
------------------------------- Initialize and Settings
local soundEnabled = dbconfig("sound") or "1"
dbconfig("sound", soundEnabled)
------------------------------- Other stuff
sounds.initialize()
------------------------------- Notifications

------------------------------- Memory handler
local function handleLowMemory( event )
	print( "memory warning received! will atempt to purge inactive scenes." )
	storyboard.purgeAll()
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

if cacharro.isSimulator then
	audio.setVolume(0)
	storyboard.gotoScene("scenes.testMenu")
else
	storyboard.gotoScene("scenes.home")
end

