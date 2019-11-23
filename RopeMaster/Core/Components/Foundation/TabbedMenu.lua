local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local TabBar = require(Foundation._TabBar)

local TabbedMenu = Roact.PureComponent:extend("TabbedMenu")

function TabbedMenu:render()
	return withTheme(
		function(theme)
			local props = self.props
			local tabs = props.tabs
			local activeId = props.activeId
			local onTabClick = props.onTabClick
			local Size = props.Size or UDim2.new(1, 0, 1, 0)

			local tabberTheme = theme.tabber
			local tabHeight = Constants.TAB_HEIGHT
			local backgroundColor = tabberTheme.content.backgroundColor

			return withTheme(
				function(theme)
					return Roact.createElement(
						"Frame",
						{
							Size = Size,
							BackgroundTransparency = 1
						},
						{
							TabBar = Roact.createElement(
								TabBar,
								{
									tabs = tabs,
									activeId = activeId,
									onTabClick = onTabClick
								}
							),
							TabBody = Roact.createElement(
								"Frame",
								{
									Size = UDim2.new(1, 0, 1, -tabHeight),
									Position = UDim2.new(0, 0, 0, tabHeight),
									BackgroundColor3 = backgroundColor,
									BorderSizePixel = 0
								},
								{
									Body = Roact.createElement(
										"Frame",
										{
											Size = UDim2.new(1, 0, 1, 0),
											BackgroundTransparency = 1
										},
										props[Roact.Children]
									)
								}
							)
						}
					)
				end
			)
		end
	)
end

return TabbedMenu
