local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Utility = require(Plugin.Core.Util.Utility)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)

local ThemedTextBox = Roact.PureComponent:extend("ThemedTextBox")

function ThemedTextBox:init()
	local lastValidText = self.props.textInput or ""
	local changeDebounce = false
	local focusDebounce = false

	self:setState {
		isFocused = false
	}

	local modal = getModal(self)
	self.onFocused = function(rbx)
		if (modal.isShowingModal(self.props.modalIndex) or modal.isAnyButtonPressed()) then
			focusDebounce = true
			rbx:ReleaseFocus(false)
			focusDebounce = false
			return
		end

		local isFocused = self.state.isFocused
		local onFocused = self.props.onFocused
		local textInput = self.props.textInput

		if not isFocused then
			rbx.Text = textInput
			lastValidText = textInput
			self:setState(
				{
					isFocused = true
				}
			)
			if onFocused then
				onFocused()
			end
		end
	end

	self.onFocusLost = function(rbx, enterPressed, input)
		local isFocused = self.state.isFocused
		local onFocusLost = self.props.onFocusLost
		local textFormatCallback = self.props.textFormatCallback
		local textInput = self.props.textInput
		if isFocused and not focusDebounce then
			self:setState(
				{
					isFocused = false
				}
			)
			local text = onFocusLost(rbx.Text, enterPressed, input)
			if text ~= nil then
				changeDebounce = true
				rbx.Text = textFormatCallback(text)
				changeDebounce = false
			else
				changeDebounce = true
				rbx.Text = textFormatCallback(textInput)
				changeDebounce = false
			end
		end
	end

	self.onMouseEnter = function()
		if not self.state.isHovered then
			self:setState(
				{
					isHovered = true
				}
			)
		end
	end

	self.onMouseLeave = function()
		if self.state.isHovered then
			self:setState(
				{
					isHovered = false
				}
			)
		end
	end

	self.onTextChanged = function(rbx)
		if changeDebounce then
			return
		end
		if not self.state.isFocused then
			return
		else
			local newText = rbx.Text
			local newTextValidateCallback = self.props.newTextValidateCallback
			local onInputChanged = self.props.onInputChanged
			if not newTextValidateCallback(newText) then
				changeDebounce = true
				rbx.Text = lastValidText
				changeDebounce = false
			else
				if onInputChanged then
					onInputChanged(newText)
				end
				lastValidText = newText
			end
		end
	end

	self.cursorPosition = -1
	self.onCursorPositionChanged = function(rbx)
		self.cursorPosition = rbx.CursorPosition
		self:UpdateTextBoxProperties()
		if self.props.onCursorPositionChanged then
			self.props.onCursorPositionChanged(self.cursorPosition)
		end
	end

	self.clipperRef = Roact.createRef()
	self.textboxRef = Roact.createRef()
end

ThemedTextBox.defaultProps = {
	onFocusLost = function(t)
		return t
	end,
	textFormatCallback = function(t)
		return t
	end,
	newTextValidateCallback = function()
		return true
	end,
	onInputChanged = function()
		return
	end,
	modalIndex = 0,
	inputBoxSizeOffset = 0,
	Position = UDim2.new(0, 0, 0, 0),
	TextSize = Constants.FONT_SIZE_MEDIUM,
	Size = UDim2.new(1, 0, 0, Constants.INPUT_FIELD_BOX_HEIGHT),
	textInput = "",
	slice = "Center",
	ignoreSliceLine = "",
	ZIndex = 1
}

function ThemedTextBox:render()
	local props = self.props
	local textInput = props.textInput
	local Size = props.Size
	local Position = props.Position
	local TextSize = props.TextSize
	local AnchorPoint = props.AnchorPoint
	local placeholderText = props.placeholderText
	local textFormatCallback = props.textFormatCallback
	local inputBoxSizeOffset = props.inputBoxSizeOffset
	local slice = props.slice
	local ignoreSliceLine = props.ignoreSliceLine
	local ZIndex = props.ZIndex

	return withTheme(
		function(theme)
			return withModal(
				function()
					local modal = getModal(self)
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

					children.Frame =
						Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, -textPadding * 2 + inputBoxSizeOffset, 1, 0),
							Position = UDim2.new(0, textPadding, 0, 0),
							BackgroundTransparency = 1,
							ClipsDescendants = true,
							[Roact.Ref] = self.clipperRef
						},
						{
							Input = Roact.createElement(
								"TextBox",
								{
									-- Size and Position is set by UpdateTextBoxProperties
									BackgroundTransparency = 1,
									Font = font,
									TextSize = TextSize,
									TextColor3 = inputColor,
									TextXAlignment = Enum.TextXAlignment.Left,
									ClearTextOnFocus = false,
									Text = textFormatCallback(textInput),
									TextTruncate = Enum.TextTruncate.None,
									PlaceholderText = placeholderText,
									PlaceholderColor3 = placeholderColor,
									[Roact.Event.Focused] = self.onFocused,
									[Roact.Event.FocusLost] = self.onFocusLost,
									[Roact.Event.MouseEnter] = self.onMouseEnter,
									[Roact.Event.MouseLeave] = self.onMouseLeave,
									[Roact.Event.InputBegan] = self.onInputBegan,
									[Roact.Event.InputEnded] = self.onInputEnded,
									[Roact.Change.Text] = self.onTextChanged,
									[Roact.Change.CursorPosition] = self.onCursorPositionChanged,
									[Roact.Ref] = self.textboxRef
								}
							)
						}
					)

					return Roact.createElement(
						RoundedBorderedFrame,
						{
							Size = Size,
							BackgroundColor3 = backgroundColor,
							BorderColor3 = borderColor,
							Position = Position,
							AnchorPoint = AnchorPoint,
							slice = slice,
							ignoreSliceLine = ignoreSliceLine,
							ZIndex = ZIndex,
						},
						children
					)
				end
			)
		end
	)
end

function ThemedTextBox:UpdateTextBoxProperties()
	local textbox = self.textboxRef.current
	local clipper = self.clipperRef.current

	local textWidth = textbox.TextBounds.X
	local boxWidth = clipper.AbsoluteSize.X
	local cursorPosition = self.cursorPosition
	local clipperAbsolutePosX = clipper.AbsolutePosition.X
	local textboxPosX = textbox.AbsolutePosition.X - clipperAbsolutePosX
	local text = textbox.Text
	local textsize = textbox.TextSize
	local font = textbox.Font
	local pos, size
	if textWidth < boxWidth then
		size = UDim2.new(0, boxWidth, 1, 0)
	else
		size = UDim2.new(0, textWidth, 1, 0)
	end
	local textBeforeCursor do
		if cursorPosition == -1 then
			textBeforeCursor = ""
		else
			textBeforeCursor = string.sub(text, 1, cursorPosition - 1)
		end
	end
	local cursorPositionX = Utility.GetTextSize(textBeforeCursor, textsize, font, Vector2.new(9999, 9999)).X
	if textWidth > boxWidth then
		if textboxPosX + cursorPositionX > boxWidth then
			local textAfterCursor = string.sub(text, cursorPosition, -1)
			local textAfterWidth = Utility.GetTextSize(textAfterCursor, textsize, font, Vector2.new(9999, 9999)).X
			pos = UDim2.new(0, math.clamp(-textWidth + boxWidth + textAfterWidth - 1, -textWidth + boxWidth - 1, 0), 0, 0)
		elseif textboxPosX + cursorPositionX < 0 then
			pos = UDim2.new(0, math.clamp(-cursorPositionX, -textWidth + boxWidth - 1, 0), 0, 0)
		elseif textboxPosX < -textWidth + boxWidth - 1 then
			pos = UDim2.new(0, -textWidth + boxWidth - 1, 0, 0)
		end
	else
		pos = UDim2.new(0, 0, 0, 0)
	end

	textbox.Size = size
	if pos then
		textbox.Position = pos
	end
end

function ThemedTextBox:didMount()
	local textbox = self.textboxRef.current
	local clipper = self.clipperRef.current

	self.textConn =
		textbox:GetPropertyChangedSignal("Text"):Connect(
		function()
			--self:UpdateTextBoxProperties()
		end
	)

	self.boundsConn =
		textbox:GetPropertyChangedSignal("TextBounds"):Connect(
		function()
			self:UpdateTextBoxProperties()
		end
	)

	self.clipperResizeConn =
		clipper:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			self:UpdateTextBoxProperties()
		end
	)

	self.textboxResizeConn =
		clipper:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			self:UpdateTextBoxProperties()
		end
	)

	self:UpdateTextBoxProperties()
end

function ThemedTextBox:willUnmount()
	self.textConn:Disconnect()
	self.boundsConn:Disconnect()
	self.clipperResizeConn:Disconnect()
	self.textboxResizeConn:Disconnect()
end

return ThemedTextBox
