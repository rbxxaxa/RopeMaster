local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local Catenary = Roact.PureComponent:extend("Catenary")

function Catenary:init()
	self.handleRef = Roact.createRef()
end

function Catenary:render()
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

function Catenary:RenderRope()
	local handle = self.handleRef.current

	local props = self.props
	local start, fin = props.start.p, props.fin.p
	local distance = (start - fin).magnitude
	if self.ropeModel then
		self.ropeModel:Destroy()
	end
	local mainManager = getMainManager(self)

	local lengthMode = props.lengthMode
	local length
	if lengthMode == Types.CatenaryLengthMode.FIXED then
		length = props.lengthFixed
	else
		length = distance * props.lengthRelative + Constants.DANGLE_LENGTH_FUDGE
	end

	local ropeModel
	if props.valid then
		ropeModel =
			mainManager:DrawPreset(
			"PreviewOk",
			{
				curveType = Types.Curve.CATENARY,
				points = {
					start,
					fin
				},
				length = length
			}
		)
	else
		ropeModel =
			mainManager:DrawPreset(
			"PreviewBad",
			{
				curveType = Types.Curve.CATENARY,
				points = {
					start,
					fin
				},
				length = length
			}
		)
	end

	self.ropeModel = ropeModel
	if ropeModel then
		ropeModel.Parent = handle
	end
end

function Catenary:didMount()
	self:RenderRope()
end

function Catenary:didUpdate()
	self:RenderRope()
end

return Catenary
