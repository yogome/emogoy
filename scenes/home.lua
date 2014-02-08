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
local topPipe, bottomPipe
local topPipeTransition
local bottomPipeTransition
------------------------- Constants
local topPipeOffsetY = -100
local bottomPipeOffsetY = 100
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

local function sceneTouch(event)
	if not topPipeTransition and not bottomPipeTransition then
		sounds.pipeStart()
		topPipeTransition = protector.to(topPipe,{time = 250, y = display.contentCenterY, transition = easing.inExpo, onComplete = function()
			sounds.pipeEnd()
			topPipeTransition = protector.to(topPipe,{delay = 50, time = 300, y = display.contentCenterY + topPipeOffsetY, transition = easing.inQuad, onComplete = function()
				topPipeTransition = nil
			end})
		end})

		bottomPipeTransition = protector.to(bottomPipe,{time = 250, y = display.contentCenterY, transition = easing.inExpo, onComplete = function()
			bottomPipeTransition = protector.to(bottomPipe,{delay = 50, time = 300, y = display.contentCenterY + bottomPipeOffsetY, transition = easing.inQuad, onComplete = function()
				bottomPipeTransition = nil
			end})
		end})
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
	group:insert(objectGroup)
	
	testMenuButton:toFront()
end

function scene:willEnterScene(event)
	unlockTaps = 0
	currentFrame = 0
	
	display.remove(background)
	background = nil
	background = gyroBG.new("images/backgrounds/bg_"..math.random(1,2),1024)
	backgroundGroup:insert(background)
	
	topPipe = display.newImage("images/elements/pipe.png",true)
	topPipe.anchorY = 0
	topPipe.rotation = 180
	topPipe.xScale = 0.6
	topPipe.yScale = 0.6
	topPipe.x = display.contentCenterX
	topPipe.y = display.contentCenterY + topPipeOffsetY
	objectGroup:insert(topPipe)
	
	bottomPipe = display.newImage("images/elements/pipe.png",true)
	bottomPipe.anchorY = 0
	bottomPipe.rotation = 0
	bottomPipe.xScale = 0.6
	bottomPipe.yScale = 0.6
	bottomPipe.x = display.contentCenterX
	bottomPipe.y = display.contentCenterY + bottomPipeOffsetY
	objectGroup:insert(bottomPipe)
	
	local gameFloor = display.newImage("images/elements/floor.png",true)
	gameFloor.anchorY = 1
	gameFloor.x = display.contentCenterX
	gameFloor.y = display.screenOriginY + display.viewableContentHeight + 100
	objectGroup:insert(gameFloor)
end

function scene:enterFrame(event)
	currentFrame = currentFrame + 1
	
end

function scene:enterScene( event )
	local group = self.view
	
	music.playTrack(1)
	
	Runtime:addEventListener("enterFrame", self)
	Runtime:addEventListener("tap", sceneTouch)
    Runtime:addEventListener("gyroscope", background)
	storyboard.printMemUsage()
end

function scene:exitScene( event )
	Runtime:removeEventListener ("enterFrame", self)
	Runtime:removeEventListener("gyroscope", background)
	Runtime:removeEventListener("tap", sceneTouch)
end

function scene:destroyScene( event )

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "willEnterScene", scene )

return scene
