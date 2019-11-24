local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local ThemedTextButton = Roact.PureComponent:extend("ThemedTextButton")

function ThemedTextButton:init()
	self:setState(
		{
			buttonState = "Default"
		}
	)

	self.onStateChanged = function(s)
        self:setState {buttonState = s}
        if self.props.onStateChanged then
            self.props.onStateChanged(s)
        end
	end
end

ThemedTextButton.defaultProps = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	buttonStyle = "Default",
	modalIndex = 0,
	slice = "Center",
	ignoreSliceLine = "",
	disabled = false
}

function ThemedTextButton:render()
	local props = self.props
	local Position = props.Position
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size
	local onClick = props.onClick
	local LayoutOrder = props.LayoutOrder
	local buttonStyle = props.buttonStyle
	local disabled = props.disabled
	local ZIndex = props.ZIndex
	local selected = props.selected
	local slice = props.slice
	local ignoreSliceLine = props.ignoreSliceLine

	return withTheme(
		function(theme)
			local buttonTheme = theme.button

			local boxState
			local buttonState = self.state.buttonState

			if disabled then
				boxState = "Disabled"
			elseif selected then
				local map = {
					Default = "Selected",
					Hovered = "SelectedHovered",
					PressedInside = "SelectedPressedInside",
					PressedOutside = "SelectedPressedOutside"
				}

				boxState = map[buttonState]
			else
				local map = {
					Default = "Default",
					Hovered = "Hovered",
					PressedInside = "PressedInside",
					PressedOutside = "PressedOutside"
				}

				boxState = map[buttonState]
			end

			local borderColor = buttonTheme.box.borderColor[buttonStyle][boxState]
			local backgroundColor = buttonTheme.box.backgroundColor[buttonStyle][boxState]

			return Roact.createElement(
				RoundedBorderedFrame,
				{
					Size = Size,
					BackgroundColor3 = backgroundColor,
					BorderColor3 = borderColor,
					Position = Position,
					AnchorPoint = AnchorPoint,
					LayoutOrder = LayoutOrder,
					ZIndex = ZIndex,
					slice = slice,
					ignoreSliceLine = ignoreSliceLine
				},
				{
					Button = Roact.createElement(
						StatefulButtonDetector,
						{
							Size = UDim2.new(1, 0, 1, 0),
							onClick = onClick,
							onStateChanged = self.onStateChanged,
							modalIndex = props.modalIndex
                        },
                        props[Roact.Children]
					)
				}
			)
		end
	)
end

return ThemedTextButton
