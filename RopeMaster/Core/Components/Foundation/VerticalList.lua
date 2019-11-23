local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local VerticalList = Roact.PureComponent:extend("VerticalList")

function VerticalList:init()
	self.listRef = Roact.createRef()
	self.frameRef = Roact.createRef()
	self.state = {
		height = 0
	}
end

VerticalList.defaultProps = {
	width = UDim.new(0, 100),
	PaddingTopPixel = 0,
	PaddingBottomPixel = 0,
	PaddingLeftPixel = 0,
	PaddingRightPixel = 0,
	ElementPaddingPixel = 0
}

-- Very important note when using this: Do NOT add a direct child that has a
-- non-zero scale component for its Y-Size.
function VerticalList:render()
	local props = self.props
	local width = props.width
	local Position = props.Position
	local LayoutOrder = props.LayoutOrder
	local AnchorPoint = props.AnchorPoint
	local ZIndex = props.ZIndex
	local PaddingLeftPixel = props.PaddingLeftPixel
	local PaddingTopPixel = props.PaddingTopPixel
	local PaddingRightPixel = props.PaddingRightPixel
	local PaddingBottomPixel = props.PaddingBottomPixel
	local ElementPaddingPixel = props.ElementPaddingPixel
	local Visible = props.Visible ~= false
	local HorizontalAlignment = props.HorizontalAlignment

	local frameChildren = {}
	local listProps = {}
	listProps[Roact.Ref] = self.listRef
	listProps.SortOrder = Enum.SortOrder.LayoutOrder
	listProps.HorizontalAlignment = HorizontalAlignment
	listProps.Padding = UDim.new(0, ElementPaddingPixel)
	frameChildren.UIListLayout = Roact.createElement("UIListLayout", listProps)

	if props[Roact.Children] then
		for key, value in pairs(props[Roact.Children]) do
			frameChildren[key] = value
		end
	end

	return Roact.createElement(
		"Frame",
		{
			BackgroundTransparency = 1,
			Position = Position,
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			AnchorPoint = AnchorPoint,
			Size = UDim2.new(width, UDim.new(0, PaddingTopPixel + PaddingBottomPixel)),
			Visible = Visible,
			[Roact.Ref] = self.frameRef
		},
		{
			ReffableFrame = Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					[Roact.Ref] = props[Roact.Ref]
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
		}
	)
end

function VerticalList:updateSize()
	local list = self.listRef.current
	local frame = self.frameRef.current
	if not list or not frame then
		return
	end

	local cs = list.AbsoluteContentSize
	local props = self.props
	local width = props.width
	frame.Size = UDim2.new(width, UDim.new(0, cs.Y + self.props.PaddingTopPixel + self.props.PaddingBottomPixel))
end

function VerticalList:didMount()
	local list = self.listRef.current

	self.resizeConn =
		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
		function()
			self:updateSize()
		end
	)

	self:updateSize()
end

function VerticalList:didUpdate()
	self:updateSize()
end

function VerticalList:willUnmount()
	self.resizeConn:Disconnect()
end

return VerticalList
