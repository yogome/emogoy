------------------------- ui (UI elements, transition doors, buttons)
local sounds = require( "sounds" )
local storyboard = require( "storyboard" )
local widget = require( "widget" )

local ui = {
	buttonRetry = {normal = "images/buttons/play_1.png", pressed = "images/buttons/play_2.png", tapSound = sounds.pop, toggle = false,},
	buttonFacebook = {normal = "images/buttons/back_1.png", pressed = "images/buttons/back_2.png", tapSound = sounds.pop, toggle = false,},
}

------------------------ Functions
function ui.newButton(buttonData, presslock)
	local button = display.newGroup()
    button.buttonData = buttonData
	
	if buttonData.preloaded == true then
		button.normal = buttonData.normal
		button.normal.x = 0
		button.normal.y = 0
		button:insert(button.normal)

		button.pressed = buttonData.pressed
		button.pressed.x = 0
		button.pressed.y = 0
		button.pressed.isVisible = false
		button:insert(button.pressed)
	else
		button.normal = display.newImage(buttonData.normal)
		button.normal.x = 0
		button.normal.y = 0
		button:insert(button.normal)

		button.pressed = display.newImage(buttonData.pressed)
		button.pressed.x = 0
		button.pressed.y = 0
		button.pressed.isVisible = false
		button:insert(button.pressed)
	end
	
	function button:addButtonListener(phase, listener)
		if phase == "pressed" then
			self.pressedListener = listener
        elseif phase == "hold" then
            self.holdListener = listener
		elseif phase == "released" then
			self.releaseListener = listener
		end
	end
	
	button.toggleState = false -- Not pressed
	button.pressLockState = false
	button.pressLock = presslock
    
    button.holdDelay = 20
    button.holdCounter = 0
	
	function button:resetLock()
		self.pressLockState = false
	end
    
    function button:lock()
		self.pressLockState = true
	end
	
	function button:touch(event)
		if button.pressLockState ~= true then
			if event.phase == "began" then
                button.holdCounter = 0
				display.getCurrentStage():setFocus( button )
				button.isFocus = true
				
				if buttonData.toggle == false then
					self.pressed.isVisible = true
					self.normal.isVisible = false
					button.toggleState = true
				end
				if button.pressedListener ~= nil then
					button.pressedListener(event)
				end

            elseif button.isFocus then

                if button.holdListener ~= nil then
                    button.holdCounter = button.holdCounter + 1
                    if event.phase ~= "ended" or event.phase ~= "cancelled" then
                        if button.holdCounter > button.holdDelay then
                            button.holdListener()
                        end
                    end
                end
                
				if event.phase == "moved" then
					local bounds = button.stageBounds
					local x,y = event.x,event.y
					local isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
					if isWithinBounds ~= true then
						display.getCurrentStage():setFocus( nil )
						button.isFocus = nil
						if buttonData.toggle == false then
							self.pressed.isVisible = false
							self.normal.isVisible = true
							button.toggleState = false
						end
					end
                elseif event.phase == "ended" or event.phase == "cancelled" then
                    button.holdCounter = 0
					display.getCurrentStage():setFocus( nil )
					button.isFocus = nil
					if buttonData.toggle == false then
						self.pressed.isVisible = false
						self.normal.isVisible = true
						button.toggleState = false
					else
						if button.toggleState == true then
							self.pressed.isVisible = false
							self.normal.isVisible = true
							button.toggleState = false
						else
							self.pressed.isVisible = true
							self.normal.isVisible = false
							button.toggleState = true
						end
					end
					
					if button.releaseListener ~= nil then
						if button.pressLockState ~= true then
							button.releaseListener(event)
							buttonData.tapSound()
						end
						
						if button.pressLock == true then
							button.pressLockState = true
						end
					end
				end
			end
		end
		return true
	end
	button:addEventListener("touch", button)
	return button
end

function ui.newNumber(number, margin)
	margin = margin or -16
	assert(type(number) == "number", "Parameter must be a number.")
	
	local numberGroup = display.newGroup()
	numberGroup.numberArray = { }
	
	local numberString = ""..number
	local totalWidth = 0

	numberGroup.number = number 
	
	---------------------- Create digit images
	for index = 1, #numberString do
		local digit = numberString:sub(index,index)
		
		local digitImage = display.newImage( "images/numbers/number_"..digit..".png",true )
		digitImage.anchorX = 0
        digitImage.y = 0
		digitImage.digit = digit
		
		if index < #numberString then
			totalWidth = totalWidth + margin
		end
		
		numberGroup.numberArray[#numberGroup.numberArray + 1] = digitImage
	end
	
	local currentX = -totalWidth/2
	
	for index = 1, #numberGroup.numberArray do
		local digitImage = numberGroup.numberArray[index]
		numberGroup:insert(digitImage)
		numberGroup.numberImage = digitImage
		digitImage.x = currentX
		
		currentX = currentX + digitImage.width + margin
	end
	
	numberGroup.anchorChildren = true
	numberGroup.anchorX = 0.5
	numberGroup.anchorY = 0.5
	return numberGroup
end

return ui