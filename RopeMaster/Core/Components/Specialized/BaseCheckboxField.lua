local Plugin = script.Parent.Parent.Parent.Parent

local spec = require(Plugin.Core.Util.specialize)

local Foundation = Plugin.Core.Components.Foundation
local CheckboxField = require(Foundation.CheckboxField)

local BaseCheckboxField =
	spec.specialize(
	"BaseCheckboxField",
	CheckboxField,
	{
		indentLevel = 0,
		labelWidth = 120,
		Visible = true
	},
	{
		label = spec.auto,
		LayoutOrder = spec.auto,
		checked = spec.auto,
		onToggle = spec.auto
	}
)

return BaseCheckboxField
