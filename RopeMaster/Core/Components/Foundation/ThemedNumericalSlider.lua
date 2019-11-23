local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local DraggerButton = require(Foundation._DraggerButton)

local ThemedNumericalSlider = Roact.PureComponent:extend("ThemedNumericalSlider")

function ThemedNumericalSlider:init()
	self:setState(
		{
			dragPos = Vector2.new(0, 0),
			isFocused = false
		}
	)
	self.sliderRef = Roact.createRef()
	self.lastValidText = tostring(self.props.value) or ""

	self.formatValue = function(value)
		local valueIsIntegral = self.props.valueIsIntegral
		local trucateTrailingZeroes = self.props.trucateTrailingZeroes
		local decimalPlacesToShow = self.props.decimalPlacesToShow
		if valueIsIntegral then
			return string.format("%d", value)
		else
			if not trucateTrailingZeroes then
				return string.format(string.format("%%.%df", decimalPlacesToShow), value)
			else
				if value % 1 == 0 then
					return string.format("%d", value)
				else
					local s = string.format(string.format("%%.%df", decimalPlacesToShow), value)
					return string.match(s, "(-?%d+%.%d*[1-9]+)0*")
				end
			end
		end
	end

	local modal = getModal(self)
	self.onFocused = function(rbx)
		local isFocused = self.state.isFocused
		if (modal.isShowingModal(self.props.modalIndex) or modal.isAnyButtonPressed()) then
			self.focusDebounce = true
			rbx:ReleaseFocus(false)
			self.focusDebounce = false
			return
		end

		local value = self.props.value

		if not isFocused then
			rbx.Text = self.formatValue(value)
			self:setState(
				{
					isFocused = true
				}
			)
		end
	end

	self.onFocusLost = function(rbx, enterPressed, input)
		local isFocused = self.state.isFocused
		local minValue = self.props.minValue
		local maxValue = self.props.maxValue
		local valueRound = self.props.valueRound
		local value = self.props.value
		local onValueChanged = self.props.onValueChanged
		if isFocused and not self.focusDebounce then
			self:setState(
				{
					isFocused = false
				}
			)
			local num = tonumber(rbx.Text)
			local text
			if num then
				num = Utility.Round(math.clamp(num, minValue, maxValue), valueRound)
				text = tostring(num)
			else
				text = nil
			end

			if text ~= nil then
				self.changeDebounce = true
				rbx.Text = self.formatValue(text)
				local inputValue = tonumber(text)
				if value ~= inputValue and onValueChanged then
					onValueChanged(inputValue)
				end
				self.changeDebounce = false
			else
				self.changeDebounce = true
				rbx.Text = self.formatValue(value)
				self.changeDebounce = false
			end
		end
	end

	self.onMouseEnter = function()
		local isHovered = self.state.isHovered
		if not isHovered then
			self:setState(
				{
					isHovered = true
				}
			)
		end
	end

	self.onMouseLeave = function()
		local isHovered = self.state.isHovered
		if isHovered then
			self:setState(
				{
					isHovered = false
				}
			)
		end
	end

	local function validateTextChange(text)
		local maxCharacters = self.props.maxCharacters
		local valueIsIntegral = self.props.valueIsIntegral
		if string.len(text) > maxCharacters then
			return false
		end

		if valueIsIntegral then
			return text:match("^[-%d]*$") ~= nil
		else
			return text:match("^[-%d.]*$") ~= nil
		end
	end

	self.onTextChanged = function(rbx)
		if self.changeDebounce then
			return
		end
		if not self.state.isFocused then
			return
		end
		local newText = rbx.Text
		if not validateTextChange(newText) then
			self.changeDebounce = true
			rbx.Text = self.lastValidText
			self.changeDebounce = false
		else
			self.lastValidText = newText
		end
	end

	self.dragMoved = function(x, y)
		local props = self.props
		local minValue = props.minValue
		local maxValue = props.maxValue
		local valueSnap = props.valueSnap
		local value = props.value
		local onValueChanged = props.onValueChanged
		local slider = self.sliderRef.current
		local pos, size = slider.AbsolutePosition.X, slider.AbsoluteSize.X
		local left, right = pos, pos + size
		local percent = math.clamp((x - left) / (right - left), 0, 1)
		local dragValue = Utility.Lerp(minValue, maxValue, percent)
		dragValue = Utility.Round(dragValue, valueSnap)
		dragValue = math.clamp(dragValue, minValue, maxValue)
		if value ~= dragValue and onValueChanged then
			onValueChanged(dragValue)
		end
	end

	self.dragBegan = function(x, y)
		local props = self.props
		local minValue = props.minValue
		local maxValue = props.maxValue
		local valueSnap = props.valueSnap
		local value = props.value
		local onValueChanged = props.onValueChanged
		local slider = self.sliderRef.current
		local pos, size = slider.AbsolutePosition.X, slider.AbsoluteSize.X
		local left, right = pos, pos + size
		local percent = math.clamp((x - left) / (right - left), 0, 1)
		local dragValue = Utility.Lerp(minValue, maxValue, percent)
		dragValue = Utility.Round(dragValue, valueSnap)
		dragValue = math.clamp(dragValue, minValue, maxValue)
		if value ~= dragValue and onValueChanged then
			onValueChanged(dragValue)
		end
	end

	self.dragEnded = function(x, y)
		local props = self.props
		local minValue = props.minValue
		local maxValue = props.maxValue
		local valueSnap = props.valueSnap
		local value = props.value
		local onValueChanged = props.onValueChanged
		local slider = self.sliderRef.current
		local pos, size = slider.AbsolutePosition.X, slider.AbsoluteSize.X
		local left, right = pos, pos + size
		local percent = math.clamp((x - left) / (right - left), 0, 1)
		local dragValue = Utility.Lerp(minValue, maxValue, percent)
		dragValue = Utility.Round(dragValue, valueSnap)
		dragValue = math.clamp(dragValue, minValue, maxValue)
		if value ~= dragValue and onValueChanged then
			onValueChanged(dragValue)
		end
	end
end

ThemedNumericalSlider.defaultProps = {
	Size = UDim2.new(1, 0, 0, Constants.INPUT_FIELD_BOX_HEIGHT),
	Position = UDim2.new(0, 0, 0, 0),
	TextSize = Constants.FONT_SIZE_MEDIUM,
	textboxWidthPixel = 60,
	valueIsIntegral = false,
	decimalPlacesToShow = 2,
	maxCharacters = 6,
	trucateTrailingZeroes = true,
	textboxIsEditable = true,
	modalIndex = 0
}

function ThemedNumericalSlider:willUpdate(nextProps, _)
	self.lastValidText = tostring(self.props.value) or ""
end

function ThemedNumericalSlider:render()
	local props = self.props
	local Size = props.Size
	local Position = props.Position
	local TextSize = props.TextSize
	local AnchorPoint = props.AnchorPoint
	local textboxWidthPixel = props.textboxWidthPixel
	local minValue = props.minValue
	local maxValue = props.maxValue
	local valueIsIntegral = props.valueIsIntegral
	local valueRound = props.valueRound
	local valueSnap = props.valueSnap
	local value = props.value

	if valueIsIntegral then
		assert(
			valueRound % 1 == 0 and valueSnap % 1 == 0,
			"valueIsIntegral is set to true. valueRound, valueSnap, must also be integral."
		)
	end

	return withTheme(
		function(theme)
			return withModal(
				function()
					local modal = getModal(self)
					local sliderTheme = theme.numericalSliderField
					local fieldTheme = theme.textField
					local textPadding = Constants.INPUT_FIELD_TEXT_PADDING
					local font = Constants.FONT
					local inputColor = fieldTheme.box.textColor
					local isHovered = self.state.isHovered
					local isFocused = self.state.isFocused

					local boxState
					if isFocused then
						boxState = "Focused"
					elseif isHovered and not (modal.isShowingModal(self.props.modalIndex) or modal.isAnyButtonPressed()) then
						boxState = "Hovered"
					else
						boxState = "Default"
					end

					local borderColor
					if boxState == "Focused" then
						borderColor = fieldTheme.box.borderColor.Selected
					elseif boxState == "Hovered" then
						borderColor = fieldTheme.box.borderColor.Hover
					else
						borderColor = fieldTheme.box.borderColor.Default
					end

					local backgroundColor
					if boxState == "Focused" then
						backgroundColor = fieldTheme.box.backgroundColor.Selected
					elseif boxState == "Hovered" then
						backgroundColor = fieldTheme.box.backgroundColor.Hover
					else
						backgroundColor = fieldTheme.box.backgroundColor.Default
					end

					local placeholderColor = fieldTheme.box.placeholderColor

					local children = {}
					if props[Roact.Children] then
						for key, child in next, props[Roact.Children] do
							children[key] = child
						end
					end

					children.Input =
						Roact.createElement(
						"TextBox",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -textPadding * 2, 1, 0),
							Position = UDim2.new(0, textPadding, 0, 0),
							Font = font,
							TextSize = TextSize,
							TextColor3 = inputColor,
							TextXAlignment = Enum.TextXAlignment.Center,
							ClearTextOnFocus = false,
							Text = self.formatValue(value),
							--					TextTruncate = Enum.TextTruncate.AtEnd,
							PlaceholderColor3 = placeholderColor,
							[Roact.Event.Focused] = self.onFocused,
							[Roact.Event.FocusLost] = self.onFocusLost,
							[Roact.Event.MouseEnter] = self.onMouseEnter,
							[Roact.Event.MouseLeave] = self.onMouseLeave,
							[Roact.Change.Text] = self.onTextChanged
						}
					)

					local textbox =
						Roact.createElement(
						RoundedBorderedFrame,
						{
							Size = UDim2.new(0, textboxWidthPixel, 1, 0),
							Position = UDim2.new(0, 0, 0, 0),
							AnchorPoint = Vector2.new(0, 0),
							BackgroundColor3 = backgroundColor,
							BorderColor3 = borderColor
						},
						children
					)

					local fillPercent = math.clamp((value - minValue) / (maxValue - minValue), 0, 1)
					local barBackgroundColor = sliderTheme.barBackgroundColor
					local barFillColor = sliderTheme.barFillColor
					local spacingBetweenBarAndTextBox = 4
					local slider =
						Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, -textboxWidthPixel - Constants.SLIDER_BUTTON_WIDTH - spacingBetweenBarAndTextBox, 0, 0),
							Position = UDim2.new(0, textboxWidthPixel + spacingBetweenBarAndTextBox + Constants.SLIDER_BUTTON_WIDTH / 2, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							[Roact.Ref] = self.sliderRef
						},
						{
							BarBack = Roact.createElement(
								"Frame",
								{
									BorderSizePixel = 0,
									Size = UDim2.new(1, 0, 0, 6),
									Position = UDim2.new(0, 0, 0.5, 0),
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundColor3 = barBackgroundColor
								}
							),
							BarFill = Roact.createElement(
								"Frame",
								{
									BorderSizePixel = 0,
									Size = UDim2.new(fillPercent, 0, 0, 6),
									Position = UDim2.new(0, 0, 0.5, 0),
									AnchorPoint = Vector2.new(0, 0.5),
									BackgroundColor3 = barFillColor,
									ZIndex = 2
								}
							),
							Dragger = Roact.createElement(
								DraggerButton,
								{
									Size = UDim2.new(1, 0, 0, 20),
									Position = UDim2.new(0, 0, 0.5, 0),
									AnchorPoint = Vector2.new(0, 0.5),
									ZIndex = 3,
									percent = fillPercent,
									dragMoved = self.dragMoved,
									dragBegan = self.dragBegan,
									dragEnded = self.dragEnded,
									modalIndex = props.modalIndex
								}
							)
						}
					)

					return Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = Size,
							Position = Position,
							AnchorPoint = AnchorPoint
						},
						{
							Textbox = textbox,
							Slider = slider
						}
					)
				end
			)
		end
	)
end

return ThemedNumericalSlider
