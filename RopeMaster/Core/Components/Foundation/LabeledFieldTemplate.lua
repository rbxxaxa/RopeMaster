local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PreciseFrame = require(Foundation.PreciseFrame)

local LabeledFieldTemplate = Roact.PureComponent:extend("LabeledFieldTemplate")

LabeledFieldTemplate.defaultProps = {
	indentLevel = 0,
	labelWidth = Constants.DEFAULT_LABEL_WIDTH
}

function LabeledFieldTemplate:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local label = props.label
	local indentLevel = props.indentLevel
	local labelWidth = props.labelWidth
	local Visible = props.Visible
	local enabled = props.enabled ~= false

	return withTheme(
		function(theme)
			local fieldTheme = theme.labeledField
			local fieldHeight = props.height or Constants.INPUT_FIELD_HEIGHT
			local perLevelIndent = Constants.INPUT_FIELD_INDENT_PER_LEVEL
			local labelPadding = Constants.INPUT_FIELD_LABEL_PADDING
			local fontSize = Constants.FONT_SIZE_MEDIUM
			local font = Constants.FONT
			local labelColor = enabled and fieldTheme.textColor.Enabled or fieldTheme.textColor.Disabled
			local totalIndent = perLevelIndent * (indentLevel)
			local width = labelWidth - totalIndent
			local finalLabelWidth = width - labelPadding
			local textFits = Utility.GetTextSize(label, fontSize, font, Vector2.new(9999, 9999)).X <= finalLabelWidth

			return Roact.createElement(
				PreciseFrame,
				{
					Size = UDim2.new(1, 0, 0, fieldHeight),
					BackgroundTransparency = 1,
					LayoutOrder = LayoutOrder,
					ZIndex = ZIndex,
					Visible = Visible
				},
				{
					Label = Roact.createElement(
						"TextLabel",
						{
							Size = UDim2.new(0, finalLabelWidth, 0, fieldHeight),
							BackgroundTransparency = 1,
							TextColor3 = labelColor,
							TextSize = fontSize,
							TextTruncate = textFits and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
							Font = font,
							Text = label,
							TextXAlignment = Enum.TextXAlignment.Left,
							Position = UDim2.new(0, totalIndent + labelPadding, 0, 0),
							ZIndex = 2
						}
					),
					FieldContainer = Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -labelWidth, 0, fieldHeight),
							Position = UDim2.new(0, labelWidth, 0, 0),
							ZIndex = 2
						},
						props[Roact.Children]
					)
				}
			)
		end
	)
end

return LabeledFieldTemplate
