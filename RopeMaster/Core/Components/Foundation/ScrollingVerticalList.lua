local Plugin = script.Parent.Parent.Parent.Parent

local RunService = game:GetService("RunService")

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal
local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local PreciseButton = require(Foundation.PreciseButton)

local ScrollingVerticalList = Roact.PureComponent:extend("ScrollingVerticalList")

function ScrollingVerticalList:init()
	self.listRef = Roact.createRef()
	self.scrollRef = Roact.createRef()
	self.detectorRef = Roact.createRef()
	self.scrollbarRef = Roact.createRef()

	self.contentHeight = 1
	self.viewHeight = 1

	self.onCanvasPositionChanged = function(rbx)
		self:updateHeights()
	end

	self.onAbsoluteSizeChanged = function(rbx)
		self:updateHeights()
	end

	self.onMouseButton1Down = function(rbx, _, y)
		if getModal(self).isShowingModal(self.props.modalIndex) then
			return
		end
		local scroll = self.scrollRef.current
		local canvasPos = scroll.CanvasPosition
		local canvasPercent = canvasPos.Y / self.contentHeight
		y = y - rbx.AbsolutePosition.Y
		local clickPercent = y / self.viewHeight
		local skipPercent = self.props.skipPercent
		local skipPixel = self.props.skipPixel
		if clickPercent < canvasPercent then
			scroll.CanvasPosition = canvasPos - Vector2.new(0, skipPercent * self.contentHeight + skipPixel)
		else
			scroll.CanvasPosition = canvasPos + Vector2.new(0, skipPercent * self.contentHeight + skipPixel)
		end
	end

	local contentSizeDebounce = false
	self.onAbsoluteContentSizeChanged = function(rbx)
		-- Lame hack. Even Roact 1.0 doesn't fix this.
		-- Otherwise, the canvas height isn't updated properly sometimes.
		if not contentSizeDebounce then
			contentSizeDebounce = true
			RunService.Heartbeat:Wait()
			self:updateHeights()
			contentSizeDebounce = false
		end
	end
end

ScrollingVerticalList.defaultProps = {
	skipPercent = 0.1,
	skipPixel = 0,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	ScrollbarThickness = Constants.SCROLL_BAR_THICKNESS,
	modalIndex = 0
}

-- Very important note when using this: Do NOT add a direct child that has a
-- non-zero scale component for its Y-Size.
function ScrollingVerticalList:render()
	return withTheme(
		function(theme)
			return withModal(
				function(modalTarget, modalStatus)
					local props = self.props
					local Size = props.Size
					local Position = props.Position
					local thickness = props.ScrollbarThickness
					local overlay = props.overlay
					local ZIndex = props.ZIndex
					local LayoutOrder = props.LayoutOrder

					local scrollbarTheme = theme.scrollbar
					local backgroundColor = scrollbarTheme.backgroundColor
					local borderColor = scrollbarTheme.borderColor
					local arrowColor = scrollbarTheme.arrowColor

					local scrollbarColor = scrollbarTheme.scrollbarColor.Default

					local frameChildren = {}
					local listProps = {}
					listProps[Roact.Ref] = self.listRef
					listProps[Roact.Change.AbsoluteContentSize] = self.onAbsoluteContentSizeChanged
					listProps.SortOrder = Enum.SortOrder.LayoutOrder
					frameChildren.UIListLayout = Roact.createElement("UIListLayout", listProps)
					if props[Roact.Children] then
						for key, value in pairs(props[Roact.Children]) do
							frameChildren[key] = value
						end
					end

					local children = {}
					children.Frame =
						Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							[Roact.Ref] = self.frameRef
						},
						frameChildren
					)

					local scrollingFrame =
						Roact.createElement(
						"ScrollingFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							CanvasSize = UDim2.new(1, -thickness, 0, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							VerticalScrollBarInset = Enum.ScrollBarInset.Always,
							ScrollBarThickness = thickness,
							ScrollBarImageTransparency = 1,
							ZIndex = 2,
							[Roact.Change.CanvasPosition] = self.onCanvasPositionChanged,
							[Roact.Change.AbsoluteSize] = self.onAbsoluteSizeChanged,
							[Roact.Ref] = self.scrollRef
						},
						children
					)

					local scrollPercent = 0
					local scrollbarVisible = false
					local scrollbarHeightPixel = 0

					return Roact.createElement(
						"Frame",
						{
							Size = Size,
							BackgroundTransparency = 1,
							Position = Position,
							ZIndex = ZIndex,
							LayoutOrder = LayoutOrder
						},
						{
							ScrollingFrame = scrollingFrame,
							Footer = Roact.createElement(
								"Frame",
								{
									BackgroundTransparency = 1,
									Size = UDim2.new(1, -thickness, 1, 0),
									Position = UDim2.new(0, 0, 0, 0),
									ZIndex = 2
								},
								{
									overlay
								}
							),
							ScrollBarBackground = Roact.createElement(
								BorderedFrame,
								{
									BackgroundColor3 = backgroundColor,
									BorderColor3 = borderColor,
									Size = UDim2.new(0, thickness, 1, 0),
									Position = UDim2.new(1, 0, 0, 0),
									AnchorPoint = Vector2.new(1, 0),
									BorderThicknessTop = 0,
									BorderThicknessBottom = 0
								},
								{
									HoverDetector = Roact.createElement(
										PreciseButton,
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, 0, 0, scrollbarHeightPixel),
											Position = UDim2.new(0, 0, scrollPercent, scrollPercent <= 0 and -1 or scrollPercent >= 1 and 1 or 0),
											AnchorPoint = Vector2.new(0, scrollPercent),
											Visible = false,
											[Roact.Ref] = self.detectorRef,
											ZIndex = 2
										},
										{
											ScrollBar = Roact.createElement(
												RoundedBorderedFrame,
												{
													BackgroundColor3 = scrollbarColor,
													BorderColor3 = borderColor,
													Size = UDim2.new(1, 0, 1, 0),
													Visible = scrollbarVisible,
													[Roact.Ref] = self.scrollbarRef
												},
												{
													ArrowUp = Roact.createElement(
														"ImageLabel",
														{
															Size = UDim2.new(0, 8, 0, 8),
															Position = UDim2.new(0, thickness / 4, 0, thickness / 4),
															Rotation = 180,
															BackgroundTransparency = 1,
															Image = Constants.SCROLL_BAR_ARROW_DOWN,
															ImageColor3 = arrowColor
														}
													),
													ArrowDown = Roact.createElement(
														"ImageLabel",
														{
															Size = UDim2.new(0, thickness / 2, 0, thickness / 2),
															Position = UDim2.new(0, thickness / 4, 1, -thickness / 4),
															AnchorPoint = Vector2.new(0, 1),
															BackgroundTransparency = 1,
															Image = Constants.SCROLL_BAR_ARROW_DOWN,
															ImageColor3 = arrowColor
														}
													)
												}
											)
										}
									),
									SkipDetector = Roact.createElement(
										PreciseButton,
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, 0, 1, 0),
											[Roact.Event.MouseButton1Down] = self.onMouseButton1Down
										}
									)
								}
							)
						}
					)
				end
			)
		end
	)
end

function ScrollingVerticalList:updateHeights()
	local list = self.listRef.current
	local scroll = self.scrollRef.current
	if not list or not scroll then
		return
	end

	local contentHeight = list.AbsoluteContentSize.Y
	local canvasPosition = scroll.CanvasPosition.Y
	local viewHeight = scroll.AbsoluteSize.Y
	local props = self.props
	local thickness = props.ScrollbarThickness or Constants.SCROLL_BAR_THICKNESS
	scroll.CanvasSize = UDim2.new(1, -thickness, 0, contentHeight)

	local scrollPercent
	local scrollbarHeightPixel
	local scrollbarVisible
	if viewHeight >= contentHeight then
		scrollbarVisible = false
	else
		scrollbarVisible = true
		if canvasPosition <= 1 then
			scrollPercent = 0
		elseif contentHeight - canvasPosition - viewHeight <= 1 then
			scrollPercent = 1
		else
			scrollPercent = (canvasPosition) / (contentHeight - viewHeight)
		end
		-- minimum height is 2x scrollbar thickness
		scrollbarHeightPixel = math.max(viewHeight / contentHeight * viewHeight, thickness * 2)
	end

	self.contentHeight = contentHeight
	self.viewHeight = viewHeight

	local detector = self.detectorRef.current
	detector.Size = UDim2.new(1, 0, 0, scrollbarHeightPixel)
	detector.Position = UDim2.new(0, 0, scrollPercent, scrollPercent == 0 and -1 or scrollPercent == 1 and 1 or 0)
	detector.AnchorPoint = Vector2.new(0, scrollPercent)

	local scrollbar = self.scrollbarRef.current
	scrollbar.Visible = scrollbarVisible
	detector.Visible = scrollbarVisible
end

function ScrollingVerticalList:didMount()
	self:updateHeights()
end

function ScrollingVerticalList:didUpdate()
	if self.props.CanvasPosition then
		self.scrollRef.current.CanvasPosition = self.props.CanvasPosition
	end
	self:updateHeights()
end

return ScrollingVerticalList
