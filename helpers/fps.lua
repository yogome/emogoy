-------------------------- FPS, frame and memory counter
local fps = {prevTime = 0, maxSavedFps = 30, lastFps = {}, lastFpsCounter = 1}

local function minElement(table)
	local min = 10000;
	for i = 1, #table do
		if(table[i] < min) then min = table[i]; end
	end
	return min;
end

function fps:enterFrame(event)
	local curTime = system.getTimer()
	local dt = curTime - self.prevTime
	self.prevTime = curTime

	local fps = math.floor(1000/dt)

	self.lastFps[self.lastFpsCounter] = fps
	self.lastFpsCounter = self.lastFpsCounter + 1
	if self.lastFpsCounter > self.maxSavedFps then
		self.lastFpsCounter = 1
	end
	local minLastFps = minElement(self.lastFps)
	
	self.framerate.text = "FPS: "..fps.."(min: "..minLastFps..")"
	self.memory.text = "Mem: "..(system.getInfo("textureMemoryUsed")/1000000).." mb"
end

function fps:createInstance()
	self.group = display.newGroup();

	self.memory = display.newText("0/10", 0, -10, native.systemFont, 15);
	self.framerate = display.newText("0", 0, 10, native.systemFont, 20);
	local background = display.newRect(0,0, 175, 50);
	background:setFillColor(0,0,0);

	self.memory:setFillColor(1,1,1);
	self.framerate:setFillColor(1,1,1);

	self.group:insert(background);
	self.group:insert(self.memory);
	self.group:insert(self.framerate);
end

function fps:new()
	if self.group == nil then 
		self:createInstance()
		Runtime:addEventListener("enterFrame", self);
	end
	
	return self.group
end

return fps
