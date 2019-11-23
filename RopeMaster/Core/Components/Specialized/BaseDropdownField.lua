local Plugin = script.Parent.Parent.Parent.Parent

local spec = require(Plugin.Core.Util.specialize)

local Foundation = Plugin.Core.Components.Foundation
local DropdownField = require(Foundation.DropdownField)

local BaseDropdownField =
	spec.specialize(
	"BaseDropdownField",
	DropdownField,
	{
		indentLevel = 0,
		labelWidth = 120,
		Visible = true
	},
	{
		label = spec.auto,
		LayoutOrder = spec.auto,
		entries = spec.auto,
		selectedId = spec.auto,
		onSelected = spec.auto
	}
)

return BaseDropdownField
