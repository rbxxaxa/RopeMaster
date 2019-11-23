local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local DockWidget = require(Foundation.DockWidget)
local ExternalServicesWrapper = require(Components.ExternalServicesWrapper)
local App = require(Components.App)

local MainPlugin = Roact.PureComponent:extend("MainPlugin")

function MainPlugin:init(props)
	self.plugin = props.plugin
	if not self.plugin then
		error("MainPlugin component requires plugin to be passed as prop")
	end

	self.state = {
		enabled = true,
		-- Put the plugin gui in the state so that once its loaded, we
		-- trigger a rerender
		pluginGui = nil,
		pluginTitle = "RopeMaster"
	}

	self.toolbar = self.plugin:CreateToolbar("RopeMaster")
	self.pluginToolbarButton = self.toolbar:CreateButton("RopeMaster", "Open the RopeMaster widget.", Constants.TOOLBAR_ICON)

	self.pluginToolbarButton:SetActive(self.state.enabled)

	self.pluginToolbarButton.Click:connect(
		function()
			self:setState(
				function(state)
					return {
						enabled = not state.enabled
					}
				end
			)
		end
	)

	self.onDockWidgetEnabledChanged = function(rbx)
		if self.state.enabled == rbx.Enabled then
			return
		end

		self:setState(
			{
				enabled = rbx.Enabled
			}
		)
	end

	self.onAncestryChanged = function(rbx, child, parent)
		if not parent and self.props.onPluginWillDestroy then
			self.props.onPluginWillDestroy()
		end
	end

	self.dockWidgetRefFunc = function(ref)
		self.dockWidget = ref
	end
end

function MainPlugin:didMount()
	self.onDockWidgetEnabledChanged(self.dockWidget)

	-- Now we have the dock widget, trigger a rerender
	self:setState(
		{
			pluginGui = self.dockWidget
		}
	)
end

function MainPlugin:willUnmount()
end

function MainPlugin:didUpdate()
	self.pluginToolbarButton:SetActive(self.state.enabled)
end

function MainPlugin:render()
	local enabled = self.state.enabled

	local plugin = self.props.plugin
	local pluginGui = self.state.pluginGui
	local theme = self.props.theme
	local mainManager = self.props.mainManager

	local initialWidth = pluginGui and pluginGui.AbsoluteSize.x or Constants.PLUGIN_MIN_WIDTH

	local pluginGuiLoaded = pluginGui ~= nil

	return Roact.createElement(
		DockWidget,
		{
			plugin = plugin,
			Title = self.state.pluginTitle,
			Name = self.state.pluginTitle,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			InitialDockState = Enum.InitialDockState.Left,
			InitialEnabled = true,
			InitialEnabledShouldOverrideRestore = false,
			FloatingXSize = 0,
			FloatingYSize = 0,
			MinWidth = Constants.PLUGIN_MIN_WIDTH,
			MinHeight = Constants.PLUGIN_MIN_WIDTH,
			Enabled = enabled,
			[Roact.Ref] = self.dockWidgetRefFunc,
			[Roact.Change.Enabled] = self.onDockWidgetEnabledChanged,
			[Roact.Event.AncestryChanged] = self.onAncestryChanged
		},
		{
			Plugin = pluginGuiLoaded and
				Roact.createElement(
					ExternalServicesWrapper,
					{
						plugin = plugin,
						pluginGui = pluginGui,
						theme = theme,
						mainManager = mainManager
					},
					{
						Roact.createElement(
							App,
							{
								initialWidth = initialWidth
							}
						)
					}
				)
		}
	)
end

return MainPlugin
