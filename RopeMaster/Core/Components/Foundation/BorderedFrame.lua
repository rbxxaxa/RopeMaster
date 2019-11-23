local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local BorderedFrame = Roact.PureComponent:extend("BorderedFrame")

function BorderedFrame:render()
	local props = self.props
	local BorderColor3 = props.BorderColor3 or Color3.new(0, 0, 0)
	local BackgroundColor3 = props.BackgroundColor3 or Color3.new(1, 1, 1)
	local BorderThicknessTop = props.BorderThicknessTop or 1
	local BorderThicknessRight = props.BorderThicknessRight or 1
	local BorderThicknessBottom = props.BorderThicknessBottom or 1
	local BorderThicknessLeft = props.BorderThicknessLeft or 1
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	local PaddingLeftPixel = props.PaddingLeftPixel or 0
	local PaddingRightPixel = props.PaddingRightPixel or 0
	local Size = props.Size or UDim2.new(0, 100, 0, 100)
	local Position = props.Position or UDim2.new(0, 0, 0, 0)
	local AnchorPoint = props.AnchorPoint
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local Visible = props.Visible ~= false

	return Roact.createElement(
		"Frame",
		{
			Size = Size,
			BorderSizePixel = 0,
			BackgroundColor3 = BorderColor3,
			Position = Position,
			LayoutOrder = LayoutOrder,
			AnchorPoint = AnchorPoint,
			ZIndex = ZIndex,
			Visible = Visible,
			[Roact.Ref] = props[Roact.Ref] or nil
		},
		{
			InnerFrame = Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, -BorderThicknessLeft - BorderThicknessRight, 1, -BorderThicknessTop - BorderThicknessBottom),
					Position = UDim2.new(0, BorderThicknessLeft, 0, BorderThicknessTop),
					BackgroundColor3 = BackgroundColor3,
					BorderSizePixel = 0
				}
			),
			ContentFrame = Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, -PaddingLeftPixel - PaddingRightPixel, 1, -PaddingTopPixel - PaddingBottomPixel),
					Position = UDim2.new(0, PaddingLeftPixel, 0, PaddingTopPixel),
					BackgroundTransparency = 1
				},
				props[Roact.Children]
			)
		}
	)
end

return BorderedFrame
