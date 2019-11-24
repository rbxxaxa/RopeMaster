local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Utility = require(Plugin.Core.Util.Utility)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation

local TabbedMenu = Roact.PureComponent:extend("TabbedMenu")

local TabBar do
	local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)
	local BorderedFrame = require(Foundation.BorderedFrame)

	local TabButton = Roact.PureComponent:extend("TabButton")

	function TabButton:init()
		self:setState {
			buttonState = "Default"
		}

		self.onStateChanged = function(s)
			self:setState {buttonState = s}
		end
	end

	TabButton.defaultProps = {
		modalIndex = 0
	}

	function TabButton:render()
		local props = self.props
		local text = props.text
		local isActive = props.active
		local onClick = props.onClick
		local LayoutOrder = props.LayoutOrder
		local image = props.image
		local Size = props.Size
		local Position = props.Position

		return withTheme(
			function(theme)
				local fontSize = Constants.FONT_SIZE_LARGE
				local font = isActive and Constants.FONT_BOLD or Constants.FONT

				local buttonTheme = theme.tabber.tabButton

				local bgColor
				local buttonState = self.state.buttonState
				if isActive then
					bgColor = buttonTheme.backgroundColor.Selected
				elseif buttonState == "Hovered" or buttonState == "PressedInside" then
					bgColor = buttonTheme.backgroundColor.Hover
				else
					bgColor = buttonTheme.backgroundColor.Default
				end

				local textColor
				if isActive then
					textColor = buttonTheme.textColor.Selected
				else
					textColor = buttonTheme.textColor.Default
				end

				local underlineColor = buttonTheme.underlineColor

				return Roact.createElement(
					StatefulButtonDetector,
					{
						Size = Size,
						Position = Position,
						onClick = onClick,
						onStateChanged = self.onStateChanged,
						LayoutOrder = LayoutOrder,
						modalIndex = self.props.modalIndex
					},
					{
						OuterFrame = Roact.createElement(
							BorderedFrame,
							{
								Size = UDim2.new(1, 0, 1, -1),
								BackgroundColor3 = bgColor,
								BorderColor3 = underlineColor,
								BorderThicknessTop = 0,
								BorderThicknessBottom = isActive and 3 or 0,
								BorderThicknessLeft = 0,
								BorderThicknessRight = 0
							},
							{
								Wrap = Roact.createElement(
									"Frame",
									{
										BackgroundTransparency = 1,
										Size = UDim2.new(1, 0, 1, -3)
									},
									{
										H = Roact.createElement(
											"UIListLayout",
											{
												SortOrder = Enum.SortOrder.LayoutOrder,
												FillDirection = Enum.FillDirection.Horizontal,
												VerticalAlignment = Enum.VerticalAlignment.Center,
												HorizontalAlignment = Enum.HorizontalAlignment.Center,
												Padding = UDim.new(0, 4)
											}
										),
										Icon = Roact.createElement(
											"ImageLabel",
											{
												BackgroundTransparency = 1,
												Image = image,
												AnchorPoint = Vector2.new(0.5, 0),
												Size = Constants.TAB_ICON_SIZE,
												ImageColor3 = textColor,
												LayoutOrder = 1
											}
										),
										Text = Roact.createElement(
											"TextLabel",
											{
												Text = text,
												BackgroundTransparency = 1,
												TextColor3 = textColor,
												Font = font,
												TextSize = fontSize,
												Size = UDim2.new(0, Utility.GetTextSize(text, fontSize, font, Vector2.new(9999, 9999)).X, 0, fontSize),
												AnchorPoint = Vector2.new(0, 1),
												TextXAlignment = Enum.TextXAlignment.Center,
												LayoutOrder = 2
											}
										)
									}
								)
								--							Overlay = Roact.createElement(
								--								"Frame",
								--								{
								--									BackgroundTransparency = 1,
								--									Size = UDim2.new(1, 0, 1, 0),
								--									ZIndex = 2
								--								},
								--								overlay
								--							)
							}
						)
					}
				)
			end
		)
	end

	TabBar = Roact.PureComponent:extend("TabBar")

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
end

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
