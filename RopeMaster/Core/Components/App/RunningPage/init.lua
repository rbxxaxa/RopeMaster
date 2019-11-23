local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local TabbedMenu = require(Foundation.TabbedMenu)
local Draw = require(script.Draw)
local RunningPage = Roact.PureComponent:extend("RunningPage")

function RunningPage:init()
	self:setState(
		{
			currentTab = "Draw"
		}
	)
end

function RunningPage:render()
	return withTheme(
		function(theme)
			local page =
				Roact.createElement(
				"Frame",
				{
					BackgroundColor3 = theme.mainBackgroundColor,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 1, 0)
				},
				{
					Tabber = Roact.createElement(
						TabbedMenu,
						{
							tabs = {
								{id = "Draw", text = "Draw", image = "rbxassetid://3578089527"}
							},
							activeId = self.state.currentTab,
							onTabClick = function(tabId)
								if self.state.currentTab ~= tabId then
									self:setState {currentTab = tabId}
									getMainManager(self):Deactivate()
								end
							end
						},
						{
							Draw = self.state.currentTab == "Draw" and Roact.createElement(Draw)
						}
					)
				}
			)

			return page
		end
	)
end

return RunningPage
