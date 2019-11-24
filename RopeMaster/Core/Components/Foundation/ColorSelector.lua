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
local BorderedFrame = require(Foundation.BorderedFrame)
local VerticalList = require(Foundation.VerticalList)
local PreciseButton = require(Foundation.PreciseButton)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local LabeledFieldTemplate = require(Foundation.LabeledFieldTemplate)

local ColorSelector = Roact.PureComponent:extend("ColorSelector")

local ColorSlider
do
	local DraggerButton = Roact.PureComponent:extend("DraggerButton")

	function DraggerButton:init()
		self:setState(
			{
				isHovered = false,
				isPressed = false
			}
		)

		self.onMouseButton1Down = function(rbx, x, y)
			local dragBegan = self.props.dragBegan

			local modal = getModal(self)
			if dragBegan then
				dragBegan(x, y)
			end

			self:setState(
				{
					isPressed = true
				}
			)

			modal.onButtonPressed(self)
		end

		self.onInputEnded = function(rbx, inputObject)
			local modal = getModal(self)
			if self.state.isPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				-- I can't do this after onClick for some reason...
				self:setState(
					{
						isPressed = false
					}
				)

				local disabled = self.props.disabled
				local dragEnded = self.props.dragEnded

				if
					(not disabled and not (modal.isShowingModal(self.props.modalIndex)) or
						(modal.isAnyButtonPressed() and not modal.isButtonPressed(self)))
				 then
					if dragEnded then
						dragEnded(inputObject.Position.X, inputObject.Position.Y)
					end
				end

				modal.onButtonReleased()
			end
		end

		self.onMouseEnterDragButton = function()
			if not self.state.isHovered then
				self:setState(
					{
						isHovered = true
					}
				)
			end
		end

		self.onMouseLeaveDragButton = function()
			if self.state.isHovered then
				self:setState(
					{
						isHovered = false
					}
				)
			end
		end

		self.onMouseButton1DownDragButton = function(rbx, x, y)
			local modal = getModal(self)
			if
				not self.state.isPressed and
					not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)))
			 then
				local dragBegan = self.props.dragBegan
				if dragBegan then
					dragBegan(x, y)
				end

				self:setState(
					{
						isPressed = true
					}
				)

				modal.onButtonPressed(self)
			end
		end

		self.onInputEndedDragButton = function(rbx, inputObject)
			local modal = getModal(self)
			if self.state.isPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				-- I can't do this after onClick for some reason...
				self:setState(
					{
						isPressed = false
					}
				)

				local disabled = self.props.disabled
				local dragEnded = self.props.dragEnded

				if
					(not disabled and not (modal.isShowingModal(self.props.modalIndex)) or
						(modal.isAnyButtonPressed() and not modal.isButtonPressed(self)))
				 then
					if dragEnded then
						dragEnded(inputObject.Position.X, inputObject.Position.Y)
					end
				end

				modal.onButtonReleased()
			end
		end

		self.onMouseMovedPortalDetector = function(rbx, x, y)
			local dragMoved = self.props.dragMoved
			if dragMoved then
				dragMoved(x, y)
			end
		end
	end

	DraggerButton.defaultProps = {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 100, 0, 100),
		Font = Constants.FONT,
		checked = false
	}

	function DraggerButton:render()
		local props = self.props
		local Position = props.Position
		local isPressed = self.state.isPressed
		local AnchorPoint = props.AnchorPoint
		local Size = props.Size
		local ZIndex = props.ZIndex
		local percent = props.percent

		return withTheme(
			function(theme)
				return Roact.createElement(
					"TextButton",
					{
						Text = "",
						ZIndex = ZIndex,
						BackgroundTransparency = 1,
						Size = Size,
						Position = Position,
						AnchorPoint = AnchorPoint,
						[Roact.Event.MouseButton1Down] = self.onMouseButton1Down,
						[Roact.Event.InputEnded] = self.onInputEnded
					},
					{
						Arrow = Roact.createElement(
							"ImageLabel",
							{
								Position = UDim2.new(percent, 0, 0.5, -5),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = UDim2.new(0, 11, 0, 11),
								Image = "rbxassetid://3645512604",
								BackgroundTransparency = 1
							}
						),
						DragButton = Roact.createElement(
							"TextButton",
							{
								Text = "",
								Size = UDim2.new(0, Constants.SLIDER_BUTTON_WIDTH, 0, Constants.SLIDER_BUTTON_HEIGHT),
								Position = UDim2.new(percent, 0, 0.5, 0),
								BackgroundTransparency = 1,
								AnchorPoint = Vector2.new(0.5, 0.5),
								[Roact.Event.MouseEnter] = self.onMouseEnterDragButton,
								[Roact.Event.MouseLeave] = self.onMouseLeaveDragButton,
								[Roact.Event.MouseButton1Down] = self.onMouseButton1DownDragButton,
								[Roact.Event.InputEnded] = self.onInputEndedDragButton
							}
						),
						Portal = isPressed and
							withModal(
								function(modalTarget)
									return Roact.createElement(
										Roact.Portal,
										{
											target = modalTarget
										},
										{
											Detector = Roact.createElement(
												"TextButton",
												{
													Text = "",
													Size = UDim2.new(1, 0, 1, 0),
													BackgroundTransparency = 1,
													ZIndex = 10,
													[Roact.Event.MouseMoved] = self.onMouseMovedPortalDetector
												}
											)
										}
									)
								end
							)
					}
				)
			end
		)
	end

	function DraggerButton:willUnmount()
		if self.state.isPressed then
			local modal = getModal(self)
			modal.onButtonReleased()
		end
	end

	ColorSlider = Roact.PureComponent:extend("ColorSlider")

	function ColorSlider:init()
		self:setState(
			{
				dragPos = Vector2.new(0, 0),
				isFocused = false
			}
		)
		self.sliderRef = Roact.createRef()
		self.lastValidText = tostring(self.props.value) or ""

		self.formatValue = function(value)
			return string.format("%d", value)
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
			local minValue = 0
			local maxValue = 255
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
					num = Utility.Round(math.clamp(num, minValue, maxValue), 1)
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
			if string.len(text) > 3 then
				return false
			end

			return text:match("^[-%d]*$") ~= nil
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
			local value = props.value
			local onValueChanged = props.onValueChanged
			local minValue = 0
			local maxValue = 255
			local valueSnap = 1
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
			local value = props.value
			local onValueChanged = props.onValueChanged
			local minValue = 0
			local maxValue = 255
			local valueSnap = 1
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
			local value = props.value
			local onValueChanged = props.onValueChanged
			local minValue = 0
			local maxValue = 255
			local valueSnap = 1
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

	ColorSlider.defaultProps = {
		Size = UDim2.new(1, 0, 0, Constants.INPUT_FIELD_BOX_HEIGHT),
		Position = UDim2.new(0, 0, 0, 0),
		TextSize = Constants.FONT_SIZE_MEDIUM,
		valueIsIntegral = false,
		textboxIsEditable = true
	}

	function ColorSlider:willUpdate(nextProps, _)
		self.lastValidText = tostring(self.props.value) or ""
	end

	function ColorSlider:render()
		local props = self.props
		local textboxWidthPixel = 40
		local minValue = 0
		local maxValue = 255
		local value = props.value or minValue
		local color = props.color
		local shaderColor = props.shaderColor
		local label = props.label
		local LayoutOrder = props.LayoutOrder

		return withTheme(
			function(theme)
				return withModal(
					function()
						local modal = getModal(self)
						local fieldTheme = theme.textField
						local textPadding = Constants.INPUT_FIELD_TEXT_PADDING
						local fontSize = Constants.FONT_SIZE_MEDIUM
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
								TextSize = fontSize,
								TextColor3 = inputColor,
								TextXAlignment = Enum.TextXAlignment.Center,
								ClearTextOnFocus = false,
								Text = self.formatValue(value),
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
								Frame = Roact.createElement(
									BorderedFrame,
									{
										BorderColor3 = theme.borderColor,
										Size = UDim2.new(1, 2, 0, 14),
										Position = UDim2.new(0, -1, 0.5, 0),
										AnchorPoint = Vector2.new(0, 0.5)
									}
								),
								BarBack = Roact.createElement(
									"Frame",
									{
										BorderSizePixel = 0,
										Size = UDim2.new(1, 0, 0, 12),
										Position = UDim2.new(0, 0, 0.5, 0),
										AnchorPoint = Vector2.new(0, 0.5),
										BackgroundColor3 = color,
										ZIndex = 2
									},
									{
										Shader = Roact.createElement(
											"ImageLabel",
											{
												BackgroundTransparency = 1,
												Image = "rbxassetid://3111228327",
												Size = UDim2.new(1, 0, 1, 0),
												ImageColor3 = shaderColor
											}
										)
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

						local boxPadding = Constants.INPUT_FIELD_BOX_PADDING
						local boxHeight = Constants.INPUT_FIELD_BOX_HEIGHT
						return Roact.createElement(
							LabeledFieldTemplate,
							{
								label = label,
								LayoutOrder = LayoutOrder
							},
							{
								Slider = Roact.createElement(
									"Frame",
									{
										BackgroundTransparency = 1,
										Size = UDim2.new(1, -boxPadding, 0, boxHeight),
										Position = UDim2.new(0, boxPadding, 0.5, 0),
										AnchorPoint = Vector2.new(0, 0.5)
									},
									{
										Textbox = textbox,
										Slider = slider
									}
								)
							}
						)
					end
				)
			end
		)
	end
end

function ColorSelector:init()
	self.state = {
		valuePressed = false,
		chromaPressed = false
	}

	self.onRedSliderChanged = function(newRed)
		local props = self.props
		local h, s, v = props.h, props.s, props.v
		local color = Color3.fromHSV(h, s, v)
		local _, g, b = color.r, color.g, color.b
		local newColor = Color3.new(newRed / 255, g, b)
		h, s, v = Color3.toHSV(newColor)

		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end
	end
	self.onGreenSliderChanged = function(newGreen)
		local props = self.props
		local h, s, v = props.h, props.s, props.v
		local color = Color3.fromHSV(h, s, v)
		local r, _, b = color.r, color.g, color.b
		local newColor = Color3.new(r, newGreen / 255, b)
		h, s, v = Color3.toHSV(newColor)

		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end
	end
	self.onBlueSliderChanged = function(newBlue)
		local props = self.props
		local h, s, v = props.h, props.s, props.v
		local color = Color3.fromHSV(h, s, v)
		local r, g, _ = color.r, color.g, color.b
		local newColor = Color3.new(r, g, newBlue / 255)
		h, s, v = Color3.toHSV(newColor)

		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end
	end
	self.onButton1DownChroma = function(rbx, x, y)
		local modal = getModal(self)

		local detector = self.chromaDetectorRef.current
		local topLeft = detector.AbsolutePosition
		local size = detector.AbsoluteSize
		x, y = x - topLeft.X, y - topLeft.Y
		local h = math.clamp(x / size.X, 0, 1)
		local s = 1 - math.clamp(y / size.Y, 0, 1)
		local v = self.props.v

		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end

		self:setState {
			chromaPressed = true
		}

		modal.onButtonPressed(self)
	end
	self.onInputEndedChroma = function(rbx, inputObject)
		local modal = getModal(self)
		if self.state.chromaPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			-- I can't do this after onClick for some reason...
			self:setState(
				{
					chromaPressed = false
				}
			)

			modal.onButtonReleased()
		end
	end
	self.onMouseMovedChroma = function(rbx, x, y)
		local detector = self.chromaDetectorRef.current
		local topLeft = detector.AbsolutePosition
		local size = detector.AbsoluteSize
		x, y = x - topLeft.X, y - topLeft.Y
		local h = math.clamp(x / size.X, 0, 1)
		local s = 1 - math.clamp(y / size.Y, 0, 1)
		local v = self.props.v
		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end
	end
	self.onMouseButton1DownValue = function(rbx, x, y)
		local modal = getModal(self)

		local detector = self.valueDetectorRef.current
		local topLeft = detector.AbsolutePosition
		local size = detector.AbsoluteSize
		y = y - topLeft.Y
		local h, s = self.props.h, self.props.s
		local v = 1 - math.clamp(y / size.Y, 0, 1)
		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end

		self:setState {
			valuePressed = true
		}

		modal.onButtonPressed(self)
	end
	self.onInputEndedValue = function(rbx, inputObject)
		local modal = getModal(self)
		if self.state.valuePressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			-- I can't do this after onClick for some reason...
			self:setState(
				{
					valuePressed = false
				}
			)

			modal.onButtonReleased()
		end
	end
	self.onMouseMovedValue = function(rbx, _, y)
		local detector = self.valueDetectorRef.current
		local topLeft = detector.AbsolutePosition
		local size = detector.AbsoluteSize
		y = y - topLeft.Y
		local h, s = self.props.h, self.props.s
		local v = 1 - math.clamp(y / size.Y, 0, 1)
		if self.props.onColorChanged then
			self.props.onColorChanged {
				h = h,
				s = s,
				v = v
			}
		end
	end

	self.chromaDetectorRef = Roact.createRef()
	self.valueDetectorRef = Roact.createRef()
end

local function Round(n, multiple)
	multiple = multiple or 1
	return (math.floor(n / multiple + 1 / 2) * multiple)
end

ColorSelector.defaultProps = {
	modalIndex = 0
}

function ColorSelector:render()
	return withTheme(
		function(theme)
			local props = self.props
			local textured = props.textured
			local color = Color3.fromHSV(self.props.h, self.props.s, self.props.v)
			local texture = props.texture
			local modalIndex = props.modalIndex
			local r, g, b = color.r, color.g, color.b
			local r_int, g_int, b_int = Round(r * 255), Round(g * 255), Round(b * 255)
			return Roact.createElement(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 188),
					LayoutOrder = props.LayoutOrder
				},
				{
					ColorBox = Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 102),
							LayoutOrder = 1
						},
						{
							ColorSquare = Roact.createElement(
								BorderedFrame,
								{
									Size = UDim2.new(1, -26, 1, 0),
									BorderColor3 = theme.borderColor
								},
								{
									Chroma = Roact.createElement(
										"ImageLabel",
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, -2, 1, -2),
											Position = UDim2.new(0, 1, 0, 1),
											Image = "rbxassetid://181615068",
											ClipsDescendants = true
										},
										{
											Shader = Roact.createElement(
												"Frame",
												{
													BorderSizePixel = 0,
													BackgroundColor3 = Color3.new(0, 0, 0),
													BackgroundTransparency = self.props.v,
													Size = UDim2.new(1, 0, 1, 0)
												}
											),
											Circle = Roact.createElement(
												"ImageLabel",
												{
													Position = (function()
														local h, s = self.props.h, self.props.s
														return UDim2.new(h, 0, 1 - s, 0)
													end)(),
													AnchorPoint = Vector2.new(0.5, 0.5),
													Size = UDim2.new(0, 13, 0, 13),
													Image = "rbxassetid://3645522059",
													BackgroundTransparency = 1,
													ZIndex = 2
												}
											),
											Detector = Roact.createElement(
												PreciseButton,
												{
													Size = UDim2.new(1, 0, 1, 0),
													BackgroundTransparency = 1,
													[Roact.Event.MouseButton1Down] = self.onButton1DownChroma,
													[Roact.Event.InputEnded] = self.onInputEndedChroma,
													[Roact.Ref] = self.chromaDetectorRef
												},
												{
													ChromaPortal = self.state.chromaPressed and
														withModal(
															function(modalTarget)
																return Roact.createElement(
																	Roact.Portal,
																	{
																		target = modalTarget
																	},
																	{
																		Detector = Roact.createElement(
																			"TextButton",
																			{
																				Text = "",
																				Size = UDim2.new(1, 0, 1, 0),
																				BackgroundTransparency = 1,
																				ZIndex = 10,
																				[Roact.Event.MouseMoved] = self.onMouseMovedChroma
																			}
																		)
																	}
																)
															end
														)
												}
											)
										}
									)
								}
							),
							ValueSquare = Roact.createElement(
								BorderedFrame,
								{
									Size = UDim2.new(0, 14, 1, 0),
									Position = UDim2.new(1, -8, 0, 0),
									AnchorPoint = Vector2.new(1, 0),
									BorderColor3 = theme.borderColor,
									BackgroundColor3 = Color3.fromHSV(self.props.h, self.props.s, 1)
								},
								{
									ValueShader = Roact.createElement(
										"ImageLabel",
										{
											Size = UDim2.new(1, -2, 1, -2),
											Position = UDim2.new(0, 1, 0, 1),
											Image = "rbxassetid://3108067184",
											BackgroundTransparency = 1
										},
										{
											Arrow = Roact.createElement(
												"ImageLabel",
												{
													Position = (function()
														local v = self.props.v
														return UDim2.new(0.5, 5, 1 - v, 0)
													end)(),
													AnchorPoint = Vector2.new(0.5, 0.5),
													Size = UDim2.new(0, 11, 0, 11),
													Image = "rbxassetid://3645508323",
													BackgroundTransparency = 1
												}
											),
											Detector = Roact.createElement(
												PreciseButton,
												{
													Size = UDim2.new(1, 0, 1, 0),
													BackgroundTransparency = 1,
													[Roact.Event.MouseButton1Down] = self.onMouseButton1DownValue,
													[Roact.Event.InputEnded] = self.onInputEndedValue,
													[Roact.Ref] = self.valueDetectorRef
												},
												{
													ValuePortal = self.state.valuePressed and
														withModal(
															function(modalTarget)
																return Roact.createElement(
																	Roact.Portal,
																	{
																		target = modalTarget
																	},
																	{
																		Detector = Roact.createElement(
																			"TextButton",
																			{
																				Text = "",
																				Size = UDim2.new(1, 0, 1, 0),
																				BackgroundTransparency = 1,
																				ZIndex = 10,
																				[Roact.Event.MouseMoved] = self.onMouseMovedValue
																			}
																		)
																	}
																)
															end
														)
												}
											)
										}
									)
								}
							)
						}
					),
					PreviewBox = Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, 0, 0, 82),
							Position = UDim2.new(0, 0, 0, 106),
							BackgroundTransparency = 1
						},
						{
							PreviewImageBox = Roact.createElement(
								BorderedFrame,
								{
									Size = UDim2.new(0, 82, 0, 82),
									Position = UDim2.new(0, 0, 0, 0),
									AnchorPoint = Vector2.new(0, 0),
									BorderColor3 = theme.borderColor,
									BackgroundColor3 = color
								},
								(function()
									if not textured then
										return {}
									end
									local children = {}

									children.Clipper =
										Roact.createElement(
										"Frame",
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, -2, 1, -2),
											Position = UDim2.new(0, 1, 0, 1),
											ClipsDescendants = true
										},
										{
											PreviewImage = Roact.createElement(
												"ImageLabel",
												{
													BorderSizePixel = 0,
													BackgroundTransparency = 0,
													BackgroundColor3 = color,
													Image = texture or "",
													ImageColor3 = color,
													ScaleType = Enum.ScaleType.Tile,
													TileSize = UDim2.new(0, 60, 0, 60),
													Size = UDim2.new(0, 180, 0, 180),
													Position = UDim2.new(0, -50, 0, -50)
												}
											),
											ShadeLeft = Roact.createElement(
												"Frame",
												{
													BorderSizePixel = 0,
													Size = UDim2.new(0.125, 0, 1, 0),
													BackgroundColor3 = Color3.new(0, 0, 0),
													BackgroundTransparency = 0.5,
													ZIndex = 2
												}
											),
											ShadeRight = Roact.createElement(
												"Frame",
												{
													BorderSizePixel = 0,
													Size = UDim2.new(0.125, 0, 1, 0),
													Position = UDim2.new(0.875, 0, 0, 0),
													BackgroundColor3 = Color3.new(0, 0, 0),
													BackgroundTransparency = 0.5,
													ZIndex = 2
												}
											),
											ShadeTop = Roact.createElement(
												"Frame",
												{
													BorderSizePixel = 0,
													Size = UDim2.new(0.75, 0, 0.125, 0),
													Position = UDim2.new(0.125, 0, 0, 0),
													BackgroundColor3 = Color3.new(0, 0, 0),
													BackgroundTransparency = 0.5,
													ZIndex = 2
												}
											),
											ShadeBottom = Roact.createElement(
												"Frame",
												{
													BorderSizePixel = 0,
													Size = UDim2.new(0.75, 0, 0.125, 0),
													Position = UDim2.new(0.125, 0, 0.875, 0),
													BackgroundColor3 = Color3.new(0, 0, 0),
													BackgroundTransparency = 0.5,
													ZIndex = 2
												}
											)
										}
									)

									return children
								end)()
							),
							SliderFrame = Roact.createElement(
								"Frame",
								{
									BackgroundTransparency = 1,
									Position = UDim2.new(0, 86, 0, 0),
									Size = UDim2.new(1, -86, 1, 0)
								},
								{
									SliderList = Roact.createElement(
										VerticalList,
										{
											width = UDim.new(1, 0),
											ElementPaddingPixel = 4,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											Position = UDim2.new(0, 0, 0.5, 0),
											AnchorPoint = Vector2.new(0, 0.5)
										},
										{
											RedSlider = Roact.createElement(
												ColorSlider,
												{
													value = r_int,
													color = Color3.new(1, g, b),
													shaderColor = Color3.new(0, g, b),
													LayoutOrder = 1,
													onValueChanged = self.onRedSliderChanged,
													label = "R",
													modalIndex = modalIndex
												}
											),
											GreenSlider = Roact.createElement(
												ColorSlider,
												{
													value = g_int,
													color = Color3.new(r, 1, b),
													shaderColor = Color3.new(r, 0, b),
													LayoutOrder = 2,
													onValueChanged = self.onGreenSliderChanged,
													label = "G",
													modalIndex = modalIndex
												}
											),
											BlueSlider = Roact.createElement(
												ColorSlider,
												{
													value = b_int,
													color = Color3.new(r, g, 1),
													shaderColor = Color3.new(r, g, 0),
													LayoutOrder = 3,
													onValueChanged = self.onBlueSliderChanged,
													label = "B",
													modalIndex = modalIndex
												}
											)
										}
									)
								}
							)
						}
					)
				}
			)
		end
	)
end

function ColorSelector:willUnmount()
	if self.state.chromaPressed or self.state.valuePressed then
		local modal = getModal(self)
		modal.onButtonReleased()
	end
end

return ColorSelector
