local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PreciseButton = require(Foundation.PreciseButton)
local StatefulButtonDetector = Roact.PureComponent:extend("StatefulButtonDetector")

function StatefulButtonDetector:init()
	self:setState {
		isHovered = false,
		isPressed = false,
		buttonState = "Default"
	}

	self.onMouseEnter = function()
		if not self.state.isHovered then
			self:updateStates(true, self.state.isPressed)
		end
	end
	self.onMouseLeave = function()
		if self.state.isHovered then
			self:updateStates(false, self.state.isPressed)
		end
	end
	self.onMouseButton1Down = function(rbx, ...)
		local modal = getModal(self)

		if not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed())) then
			if self.props[Roact.Event.MouseButton1Down] then
				self.props[Roact.Event.MouseButton1Down](...)
			end
		end

		if
			not self.state.isPressed and
				not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)))
		 then
			self:updateStates(self.state.isHovered, true)
		end

		modal.onButtonPressed(self)
	end

	self.onMouseButton2Down = function(rbx, ...)
		local modal = getModal(self)

		if not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed())) then
			if self.props[Roact.Event.MouseButton2Down] then
				self.props[Roact.Event.MouseButton2Down](...)
			end
		end
	end

	self.onMouseButton2Up = function(rbx, ...)
		local modal = getModal(self)

		if not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed())) then
			if self.props[Roact.Event.MouseButton2Up] then
				self.props[Roact.Event.MouseButton2Up](...)
			end
		end
	end

	self.onInputEnded = function(rbx, inputObject)
		local modal = getModal(self)
		if self.state.isPressed and inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			self:updateStates(self.state.isHovered, false)

			if
				not (modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self))) and
					self.state.isHovered
			 then
				if self.props.onClick then
					self.props.onClick()
				end
			end

			modal.onButtonReleased()
		end

		if self.props[Roact.Event.InputEnded] then
			self.props[Roact.Event.InputEnded](rbx, inputObject)
		end
	end
	self.onInputChanged = function(rbx, inputObject)
		if self.props[Roact.Event.InputChanged] then
			self.props[Roact.Event.InputChanged](rbx, inputObject)
		end
	end
	self.onInputBegan = function(rbx, inputObject)
		if self.props[Roact.Event.InputBegan] then
			self.props[Roact.Event.InputBegan](rbx, inputObject)
		end
	end
end

StatefulButtonDetector.defaultProps = {
	modalIndex = 0
}

function StatefulButtonDetector:updateStates(isHovered, isPressed)
	local buttonState = "Default"
	local modal = getModal(self)
	if modal.isShowingModal(self.props.modalIndex) or (modal.isAnyButtonPressed() and not modal.isButtonPressed(self)) then
		buttonState = "Default"
	elseif isPressed and isHovered then
		buttonState = "PressedInside"
	elseif isPressed and not isHovered then
		buttonState = "PressedOutside"
	elseif isHovered then
		buttonState = "Hovered"
	end

	if buttonState ~= self.state.buttonState then
		self:setState {
			isHovered = isHovered,
			isPressed = isPressed,
			buttonState = buttonState
		}
		if self.props.onStateChanged then
			self.props.onStateChanged(buttonState, isHovered, isPressed)
		end
	elseif isHovered ~= self.state.isHovered or isPressed ~= self.state.isPressed then
		self:setState {
			isHovered = isHovered,
			isPressed = isPressed
		}
		if self.props.onStateChanged then
			self.props.onStateChanged(buttonState, isHovered, isPressed)
		end
	end
end

function StatefulButtonDetector:render()
	local props = self.props
	local Position = props.Position
	local AnchorPoint = props.AnchorPoint
	local Size = props.Size
	local LayoutOrder = props.LayoutOrder
	local ZIndex = props.ZIndex

	local children = {}
	if props[Roact.Children] then
		for k, v in next, props[Roact.Children] do
			children[k] = v
		end
	end

	children.StatefulButton =
		Roact.createElement(
		PreciseButton,
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseLeave] = self.onMouseLeave,
			[Roact.Event.MouseButton1Down] = self.onMouseButton1Down,
			[Roact.Event.InputEnded] = self.onInputEnded,
			[Roact.Event.InputBegan] = self.onInputBegan,
			[Roact.Event.InputChanged] = self.onInputChanged,
			[Roact.Event.MouseButton2Up] = self.onMouseButton2Up,
			[Roact.Event.MouseButton2Down] = self.onMouseButton2Down
		}
	)

	return Roact.createElement(
		"Frame",
		{
			Position = Position,
			AnchorPoint = AnchorPoint,
			Size = Size,
			LayoutOrder = LayoutOrder,
			ZIndex = ZIndex,
			BackgroundTransparency = 1
		},
		children
	)
end

function StatefulButtonDetector:didMount()
	self.modalDisconnect =
		getModal(self).modalStatus:subscribe(
		function()
			self:updateStates(self.state.isHovered, self.state.isPressed)
		end
	)
end

function StatefulButtonDetector:willUnmount()
	if self.state.isPressed then
		local modal = getModal(self)
		modal.onButtonReleased()
	end
	self.modalDisconnect()
end

return StatefulButtonDetector
