local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local VerticalGrid = Roact.PureComponent:extend("VerticalGrid")

function VerticalGrid:init()
	self.gridRef = Roact.createRef()
	self.frameRef = Roact.createRef()
	self.anchorRef = Roact.createRef()
	self.state = {
		height = 0
	}
end

VerticalGrid.defaultProps = {
	width = UDim.new(0, 100),
	PaddingTopPixel = 0,
	PaddingBottomPixel = 0,
	PaddingLeftPixel = 0,
	PaddingRightPixel = 0,
	CellPaddingPixelX = 0,
	CellPaddingPixelY = 0,
	CellSizePixelX = 100,
	CellSizePixelY = 100,
	Visible = true,
	frameAlignment = 0.5
}

-- Very important note when using this: Do NOT add a direct child that has a
-- non-zero scale component for its Y-Size.
function VerticalGrid:render()
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
	local CellPaddingPixelX = props.CellPaddingPixelX
	local CellPaddingPixelY = props.CellPaddingPixelY
	local CellSizePixelX = props.CellSizePixelX
	local CellSizePixelY = props.CellSizePixelY
	local Visible = props.Visible
	local HorizontalAlignment = props.HorizontalAlignment
	local VerticalAlignment = props.VerticalAlignment
	local frameHorizontalAnchor = props.frameHorizontalAnchor

	local frameChildren = {}
	local gridProps = {}
	gridProps[Roact.Ref] = self.gridRef
	gridProps.SortOrder = Enum.SortOrder.LayoutOrder
	gridProps.HorizontalAlignment = HorizontalAlignment
	gridProps.VerticalAlignment = VerticalAlignment
	gridProps.CellPadding = UDim2.new(0, CellPaddingPixelX, 0, CellPaddingPixelY)
	gridProps.CellSize = UDim2.new(0, CellSizePixelX, 0, CellSizePixelY)
	gridProps.FillDirection = Enum.FillDirection.Horizontal
	frameChildren.UIGridLayout = Roact.createElement("UIGridLayout", gridProps)

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
			AnchorFrame = Roact.createElement(
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
						{
							Anchor = Roact.createElement(
								"Frame",
								{
									Size = UDim2.new(0, 0, 1, 0),
									Position = UDim2.new(frameHorizontalAnchor, 0, 0, 0),
									AnchorPoint = Vector2.new(frameHorizontalAnchor, 0),
									BackgroundTransparency = 1,
									[Roact.Ref] = self.anchorRef
								},
								frameChildren
							)
						}
					)
				}
			)
		}
	)
end

function VerticalGrid:updateSize()
	local grid = self.gridRef.current
	local frame = self.frameRef.current
	local anchor = self.anchorRef.current
	if not grid or not frame then
		return
	end

	local props = self.props
	local width = props.width
	anchor.Size = UDim2.new(1, 0, 1, 0)
	local cs = grid.AbsoluteContentSize
	frame.Size = UDim2.new(width, UDim.new(0, cs.Y + self.props.PaddingTopPixel + self.props.PaddingBottomPixel))
	anchor.Size = UDim2.new(0, cs.X, 1, 0)
end

function VerticalGrid:didMount()
	local grid = self.gridRef.current
	local frame = self.frameRef.current

	self.resizeConn1 =
		grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
		function()
			self:updateSize()
		end
	)

	self.resizeConn2 =
		frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			self:updateSize()
		end
	)

	self:updateSize()
end

function VerticalGrid:didUpdate()
	self:updateSize()
end

function VerticalGrid:willUnmount()
	self.resizeConn1:Disconnect()
	self.resizeConn2:Disconnect()
end

return VerticalGrid
