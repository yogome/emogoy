------------------------------- Home (Main screen)
local storyboard = require( "storyboard" )
local sounds = require ( "sounds" )
local dbconfig = require ( "vendor.dbconfig.dbconfig" )
local music = require ( "music" )
local protector = require( "helpers.protector" )
local gyroBG = require( "helpers.gyroBackground" )
local scene = storyboard.newScene()
------------------------- Variables
local buttonsEnabled 
local unlockTaps
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


	buttonNew = ui.newButton(ui.buttonPlay, true)
	buttonNew.x = display.contentCenterX
	buttonNew.y = display.contentCenterY + 200
	hudGroup:insert(buttonNew)

	buttonSettings = ui.newButton(ui.buttonSettings)
	buttonSettings.x = display.screenOriginX + display.actualContentWidth - 60
	buttonSettings.y = display.screenOriginY + display.actualContentHeight - 60
	hudGroup:insert(buttonSettings)

	buttonNew:addButtonListener("released", buttonPlayPressed)
	buttonSettings:addButtonListener("released", buttonSettingsPressed)
	
	logoGroup.isVisible = false
	buttonNew.isVisible = false
	buttonSettings.isVisible = false
	
	testMenuButton:toFront()
end

function scene:willEnterScene(event)
	background = gyroBG.new("images/home/background",1024)
	backgroundGroup:insert(background)
end

function scene:enterScene( event )
	local group = self.view
	unlockTaps = 0
	
	currentLoop = 100
	objectArray = { }
	
	logoGroup.isVisible = true
	buttonNew.isVisible = true
	buttonSettings.isVisible = true

	buttonNew.xScale = 4
	buttonNew.yScale = 4
	buttonNew.alpha = 0
	if buttonPlayMoveTransition == nil then
		buttonPlayMoveTransition = timer.performWithDelay(1500, function()
			transition.to( buttonNew, { time=500, xScale = 0.75, yScale = 0.75, transition=easing.outQuad } )
			transition.to( buttonNew, { delay=500, time=1000, xScale = .6, yScale = .6, transition=easing.outQuad } )
		end, 0)
	end
	
	createLogo()

	buttonSettings.alpha = 0
	buttonSettings.xScale = 0.45
	buttonSettings.yScale = 0.45
		
	buttonsEnabled = true
	buttonNew:resetLock()
	transition.to( buttonNew, { delay = 700, time=800, alpha = 1, xScale = .4, yScale = .4, transition=easing.outQuad })
	transition.to( buttonSettings, { delay=1500, time=1000, alpha = 1, transition=easing.outQuad} )
	
	createButtonParents()
	
	currentLoop = 0
	music.playTrack(1)
	
	Runtime:addEventListener("enterFrame", onFrameUpdate)
	
    Runtime:addEventListener("gyroscope", background)
	storyboard.printMemUsage()
end

function scene:exitScene( event )
	Runtime:removeEventListener ("enterFrame", onFrameUpdate)
	Runtime:removeEventListener("gyroscope", background)
	
	for index = #objectArray,1,-1 do
		local object = objectArray[index]
		if object ~= nil then
			display.remove(object)
			objectArray[index] = nil
			object = nil
		end
	end
end

function scene:destroyScene( event )

end

function scene:overlayBegan( event )
	local group = self.view
	overlayBeganLanguage = language
	
	transition.to( buttonNew, { time=300, alpha = 0, transition=easing.outQuad })
	transition.to( buttonSettings, { time=300, alpha = 0, transition=easing.outQuad })
end

function scene:overlayEnded( event )
	buttonNew.alpha = 0
	buttonNew.isVisible = true
	transition.to( buttonNew, { delay = 0, time=800, alpha = 1, transition=easing.outQuad })

	buttonSettings.xScale = 0.45
	buttonSettings.yScale = 0.45
	buttonSettings.alpha = 0
	buttonSettings.isVisible = true
	transition.to( buttonSettings, { delay = 0, time=800, alpha = 1, transition=easing.outQuad })
	
	language = dbconfig("language") or "en"

	if language ~= overlayBeganLanguage then
		if languageLogo then
			transition.to( logoGroup, { delay = 0, time=300, alpha = 0, transition=easing.outQuad })
			timer.performWithDelay(300, function()
				createLogo()
			end)
		end
	end
	buttonsEnabled = true
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "overlayBegan", scene )
scene:addEventListener( "overlayEnded", scene )

return scene
