local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local Line = Roact.PureComponent:extend("Line")

function Line:init()
	self.handleRef = Roact.createRef()
end

function Line:render()
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

function Line:RenderRope()
	local handle = self.handleRef.current

	local props = self.props
	local start, fin = props.start.p, props.fin.p
	if self.ropeModel then
		self.ropeModel:Destroy()
	end
	local mainManager = getMainManager(self)

	local ropeModel
	if props.valid then
		ropeModel =
			mainManager:DrawPreset(
			"PreviewOk",
			{
				curveType = Types.Curve.LINE,
				points = {
					start,
					fin
				}
			}
		)
	else
		ropeModel =
			mainManager:DrawPreset(
			"PreviewBad",
			{
				curveType = Types.Curve.LINE,
				points = {
					start,
					fin
				}
			}
		)
	end

	self.ropeModel = ropeModel
	if ropeModel then
		ropeModel.Parent = handle
	end
end

function Line:didMount()
	self:RenderRope()
end

function Line:didUpdate()
	self:RenderRope()
end

return Line
