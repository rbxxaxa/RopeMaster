local Plugin = script.Parent.Parent.Parent
local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local NONE = Roact.None
local AUTO = {}
local function specialize(name, component, defaultProps, propMap)
	local specialized = Roact.PureComponent:extend(name)

	for from, to in next, propMap do
		if to == AUTO then
			propMap[from] = from
		end
	end

	local function dup()
		local t = {}
		for k, v in next, defaultProps do
			rawset(t, k, v)
		end

		return t
	end

	function specialized:render()
		local propsToPass = dup()
		local props = self.props
		for from, to in next, propMap do
			local v = props[from]
			if v ~= nil then
				propsToPass[to] = v ~= NONE and v or v == NONE and nil
			end
		end

		return Roact.createElement(component, propsToPass)
	end

	function specialized:shouldUpdate(nextProps, nextState)
		local props = self.props
		for k, _ in next, nextProps do
			if props[k] ~= nextProps[k] then
				return true
			end
		end

		return false
	end

	return specialized
end

return {
	auto = AUTO,
	specialize = specialize
}
