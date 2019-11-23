local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local Loop = Roact.PureComponent:extend("Loop")

function Loop:init()
	self.handleRef = Roact.createRef()
end

function Loop:render()
	local props = self.props
	local ZIndex = props.ZIndex
	local valid = props.valid

	local color = valid and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)

	return Roact.createElement(
		"ViewportFrame",
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BackgroundColor3 = color,
			ImageColor3 = color,
			ZIndex = ZIndex,
			CurrentCamera = workspace.CurrentCamera
		},
		{
			Handle = Roact.createElement(
				"Model",
				{
					[Roact.Ref] = self.handleRef
				}
			)
		}
	)
end

function Loop:RenderRope()
	local handle = self.handleRef.current

	local props = self.props
	local hit, p, p2 = props.hit, props.p, props.p2
	local shape, offset = props.shape, props.offset
	if self.ropeModel then
		self.ropeModel:Destroy()
	end

	local mainManager = getMainManager(self)
	local ropeModel =
		mainManager:DrawPreset(
		"PreviewOk",
		{
			curveType = Types.Curve.LOOP,
			shape = shape,
			hit = hit,
			p = p,
			p2 = p2,
			offset = offset
		}
	)

	self.ropeModel = ropeModel
	if ropeModel then
		ropeModel.Parent = handle
	end
end

function Loop:didMount()
	self:RenderRope()
end

function Loop:didUpdate()
	self:RenderRope()
end

return Loop
