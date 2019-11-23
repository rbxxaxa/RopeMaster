local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getMainManager = ContextGetter.getMainManager

local MainManagerConsumer = Roact.PureComponent:extend("MainManagerConsumer")

function MainManagerConsumer:init()
	local mainManager = getMainManager(self)

	self:setState {}

	self.mainManager = mainManager
end

function MainManagerConsumer:render()
	return self.props.render(self.mainManager)
end

function MainManagerConsumer:didMount()
	self.disconnectModalListener =
		self.mainManager:subscribe(
		function()
			self:setState {}
		end
	)
end

function MainManagerConsumer:willUnmount()
	self.disconnectModalListener()
end

return MainManagerConsumer
