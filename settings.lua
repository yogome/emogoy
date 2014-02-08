local settings = {
	mode = 'production',
	dbPath = 'yogodb.sqlite',
	currentSchemaVersion = 1,
	version = 'v1_00',
	gamename = 'NsheBird',
	bundle = 'com.yogome.NsheBird',
	debugRequests = true,
	debugNetwork = true,
	dev = {
		parse = {
			appid = 'mvtM3YoxmjXbQnsAukUThu2JkUKtoYvCNtJXVtbE',
			rest_key = 'AFtRuyhAVkkDsUGv82vApUGkhsMTJJeZjCxLdWwU',
			idKey = '_id',
			host = 'http://staging.yogome.com/'
		},
	},
	production = {
		parse = {
			appid = 'mvtM3YoxmjXbQnsAukUThu2JkUKtoYvCNtJXVtbE',
			rest_key = 'AFtRuyhAVkkDsUGv82vApUGkhsMTJJeZjCxLdWwU',
			idKey = '_id',
			host = 'http://dashboard.yogome.com/'
		},
	},
}

if settings.mode == 'production' then
	settings.debugRequests = false
	settings.debugNetwork = false
	settings.debugSql = false
	settings.debugAnalytics = false
end

function settings:get (key)
	local pos = key:find('.', 1, true)
	if pos then
		local before = string.sub(key, 1, pos-1)
		local after = string.sub(key, pos+1)
		return self[self.mode][before][after]
	else
		return self[self.mode][key]
	end
end

return settings
