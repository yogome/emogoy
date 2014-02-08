local protector = require( "helpers.protector" )

local gyroBG = {}

function gyroBG.new(imagePath, backgroundSize)
	assert(imagePath and backgroundSize, "Image path and background size must not be nil")
	local background = display.newGroup()
	
	background.gyroTransitions = {}
	
	background.backgrounds = {}
    local backGroundScale = display.actualContentWidth / backgroundSize
	
	local notFound = false
	local index = 0
	repeat
		index = index + 1
		local internalBG = display.newImageRect( imagePath..index..".png",backgroundSize,backgroundSize)
		if internalBG then
			internalBG.x = display.contentCenterX
			internalBG.y = display.contentCenterY
			internalBG.xScale = backGroundScale
			internalBG.yScale = backGroundScale
			background:insert(internalBG)
			background.backgrounds[index] = internalBG
		else
			notFound = true
		end
	until notFound
	
	function background.gyroscope(self, event)
		for transitionIndex = 1, #background.gyroTransitions do
			transition.cancel(self.gyroTransitions[transitionIndex])
		end
		
		self.gyroTransitions = {}
		
		local minRotationX = -40
		local maxRotationX = 40

		for backgroundIndex = 1, #self.backgrounds do
			local background = self.backgrounds[backgroundIndex]

			if not background.gyroX then
				background.gyroX = 0
			else
				background.gyroX = background.gyroX + event.xRotation * 4
				if background.gyroX > maxRotationX then background.gyroX = maxRotationX end
				if background.gyroX < minRotationX then background.gyroX = minRotationX end
			end

			self.gyroTransitions[1 + (#self.backgrounds*(backgroundIndex-1))] = protector.to(background.path, {transition = easing.inOutQuad, time = 50, y1 = -background.gyroX * (#self.backgrounds - backgroundIndex + 1)})
			self.gyroTransitions[2 + (#self.backgrounds*(backgroundIndex-1))] = protector.to(background.path, {transition = easing.inOutQuad, time = 50, y2 = background.gyroX * (#self.backgrounds - backgroundIndex + 1)})
			self.gyroTransitions[3 + (#self.backgrounds*(backgroundIndex-1))] = protector.to(background.path, {transition = easing.inOutQuad, time = 50, y3 = -background.gyroX * (#self.backgrounds - backgroundIndex + 1)})
			self.gyroTransitions[4 + (#self.backgrounds*(backgroundIndex-1))] = protector.to(background.path, {transition = easing.inOutQuad, time = 50, y4 = background.gyroX * (#self.backgrounds - backgroundIndex + 1)})	
		end
	end
	
	return background
end

return gyroBG