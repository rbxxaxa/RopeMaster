local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

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

return TabButton
