------------------------------- Home (Main screen)
local storyboard = require( "storyboard" )
local sounds = require ( "sounds" )
local dbconfig = require ( "vendor.dbconfig.dbconfig" )
local music = require ( "music" )
local protector = require( "helpers.protector" )
local gyroBG = require( "helpers.gyroBackground" )
local ui = require( "helpers.ui" )
local scene = storyboard.newScene()
------------------------- Variables
local buttonsEnabled 
local unlockTaps
local backgroundGroup, background
local hudGroup, scoreNumber
local objectGroup
local currentFrame
------------------------- Constants
------------------------- Functions
local function openTestMenu()
	if buttonsEnabled == true then
		unlockTaps = unlockTaps + 1
		if unlockTaps == 5 then
			buttonsEnabled = false
			unlockTaps = 0
			storyboard.gotoScene("scenes.testMenu")
		end
	end
end

------------------------- class functions 
function scene:updateScore(newScore)
	display.remove(scoreNumber)
	scoreNumber = nil
	scoreNumber = ui.newNumber(newScore, -10)
	scoreNumber.x = display.contentCenterX
	scoreNumber.y = display.screenOriginY + 100
	
	hudGroup:insert(scoreNumber)
end

function scene:createScene( event )
	local group = self.view
	
	local testMenuButton = display.newRect(display.screenOriginX + 15,display.screenOriginY + 15,30,30)
	testMenuButton.isVisible = false
	testMenuButton.isHitTestable = true
	testMenuButton:addEventListener("tap", openTestMenu)
	group:insert(testMenuButton)

    backgroundGroup = display.newGroup()
    group:insert(backgroundGroup)
	
    hudGroup = display.newGroup()
    group:insert(hudGroup)
	
	objectGroup = display.newGroup()
	backgroundGroup:insert(objectGroup)
	
	testMenuButton:toFront()
end

function scene:willEnterScene(event)
	unlockTaps = 0
	currentFrame = 0
	
	display.remove(background)
	background = nil
	background = gyroBG.new("images/backgrounds/bg_"..math.random(1,2),1024)
	backgroundGroup:insert(background)
end

function scene:enterFrame(event)
	currentFrame = currentFrame + 1
end

function scene:enterScene( event )
	local group = self.view
	
	music.playTrack(1)
	
	Runtime:addEventListener("enterFrame", self)
	
    Runtime:addEventListener("gyroscope", background)
	storyboard.printMemUsage()
end

function scene:exitScene( event )
	Runtime:removeEventListener ("enterFrame", self)
	Runtime:removeEventListener("gyroscope", background)
end

function scene:destroyScene( event )

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "willEnterScene", scene )

return scene
