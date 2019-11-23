local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local spec = require(Plugin.Core.Util.specialize)

local Foundation = Plugin.Core.Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local CollapsibleTitledSection = require(Foundation.CollapsibleTitledSection)

local PaddedCollapsibleSectionBase =
	spec.specialize(
	"PaddedCollapsibleSectionBase",
	CollapsibleTitledSection,
	{
		width = UDim.new(1, 0),
		collapsible = true,
		Position = UDim2.new(0, 0),
		collapsed = false,
		LayoutOrder = 0
	},
	{
		LayoutOrder = spec.auto,
		title = spec.auto,
		collapsed = spec.auto,
		onCollapseToggled = spec.auto,
		[Roact.Children] = Roact.Children
	}
)

local PaddedList =
	spec.specialize(
	"PaddedList",
	VerticalList,
	{
		width = UDim.new(1, 0),
		Visible = true,
		PaddingLeftPixel = 4,
		PaddingRightPixel = 4,
		PaddingBottomPixel = 4,
		PaddingTopPixel = 4,
		ElementPaddingPixel = 4
	},
	{
		Visible = spec.auto,
		[Roact.Children] = Roact.Children
	}
)

local PaddedCollapsibleSection = Roact.PureComponent:extend("PaddedCollapsibleSection")
function PaddedCollapsibleSection:render()
	local props = self.props
	return Roact.createElement(
		PaddedCollapsibleSectionBase,
		{
			LayoutOrder = props.LayoutOrder,
			title = props.title,
			collapsed = props.collapsed,
			onCollapseToggled = props.onCollapseToggled
		},
		{
			List = Roact.createElement(
				PaddedList,
				{
					Visible = not props.collapsed
				},
				props[Roact.Children]
			)
		}
	)
end

function PaddedCollapsibleSection:shouldUpdate(nextProps, nextState)
	local props = self.props
	if
		props.collapsed ~= nextProps.collapsed or props.LayoutOrder ~= nextProps.LayoutOrder or props.title ~= nextProps.title or
			props.onCollapseToggled ~= nextProps.onCollapseToggled or
			props[Roact.Children] ~= nextProps[Roact.Children]
	 then
		return true
	end

	return false
end

return PaddedCollapsibleSection
