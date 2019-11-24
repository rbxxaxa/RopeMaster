local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Utility = require(Plugin.Core.Util.Utility)
local GetTextSize = Utility.GetTextSize

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local ThemedButton = require(Foundation.ThemedButton)

local ThemedTextButton = Roact.PureComponent:extend("ThemedTextButton")

ThemedTextButton.defaultProps = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	buttonStyle = "Default",
	TextWrapped = false,
	Font = Constants.FONT,
	TextSize = Constants.FONT_SIZE_MEDIUM,
	modalIndex = 0,
	iconStyle = "Top",
	disabled = false
}

function ThemedTextButton:render()
	local props = self.props
	local Position = props.Position
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size
	local onClick = props.onClick
	local Text = props.Text
	local LayoutOrder = props.LayoutOrder
	local buttonStyle = props.buttonStyle
	local TextWrapped = props.TextWrapped
	local TextXAlignment = props.TextXAlignment
	local TextYAlignment = props.TextYAlignment
	local disabled = props.disabled
	local Font = props.Font
	local TextSize = props.TextSize
	local ZIndex = props.ZIndex
	local selected = props.selected
	local modalIndex = props.modalIndex
	local icon = props.icon
	local iconStyle = props.iconStyle

	return withTheme(
		function(theme)
			local buttonTheme = theme.button
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
				local textWidth = GetTextSize(Text, TextSize, Font, Vector2.new(9999, 9999)).X
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
				ThemedButton,
				{
					Size = Size,
					Position = Position,
					AnchorPoint = AnchorPoint,
					LayoutOrder = LayoutOrder,
					ZIndex = ZIndex,
					selected = selected,
					modalIndex = modalIndex,
					onClick = onClick,
					disabled = false
				},
				buttonChildren
			)
		end
	)
end

return ThemedTextButton