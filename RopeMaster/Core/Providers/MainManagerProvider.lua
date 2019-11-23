local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Keys = require(Plugin.Core.Util.Keys)

local MainManagerProvider = Roact.Component:extend("MainManagerProvider")

function MainManagerProvider:init()
	self._context[Keys.mainManager] = self.props.mainManager
end

function MainManagerProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

function MainManagerProvider:willUnmount()
	local mainManager = self._context[Keys.mainManager]
	if mainManager then
		mainManager:destroy()
	end
end

return MainManagerProvider
