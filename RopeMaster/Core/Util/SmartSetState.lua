local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local function SmartSetState(component, stateChange)
	local shouldSetState = false
	local currentState = component.state
	for key, newValue in next, stateChange do
		local currentValue = currentState[key]
		if newValue ~= currentValue then
			if currentValue == nil and newValue == Roact.None then
				-- It's already nil...
			else
				shouldSetState = true
				break
			end
		end
	end

	if shouldSetState then
		component:setState(stateChange)
	end
end

return SmartSetState
