local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local PreciseFrame = Roact.PureComponent:extend("PreciseFrame")

function PreciseFrame:init()
	self:setState {
		mouseInside = false
	}

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
end

function PreciseFrame:render()
	local props = self.props

	return Roact.createElement(
		"Frame",
		{
			Size = props.Size,
			Position = props.Position,
			BackgroundColor3 = props.BackgroundColor3,
			BorderSizePixel = props.BorderSizePixel,
			BackgroundTransparency = props.BackgroundTransparency,
			AnchorPoint = props.AnchorPoint,
			ZIndex = props.ZIndex,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			[Roact.Event.MouseEnter] = self.onMouseEnter,
			[Roact.Event.MouseMoved] = self.onMouseMoved,
			[Roact.Event.MouseLeave] = self.onMouseLeave
		},
		props[Roact.Children]
	)
end

return PreciseFrame
