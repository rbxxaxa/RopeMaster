local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local PreciseButton = Roact.PureComponent:extend("PreciseButton")

function PreciseButton:init()
	self:setState {
		mouseInside = false
	}

	self.onMouseMoved = function(rbx, x, y)
		local absPos = rbx.AbsolutePosition
		local absSize = rbx.AbsoluteSize
		local topLeft = absPos
		local bottomRight = absPos + absSize
		local isInside = x > topLeft.X and y > topLeft.Y and x <= bottomRight.X and y <= bottomRight.Y

		local onMouseEnter = self.props[Roact.Event.MouseEnter]
		local onMouseLeave = self.props[Roact.Event.MouseLeave]
		local onMouseMoved = self.props[Roact.Event.MouseMoved]

		if isInside and not self.state.mouseInside then
			self:setState {
				mouseInside = true
			}
			if onMouseEnter then
				onMouseEnter(rbx, x, y)
			end
		elseif not isInside and self.state.mouseInside then
			self:setState {
				mouseInside = false
			}
			if onMouseLeave then
				onMouseLeave(rbx, x, y)
			end
		end

		if onMouseMoved then
			onMouseMoved(rbx, x, y)
		end
	end

	self.onMouseLeave = function(rbx, x, y)
		self:setState {
			mouseInside = false
		}

		local onMouseLeave = self.props[Roact.Event.MouseLeave]

		if onMouseLeave then
			onMouseLeave(rbx, x, y)
		end
	end

	self.onMouseButton1Down = function(rbx, x, y)
		if not self.state.mouseInside then
			return
		end

		local onMouseButton1Down = self.props[Roact.Event.MouseButton1Down]
		local onDoubleMouseButton1Down = self.props.onDoubleMouseButton1Down

		if onMouseButton1Down then
			onMouseButton1Down(rbx, x, y)
		end

		local doubleClickDelay = Constants.DOUBLE_CLICK_DELAY
		local timeNow = tick()
		if timeNow - self.lastClick < doubleClickDelay and onDoubleMouseButton1Down then
			self.lastClick = 0
			onDoubleMouseButton1Down()
		else
			self.lastClick = timeNow
		end
	end

	self.onMouseEnter = function(rbx, x, y)
		local absPos = rbx.AbsolutePosition
		local absSize = rbx.AbsoluteSize
		local topLeft = absPos
		local bottomRight = absPos + absSize
		local isInside = x > topLeft.X and y > topLeft.Y and x <= bottomRight.X and y <= bottomRight.Y

		local onMouseEnter = self.props[Roact.Event.MouseEnter]

		if isInside and not self.state.mouseInside then
			self:setState {
				mouseInside = true
			}
			if onMouseEnter then
				onMouseEnter(rbx, x, y)
			end
		end
	end

	self.onMouseButton1Up = function(rbx, x, y)
		if not self.state.mouseInside then
			return
		end
		local onMouseButton1Up = self.props[Roact.Event.MouseButton1Up]
		if onMouseButton1Up then
			onMouseButton1Up(rbx, x, y)
		end
	end

	self.onMouseButton1Click = function(rbx)
		if not self.state.mouseInside then
			return
		end
		local onMouseButton1Click = self.props[Roact.Event.MouseButton1Click]
		if onMouseButton1Click then
			onMouseButton1Click(rbx)
		end
	end

	self.onMouseButton2Down = function(rbx, x, y)
		if not self.state.mouseInside then
			return
		end
		local onMouseButton2Down = self.props[Roact.Event.MouseButton2Down]
		if onMouseButton2Down then
			onMouseButton2Down(rbx, x, y)
		end
	end

	self.onMouseButton2Up = function(rbx, x, y)
		if not self.state.mouseInside then
			return
		end
		local onMouseButton2Up = self.props[Roact.Event.MouseButton2Up]
		if onMouseButton2Up then
			onMouseButton2Up(rbx, x, y)
		end
	end

	self.onMouseButton2Click = function(rbx)
		if not self.state.mouseInside then
			return
		end
		local onMouseButton2Click = self.props[Roact.Event.MouseButton2Click]
		if onMouseButton2Click then
			onMouseButton2Click(rbx)
		end
	end

	self.lastClick = 0
end

function PreciseButton:render()
	local props = self.props

	return Roact.createElement(
		"TextButton",
		{
			Text = "",
			Size = props.Size,
			Position = props.Position,
			BackgroundColor3 = props.BackgroundColor3,
			BorderSizePixel = props.BorderSizePixel,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			ZIndex = props.ZIndex,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			AutoButtonColor = props.AutoButtonColor,
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseMoved] = self.onMouseMoved,
			[Roact.Event.MouseLeave] = self.onMouseLeave,
			[Roact.Event.MouseButton1Down] = self.onMouseButton1Down,
			[Roact.Event.MouseButton1Up] = self.onMouseButton1Up,
			[Roact.Event.MouseButton1Click] = self.onMouseButton1Click,
			[Roact.Event.MouseButton2Down] = self.onMouseButton2Down,
			[Roact.Event.MouseButton2Up] = self.onMouseButton2Up,
			[Roact.Event.MouseButton2Click] = self.onMouseButton2Click,
			[Roact.Event.InputBegan] = props[Roact.Event.InputBegan],
			[Roact.Event.InputChanged] = props[Roact.Event.InputChanged],
			[Roact.Event.InputEnded] = props[Roact.Event.InputEnded],
			[Roact.Ref] = props[Roact.Ref]
		},
		props[Roact.Children]
	)
end

return PreciseButton
