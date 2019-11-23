local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local LabeledFieldTemplate = require(Foundation.LabeledFieldTemplate)
local ThemedDropdown = require(Foundation.ThemedDropdown)

local DropdownField = Roact.PureComponent:extend("DropdownField")

function DropdownField:init()
end

function DropdownField:render()
	local props = self.props
	local indentLevel = props.indentLevel
	local labelWidth = props.labelWidth
	local label = props.label
	local LayoutOrder = props.LayoutOrder
	local entries = props.entries
	local selectedId = props.selectedId
	local Visible = props.Visible ~= false
	local onSelected = props.onSelected
	local collapsible = props.collapsible
	local collapsed = props.collapsed
	local onCollapseToggled = props.onCollapseToggled
	local enabled = props.enabled
	local inactive = props.inactive
	local modalIndex = props.modalIndex

	local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
	local boxHeight = props.height or Constants.INPUT_FIELD_BOX_HEIGHT
	local fontSize = Constants.FONT_SIZE_MEDIUM

	return Roact.createElement(
		LabeledFieldTemplate,
		{
			label = label,
			indentLevel = indentLevel,
			labelWidth = labelWidth,
			LayoutOrder = LayoutOrder,
			Visible = Visible,
			collapsible = collapsible,
			collapsed = collapsed,
			onCollapseToggled = onCollapseToggled,
			enabled = enabled,
			height = boxHeight
		},
		{
			Box = Roact.createElement(
				ThemedDropdown,
				{
					entries = entries,
					selectedId = selectedId,
					Size = UDim2.new(1, -boxPadding, 0, boxHeight),
					entryHeight = boxHeight,
					Position = UDim2.new(0, boxPadding, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					TextSize = fontSize,
					onSelected = onSelected,
					enabled = enabled,
					onOpen = props.onOpen,
					onClose = props.onClose,
					Visible = Visible,
					inactive = inactive,
					modalIndex = modalIndex
				}
			)
		}
	)
end

return DropdownField
