local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local ThemedAutoWidthLineCheckbox = Roact.PureComponent:extend("ThemedAutoWidthLineCheckbox")

function ThemedAutoWidthLineCheckbox:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)

	self.onStateChanged = function(s)
		self:setState {buttonState = s}
	end

	self.frameRef = Roact.createRef()
	self.textRef = Roact.createRef()
end

ThemedAutoWidthLineCheckbox.defaultProps = {
	height = UDim.new(0, 24),
	Position = UDim2.new(0, 0, 0, 0),
	modalIndex = 0
}

function ThemedAutoWidthLineCheckbox:render()
	local props = self.props
	local height = props.height
	local Position = props.Position
	local checked = not (not props.checked)
	local AnchorPoint = props.AnchorPoint
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex
	local onToggle = props.onToggle
	local label = props.label

	local checkboxSize = UDim2.new(0, Constants.CHECKBOX_SIZE, 0, Constants.CHECKBOX_SIZE)
	local labelPaddingFromCheckbox = 20
	local textSize = Constants.FONT_SIZE_MEDIUM
	local font = Constants.FONT

	local textWidth = Utility.GetTextSize(label, textSize, font, Vector2.new(9999, 9999)).X

	return withTheme(
		function(theme)
			local fieldTheme = theme.checkboxField
			local checkmarkColor = fieldTheme.checkmarkColor
			local boxColors = fieldTheme.box
			local bgColor, borderColor
			local buttonState = self.state.buttonState
			if buttonState == "Hovered" or buttonState == "PressedInside" then
				bgColor = boxColors.backgroundColor.Hover
				borderColor = boxColors.borderColor.Hover
			else
				bgColor = boxColors.backgroundColor.Default
				borderColor = boxColors.borderColor.Default
			end

			local textColor = theme.mainTextColor

			return Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(UDim.new(0, labelPaddingFromCheckbox + textWidth), height),
					Position = Position,
					BackgroundTransparency = 1,
					LayoutOrder = LayoutOrder,
					Zindex = ZIndex,
					AnchorPoint = AnchorPoint,
					[Roact.Ref] = self.frameRef
				},
				{
					Button = Roact.createElement(
						StatefulButtonDetector,
						{
							Size = UDim2.new(1, 0, 1, 0),
							onClick = onToggle,
							onStateChanged = self.onStateChanged,
							modalIndex = props.modalIndex
						}
					),
					Checkbox = Roact.createElement(
						"Frame",
						{
							Size = checkboxSize,
							Position = UDim2.new(0, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1
						},
						{
							Border = Roact.createElement(
								RoundedBorderedFrame,
								{
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundColor3 = bgColor,
									BorderColor3 = borderColor
								}
							),
							Checkmark = checked and
								Roact.createElement(
									"ImageLabel",
									{
										BackgroundTransparency = 1,
										Image = Constants.CHECK_IMAGE,
										Size = UDim2.new(1, -6, 1, -6),
										Position = UDim2.new(0, 3, 0, 3),
										ImageColor3 = checkmarkColor
									}
								)
						}
					),
					Text = Roact.createElement(
						"TextLabel",
						{
							Size = UDim2.new(UDim.new(0, textWidth), height),
							Position = UDim2.new(0, labelPaddingFromCheckbox, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							TextColor3 = textColor,
							BackgroundTransparency = 1,
							Text = label,
							Font = font,
							TextSize = textSize,
							[Roact.Ref] = self.textRef
						}
					)
				}
			)
		end
	)
end

function ThemedAutoWidthLineCheckbox:didMount()
	local text = self.textRef.current
	local frame = self.frameRef.current
	local labelPaddingFromCheckbox = 24
	self.resizeRef =
		text:GetPropertyChangedSignal("TextBounds"):Connect(
		function()
			local textWidth = text.TextBounds.X
			frame.Size = UDim2.new(UDim.new(0, labelPaddingFromCheckbox + textWidth), self.props.height)
			text.Size = UDim2.new(UDim.new(0, textWidth), self.props.height)
		end
	)
end

function ThemedAutoWidthLineCheckbox:willUnmount()
	self.resizeRef:Disconnect()
end

return ThemedAutoWidthLineCheckbox
