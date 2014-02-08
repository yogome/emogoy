local dbconfig = require ( "vendor.dbconfig.dbconfig" )

local sounds = {}

-- Variables
local soundEnabled = "1"

local pop
local coins
local shine
local cheers
local drag
local stars
local jackpot
local run
local breakSound
local victory
local defeat

local monsterLike
local monsterDislike
local monsterEat
local monsterNames

local explosion
local gemtap
local basket

local burp

-- dynamic sounds
local go
local ready
local language = "en"

-- Constants
local currentChannel = 1

-- Functions
function sounds.setEnabled( value )
	soundEnabled = value
end

function sounds.updateLanguage()
	language = dbconfig("language") or "en"
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
	pop = audio.loadSound("sounds/pop.mp3")
	coins = audio.loadSound("sounds/coins.mp3")
	shine = audio.loadSound("sounds/shine.mp3")
	cheers = audio.loadSound("sounds/cheers.mp3")
	drag = audio.loadSound("sounds/drag.mp3")
	stars = audio.loadSound("sounds/stars.mp3")
	
	jackpot = audio.loadSound("sounds/jackpot.mp3")
	run = audio.loadSound("sounds/run.mp3")
	breakSound = audio.loadSound("sounds/breakSound.mp3")
	victory = audio.loadSound("sounds/victory.mp3")
	defeat = audio.loadSound("sounds/defeat.mp3")
	
	monsterLike = audio.loadSound("sounds/monsterlike.mp3")
	monsterEat = audio.loadSound("sounds/monstereat.mp3")
	monsterDislike = audio.loadSound("sounds/monsterlike.mp3")
	monsterNames = {}
	for index = 1, 6 do
		monsterNames[index] = audio.loadSound("sounds/names/m"..index..".mp3")
	end
	
	explosion = audio.loadSound("sounds/explode.mp3")
	gemtap = audio.loadSound("sounds/gemtap.mp3")
	basket = audio.loadSound("sounds/basket.mp3")
	
	burp = audio.loadSound("sounds/burp.mp3")
	
	soundEnabled = dbconfig("sound") or "1"
end

function sounds.ready( )
	if ready ~= nil then
		audio.dispose(ready)
		ready = nil
	end
	ready = audio.loadSound("sounds/ready_"..language..".mp3")
	sounds.playSound(ready)
end

function sounds.go( )
	if go ~= nil then
		audio.dispose(go)
		go = nil
	end
	go = audio.loadSound("sounds/go_"..language..".mp3")
	sounds.playSound(go)
end

function sounds.doorOpen()
	
end
function sounds.doorClose()
	
end

function sounds.pop( )
	sounds.playSound(pop)
end
function sounds.coins( )
	sounds.playSound(coins)
end
function sounds.shine()
	sounds.playSound(shine)
end
function sounds.cheers()
	sounds.playSound(cheers)
end
function sounds.drag()
	sounds.playSound(drag)
end
function sounds.stars()
	sounds.playSound(stars)
end

function sounds.run()
	sounds.playSound(run)
end
function sounds.breakSound()
	sounds.playSound(breakSound)
end
function sounds.victory()
	sounds.playSound(victory)
end
function sounds.defeat()
	sounds.playSound(defeat)
end
function sounds.jackpot()
	sounds.playSound(jackpot)
end

function sounds.comboMessage(index)
	-- TODO play "delicious", "healthy" and others
end
function sounds.explosion()
	sounds.playSound(explosion)
end
function sounds.gemTap()
	sounds.playSound(gemtap)
end
function sounds.basket()
	sounds.playSound(basket)
end

function sounds.monsterEat()
	sounds.playSound(monsterEat)
end
function sounds.monsterLike()
	sounds.playSound(monsterLike)
end
function sounds.monsterDisike()
	sounds.playSound(monsterDislike)
end
function sounds.monsterName(index)
	index = index or 1
	sounds.playSound(monsterNames[index])
end

function sounds.burp()
	sounds.playSound(burp)
end

function sounds.loseStar() -- Plays when user loses a star
	
end
function sounds.warning() -- Plays when monster is about to appear
	
end
function sounds.evilLaugh() -- Played when squirrel laughs
	
end
function sounds.steal() -- Played when bird or squirrel steal gems
	
end

function sounds.machine() -- Played when machine is fed food
	
end

return sounds