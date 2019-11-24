local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PreciseFrame = require(Foundation.PreciseFrame)

local LabeledFieldTemplate = Roact.PureComponent:extend("LabeledFieldTemplate")

LabeledFieldTemplate.defaultProps = {
}

function LabeledFieldTemplate:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local label = props.label
	local Visible = props.Visible
	local enabled = props.enabled ~= false

	return withTheme(
		function(theme)
			local fieldTheme = theme.labeledField
			local fieldHeight = props.height or Constants.INPUT_FIELD_HEIGHT
			local fontSize = Constants.FONT_SIZE_SMALL
			local font = Constants.FONT
			local labelColor = enabled and fieldTheme.textColor.Enabled or fieldTheme.textColor.Disabled
			local spacerHeight = 4

			return Roact.createElement(
				PreciseFrame,
				{
					Size = UDim2.new(1, 0, 0, fontSize+fieldHeight+spacerHeight),
					BackgroundTransparency = 1,
					LayoutOrder = LayoutOrder,
					ZIndex = ZIndex,
					Visible = Visible
				},
				{
					Label = Roact.createElement(
						"TextLabel",
						{
							Size = UDim2.new(1, 0, 0, fontSize),
							BackgroundTransparency = 1,
							TextColor3 = labelColor,
							TextSize = fontSize,
							TextTruncate = Enum.TextTruncate.None,
							Font = font,
							Text = label,
							TextXAlignment = Enum.TextXAlignment.Left,
							Position = UDim2.new(0, 0, 0, 0),
							ZIndex = 2
						}
					),
					FieldContainer = Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, fieldHeight),
							Position = UDim2.new(0, 0, 0, fontSize+spacerHeight),
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
