local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local TabButton = require(Foundation._TabButton)
local BorderedFrame = require(Foundation.BorderedFrame)

local TabBar = Roact.PureComponent:extend("TabBar")

function TabBar:init()
	self.barRef = Roact.createRef()
	self:setState(
		{
			width = 0
		}
	)
end

function TabBar:render()
	return withTheme(
		function(theme)
			local props = self.props
			local tabs = props.tabs
			local activeId = props.activeId
			local onTabClick = props.onTabClick

			local tabberTheme = theme.tabber
			local backgroundColor = tabberTheme.tabBar.backgroundColor
			local borderColor = tabberTheme.tabBar.borderColor
			local tabHeight = Constants.TAB_HEIGHT

			local tabsChildren = {}

			for idx, entry in next, tabs do
				local tabId, tabText, tabImage, overlay = entry.id, entry.text, entry.image, entry.overlay
				local tabWidth = self.state.width / #tabs
				local tab =
					Roact.createElement(
					TabButton,
					{
						text = tabText,
						active = activeId == tabId,
						onClick = function()
							if onTabClick then
								onTabClick(tabId)
							end
						end,
						LayoutOrder = idx,
						isFirst = idx == 1,
						isLast = idx == #tabs,
						image = tabImage,
						overlay = overlay,
						Size = UDim2.new(0, tabWidth, 0, tabHeight),
						Position = UDim2.new(0, tabWidth * (idx - 1), 0, 0)
					}
				)

				tabsChildren[tabId] = tab
			end

			tabsChildren._shadow =
				Roact.createElement(
				"ImageLabel",
				{
					Size = UDim2.new(1, 0, 0, 2),
					Position = UDim2.new(0, 0, 1, 0),
					Image = "rbxassetid://3005345024",
					BackgroundTransparency = 1,
					ImageTransparency = 0.8,
					ImageColor3 = Color3.new(0, 0, 0)
				}
			)

			return Roact.createElement(
				BorderedFrame,
				{
					Size = UDim2.new(1, 0, 0, tabHeight),
					BackgroundColor3 = backgroundColor,
					BorderColor3 = borderColor,
					BorderThicknessTop = 0,
					BorderThicknessBottom = 1,
					BorderThicknessLeft = 0,
					BorderThicknessRight = 0,
					ZIndex = 2,
					[Roact.Ref] = self.barRef
				},
				tabsChildren
			)
		end
	)
end

function TabBar:didMount()
	local bar = self.barRef.current

	self:setState(
		{
			width = bar.AbsoluteSize.X
		}
	)

	self.resizeConn =
		bar:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			self:setState(
				{
					width = bar.AbsoluteSize.X
				}
			)
		end
	)
end

function TabBar:willUnmount()
	self.resizeConn:Disconnect()
end

return TabBar
