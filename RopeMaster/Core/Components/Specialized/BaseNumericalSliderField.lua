local Plugin = script.Parent.Parent.Parent.Parent

local spec = require(Plugin.Core.Util.specialize)

local Foundation = Plugin.Core.Components.Foundation
local NumericalSliderField = require(Foundation.NumericalSliderField)

local BaseNumericalSliderField =
	spec.specialize(
	"BaseNumericalSliderField",
	NumericalSliderField,
	{
		indentLevel = 0,
		labelWidth = 120,
		Visible = true
	},
	{
		label = spec.auto,
		LayoutOrder = spec.auto,
		textboxWidthPixel = spec.auto,
		minValue = spec.auto,
		maxValue = spec.auto,
		valueIsIntegral = spec.auto,
		valueRound = spec.auto,
		valueSnap = spec.auto,
		value = spec.auto,
		onValueChanged = spec.auto,
		decimalPlacesToShow = spec.auto,
		maxCharacters = spec.auto,
		trucateTrailingZeroes = spec.auto
	}
)

return BaseNumericalSliderField
