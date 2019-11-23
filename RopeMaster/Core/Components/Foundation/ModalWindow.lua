local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local CollapsibleTitledSection = require(Foundation.CollapsibleTitledSection)

local ModalWindow = Roact.PureComponent:extend("ModalWindow")

function ModalWindow:render()
	local props = self.props
	local title = props.title
	local ZIndex = props.ZIndex

	return Roact.createElement(
		VerticalList,
		{
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			width = UDim.new(1, -16),
			ZIndex = ZIndex
		},
		{
			Border = Roact.createElement(
				CollapsibleTitledSection,
				{
					title = title,
					collapsed = false,
					collapsible = false
				},
				{
					InnerList = Roact.createElement(
						VerticalList,
						{
							PaddingLeftPixel = 12,
							PaddingRightPixel = 12,
							PaddingTopPixel = 12,
							PaddingBottomPixel = 12,
							ElementPaddingPixel = 12,
							width = UDim.new(1, 0)
						},
						props[Roact.Children]
					)
				}
			)
		}
	)
end

return ModalWindow
