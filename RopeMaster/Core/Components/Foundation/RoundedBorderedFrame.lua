local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local BorderedFrame = Roact.PureComponent:extend("BorderedFrame")

BorderedFrame.defaultProps = {
	BorderColor3 = Color3.new(0, 0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Size = UDim2.new(0, 100, 0, 100),
	Position = UDim2.new(0, 0, 0, 0),
	Visible = true,
	borderTransparency = 0,
	BackgroundTransparency = 0,
	sliceLine = true,
	slice = "Center",
	ignoreSliceLine = "",
	borderStyle = "Round"
}

local rect_map = {
	Center = {Vector2.new(0, 0), Vector2.new(10, 10), Rect.new(4, 4, 5, 5)},
	Top = {Vector2.new(0, 0), Vector2.new(10, 5), Rect.new(4, 4, 5, 5)},
	Bottom = {Vector2.new(0, 5), Vector2.new(10, 5), Rect.new(4, 0, 5, 1)},
	Right = {Vector2.new(5, 0), Vector2.new(5, 10), Rect.new(0, 4, 1, 5)},
	Left = {Vector2.new(0, 0), Vector2.new(5, 10), Rect.new(4, 4, 5, 5)},
	TopRight = {Vector2.new(5, 0), Vector2.new(5, 5), Rect.new(0, 4, 0, 4)},
	TopLeft = {Vector2.new(0, 0), Vector2.new(5, 5), Rect.new(4, 4, 4, 4)},
	BottomLeft = {Vector2.new(0, 5), Vector2.new(5, 5), Rect.new(4, 0, 4, 0)},
	BottomRight = {Vector2.new(5, 5), Vector2.new(5, 5), Rect.new(0, 0, 0, 0)}
}

local line_1_map = {
	Top = {"Bottom", UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1)},
	Bottom = {"Top", UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 0)},
	Left = {"Right", UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0)},
	Right = {"Left", UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0)},
	TopRight = {"Bottom", UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1)},
	TopLeft = {"Bottom", UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1)},
	BottomLeft = {"Top", UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 0)},
	BottomRight = {"Top", UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 0)}
}

local line_2_map = {
	TopRight = {"Left", UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0)},
	TopLeft = {"Right", UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0)},
	BottomLeft = {"Right", UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0)},
	BottomRight = {"Left", UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0)}
}

function BorderedFrame:render()
	local props = self.props
	local BorderColor3 = props.BorderColor3
	local BackgroundColor3 = props.BackgroundColor3
	local Size = props.Size
	local Position = props.Position
	local AnchorPoint = props.AnchorPoint
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local Visible = props.Visible
	local borderTransparency = props.borderTransparency
	local BackgroundTransparency = props.BackgroundTransparency
	local slice = props.slice
	local sliceLine = props.sliceLine
	local ignoreSliceLine = props.ignoreSliceLine
	local borderStyle = props.borderStyle

	local ro, rs, sc = unpack(rect_map[slice])

	local s, ls_1, lp_1
	local line_1_entry = line_1_map[slice]
	if line_1_entry then
		s, ls_1, lp_1 = unpack(line_1_entry)
		if ignoreSliceLine == s then
			ls_1, lp_1 = nil, nil
		end
	end

	local ls_2, lp_2
	local line_2_entry = line_2_map[slice]
	if line_2_entry then
		s, ls_2, lp_2 = unpack(line_2_entry)
		if ignoreSliceLine == s then
			ls_2, lp_2 = nil, nil
		end
	end

	local borderImage, fillImage
	if borderStyle == "Round" then
		borderImage = "rbxassetid://3008790403"
		fillImage = "rbxassetid://3008645364"
	elseif borderStyle == "Square" then
		borderImage = "rbxassetid://3460107198"
		fillImage = "rbxassetid://3460107337"
	end

	return Roact.createElement(
		"ImageLabel",
		{
			Size = Size,
			Position = Position,
			LayoutOrder = LayoutOrder,
			AnchorPoint = AnchorPoint,
			ZIndex = ZIndex,
			Visible = Visible,
			BackgroundTransparency = 1,
			Image = fillImage,
			ImageTransparency = BackgroundTransparency,
			ImageColor3 = BackgroundColor3,
			ScaleType = Enum.ScaleType.Slice,
			ImageRectOffset = ro,
			ImageRectSize = rs,
			SliceCenter = sc,
			[Roact.Ref] = props[Roact.Ref] or nil
		},
		{
			Border = Roact.createElement(
				"ImageLabel",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Image = borderImage,
					ImageColor3 = BorderColor3,
					ScaleType = Enum.ScaleType.Slice,
					ImageRectOffset = ro,
					ImageRectSize = rs,
					SliceCenter = sc,
					ImageTransparency = borderTransparency
				}
			),
			Line1 = ls_1 and sliceLine and
				Roact.createElement(
					"Frame",
					{
						BackgroundColor3 = BorderColor3,
						BorderSizePixel = 0,
						Size = ls_1,
						Position = lp_1,
						BackgroundTransparency = borderTransparency
					}
				),
			Line2 = ls_2 and sliceLine and
				Roact.createElement(
					"Frame",
					{
						BackgroundColor3 = BorderColor3,
						BorderSizePixel = 0,
						Size = ls_2,
						Position = lp_2,
						BackgroundTransparency = borderTransparency
					}
				),
			ContentFrame = Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex = 2
				},
				props[Roact.Children]
			)
		}
	)
end

return BorderedFrame
