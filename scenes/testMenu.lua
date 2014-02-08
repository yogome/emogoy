------------------------- Test Menu
local storyboard = require( "storyboard" )
local sounds = require ( "sounds" )
local dbconfig = require ( "vendor.dbconfig.dbconfig" )
local scene = storyboard.newScene()
------------------------- Variables
local performance 
local buttonsEnabled = false
------------------------- Constants
------------------------- Functions
local function goGame()
	storyboard.gotoScene("scenes.home")
end

local function toggleFPS()
	if performance.alpha <= 0 then performance.alpha = 0.7 else performance.alpha = 0 end
end

------------------------- Class functions
function scene:addButton(text, listener, rectColor)
	if text ~= nil and listener ~= nil then
		rectColor = rectColor or {0.1,0.1,0.1}
	
		local group = self.view
		local button = display.newGroup()
		group:insert(button)

		local rectangle = display.newRect(0,0,290,46)
		rectangle.x = 0
		rectangle.y = 0
		button:insert(rectangle)
		rectangle.listener = listener
		rectangle:setFillColor(rectColor[1],rectColor[2],rectColor[3])

		local text = display.newText(text, 0, 0, native.systemFont, 34)
		text.x = 0
		text.y = 0
		button:insert(text)

		rectangle:addEventListener("tap", function()
			if buttonsEnabled == true then
				rectangle.listener()
			end
		end)
		
		button.x = display.screenOriginX + 147 + (292 * self.columnSpaces)
		button.y = display.screenOriginY + 24 + (48 * self.rowSpaces)
		
		self.rowSpaces = self.rowSpaces + 1
	end
end

function scene:skipRow()
	self.rowSpaces = self.rowSpaces + 1
end

function scene:skipColumn()
	self.columnSpaces = self.columnSpaces + 1
	self.rowSpaces = 0
end

function scene:createScene(event)
	self.rowSpaces = 0
	self.columnSpaces = 0
	
	------------------------- Buttons
	
	self:addButton("Go to game", goGame,{0.2,0.2,0.2})
	self:skipColumn()
	
	------------------------- Initialization
	local fps = require("helpers.fps")
	performance = fps:new()
	performance.x = display.screenOriginX + display.viewableContentWidth - 85
	performance.y = display.screenOriginY + display.viewableContentHeight - 25
	performance.alpha = 0;
end

function scene:destroyScene()
	
end

function scene:enterScene(event)
	buttonsEnabled = false
	timer.performWithDelay(400, function()
		buttonsEnabled = true
	end)
	display.setDefault("background", 0, 0, 0)
	storyboard.printMemUsage()
end

function scene:exitScene ( event )

end

scene:addEventListener( 'createScene', scene )
scene:addEventListener( 'destroyScene', scene )
scene:addEventListener( 'exitScene', scene )
scene:addEventListener( "enterScene", scene )

return scene

