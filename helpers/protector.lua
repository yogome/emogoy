local protector = {}

function protector.to(target, params)
	if params.onComplete and type(params.onComplete) == "function" then
		local onComplete = params.onComplete
		params.onComplete = function()
			pcall(function()
				onComplete()
			end)
		end
	end
	if params.onStart and type(params.onStart) == "function" then
		local onStart = params.onStart
		params.onStart = function()
			pcall(function()
				onStart()
			end)
		end
	end
	return transition.to(target, params)
end

function protector.from(target, params)
	if params.onComplete and type(params.onComplete) == "function" then
		local onComplete = params.onComplete
		params.onComplete = function()
			pcall(function()
				onComplete()
			end)
		end
	end
	if params.onStart and type(params.onStart) == "function" then
		local onStart = params.onStart
		params.onStart = function()
			pcall(function()
				onStart()
			end)
		end
	end
	return transition.from(target, params)
end

function protector.performWithDelay(delay, listener, iterations)
	return timer.performWithDelay(delay, function()
		pcall(function()
			listener()
		end)
	end, iterations)
end

return protector

