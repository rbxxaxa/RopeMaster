local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local RoundedBorderedFrame = require(Components.Foundation.RoundedBorderedFrame)
local BorderedFrame = require(Components.Foundation.BorderedFrame)
local ScrollingVerticalList = require(Components.Foundation.ScrollingVerticalList)

local ThemedDropdown = Roact.PureComponent:extend("ThemedDropdown")

local POSITION_FUDGE = 2
local ARROW_WIDTH = 16

function ThemedDropdown:init()
	self:setState(
		{
			isOpen = false,
			isHovered = false,
			dropdownHighlightId = nil
		}
	)

	self.onMouseEnter = function()
		if not self.state.isHovered and self.props.Visible then
			self:setState(
				{
					isHovered = true
				}
			)
		end
	end

	self.onMouseLeave = function()
		if self.state.isHovered and self.props.Visible then
			self:setState(
				{
					isHovered = false
				}
			)
		end
	end

	self.onMouseButton1Down = function()
		local Visible = self.props.Visible
		local isOpen = self.state.isOpen

		if not (Visible and (not isOpen)) then
			return
		end

		local onOpen = self.props.onOpen
		local onClose = self.props.onClose
		local enabled = self.props.enabled
		local selectedId = self.props.selectedId

		if isOpen then
			self:setState(
				{
					isOpen = false
				}
			)
			if onClose then
				onClose()
			end
			getModal(self).onDropdownClosed()
		elseif not getModal(self).isShowingModal(self.props.modalIndex) then
			if not enabled then
				return
			end
			self.justOpened = true
			self:setState(
				{
					isOpen = true,
					dropdownHighlightId = selectedId,
					openedHighlightId = selectedId
				}
			)
			if onOpen then
				onOpen()
			end
			getModal(self).onDropdownOpened()
		end
	end

	self.onClickOut = function(rbx, x, y)
		local isOpen = self.state.isOpen
		local onClose = self.props.onClose

		if isOpen then
			self:setState(
				{
					isOpen = false
				}
			)
			if onClose then
				onClose()
			end
			getModal(self).onDropdownClosed()
		end
	end

	self.onMouseMovedDropdown = function(rbx, x, y)
		local entryHeight = self.props.entryHeight or Constants.DROPDOWN_ENTRY_HEIGHT
		local entries = self.props.entries

		local screenPos = rbx.AbsolutePosition
		local fromCornerY = y - screenPos.Y
		local idx = math.clamp(math.floor(fromCornerY / entryHeight) + 1, 1, #entries)
		local hoveredEntry = entries[idx]
		if hoveredEntry and self.state.dropdownHighlightId ~= hoveredEntry.id then
			self:setState(
				{
					dropdownHighlightId = hoveredEntry.id
				}
			)
		end
	end

	self.onMouseButton1Dropdown = function(rbx, x, y)
		local entryHeight = self.props.entryHeight or Constants.DROPDOWN_ENTRY_HEIGHT
		local entries = self.props.entries
		local onSelected = self.props.onSelected
		local onClose = self.props.onClose

		local screenPos = rbx.AbsolutePosition
		local fromCornerY = y - screenPos.Y
		local idx = math.clamp(math.floor(fromCornerY / entryHeight) + 1, 1, #entries)
		local hoveredEntry = entries[idx]
		if onSelected then
			onSelected(hoveredEntry.id)
		end
		self:setState(
			{
				isOpen = false,
				isHovered = false
			}
		)
		if onClose then
			onClose()
		end
		getModal(self).onDropdownClosed()
	end

	self.boxRef = Roact.createRef()
end

ThemedDropdown.defaultProps = {
	enabled = true,
	Visible = true,
	inactive = false,
	Size = UDim2.new(1, 0, 0, Constants.INPUT_FIELD_BOX_HEIGHT),
	Position = UDim2.new(0, 0, 0, 0),
	maxDropdownRows = 6,
	modalIndex = 0
}

function ThemedDropdown:render()
	local props = self.props
	local Size = props.Size
	local Position = props.Position
	local entries = props.entries
	local selectedId = props.selectedId
	local isOpen = self.state.isOpen
	local isHovered = self.state.isHovered
	local AnchorPoint = props.AnchorPoint
	local ZIndex = props.ZIndex
	local enabled = props.enabled
	local Visible = props.Visible
	local inactive = props.inactive
	local maxDropdownRows = props.maxDropdownRows
	local entryHeight = props.entryHeight or Constants.DROPDOWN_ENTRY_HEIGHT

	return withTheme(
		function(theme)
			local fieldTheme = theme.dropdownField
			local textPadding = Constants.INPUT_FIELD_TEXT_PADDING
			local fontSize = Constants.FONT_SIZE_MEDIUM
			local font = Constants.FONT
			local arrowColor = fieldTheme.box.arrowColor
			local arrowImage = Constants.DROPDOWN_ARROW_IMAGE
			local dropdownBorderColor = fieldTheme.dropdown.borderColor
			local dropdownFrameColor = fieldTheme.dropdown.backgroundColor
			local highlightColor = fieldTheme.dropdown.highlightColor

			local selectedText = nil
			local selectedElement = nil
			for _, entry in next, entries do
				if entry.id == selectedId then
					if entry.text then
						selectedText = entry.text
					elseif entry.customElement then
						selectedElement = entry.customElement
					end
				end
			end

			local dropdownHighlightId = self.state.dropdownHighlightId
			local highlightIndex
			if dropdownHighlightId then
				for idx, entry in next, entries do
					if entry.id == dropdownHighlightId then
						highlightIndex = idx
					end
				end
			end

			local openedHighlightId = self.state.openedHighlightId
			local openedIndex
			if openedHighlightId and self.justOpened then
				for idx, entry in next, entries do
					if entry.id == openedHighlightId then
						openedIndex = idx
					end
				end
			end
			self.justOpened = false

			return Roact.createElement(
				"Frame",
				{
					Size = Size,
					Position = Position,
					AnchorPoint = AnchorPoint,
					ZIndex = ZIndex,
					Visible = Visible,
					BackgroundTransparency = 1,
					[Roact.Ref] = self.boxRef
				},
				{
					Border = withModal(
						function()
							local modal = getModal(self)
							local boxState
							if not enabled then
								boxState = "Disabled"
							elseif isOpen then
								boxState = "Open"
							elseif isHovered and not (modal.isShowingModal(self.props.modalIndex) or modal.isAnyButtonPressed()) then
								boxState = "Hovered"
							else
								boxState = "Default"
							end

							local textState
							if boxState == "Disabled" then
								textState = "Disabled"
							elseif inactive then
								textState = "Inactive"
							else
								textState = "Default"
							end

							local borderColor = fieldTheme.box.borderColor[boxState]
							local backgroundColor = fieldTheme.box.backgroundColor[boxState]
							local textColor = fieldTheme.box.textColor[textState]

							return Roact.createElement(
								RoundedBorderedFrame,
								{
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundColor3 = backgroundColor,
									BorderColor3 = borderColor,
									Position = UDim2.new(),
									ZIndex = -1
								},
								{
									Element = (function()
										if selectedText then
											return Roact.createElement(
												"TextLabel",
												{
													BackgroundTransparency = 1,
													Size = UDim2.new(1, -textPadding * 2 - ARROW_WIDTH, 1, 0),
													Position = UDim2.new(0, textPadding, 0, 0),
													Font = font,
													TextSize = fontSize,
													TextColor3 = textColor,
													TextXAlignment = Enum.TextXAlignment.Left,
													Text = selectedText,
													TextTruncate = Enum.TextTruncate.None,
													Visible = Visible
												}
											)
										else
											return Roact.createElement(
												"Frame",
												{
													Size = UDim2.new(1, -textPadding * 2 - ARROW_WIDTH, 1, 0),
													Position = UDim2.new(0, textPadding, 0, 0),
													BackgroundTransparency = 1,
													Visible = Visible
												},
												{
													Element = selectedElement
												}
											)
										end
									end)()
								}
							)
						end
					),
					Arrow = Roact.createElement(
						"ImageLabel",
						{
							Image = arrowImage,
							BackgroundTransparency = 1,
							ImageColor3 = arrowColor,
							Position = UDim2.new(1, -4, 0.5, 0),
							AnchorPoint = Vector2.new(1, 0.5),
							Size = UDim2.new(0, 12, 0, 12),
							Visible = Visible
						}
					),
					Button = Roact.createElement(
						"TextButton",
						{
							Text = "",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 1, 0),
							Visible = Visible,
							[Roact.Event.MouseEnter] = self.onMouseEnter,
							[Roact.Event.MouseLeave] = self.onMouseLeave,
							[Roact.Event.MouseButton1Down] = self.onMouseButton1Down
						}
					),
					Portal = isOpen and
						Roact.createElement(
							Roact.Portal,
							{
								target = getModal(self).modalTarget
							},
							{
								-- Consume all clicks outside the dropdown to close it when it "loses focus"
								ClickEventDetectFrame = Roact.createElement(
									"ImageButton",
									{
										ZIndex = 10,
										Position = UDim2.new(0, 0, 0, 0),
										Size = UDim2.new(1, 0, 1, 0),
										BackgroundTransparency = 1,
										AutoButtonColor = false,
										[Roact.Event.MouseButton1Down] = self.onClickOut
									},
									{
										-- Also block all scrolling events going through
										ScrollBlocker = Roact.createElement(
											"ScrollingFrame",
											{
												Size = UDim2.new(1, 0, 1, 0),
												-- We need to have ScrollingEnabled = true for this frame for it to block
												-- But we don't want it to actually scroll, so its canvas must be same size as the frame
												ScrollingEnabled = true,
												CanvasSize = UDim2.new(1, 0, 1, 0),
												BackgroundTransparency = 1,
												BorderSizePixel = 0,
												ScrollBarThickness = 0
											},
											{
												DropdownWrap = withModal(
													function(modalTarget)
														local box = self.boxRef.current
														local scrollHeight = math.min(maxDropdownRows, #entries) * entryHeight
														local dropdownHeight = #entries * entryHeight
														local dropdownTopLeft =
															box and (box.AbsolutePosition + Vector2.new(0, box.AbsoluteSize.Y + POSITION_FUDGE)) or Vector2.new()
														-- account for the edges of the screen
														if box then
															local dropdownBottomRight = dropdownTopLeft + Vector2.new(box.AbsoluteSize.X, scrollHeight)
															local screenSize = modalTarget.AbsoluteSize
															local remainingAbove = dropdownTopLeft.Y
															local remainingBelow = screenSize.Y - remainingAbove - box.AbsoluteSize.Y

															if dropdownBottomRight.X > screenSize.X or dropdownBottomRight.Y > screenSize.Y and remainingAbove > remainingBelow then
																dropdownTopLeft = box.AbsolutePosition - Vector2.new(0, scrollHeight + POSITION_FUDGE)
															end
														end
														-- BUG: When the plugin is resized, the dropdown doesn't resize with it.
														local dropdownWidth = box and box.AbsoluteSize.X - 2

														return Roact.createElement(
															"Frame",
															{
																Size = UDim2.new(0, dropdownWidth, 0, scrollHeight),
																Position = UDim2.new(0, dropdownTopLeft.X + 1, 0, dropdownTopLeft.Y),
																BackgroundTransparency = 1
															},
															{
																DropShadow = Roact.createElement(
																	"ImageLabel",
																	{
																		Size = UDim2.new(0, dropdownWidth, 0, scrollHeight),
																		ZIndex = 1,
																		Position = UDim2.new(0, 4, 0, 4),
																		BackgroundTransparency = 1,
																		Image = Constants.DROP_SHADOW_SLICE_IMAGE,
																		ScaleType = Enum.ScaleType.Slice,
																		SliceCenter = Rect.new(23, 23, 46, 46),
																		SliceScale = 0.125
																	}
																),
																Border = Roact.createElement(
																	BorderedFrame,
																	{
																		Size = UDim2.new(0, dropdownWidth + 2, 0, scrollHeight + 2),
																		Position = UDim2.new(0, -1, 0, -1),
																		BackgroundColor3 = dropdownFrameColor,
																		BorderColor3 = dropdownBorderColor,
																		BackgroundTransparency = 1,
																		ZIndex = 2
																	}
																),
																DropdownFrame = Roact.createElement(
																	ScrollingVerticalList,
																	{
																		Size = UDim2.new(0, dropdownWidth + 1, 0, scrollHeight),
																		BorderColor3 = dropdownBorderColor,
																		BackgroundColor3 = dropdownFrameColor,
																		CanvasSize = UDim2.new(1, 0, 0, dropdownHeight),
																		Position = UDim2.new(0, 0, 0, 0),
																		ZIndex = 3,
																		CanvasPosition = openedIndex and
																			Vector2.new(0, (openedIndex - 1 - math.floor((maxDropdownRows - 1) / 2)) * entryHeight) or
																			nil
																	},
																	{
																		ContentFrame = Roact.createElement(
																			"Frame",
																			{
																				Size = UDim2.new(1, 0, 0, dropdownHeight),
																				BackgroundTransparency = 1,
																				ZIndex = 2
																			},
																			(function()
																				local children = {}

																				if highlightIndex then
																					local highlight =
																						Roact.createElement(
																						"Frame",
																						{
																							Size = UDim2.new(1, 0, 0, entryHeight),
																							Position = UDim2.new(0, 0, 0, entryHeight * (highlightIndex - 1)),
																							BackgroundColor3 = highlightColor,
																							BorderSizePixel = 0,
																							ZIndex = 2
																						}
																					)

																					children.Highlight = highlight
																				end

																				for entryIndex, entry in next, entries do
																					local id, text = entry.id, entry.text
																					if entry.text then
																						local entryStyle = entry.entryStyle or "Default"
																						local entryLabel =
																							Roact.createElement(
																							"TextLabel",
																							{
																								BackgroundTransparency = 1,
																								Size = UDim2.new(1, -textPadding * 2, 0, entryHeight),
																								Position = UDim2.new(0, textPadding, 0, entryHeight * (entryIndex - 1)),
																								Font = font,
																								TextSize = fontSize,
																								TextColor3 = fieldTheme.dropdown.textColor[entryStyle],
																								TextXAlignment = Enum.TextXAlignment.Left,
																								Text = text,
																								TextTruncate = Enum.TextTruncate.None,
																								ZIndex = 3
																							}
																						)
																						children["__DROPDOWN_ENTRY_" .. tostring(id)] = entryLabel
																					else
																						children["__DROPDOWN_ENTRY_" .. tostring(id)] =
																							Roact.createElement(
																							"Frame",
																							{
																								Size = UDim2.new(1, -textPadding * 2, 0, entryHeight),
																								Position = UDim2.new(0, textPadding, 0, entryHeight * (entryIndex - 1)),
																								BackgroundTransparency = 1,
																								ZIndex = 3
																							},
																							{
																								Element = entry.customElement
																							}
																						)
																					end
																				end

																				children.inputDetector =
																					Roact.createElement(
																					"TextButton",
																					{
																						Text = "",
																						Position = UDim2.new(0, 0, 0, 0),
																						Size = UDim2.new(1, 0, 0, dropdownHeight),
																						BackgroundTransparency = 1,
																						[Roact.Event.MouseMoved] = self.onMouseMovedDropdown,
																						[Roact.Event.MouseButton1Down] = self.onMouseButton1Dropdown
																					}
																				)

																				return children
																			end)()
																		)
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
			)
		end
	)
end

function ThemedDropdown:willUnmount()
	if self.state.isOpen then
		getModal(self).onDropdownClosed()
	end
end

return ThemedDropdown
