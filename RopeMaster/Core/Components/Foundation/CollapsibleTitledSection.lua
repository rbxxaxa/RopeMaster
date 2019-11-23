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
local PreciseFrame = require(Foundation.PreciseFrame)
local PreciseButton = require(Foundation.PreciseButton)

local CollapsibleTitledSection = Roact.PureComponent:extend("CollapsibleTitledSection")

function CollapsibleTitledSection:init()
	self:setState(
		{
			isHovered = false
		}
	)

	self.onHoverBegin = function(rbx)
		self:setState(
			{
				isHovered = true
			}
		)
	end

	self.onHoverEnd = function(rbx)
		self:setState(
			{
				isHovered = false
			}
		)
	end

	local modal = getModal(self)
	self.onMouseButton1Down = function()
		if
			self.props.onCollapseToggled and
				not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)))
		 then
			self.props.onCollapseToggled()
		end
	end

	self.frameRef = Roact.createRef()
	self.listRef = Roact.createRef()
end

CollapsibleTitledSection.defaultProps = {
	modalIndex = 0,
	collapsible = true,
	width = UDim.new(1, 0),
	Position = UDim2.new(0, 0, 0, 0)
}

-- Children must have a zero Y-Scale size.
function CollapsibleTitledSection:render()
	local props = self.props
	local title = props.title
	local collapsed = props.collapsed
	local LayoutOrder = props.LayoutOrder
	local width = props.width
	local collapsible = props.collapsible
	local Position = props.Position

	local children = props[Roact.Children] ~= nil and Utility.ShallowCopy(props[Roact.Children]) or {}
	children._UIListLayout =
		Roact.createElement(
		"UIListLayout",
		{
			SortOrder = Enum.SortOrder.LayoutOrder,
			[Roact.Ref] = self.listRef
		}
	)

	return withTheme(
		function(theme)
			return withModal(
				function(modalTarget, modalStatus)
					local isHovered = self.state.isHovered

					local collapsibleTheme = theme.collapsibleTitledSection
					local headerHeight = Constants.COLLAPSIBLE_SECTION_HEIGHT
					local hoverColor = collapsibleTheme.hoverColor
					local borderColor = collapsibleTheme.borderColor
					local defaultColor = collapsibleTheme.defaultColor
					local contentColor = collapsibleTheme.contentColor
					local arrowColor = collapsibleTheme.arrowColor
					local arrowRight = Constants.COLLAPSIBLE_ARROW_RIGHT_IMAGE
					local arrowDown = Constants.COLLAPSIBLE_ARROW_DOWN_IMAGE
					local arrowSize = Constants.COLLAPSIBLE_ARROW_SIZE
					local font = Constants.FONT_BOLD
					local fontSize = Constants.FONT_SIZE_LARGE
					local textColor = collapsibleTheme.textColor

					local modal = getModal(self)
					local hovered = (isHovered and not modal.isShowingModal(props.modalIndex) and not modal.isAnyButtonPressed())

					return Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Position = Position,
							Size = UDim2.new(width, UDim.new(0, headerHeight)),
							LayoutOrder = LayoutOrder,
							[Roact.Ref] = self.frameRef
						},
						{
							Header = Roact.createElement(
								RoundedBorderedFrame,
								{
									BackgroundColor3 = hovered and hoverColor or defaultColor,
									Size = UDim2.new(1, 0, 0, headerHeight),
									BorderColor3 = borderColor,
									slice = collapsed and "Center" or "Top"
								}
							),
							HighlighteDetector = collapsible and
								Roact.createElement(
									PreciseFrame,
									{
										Size = UDim2.new(1, 0, 0, headerHeight),
										BackgroundTransparency = 1,
										[Roact.Event.MouseEnter] = self.onHoverBegin,
										[Roact.Event.MouseLeave] = self.onHoverEnd
									}
								),
							Toggle = collapsible and
								Roact.createElement(
									PreciseButton,
									{
										BackgroundTransparency = 1,
										[Roact.Event.MouseButton1Down] = self.onMouseButton1Down,
										Size = UDim2.new(1, 0, 0, headerHeight),
										Position = UDim2.new(0, 0, 0, 0)
									}
								),
							ArrowImage = collapsible and
								Roact.createElement(
									"ImageLabel",
									{
										Image = collapsed and arrowRight or arrowDown,
										Size = UDim2.new(0, arrowSize, 0, arrowSize),
										Position = UDim2.new(1, -12, 0, headerHeight / 2),
										AnchorPoint = Vector2.new(1, 0.5),
										ImageColor3 = arrowColor,
										BackgroundTransparency = 1
									}
								),
							Title = Roact.createElement(
								"TextLabel",
								{
									BackgroundTransparency = 1,
									Text = title,
									Position = UDim2.new(0, 12, 0, 0),
									Size = UDim2.new(1, -12 - 12 - arrowSize, 0, headerHeight),
									Font = font,
									TextSize = fontSize,
									TextXAlignment = Enum.TextXAlignment.Left,
									TextColor3 = textColor,
									TextTruncate = Enum.TextTruncate.AtEnd,
									ZIndex = 2
								}
							),
							Content = Roact.createElement(
								RoundedBorderedFrame,
								{
									BackgroundColor3 = contentColor,
									Size = UDim2.new(1, 0, 1, -headerHeight),
									Position = UDim2.new(0, 0, 0, headerHeight),
									LayoutOrder = LayoutOrder,
									BorderColor3 = borderColor,
									slice = "Bottom",
									sliceLine = false,
									ZIndex = 2
								},
								{
									Padder = Roact.createElement(
										"Frame",
										{
											Size = UDim2.new(1, -2, 1, -1),
											Position = UDim2.new(0, 1, 0, 0),
											BackgroundTransparency = 1
										},
										children
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

function CollapsibleTitledSection:updateContentHeight()
	local list = self.listRef.current

	local contentHeight = list.AbsoluteContentSize.Y
	local headerHeight = Constants.COLLAPSIBLE_SECTION_HEIGHT
	local width = self.props.width or UDim.new(1, 0)
	self.frameRef.current.Size = UDim2.new(width, UDim.new(0, headerHeight + contentHeight + 1))
end

function CollapsibleTitledSection:didMount()
	local list = self.listRef.current
	self.heightConn =
		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(
		function()
			self:updateContentHeight()
		end
	)

	self:updateContentHeight()
end

function CollapsibleTitledSection:didUpdate()
	self:updateContentHeight()
end

function CollapsibleTitledSection:willUnmount()
	self.heightConn:Disconnect()
end

return CollapsibleTitledSection
