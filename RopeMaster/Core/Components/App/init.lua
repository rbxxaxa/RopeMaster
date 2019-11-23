local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getMainManager = ContextGetter.getMainManager

local App = Roact.PureComponent:extend("App")
local RunningPage = require(script.RunningPage)

function App:init(props)
	self.state = {
		pluginWidth = math.max(props.initialWidth or 0, Constants.PLUGIN_MIN_WIDTH)
	}

	self.mainManagerRef = Roact.createRef()

	self.onAbsoluteSizeChange =
		function()
		local pluginWidth = math.max(self.mainManagerRef.current.AbsoluteSize.x, Constants.PLUGIN_MIN_WIDTH)
		if self.state.pluginWidth ~= pluginWidth then
			self:setState(
				{
					pluginWidth = pluginWidth
				}
			)
		end
	end or
		function(rbx)
			local pluginWidth = math.max(rbx.AbsoluteSize.x, Constants.PLUGIN_MIN_WIDTH)
			if self.state.pluginWidth ~= pluginWidth then
				self:setState(
					{
						pluginWidth = pluginWidth
					}
				)
			end
		end
end

function App:didMount()
	if self.mainManagerRef.current then
		self.mainManagerRef.current:GetPropertyChangedSignal("AbsoluteSize"):connect(self.onAbsoluteSizeChange)
	end
end

function App:render()
	return Roact.createElement(RunningPage)
end

function App:didMount()
end

function App:willUnmount()
end

return App
