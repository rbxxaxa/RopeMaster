local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local AutoHeightText = require(Foundation.AutoHeightText)

local AutoHeightThemedText = Roact.PureComponent:extend("AutoHeightThemedText")

AutoHeightThemedText.defaultProps = {
	width = UDim.new(1, 0),
	Text = "",
	Font = Constants.FONT,
	TextSize = Constants.FONT_SIZE_MEDIUM,
	textStyle = "Default",
	PaddingTopPixel = 0,
	PaddingBottonPixel = 0,
	PaddingRightPixel = 0,
	PaddingLeftPixel = 0
}

-- Children must have a zero Y-Scale size.
function AutoHeightThemedText:render()
	local props = self.props
	local width = props.width
	local Text = props.Text
	local Position = props.Position
	local Font = props.Font
	local TextSize = props.TextSize
	local TextXAlignment = props.TextXAlignment
	local textStyle = props.textStyle
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local PaddingTopPixel = props.PaddingTopPixel
	local PaddingBottomPixel = props.PaddingBottomPixel
	local PaddingLeftPixel = props.PaddingLeftPixel
	local PaddingRightPixel = props.PaddingRightPixel
	local AnchorPoint = props.AnchorPoint

	return withTheme(
		function(theme)
			local TextColor3 =
				textStyle == "Warning" and theme.warningTextColor or textStyle == "Positive" and theme.positiveTextColor or
				theme.mainTextColor
			return Roact.createElement(
				AutoHeightText,
				{
					width = width,
					Text = Text,
					Position = Position,
					Font = Font,
					TextSize = TextSize,
					TextXAlignment = TextXAlignment,
					TextColor3 = TextColor3,
					LayoutOrder = LayoutOrder,
					ZIndex = ZIndex,
					PaddingTopPixel = PaddingTopPixel,
					PaddingBottomPixel = PaddingBottomPixel,
					PaddingLeftPixel = PaddingLeftPixel,
					PaddingRightPixel = PaddingRightPixel,
					AnchorPoint = AnchorPoint
				}
			)
		end
	)
end

return AutoHeightThemedText
