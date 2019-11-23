local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local RoundedBorderedVerticalList = Roact.PureComponent:extend("RoundedBorderedVerticalList")

-- Very important note when using this: Do NOT add a direct child that has a
-- non-zero scale component for its Y-Size.
function RoundedBorderedVerticalList:init()
	self.listRef = Roact.createRef()
	self.frameRef = Roact.createRef()

	self.onAbsoluteContentSizeChanged = function(rbx, pos)
		local width = self.props.width
		local PaddingTopPixel = self.props.PaddingTopPixel or 0
		local PaddingBottomPixel = self.props.PaddingBottomPixel or 0
		local cs = rbx.AbsoluteContentSize
		local frame = self.frameRef.current
		if frame then
			frame.Size = UDim2.new(width, UDim.new(0, cs.Y + PaddingTopPixel + PaddingBottomPixel))
		end
	end
end

RoundedBorderedVerticalList.defaultProps = {
	width = UDim.new(0, 100),
	Position = UDim2.new(0, 0, 0, 0),
	PaddingTopPixel = 0,
	PaddingBottomPixel = 0,
	PaddingLeftPixel = 0,
	PaddingRightPixel = 0,
	ElementPaddingPixel = 0,
	Visible = true
}

function RoundedBorderedVerticalList:render()
	local props = self.props
	local width = props.width
	local Position = props.Position
	local LayoutOrder = props.LayoutOrder
	local AnchorPoint = props.AnchorPoint
	local ZIndex = props.ZIndex
	local BackgroundColor3 = props.BackgroundColor3
	local BorderColor3 = props.BorderColor3
	local PaddingTopPixel = props.PaddingTopPixel
	local PaddingBottomPixel = props.PaddingBottomPixel
	local PaddingLeftPixel = props.PaddingLeftPixel
	local PaddingRightPixel = props.PaddingRightPixel
	local ElementPaddingPixel = props.ElementPaddingPixel
	local BackgroundTransparency = props.BackgroundTransparency
	local Visible = props.Visible
	local slice = props.slice

	local frameChildren = {}
	local listProps = {}
	listProps[Roact.Change.AbsoluteContentSize] = self.onAbsoluteContentSizeChanged
	listProps[Roact.Ref] = self.listRef
	listProps.SortOrder = Enum.SortOrder.LayoutOrder
	listProps.Padding = UDim.new(0, ElementPaddingPixel)
	frameChildren.UIListLayout = Roact.createElement("UIListLayout", listProps)

	if props[Roact.Children] then
		for key, value in pairs(props[Roact.Children]) do
			frameChildren[key] = value
		end
	end

	return Roact.createElement(
		RoundedBorderedFrame,
		{
			BackgroundTransparency = BackgroundTransparency,
			Position = Position,
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			AnchorPoint = AnchorPoint,
			BorderColor3 = BorderColor3,
			BackgroundColor3 = BackgroundColor3,
			Size = UDim2.new(width, UDim.new(0, PaddingTopPixel + PaddingBottomPixel)),
			Visible = Visible,
			[Roact.Ref] = self.frameRef,
			slice = slice
		},
		{
			Content = Roact.createElement(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -(PaddingLeftPixel + PaddingRightPixel), 1, -(PaddingTopPixel + PaddingBottomPixel)),
					Position = UDim2.new(0, PaddingLeftPixel, 0, PaddingTopPixel)
				},
				frameChildren
			)
		}
	)
end

function RoundedBorderedVerticalList:didMount()
	local list = self.listRef.current
	local frame = self.frameRef.current

	local cs = list.AbsoluteContentSize
	local props = self.props
	local PaddingTopPixel = props.PaddingTopPixel
	local PaddingBottomPixel = props.PaddingBottomPixel
	frame.Size = UDim2.new(props.width, UDim.new(0, cs.Y + PaddingTopPixel + PaddingBottomPixel))
end

return RoundedBorderedVerticalList
