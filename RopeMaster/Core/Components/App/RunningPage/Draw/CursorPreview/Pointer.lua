local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local Pointer = Roact.PureComponent:extend("Pointer")

function Pointer:init()
	self.handleRef = Roact.createRef()
	self.partRef = Roact.createRef()
end

function Pointer:render()
	local props = self.props
	local ZIndex = props.ZIndex

	local color = Color3.new(1, 0.5, 0)

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
				},
				{
					Part = Roact.createElement(
						"Part",
						{
							Transparency = 1,
							CanCollide = false,
							Anchored = false,
							[Roact.Ref] = self.partRef
						}
					)
				}
			)
		}
	)
end

function Pointer:ClearPointerModel()
	self.pointerModel:Destroy()
end

function Pointer:CreatePointerModel()
	local PointerModelBase = Constants.POINTER_MODEL
	local model = PointerModelBase:Clone()

	local handle = self.handleRef.current
	model:SetPrimaryPartCFrame(handle:GetPrimaryPartCFrame())
	model.Parent = handle
	self.pointerModel = model
end

-- not used!
function Pointer:UpdatePointerScale()
	--	local distance = (workspace.CurrentCamera.CFrame.p - self.props.cf.p).magnitude
	--	local scale = distance/20
	--	local thicknessScale = scale
	--	local lengthScale = math.clamp(scale, 0, 4)
	--	local pointerModel = self.pointerModel
	--	pointerModel.X.Mesh.Scale = Vector3.new(lengthScale, scale, scale)
	--	pointerModel.Y.Mesh.Scale = Vector3.new(scale, lengthScale, scale)
	--	pointerModel.Z.Mesh.Scale = Vector3.new(scale, scale, lengthScale)
end

function Pointer:didMount()
	local props = self.props
	local handle = self.handleRef.current
	local part = self.partRef.current
	handle.PrimaryPart = part
	local cf = props.cf
	handle:SetPrimaryPartCFrame(cf)

	self:CreatePointerModel()
end

function Pointer:didUpdate(previousProps)
	local handle = self.handleRef.current
	handle:SetPrimaryPartCFrame(self.props.cf)
end

function Pointer:willUnmount()
	self:ClearPointerModel()
end

return Pointer
