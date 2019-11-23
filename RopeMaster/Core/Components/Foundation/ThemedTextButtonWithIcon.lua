local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Utility = require(Plugin.Core.Util.Utility)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local ThemedTextButtonWithIcon = Roact.PureComponent:extend("ThemedTextButtonWithIcon")

function ThemedTextButtonWithIcon:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)

	self.onStateChanged = function(s)
		self:setState {buttonState = s}
	end
end

ThemedTextButtonWithIcon.defaultProps = {
	iconStyle = "Top",
	modalIndex = 0
}

function ThemedTextButtonWithIcon:render()
	local props = self.props
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size or UDim2.new(0, 100, 0, 100)
	local onClick = props.onClick
	local Text = props.Text
	local LayoutOrder = props.LayoutOrder
	local buttonStyle = props.buttonStyle or "Default"
	local TextWrapped = props.TextWrapped or false
	local selected = props.selected
	local TextXAlignment = props.TextXAlignment
	local TextYAlignment = props.TextYAlignment
	local disabled = props.disabled
	local Font = props.Font or Constants.FONT
	local TextSize = props.TextSize or Constants.FONT_SIZE_MEDIUM
	local ZIndex = props.ZIndex
	local icon = props.icon
	local iconStyle = props.iconStyle

	return withTheme(
		function(theme)
			local buttonTheme = theme.button

			local boxState
			local buttonState = self.state.buttonState

			if disabled then
				boxState = "Disabled"
			elseif selected then
				local map = {
					Default = "Selected",
					Hovered = "SelectedHovered",
					PressedInside = "SelectedPressedInside",
					PressedOutside = "SelectedPressedOutside"
				}

				boxState = map[buttonState]
			else
				local map = {
					Default = "Default",
					Hovered = "Hovered",
					PressedInside = "PressedInside",
					PressedOutside = "PressedOutside"
				}

				boxState = map[buttonState]
			end

			local borderColor = buttonTheme.box.borderColor[buttonStyle][boxState]
			local backgroundColor = buttonTheme.box.backgroundColor[buttonStyle][boxState]
			local textColor = not disabled and buttonTheme.textColor[buttonStyle] or buttonTheme.textColor.Disabled

			local buttonChildren
			if iconStyle == "Top" then
				buttonChildren = {
					Text = Roact.createElement(
						"TextLabel",
						{
							Size = UDim2.new(1, -10, 0, TextSize),
							Position = UDim2.new(0, 5, 1, -5),
							BackgroundTransparency = 1,
							AnchorPoint = Vector2.new(0, 1),
							Text = Text,
							TextColor3 = textColor,
							Font = Font,
							TextSize = TextSize,
							TextXAlignment = TextXAlignment,
							TextYAlignment = TextYAlignment,
							TextWrapped = TextWrapped,
							TextTruncate = Enum.TextTruncate.None
						}
					),
					Icon = Roact.createElement(
						"ImageLabel",
						{
							Position = UDim2.new(0.5, 0, 0, 5),
							Size = UDim2.new(1, -5 * 3 - TextSize, 1, -5 * 3 - TextSize),
							AnchorPoint = Vector2.new(0.5, 0),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
							Image = icon,
							BackgroundTransparency = 1,
							ImageColor3 = textColor
						}
					)
				}
			elseif iconStyle == "Left" then
				local textWidth = Utility.GetTextSize(Text, TextSize, Font, Vector2.new(9999, 9999)).X
				buttonChildren = {
					-- This wrapping frame is necessary. Otherwise, the frame inside the button will also be layouted.
					Frame = Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1
						},
						{
							Layout = Roact.createElement(
								"UIListLayout",
								{
									SortOrder = Enum.SortOrder.LayoutOrder,
									FillDirection = Enum.FillDirection.Horizontal,
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									VerticalAlignment = Enum.VerticalAlignment.Center,
									Padding = UDim.new(0, 4)
								}
							),
							Icon = Roact.createElement(
								"ImageLabel",
								{
									Position = UDim2.new(0, 0, 0, 0),
									Size = UDim2.new(0, TextSize, 0, TextSize),
									AnchorPoint = Vector2.new(0, 0),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									Image = icon,
									BackgroundTransparency = 1,
									ImageColor3 = textColor,
									LayoutOrder = 1
								}
							),
							Text = Roact.createElement(
								"TextLabel",
								{
									Size = UDim2.new(0, textWidth, 0, TextSize),
									Position = UDim2.new(0, 0, 0, 0),
									BackgroundTransparency = 1,
									AnchorPoint = Vector2.new(0, 0),
									Text = Text,
									TextColor3 = textColor,
									Font = Font,
									TextSize = TextSize,
									TextXAlignment = TextXAlignment,
									TextYAlignment = TextYAlignment,
									TextWrapped = TextWrapped,
									TextTruncate = Enum.TextTruncate.None,
									LayoutOrder = 2
								}
							)
						}
					)
				}
			else
				error("Invalid iconStyle.")
			end
			return Roact.createElement(
				RoundedBorderedFrame,
				{
					Size = Size,
					BackgroundColor3 = backgroundColor,
					BorderColor3 = borderColor,
					Position = Position,
					AnchorPoint = AnchorPoint,
					LayoutOrder = LayoutOrder,
					ZIndex = ZIndex
				},
				{
					Button = Roact.createElement(
						StatefulButtonDetector,
						{
							Size = UDim2.new(1, 0, 1, 0),
							onClick = onClick,
							onStateChanged = self.onStateChanged,
							modalIndex = props.modalIndex
						},
						buttonChildren
					)
				}
			)
		end
	)
end

return ThemedTextButtonWithIcon
