local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local ThemedTextButton = Roact.PureComponent:extend("ThemedTextButton")

function ThemedTextButton:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)

	self.onStateChanged = function(s)
		self:setState {buttonState = s}
	end
end

ThemedTextButton.defaultProps = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	buttonStyle = "Default",
	TextWrapped = false,
	Font = Constants.FONT,
	TextSize = Constants.FONT_SIZE_MEDIUM,
	modalIndex = 0
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
						{
							Text = Roact.createElement(
								"TextLabel",
								{
									Size = UDim2.new(1, -10, 1, 0),
									Position = UDim2.new(0, 5, 0, 0),
									BackgroundTransparency = 1,
									Text = Text,
									TextColor3 = textColor,
									Font = Font,
									TextSize = TextSize,
									TextXAlignment = TextXAlignment,
									TextYAlignment = TextYAlignment,
									TextWrapped = TextWrapped,
									TextTruncate = Enum.TextTruncate.None
								}
							)
						}
					)
				}
			)
		end
	)
end

return ThemedTextButton
