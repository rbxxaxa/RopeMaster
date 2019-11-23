local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)

local AutoHeightThemedText = Roact.PureComponent:extend("AutoHeightThemedText")

function AutoHeightThemedText:init()
	self.frameRef = Roact.createRef()
	self.textRef = Roact.createRef()
	self.changedDebounce = false
end

-- Children must have a zero Y-Scale size.
function AutoHeightThemedText:render()
	local props = self.props
	local width = props.width or UDim.new(1, 0)
	local Text = props.Text or ""
	local Position = props.Position
	local Font = props.Font or Constants.FONT
	local TextSize = props.TextSize or Constants.FONT_SIZE_MEDIUM
	local TextXAlignment = props.TextXAlignment
	local TextColor3 = props.TextColor3
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	local PaddingLeftPixel = props.PaddingLeftPixel or 0
	local PaddingRightPixel = props.PaddingRightPixel or 0
	local AnchorPoint = props.AnchorPoint
	return Roact.createElement(
		"Frame",
		{
			BackgroundTransparency = 1,
			Position = Position,
			Size = UDim2.new(width, UDim2.new(0, 0)),
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			[Roact.Ref] = self.frameRef,
			AnchorPoint = AnchorPoint
		},
		{
			Text = Roact.createElement(
				"TextLabel",
				{
					Position = UDim2.new(0, PaddingLeftPixel, 0, PaddingTopPixel),
					Size = UDim2.new(1, -(PaddingLeftPixel + PaddingRightPixel), 1, -(PaddingTopPixel + PaddingBottomPixel)),
					Font = Font,
					TextSize = TextSize,
					TextXAlignment = TextXAlignment,
					Text = Text,
					BackgroundTransparency = 1,
					TextColor3 = TextColor3,
					TextWrapped = true,
					[Roact.Ref] = self.textRef,
					TextTruncate = Enum.TextTruncate.None
				},
				props[Roact.Children]
			)
		}
	)
end

function AutoHeightThemedText:doUpdate()
	local frame = self.frameRef.current
	local textLabel = self.textRef.current
	if not frame or not textLabel then
		return
	end

	local props = self.props
	local PaddingTopPixel = props.PaddingTopPixel or 0
	local PaddingBottomPixel = props.PaddingBottomPixel or 0
	local maxHeight = props.maxHeight or 9999
	if self.changedDebounce then
		return
	end
	self.changedDebounce = true

	local textSize =
		Utility.GetTextSize(textLabel.Text, textLabel.TextSize, textLabel.Font, Vector2.new(textLabel.AbsoluteSize.X, 9999))
	-- Gotta do this because TextTruncate.AtEnd still truncates in some cases even though
	-- the text fits anyway.
	local height
	if textSize.Y > maxHeight then
		textLabel.TextTruncate = Enum.TextTruncate.None
		height = Utility.RoundDown(maxHeight, textLabel.TextSize)
	else
		textLabel.TextTruncate = Enum.TextTruncate.None
		height = textSize.Y
	end
	frame.Size = UDim2.new(props.width, UDim.new(0, height + PaddingTopPixel + PaddingBottomPixel))
	self.changedDebounce = false
end

function AutoHeightThemedText:didMount()
	local textLabel = self.textRef.current
	self.sizeChangedConn =
		textLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			self:doUpdate()
		end
	)

	self:doUpdate()
end

function AutoHeightThemedText:willUnmount()
	self.sizeChangedConn:Disconnect()
end

function AutoHeightThemedText:didUpdate(oldProps)
	self:doUpdate()
end

return AutoHeightThemedText
