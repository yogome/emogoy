local dbconfig = require ( "vendor.dbconfig.dbconfig" )

local sounds = {}

-- Variables
local soundEnabled = "1"

local pipeStart 
local pipeEnd 
local birdFlap
local birdCrush 
local bloodSplat
local birdBump
local pop
local bounce

-- Constants
local currentChannel = 1

-- Functions
function sounds.setEnabled( value )
	soundEnabled = value
end

function sounds.stopAll()
	for channel = 1, 30 do
		audio.stop(channel)
	end
end

-- Sounds will be played on channels 1 to 16
function sounds.playSound( sound )
	if soundEnabled == "1" then	
		audio.play(sound, { channel = currentChannel})
		currentChannel = currentChannel + 1
		if currentChannel > 30 then
			currentChannel = 1
		end
	end
end

function sounds.initialize() -- Frequently used audio has to be loaded here.
	pipeStart = audio.loadSound("sounds/pipestart.mp3")
	pipeEnd = audio.loadSound("sounds/pipeend.mp3")
	birdFlap = audio.loadSound("sounds/birdflap.mp3")
	birdCrush = audio.loadSound("sounds/bonecrushing.mp3")
	bloodSplat = audio.loadSound("sounds/bloodsplat.mp3")
	birdBump = audio.loadSound("sounds/pop.mp3")
	pop = audio.loadSound("sounds/pop.mp3")
	bounce = audio.loadSound("sounds/bounce.mp3")
	
	soundEnabled = dbconfig("sound") or "1"
end

function sounds.pipeStart( )
	sounds.playSound(pipeStart)
end
function sounds.pipeEnd( )
	sounds.playSound(pipeEnd)
end
function sounds.birdFlap( )
	sounds.playSound(birdFlap)
end
function sounds.birdCrush( )
	sounds.playSound(birdCrush)
end
function sounds.bloodSplat( )
	sounds.playSound(bloodSplat)
end
function sounds.birdBump( )
	sounds.playSound(birdBump)
end
function sounds.pop( )
	sounds.playSound(pop)
end
function sounds.bounce()
	sounds.playSound(bounce)
end

return sounds