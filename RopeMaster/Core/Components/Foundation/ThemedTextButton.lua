local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

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
	local modalIndex = props.modalIndex

	return withTheme(
		function(theme)
			local buttonTheme = theme.button
			local textColor = not disabled and buttonTheme.textColor[buttonStyle] or buttonTheme.textColor.Disabled

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
					disabled = disabled
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
		end
	)
end

return ThemedTextButton
