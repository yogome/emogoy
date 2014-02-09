------------------------------- Home (Main screen)
local storyboard = require( "storyboard" )
local sounds = require ( "sounds" )
local dbconfig = require ( "vendor.dbconfig.dbconfig" )
local music = require ( "music" )
local protector = require( "helpers.protector" )
local gyroBG = require( "helpers.gyroBackground" )
local ui = require( "helpers.ui" )
local physics = require( "physics" )
local facebook = require( "facebook" )
local log = require("vendor.log.log")
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
local companyLogo, gameOverImage
local score, scoreText, highScore
local endScreenGroup, endScreen
local crushBirds
local birdsSpawned
local birdsCrushed
local bloodParticleArray
local medal, endBestScoreText, newBestScore, endCurrentScore, endRetry, endShare
local tapHere1, tapHere2
local gameState -- "loading", ready","transition" "game", "end"
local fadeRectangle, logo, gameFloor
------------------------- Constants
local birdFilter = {categoryBits = 1, maskBits = 2} 
local pipeFilter = {categoryBits = 2, maskBits = 1023} 
local bloodFilter = {categoryBits = 8, maskBits = 4} 
local floorFilter = {categoryBits = 4, maskBits = 9} 

local topPipeOffsetY = -120
local bottomPipeOffsetY = 120

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

local medalColors = {
	{r = 255/255, g = 128/255, b = 0/255},
	{r = 192/255, g = 192/255, b = 192/255},
	{r = 255/255, g = 255/255, b = 0/255},
	{r = 255/255, g = 255/255, b = 255/255},
}

------------------------- Functions
local function angleOfPoint( pt )
	local x, y = pt.x, pt.y
	local radian = math.atan2(y,x)
	local angle = radian*180/math.pi
	if angle < 0 then angle = 360 + angle end
	return angle
end

local function angleBetweenPoints( a, b )
	local x, y = b.x - a.x, b.y - a.y
	return angleOfPoint( { x=x, y=y } )
end

local function openTestMenu()
	unlockTaps = unlockTaps + 1
	if unlockTaps == 5 then
		unlockTaps = 0
		storyboard.gotoScene("scenes.testMenu")
	end
end

local function pipeCrush()
	if not topPipeTransition and not bottomPipeTransition then
		sounds.pipeStart()
		topPipeGroup.crushing = true
		bottomPipeGroup.crushing = true
		
		local savedX = topPipeGroup.x
		for index = 1, 10 do
			protector.performWithDelay(21 * index, function()
				local number = 2 + (index * 2)
				topPipeGroup.x = savedX + math.random(-number,number)
				bottomPipeGroup.x = savedX + math.random(-number,number)
				if index == 10 then
					topPipeGroup.x = savedX
					bottomPipeGroup.x = savedX
				end
			end)
		end

		topPipeTransition = protector.to(topPipeGroup,{time = 210, y = display.contentCenterY, transition = easing.inExpo, onComplete = function()
			sounds.pipeEnd()
			topPipeGroup.crushing = false
			crushBirds = true
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

local function startGame()
	if gameState == "ready" then
		gameState = "transition"
		sounds.pop()
		protector.to(companyLogo, {time = 500, x = display.screenOriginX - 500, alpha = 0, transition = easing.inQuad})
		protector.to(logo, {time = 500, x = display.screenOriginX + display.viewableContentWidth + 500, alpha = 0, transition = easing.inQuad})

		protector.to(tapHere1, {time = 500, alpha = 0, transition = easing.outQuad})
		protector.to(tapHere2, {time = 500, alpha = 0, transition = easing.outQuad})

		protector.to(fadeRectangle, {time = 500, alpha = 0, transition = easing.outQuad, onComplete = function()
			gameState = "game"
			protector.from(scoreText, {time = 500, alpha = 0, y = display.screenOriginY - 100, transition = easing.outQuad, onStart = function()
				scoreText.isVisible = true
			end})
		end})
	end
end

local function sceneTouch(event)
	if "began" == event.phase then
		
		if gameState == "ready" then
			startGame()
		elseif gameState == "game" then
			pipeCrush()
		end
		
	end
end

local function newBloodSplash()
	local bloodSplash = display.newGroup()
	bloodSplash.anchorChildren = true
	bloodSplash.anchorX = 1
	
	local frameData = { width = 512, height = 256, numFrames = 8 }
	local bloodSheet = graphics.newImageSheet( "images/blood/bloodsplash1.png", frameData )
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
	
	physics.addBody( bird, { density = 1.0, friction = 0.3, bounce = 0.2, radius = 25, filter = birdFilter} )
	bird.isFixedRotation = true
	bird.isBullet = true
	bird.name = "bird"
	bird.soundPlay = 0
	
	function bird:update()
		if self.sprite.frame == 3 then
			self.soundPlay = self.soundPlay + 1
			if self.soundPlay == 15 then
				sounds.birdFlap()
				self.soundPlay = 0
			end
			
		end
		local vX, vY = self:getLinearVelocity()
		if self.y > display.contentCenterY then
			if vY > - 200 then
				self:applyForce(0, -100, 0, 0)
			end
		end
		
		if vX < 160 + self.value * 100 then
			self:applyForce(50 + self.value * 30, 0, 0, 0)
		end
		
		bird.rotation = angleOfPoint({x = vX, y = vY})
	end
	
	table.insert(birdArray, bird)
	birdsSpawned = birdsSpawned + 1
	
	return bird
end

local function newBloodParticle()
	local bloodParticle = display.newRect(0, 0, 10, 10)
	bloodParticle:setFillColor(1,0,0)
	physics.addBody( bloodParticle, { density = 1.0, friction = 1, bounce = 0, radius = 10, filter = bloodFilter} )
	bloodParticle.name = "bloodParticle"
	table.insert(bloodParticleArray, bloodParticle)
	return bloodParticle
end

local function destroyBird(bird)
	bird.remove = true
	local leftBloodSplash = newBloodSplash()
	leftBloodSplash.x = topPipeGroup.x
	leftBloodSplash.y = display.contentCenterY
	objectGroup:insert(leftBloodSplash)

	local rightBloodSplash = newBloodSplash()
	rightBloodSplash.x = bottomPipeGroup.x
	rightBloodSplash.y = display.contentCenterY
	rightBloodSplash.xScale = -1
	objectGroup:insert(rightBloodSplash)
	birdsCrushed = birdsCrushed + 1
	
	for int = 1, 3 do
		local bloodParticle = newBloodParticle()
		bloodParticle.x = bottomPipeGroup.x
		bloodParticle.y = display.contentCenterY
		objectGroup:insert(bloodParticle)
		
		bloodParticle:applyLinearImpulse(math.random(-10,10)*0.4, (-1 + (math.random(1,2))) * 0.4, 0, 0)
	end
	
	score = score + bird.value
	scoreText.text = score
end

local function newBloodStain(index)
	local bloodStain = display.newImage("images/blood/floorstain"..index..".png")
	bloodStain.anchorY = 0
	
	protector.to(bloodStain,{delay = 2000 + (math.random(1,200)), time = 500, alpha = 0, transition = easing.outQuad, onComplete = function()
		display.remove(bloodStain)
		bloodStain = nil
	end})
	bloodStain.xScale = 0.5
	bloodStain.yScale = 0.5
	
	return bloodStain
end

local function checkTubeCollision( tube, object, element1, element2)
	if tube.name == "pipe" then
		if object.name == "bird" then
			object.value = object.value + 1
			object:applyLinearImpulse(-130 + (15 * object.value),0,0,0)
		end
	end
end

local function checkFloorCollision(supposedFloor, object)
	if supposedFloor.name == "floor" then
		if object.name == "bloodParticle" then
			if not object.remove then
				object.remove = true
				local bloodStain = newBloodStain(math.random(1,3))
				bloodStain.x = object.x
				bloodStain.y = supposedFloor.y - supposedFloor.height
				objectGroup:insert(bloodStain)
				sounds.bloodSplat()
			end
		end
	end
end

local function gameOver()
	gameState = "transition"
	physics.pause()
	protector.to(scoreText, {time = 500, alpha = 0, transition = easing.outQuad})
	protector.to(fadeRectangle, {time = 500, alpha = 0.6, transition = easing.outQuad})
	protector.from(gameOverImage, {time = 500, alpha = 0, transition = easing.outQuad, onStart = function()
		gameOverImage.isVisible = true
		
		local medalIndex = math.floor(score / 200)
		if medalIndex > 0 then
			medal.isVisible = true
			if medalIndex > #medalColors then
				medalIndex = #medalColors
			end
			local medalColor = medalColors[medalIndex]
			medal:setFillColor(medalColor.r,medalColor.g,medalColor.b)
		end
		
		local updatedScore = false
		for index = 1, score do
			protector.performWithDelay(20 * index, function()
				endCurrentScore.text = index
				
				if index > highScore then
					if not updatedScore then
						newBestScore.isVisible = true
						local delay = 500
						if score * 20 > 500 then delay = score * 20 end
						protector.performWithDelay(delay, function()
							dbconfig("best", score)
						end)
					end
					endBestScoreText.text = index
				end
			end)
		end
	end, onComplete = function()
		transition.from(endScreenGroup, {time = 500, alpha = 0, transition = easing.outQuad, onStart = function()
			endScreenGroup.isVisible = true
		end})
		transition.to(gameOverImage, {time = 500, y = display.contentCenterY - 200, transition = easing.outQuad, onComplete = function()
			gameState = "end"
		end})
	end})
end

local function retryGame()
	if gameState == "end" then
		gameState = "loading"
		sounds.pop()
		storyboard.gotoScene("scenes.home")
	end
end

local function shareGame()
	local function listener( event )
		log(event)
		if ( "session" == event.type ) then
			print("Entered session")
			if ( "login" == event.phase ) then
				print("Atempt to show dialog")
				facebook.showDialog( "apprequests", { message="I just scored "..score.." on NsheBird! get revenge on those nasty birds!" } )
			end
		elseif ( "dialog" == event.type ) then
			print("Something went wrong: "..event.response )
		end
	end

	facebook.login( "251337851713033", listener )
end

local function stainPipes()
	local topPipeStain = display.newImage("images/blood/pipestain"..math.random(1,3)..".png")
	topPipeStain.anchorY = 0
	topPipeStain.y = -topPipeGroup.height/2
	topPipeStain.yScale = 0.05
	topPipeGroup:insert(topPipeStain)
	
	protector.to(topPipeStain,{time = 400, yScale = 1, transition = easing.outQuad, onComplete = function()
		protector.to(topPipeStain,{time = 400, alpha = 0, transition = easing.outQuad, onComplete = function()
			display.remove(topPipeStain)
			topPipeStain = nil
		end})
	end})
	
	local bottomPipeStain = display.newImage("images/blood/pipestain"..math.random(1,3)..".png")
	bottomPipeStain.anchorY = 0
	bottomPipeStain.y = -topPipeGroup.height/2
	bottomPipeStain.yScale = 0.05
	bottomPipeGroup:insert(bottomPipeStain)
	
	protector.to(bottomPipeStain,{time = 400, yScale = 1, transition = easing.outQuad, onComplete = function()
		protector.to(bottomPipeStain,{time = 400, alpha = 0, transition = easing.outQuad, onComplete = function()
			display.remove(bottomPipeStain)
			bottomPipeStain = nil
		end})
	end})
	
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
	
		topPipeGroup = display.newGroup()
	topPipeGroup.anchorChildren = true
	topPipeGroup.anchorY = 0
	topPipeGroup.x = display.screenOriginX + display.viewableContentWidth - 200
	topPipeGroup.y = display.contentCenterY + topPipeOffsetY
	topPipeGroup.name = "pipe"
	topPipeGroup.rotation = 180
	topPipe = display.newImage("images/elements/pipe.png",true)
	topPipeGroup:insert(topPipe)
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
	objectGroup:insert(bottomPipeGroup)
	
	gameFloor = display.newImage("images/elements/floor.png")
	gameFloor.anchorY = 1
	gameFloor.x = display.contentCenterX
	gameFloor.y = display.screenOriginY + display.viewableContentHeight + 100
	gameFloor.name = "floor"
	objectGroup:insert(gameFloor)
	
	fadeRectangle = display.newRect(display.contentCenterX, display.contentCenterY, display.viewableContentWidth + 4, display.viewableContentHeight + 4)
	fadeRectangle:setFillColor(0, 1)
	hudGroup:insert(fadeRectangle)
	
	scoreText = display.newText("0",0,0,"pixel",60)
	scoreText.x = display.contentCenterX - 40
	scoreText.y = display.screenOriginY + 70
	scoreText.isVisible = false
	hudGroup:insert(scoreText)
	
	logo = display.newImage("images/logo.png", true)
	logo.x = display.contentCenterX
	logo.y = display.contentCenterY - 200
	hudGroup:insert(logo)
	local function logoTransition()
		transition.to( logo, { time=500, y = display.contentCenterY - 180 , transition=easing.inOutQuad } )
		transition.to( logo, { delay=500, time=1000, y = display.contentCenterY - 200, transition=easing.inOutQuad } )
	end
	logoTransition()
	protector.performWithDelay(1500, function()
		logoTransition()
	end, 0)
	
	tapHere1 = display.newImage("images/tap1.png")
	tapHere1.anchorX = 1
	tapHere1.x = display.contentCenterX - 40
	tapHere1.y = display.contentCenterY
	hudGroup:insert(tapHere1)
	
	tapHere2 = display.newImage("images/tap2.png")
	tapHere2.anchorX = 0
	tapHere2.x = display.contentCenterX + 40
	tapHere2.y = display.contentCenterY
	hudGroup:insert(tapHere2)
	
	local function tapTransition()
		transition.to( tapHere1, { time=500, xScale = 1, yScale = 1, transition=easing.inOutQuad } )
		transition.to( tapHere1, { delay=500, time=1000, xScale = 1.1, yScale = 1.1, transition=easing.inOutQuad } )
		
		transition.to( tapHere2, { time=500, xScale = 1, yScale = 1, transition=easing.inOutQuad } )
		transition.to( tapHere2, { delay=500, time=1000, xScale = 1.1, yScale = 1.1, transition=easing.inOutQuad } )
	end
	tapTransition()
	protector.performWithDelay(1500, function()
		tapTransition()
	end, 0)
	
	companyLogo = display.newImage("images/company.png", true)
	companyLogo.anchorX = 0
	companyLogo.anchorY = 1
	companyLogo.x = display.screenOriginX + 10
	companyLogo.y = display.screenOriginY + display.viewableContentHeight - 10
	companyLogo.xScale = 0.2
	companyLogo.yScale = 0.2
	hudGroup:insert(companyLogo)
	
	endScreenGroup = display.newGroup()
	hudGroup:insert(endScreenGroup)
	
	endScreen = display.newImage("images/end/screen.png")
	endScreen.x = display.contentCenterX
	endScreen.y = display.contentCenterY
	endScreenGroup:insert(endScreen)
	
	medal = display.newImage("images/end/medal.png")
	medal.x = display.contentCenterX - 140
	medal.y = display.contentCenterY + 20
	medal.isVisible = false
	endScreenGroup:insert(medal)
	
	endBestScoreText = display.newText("0",0,0,"pixel",60)
	endBestScoreText:setFillColor(1)
	endBestScoreText.anchorX = 1
	endBestScoreText.x = display.contentCenterX + 210
	endBestScoreText.y = display.contentCenterY + 60
	endScreenGroup:insert(endBestScoreText)
	
	newBestScore = display.newImage("images/end/new.png")
	newBestScore.x = display.contentCenterX + 60
	newBestScore.y = display.contentCenterY + 15
	newBestScore.isVisible = false
	endScreenGroup:insert(newBestScore)
	
	endCurrentScore = display.newText("0",0,0,"pixel",60)
	endCurrentScore:setFillColor(1)
	endCurrentScore.anchorX = 1
	endCurrentScore.x = display.contentCenterX + 210
	endCurrentScore.y = display.contentCenterY - 35
	endScreenGroup:insert(endCurrentScore)
	
	endRetry = display.newImage("images/end/retry.png")
	endRetry.x = display.contentCenterX - 120
	endRetry.y = display.contentCenterY + 210
	endScreenGroup:insert(endRetry)
	endRetry:addEventListener("tap", retryGame)
	
	endShare = display.newImage("images/end/share.png")
	endShare.x = display.contentCenterX + 120
	endShare.y = display.contentCenterY + 210
	endScreenGroup:insert(endShare)
	endShare:addEventListener("tap", shareGame)
	
	gameOverImage = display.newImage("images/gameover.png", true)
	gameOverImage.x = display.contentCenterX
	gameOverImage.y = display.contentCenterY
	local gameOverScale = display.viewableContentWidth / 1024
	gameOverImage.xScale = gameOverScale
	gameOverImage.yScale = gameOverScale
	gameOverImage.isVisible = false
	hudGroup:insert(gameOverImage)
	
	testMenuButton:toFront()
	Runtime:addEventListener( "collision", self )
end

function scene:willEnterScene(event)
	physics.start()
	physics.setGravity( 0, 15 )
	physics.setVelocityIterations( 2 )
	physics.setPositionIterations(4)
	gameState = "loading"
	
	highScore = tonumber(dbconfig("best")) or 0
	
	tapHere1.alpha = 1
	tapHere2.alpha = 1
	medal.isVisible = false
	newBestScore.isVisible = false
	scoreText.text = 0
	scoreText.isVisible = false
	scoreText.alpha = 1
	scoreText.y = display.screenOriginY + 70
	endScreenGroup.isVisible = false
	endBestScoreText.text = highScore
	endCurrentScore.text = 0
	medal.isVisible = false
	newBestScore.isVisible = false
	gameOverImage.y = display.contentCenterY
	gameOverImage.isVisible = false
	logo.alpha = 1
	logo.x = display.contentCenterX
	companyLogo.alpha = 1
	companyLogo.x = display.screenOriginX + 10
	protector.to(fadeRectangle, {delay = 100, time = 400, alpha = 0.3, transition = easing.outQuad, onComplete = function()
		gameState = "ready"
	end})
	
	birdArray = {}
	bloodParticleArray = {}
	unlockTaps = 0
	currentFrame = 0
	score = 0
	birdsSpawned = 0
	birdsCrushed = 0
	
	display.remove(background)
	background = nil
	background = display.newImage("images/backgrounds/bg_"..math.random(1,2)..".png",true)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	local backGroundScale = display.viewableContentHeight / 1024
	background.xScale = backGroundScale
	background.yScale = backGroundScale
	backgroundGroup:insert(background)
	
	physics.addBody( topPipeGroup, "kinematic", 
		{ bounce = 2, friction = 0, density = 1, filter = pipeFilter, shape = { -64,-512, 64,-512, 64,512, -64,512 }})
	topPipeGroup.isBullet = true
	
	physics.addBody( bottomPipeGroup, "kinematic", 
		{ bounce = 2, friction = 0, density = 1, filter = pipeFilter, shape = { -64,-512, 64,-512, 64,512, -64,512 }})
	bottomPipeGroup.isBullet = true
		
	physics.addBody( gameFloor, "static", { filter = floorFilter, friction=0.5, bounce=0.3 } )
end

function scene:enterFrame(event)
	if gameState == "game" then
		currentFrame = currentFrame + 1

		if currentFrame % 100 == 0 then
			currentFrame = 0

			local numBirds = 1 + (math.floor(score / 150))
			for index = 1, numBirds do
				protector.performWithDelay(math.random(5,500), function()
					local bird = newBird()
					bird.x = display.screenOriginX - 100
					bird.y = display.contentCenterY + math.random(-400,0)
					objectGroup:insert(bird)
				end)
			end
		end

		for index = #birdArray,1,-1 do
			local bird = birdArray[index]
			if bird.x > display.screenOriginX + display.viewableContentWidth + 100 then
				if bird.y > display.contentCenterY - 200 and bird.y < display.contentCenterY + 100 then
					bird.remove = true
					gameOver()
				end
			end
				
			if bird.remove == true then
				physics.removeBody(bird)
				display.remove(bird)
				table.remove(birdArray, index)
			else
				bird:update()

				if bird.x > topPipeGroup.x - topPipeGroup.width/2 and bird.x < topPipeGroup.x + topPipeGroup.width * 0.1 then
					if topPipeGroup.crushing or bottomPipeGroup.crushing then
						bird.crush = true
					end
				end
			end
		end

		for index = #bloodParticleArray,1,-1 do
			local bloodParticle = bloodParticleArray[index]
			if bloodParticle.y > display.screenOriginY + display.viewableContentHeight + 50 or bloodParticle.remove == true then
				physics.removeBody(bloodParticle)
				display.remove(bloodParticle)
				table.remove(bloodParticleArray, index)
			end
		end

		if crushBirds then
			crushBirds = false
			local birdCrushed = false
			for index = #birdArray,1,-1 do
				local bird = birdArray[index]
				if bird.crush then
					destroyBird(bird)
					stainPipes()
					birdCrushed = true
				end
				if birdCrushed then sounds.birdCrush() end
			end
		end
	end		
end

function scene:collision(event)
	if ( event.phase == "began" ) then
		checkTubeCollision(event.object1, event.object2, event.element1, event.element2)
		checkTubeCollision(event.object2, event.object1, event.element2, event.element1)
		
		checkFloorCollision(event.object1, event.object2)
		checkFloorCollision(event.object2, event.object1)
	end
end

function scene:enterScene( event )
	local group = self.view
	
	music.playTrack(1)
	
	Runtime:addEventListener("enterFrame", self)
	Runtime:addEventListener("touch", sceneTouch)
	storyboard.printMemUsage()
end

function scene:exitScene( event )
	Runtime:removeEventListener ("enterFrame", self)
	Runtime:removeEventListener("tap", sceneTouch)
	
	for index = #bloodParticleArray,1,-1 do
		local bloodParticle = bloodParticleArray[index]
		physics.removeBody(bloodParticle)
		display.remove(bloodParticle)
		table.remove(bloodParticleArray, index)
	end
	
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
