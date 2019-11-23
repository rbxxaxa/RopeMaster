local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local SignalHelperComponent = Roact.Component:extend("SignalHelperComponent")

function SignalHelperComponent:init()
	self:setState {
		dProps = self.props.initProps,
		oldInitProps = self.props.initProps
	}
end

function SignalHelperComponent.getDerivedStateFromProps(nextProps, lastState)
	if nextProps.initState ~= lastState.oldInitProps then
		return {
			dProps = nextProps.initProps,
			oldInitProps = nextProps.initProps
		}
	end
end

function SignalHelperComponent:render()
	return self.props.render(self.state.dProps)
end

function SignalHelperComponent:willUnmount()
	if self.disconnect then
		self.disconnect()
	end
end

function SignalHelperComponent:didMount()
	local subscribeCallback = self.props.subscribeCallback
	local getPropsCallback = self.props.getPropsCallback
	self.disconnect =
		subscribeCallback(
		function()
			local oldProps = self.state.dProps
			local newProps = getPropsCallback(oldProps)
			if newProps == nil then
				return
			end

			self:setState {
				dProps = newProps
			}
		end
	)
end

function SignalHelperComponent:didUpdate(previousProps, previousState)
	self.disconnect()

	local subscribeCallback = self.props.subscribeCallback
	local getPropsCallback = self.props.getPropsCallback
	self.disconnect =
		subscribeCallback(
		function()
			local oldProps = self.state.dProps
			local newProps = getPropsCallback(oldProps)
			if newProps == nil then
				return
			end

			self:setState {
				dProps = newProps
			}
		end
	)
end

-- function subscribeCallback(f)
-- Subscribe to a signal, which will only fire when the props may have changed.
-- This function shall return another function that will unsubscribe from said signal.
-- This is only used once in didMount, so changing this will do nothing after the
-- component has been mounted.

-- function getPropsCallback(dProps)
-- This is fired every time the signal is fired. The previous props are passed as the only parameter.
-- If this returns nil, then the component will not be re-rendered.
-- Otherwise, it will return a bunch of props that will be passed to render.
-- Like subscribeCallback, changing this does nothing after the component has been mounted.

-- function render(dProps)
-- A function that renders the component. A table containing the props is passed to the function.

-- table initProps (optional)
-- Optional initial props.
-- If not defined, then the return value of getPropsCallback({}) will be set
-- as the initial props. BUT, if getPropsCallback({}) returns nil, then {} will be the initialProps.

-- ... Yeah this entire thing is probably a huge antipattern, and I'm sorry. It really
-- cuts down on a lot rendering, though.

local SignalHelper = function(subscribeCallback, getPropsCallback, render, initProps)
	return Roact.createElement(
		SignalHelperComponent,
		{
			subscribeCallback = subscribeCallback,
			initProps = initProps or getPropsCallback({}) or {},
			getPropsCallback = getPropsCallback,
			render = render
		}
	)
end

return SignalHelper
