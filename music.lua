------------------------------- Music
local dbconfig = require ( "vendor.dbconfig.dbconfig" )

local music = {}

------------------------------- Variables
local musicLocked
local musicEnabled
local currentTrackIndex
local currentMusic
local nextMusic

------------------------------- Constants
local musicChannel = 32
local tracks = {"music/menu-map.mp3",	-- 1
				"music/gameplay.mp3",}	-- 2
------------------------------- Functions
local function initialize()
	if dbconfig.isInit == false then dbconfig.init() end
	musicEnabled = dbconfig("music") or "1"
	dbconfig("music", musicEnabled)
	audio.setVolume(tonumber(musicEnabled), { channel = musicChannel } )
end

function music.setEnabled( value )
	if value == "1" then
		audio.fade({ channel = musicChannel, time = 1000, volume = 1 } )
	else
		audio.fade({ channel = musicChannel, time = 1000, volume = 0 } )
	end
end

function music.fade(fadeTime)
	fadeTime = fadeTime or 50
	if currentMusic ~= nil then
		audio.fade({ channel = musicChannel, time = fadeTime, volume = 0 } )
		timer.performWithDelay(fadeTime + 1, function()
			audio.stop(musicChannel)
			timer.performWithDelay(1, function()
				audio.dispose(currentMusic)
				currentMusic = nil
			end)	
		end)
	end
end

function music.stop()
	if currentMusic ~= nil then
		audio.stop(musicChannel)
		timer.performWithDelay(1, function()
			audio.dispose(currentMusic)
			currentMusic = nil
		end)
	end
end

local function playMusicFade(file, fadeTime)
	if musicLocked ~= true then -- We lock the music so we dont clog the system, until it starts playing.
		musicLocked = true
		nextMusic = audio.loadStream(file)
		audio.fade({ channel = musicChannel, time = fadeTime, volume = 0 } )
		timer.performWithDelay(fadeTime + 1, function()
			if currentMusic ~= nil then
				audio.stop(musicChannel)
				timer.performWithDelay(1, function()
					audio.dispose(currentMusic)
					currentMusic = nil
				end)
			end
			timer.performWithDelay(2, function()
				currentMusic = nextMusic
				audio.play( currentMusic, { channel = musicChannel, loops=-1})
				if musicEnabled == "1" then
					audio.fade({ channel = musicChannel, time = 50, volume = 1 } )
				end
				musicLocked = false
			end)
		end)
	end
end

-- Will play a track, given its number, and an optional fadeTime. If track is already playing command will be igonred
function music.playTrack( trackIndex, fadeTime )
	fadeTime = fadeTime or 1
	if trackIndex > #tracks then
		trackIndex = #tracks
	elseif trackIndex < 0 then
		trackIndex = 1
	end
	if currentMusic ~= nil then
		if trackIndex ~= currentTrackIndex then
			playMusicFade(tracks[trackIndex], fadeTime)
			currentTrackIndex = trackIndex
		end
	else
		playMusicFade(tracks[trackIndex], fadeTime)
		currentTrackIndex = trackIndex
	end
end

initialize()

return music
