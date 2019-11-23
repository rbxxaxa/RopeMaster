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
local Foundation = Components.Foundation

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
	checked = false,
	modalIndex = 0
}

function DraggerButton:render()
	local props = self.props
	local Position = props.Position
	local isHovered = self.state.isHovered
	local isPressed = self.state.isPressed
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size
	local disabled = props.disabled
	local ZIndex = props.ZIndex
	local percent = props.percent

	return withTheme(
		function(theme)
			local buttonTheme = theme.button
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
					Button = (function()
						if isHovered then
							return withModal(
								function()
									local modal = getModal(self)

									local boxState
									if disabled then
										boxState = "Disabled"
									elseif modal.isShowingModal(props.modalIndex) or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)) then
										boxState = "Default"
									elseif isPressed then
										boxState = "PressedInside"
									elseif isHovered then
										boxState = "Hovered"
									else
										boxState = "Default"
									end

									local borderColor = buttonTheme.box.borderColor.Default[boxState]
									local backgroundColor = buttonTheme.box.backgroundColor.Default[boxState]

									return Roact.createElement(
										"ImageLabel",
										{
											Size = UDim2.new(0, 16, 0, 16),
											BackgroundTransparency = 1,
											ImageColor3 = backgroundColor,
											Position = UDim2.new(percent, 0, 0.5, 0),
											AnchorPoint = Vector2.new(0.5, 0.5),
											Image = "rbxassetid://3646176187"
										},
										{
											Roact.createElement(
												"ImageLabel",
												{
													Size = UDim2.new(1, 0, 1, 0),
													BackgroundTransparency = 1,
													ImageColor3 = borderColor,
													Image = "rbxassetid://3646176300"
												}
											)
										}
									)
								end
							)
						else
							local boxState
							if disabled then
								boxState = "Disabled"
							elseif isPressed then
								boxState = "PressedInside"
							elseif isHovered then
								boxState = "Hovered"
							else
								boxState = "Default"
							end

							local borderColor = buttonTheme.box.borderColor.Default[boxState]
							local backgroundColor = buttonTheme.box.backgroundColor.Default[boxState]

							return Roact.createElement(
								"ImageLabel",
								{
									Size = UDim2.new(0, 16, 0, 16),
									BackgroundTransparency = 1,
									ImageColor3 = backgroundColor,
									Position = UDim2.new(percent, 0, 0.5, 0),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Image = "rbxassetid://3646176187"
								},
								{
									Roact.createElement(
										"ImageLabel",
										{
											Size = UDim2.new(1, 0, 1, 0),
											BackgroundTransparency = 1,
											ImageColor3 = borderColor,
											Image = "rbxassetid://3646176300"
										}
									)
								}
							)
						end
					end)(),
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

return DraggerButton
