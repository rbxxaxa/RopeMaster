local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local LabeledFieldTemplate = require(Foundation.LabeledFieldTemplate)
local ThemedNumericalSlider = require(Foundation.ThemedNumericalSlider)

local NumericalSliderField = Roact.PureComponent:extend("NumericalSliderField")

function NumericalSliderField:init()
	self:setState {
		focused = false
	}
end

function NumericalSliderField:render()
	local props = self.props
	local label = props.label
	local LayoutOrder = props.LayoutOrder
	local Visible = props.Visible
	local textboxWidthPixel = props.textboxWidthPixel
	local minValue = props.minValue
	local maxValue = props.maxValue
	local valueIsIntegral = props.valueIsIntegral
	local valueRound = props.valueRound
	local valueSnap = props.valueSnap
	local value = props.value or minValue
	local onValueChanged = props.onValueChanged
	local decimalPlacesToShow = props.decimalPlacesToShow
	local maxCharacters = props.maxCharacters
	local trucateTrailingZeroes = props.trucateTrailingZeroes
	local modalIndex = props.modalIndex

	local boxHeight = Constants.INPUT_FIELD_BOX_HEIGHT
	local fontSize = Constants.FONT_SIZE_MEDIUM

	return Roact.createElement(
		LabeledFieldTemplate,
		{
			label = label,
			LayoutOrder = LayoutOrder,
			Visible = Visible,
			forceShowHighlight = self.state.focused
		},
		{
			Slider = Roact.createElement(
				ThemedNumericalSlider,
				{
					Size = UDim2.new(1, 0, 0, boxHeight),
					Position = UDim2.new(0, 0, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					TextSize = fontSize,
					textboxWidthPixel = textboxWidthPixel,
					minValue = minValue,
					maxValue = maxValue,
					valueIsIntegral = valueIsIntegral,
					valueRound = valueRound,
					valueSnap = valueSnap,
					value = value,
					onValueChanged = onValueChanged,
					decimalPlacesToShow = decimalPlacesToShow,
					maxCharacters = maxCharacters,
					trucateTrailingZeroes = trucateTrailingZeroes,
					modalIndex = modalIndex
				}
			)
		}
	)
end

return NumericalSliderField
