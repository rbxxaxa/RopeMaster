local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ModalProvider = require(Plugin.Core.Providers.ModalProvider)
local PluginProvider = require(Plugin.Core.Providers.PluginProvider)
local ThemeProvider = require(Plugin.Core.Providers.ThemeProvider)
local MainManagerProvider = require(Plugin.Core.Providers.MainManagerProvider)

local ExternalServicesWrapper = Roact.PureComponent:extend("ExternalServicesWrapper")

function ExternalServicesWrapper:shouldUpdate()
	return false
end

function ExternalServicesWrapper:render()
	local props = self.props
	local plugin = props.plugin
	local pluginGui = props.pluginGui
	local mainManager = props.mainManager
	local theme = props.theme

	return Roact.createElement(
		PluginProvider,
		{
			plugin = plugin,
			pluginGui = pluginGui
		},
		{
			Roact.createElement(
				ThemeProvider,
				{
					theme = theme
				},
				{
					Roact.createElement(
						MainManagerProvider,
						{
							mainManager = mainManager
						},
						{
							Roact.createElement(ModalProvider, {}, props[Roact.Children])
						}
					)
				}
			)
		}
	)
end

return ExternalServicesWrapper
