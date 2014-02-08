------------------------------- Home (Main screen)
local storyboard = require( "storyboard" )
local sounds = require ( "sounds" )
local dbconfig = require ( "vendor.dbconfig.dbconfig" )
local music = require ( "music" )
local protector = require( "helpers.protector" )
local gyroBG = require( "helpers.gyroBackground" )
local ui = require( "helpers.ui" )
local physics = require( "physics" )
local scene = storyboard.newScene()
------------------------- Variables
local buttonsEnabled 
local unlockTaps
local backgroundGroup, background
local hudGroup, scoreNumber
local objectGroup
local currentFrame
local topPipe, bottomPipe, topPipeGroup, bottomPipeGroup
local topPipeTransition
local bottomPipeTransition
local birdArray
local logo, gameOver
------------------------- Constants
local topPipeOffsetY = -100
local bottomPipeOffsetY = 100

local colorData = {
	{r = 243/255, g = 214/255, b = 208/255},
	{r = 168/255, g = 213/255, b = 255/255},
	{r = 68/255, g = 63/255, b = 143/255},
	{r = 255/255, g = 51/255, b = 133/255},
	{r = 255/255, g = 0/255, b = 0/255},
	{r = 0/255, g = 255/255, b = 0/255},
	{r = 255/255, g = 255/255, b = 0/255},
	{r = 255/255, g = 128/255, b = 0/255},
	{r = 0/255, g = 255/255, b = 255/255},
	{r = 0/255, g = 128/255, b = 255/255},
	{r = 0/255, g = 255/255, b = 128/255},
	{r = 128/255, g = 128/255, b = 128/255},
}

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
		topPipeGroup.crushing = true
		bottomPipeGroup.crushing = true
		
		topPipeTransition = protector.to(topPipeGroup,{time = 210, y = display.contentCenterY, transition = easing.inExpo, onComplete = function()
			sounds.pipeEnd()
			topPipeGroup.crushing = false
			topPipeTransition = protector.to(topPipeGroup,{delay = 50, time = 300, y = display.contentCenterY + topPipeOffsetY, transition = easing.inQuad, onComplete = function()
				topPipeTransition = nil
			end})
		end})

		bottomPipeTransition = protector.to(bottomPipeGroup,{time = 210, y = display.contentCenterY, transition = easing.inExpo, onComplete = function()
			bottomPipeGroup.crushing = false
			bottomPipeTransition = protector.to(bottomPipeGroup,{delay = 50, time = 300, y = display.contentCenterY + bottomPipeOffsetY, transition = easing.inQuad, onComplete = function()
				bottomPipeTransition = nil
			end})
		end})
	end
end

local function newBloodSplash()
	local bloodSplash = display.newGroup()
	bloodSplash.anchorChildren = true
	bloodSplash.anchorX = 1
	
	local frameData = { width = 512, height = 256, numFrames = 8 }
	local bloodSheet = graphics.newImageSheet( "images/blood/bloodSplash1.png", frameData )
	local bloodAnimations = {
		{ name="splash", sheet = bloodSheet, start = 1, count = 8, loopCount = 1, time = 400},
	}

	local sprite = display.newSprite( bloodSheet, bloodAnimations )
	sprite:setSequence("splash")
	sprite:play()
	bloodSplash:insert(sprite)
	bloodSplash.xScale = 0.6
	bloodSplash.yScale = 0.6
	bloodSplash.sprite = sprite
	
	protector.performWithDelay(400, function()
		display.remove(bloodSplash)
		bloodSplash = nil
	end)
	
	return bloodSplash
end

local function newBird()
	local bird = display.newGroup()
	
	local frameData = { width = 256, height = 256, numFrames = 4 }
	local normalSheet = graphics.newImageSheet( "images/elements/bird1.png", frameData )
	local colorSheet = graphics.newImageSheet( "images/elements/bird2.png", frameData )
	local normalAnimations = {
		{ name="fly", sheet = normalSheet, frames = {1,2,3}, time = 300},
	}
	local colorAnimations = {
		{ name="fly", sheet = colorSheet, frames = {1,2,3}, time = 300},
	}

	local birdSprite = display.newSprite( normalSheet, normalAnimations )
	birdSprite.xScale = 0.35
	birdSprite.yScale = 0.35
	birdSprite:setSequence("fly")
	birdSprite:play()
	
	local colorSprite = display.newSprite( colorSheet, colorAnimations )
	colorSprite.xScale = 0.35
	colorSprite.yScale = 0.35
	colorSprite:setSequence("fly")
	colorSprite:play()
	
	local color = colorData[math.random(1,#colorData)]
	colorSprite:setFillColor(color.r, color.g, color.b)
	
	bird:insert(birdSprite)
	bird:insert(colorSprite)
	
	bird.colorSprite = colorSprite
	bird.sprite = birdSprite
	bird.value = 1
	
	bird.anchorChildren = true
	
	physics.addBody( bird, { density = 1.0, friction = 0.3, bounce = 0.2, radius = 25 } )
	bird.isBullet = true
	bird.name = "bird"
	
	table.insert(birdArray, bird)
	
	return bird
end

local function checkTubeCollision( tube, object, element1, element2)
	if tube.name == "pipe" then
		if element1 == 1 and tube.crushing then -- bird crusher
			if object.name == "bird" then
				object.remove = true
				local bloodSplash = newBloodSplash()
				bloodSplash.x = object.x
				bloodSplash.y = object.y
				objectGroup:insert(bloodSplash)
			end
		else
			
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
	
	objectGroup = display.newGroup()
	group:insert(objectGroup)
	
	hudGroup = display.newGroup()
    group:insert(hudGroup)
	
	logo = display.newImage("images/logo.png", true)
	logo.x = display.contentCenterX
	logo.y = display.screenOriginY + 200
	local logoScale = display.viewableContentWidth / 1024
	logo.xScale = logoScale
	logo.yScale = logoScale
	logo.isVisible = false
	hudGroup:insert(logo)
	
	gameOver = display.newImage("images/gameover.png", true)
	gameOver.x = display.contentCenterX
	gameOver.y = display.contentCenterY
	local gameOverScale = display.viewableContentWidth / 1024
	gameOver.xScale = gameOverScale
	gameOver.yScale = gameOverScale
	gameOver.isVisible = false
	hudGroup:insert(gameOver)
	
	testMenuButton:toFront()
end

function scene:willEnterScene(event)
	physics.start()
	physics.setGravity( 6, 0 )
	--physics.setDrawMode( "hybrid" )
	
	birdArray = {}
	unlockTaps = 0
	currentFrame = 0
	
	display.remove(background)
	background = nil
	background = gyroBG.new("images/backgrounds/bg_"..math.random(1,2),1024)
	backgroundGroup:insert(background)
	
	topPipeGroup = display.newGroup()
	topPipeGroup.anchorChildren = true
	topPipeGroup.anchorY = 0
	topPipeGroup.x = display.screenOriginX + display.viewableContentWidth - 200
	topPipeGroup.y = display.contentCenterY + topPipeOffsetY
	topPipeGroup.name = "pipe"
	topPipeGroup.rotation = 180
	topPipe = display.newImage("images/elements/pipe.png",true)
	topPipeGroup:insert(topPipe)
	physics.addBody( topPipeGroup, "kinematic", 
		{ radius = 50, isSensor = true, shape = { -48,-514, 48,-514, 48,400, -48,400 }}, -- Receptor
		{ bounce = 1, friction = 0.4, density = 1, shape = { -64,-512, 64,-512, 64,512, -64,512 }})
	objectGroup:insert(topPipeGroup)
	
	bottomPipeGroup = display.newGroup()
	bottomPipeGroup.anchorChildren = true
	bottomPipeGroup.anchorY = 0
	bottomPipeGroup.rotation = 0
	bottomPipeGroup.x = display.screenOriginX + display.viewableContentWidth - 200
	bottomPipeGroup.y = display.contentCenterY + bottomPipeOffsetY
	bottomPipeGroup.name = "pipe"
	
	bottomPipe = display.newImage("images/elements/pipe.png",true)
	bottomPipeGroup:insert(bottomPipe)
	physics.addBody( bottomPipeGroup, "kinematic", 
		{ radius = 50, isSensor = true, shape = { -48,-514, 48,-514, 48,400, -48,400 }}, -- Receptor
		{ bounce = 1, friction = 0.4, density = 1, shape = { -64,-512, 64,-512, 64,512, -64,512 }})
	objectGroup:insert(bottomPipeGroup)
		
	local gameFloor = display.newImage("images/elements/floor.png")
	gameFloor.anchorY = 1
	gameFloor.x = display.contentCenterX
	gameFloor.y = display.screenOriginY + display.viewableContentHeight + 100
	objectGroup:insert(gameFloor)
	
	physics.addBody( gameFloor, "static", { friction=0.5, bounce=0.3 } )
	
	Runtime:addEventListener( "collision", self )
end

function scene:enterFrame(event)
	currentFrame = currentFrame + 1
	
	if currentFrame % 100 == 0 then
		currentFrame = 0
		local bird = newBird()
		bird.x = display.screenOriginX - 100
		bird.y = display.contentCenterY + math.random(-200,200)
		objectGroup:insert(bird)
	end
	
	for index = #birdArray,1,-1 do
		local bird = birdArray[index]
		if bird.x > display.screenOriginX + display.viewableContentWidth + 100 or bird.remove == true then
			physics.removeBody(bird)
			display.remove(bird)
			table.remove(birdArray, index)
		end
	end
end

function scene:collision(event)
	if ( event.phase == "began" ) then
		checkTubeCollision(event.object1, event.object2, event.element1, event.element2)
		checkTubeCollision(event.object2, event.object1, event.element2, event.element1)
	end
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
	
	for index = #birdArray,1,-1 do
		local bird = birdArray[index]
		physics.removeBody(bird)
		display.remove(bird)
		table.remove(birdArray, index)
	end
	
	physics.stop()
end

function scene:destroyScene( event )

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "willEnterScene", scene )

return scene
