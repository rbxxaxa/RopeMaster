local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local RunService = game:GetService("RunService")

local Pointer = Roact.PureComponent:extend("Pointer")

function Pointer:init()
	self.handleRef = Roact.createRef()
	self.partRef = Roact.createRef()
end

function Pointer:render()
	local props = self.props
	local ZIndex = props.ZIndex

	return Roact.createElement(
		"ViewportFrame",
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(0, 0, 0),
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

local lineBase = Instance.new("Part")
lineBase.Material = Enum.Material.SmoothPlastic
lineBase.Anchored = true
lineBase.CanCollide = false
Instance.new("BlockMesh", lineBase)
local RIGHT = Vector3.new(1, 0, 0)
local UP = Vector3.new(0, 1, 0)
function Pointer:CreatePointerModel()
	local model = Instance.new("Model")
	local pp = Instance.new("Part")
	pp.CFrame = CFrame.fromMatrix(Vector3.new(), UP, RIGHT)
	pp.Transparency = 1
	pp.Parent = model
	model.PrimaryPart = pp

	local line
	-- x
	line = lineBase:Clone()
	line.Size = Vector3.new(2, 0.1, 0.1)
	line.Color = Color3.new(1, 0.2, 0.2)
	line.Parent = model
	line.Name = "X"

	-- y
	line = lineBase:Clone()
	line.Size = Vector3.new(0.1, 2, 0.1)
	line.Color = Color3.new(0.2, 1, 0.2)
	line.Parent = model
	line.Name = "Y"

	-- z
	line = lineBase:Clone()
	line.Size = Vector3.new(0.1, 0.1, 2)
	line.Color = Color3.new(0.2, 0.2, 1)
	line.Parent = model
	line.Name = "Z"

	local handle = self.handleRef.current
	model:SetPrimaryPartCFrame(handle:GetPrimaryPartCFrame())
	model.Parent = handle
	self.pointerModel = model
end

function Pointer:UpdatePointerScale()
	local distance = (workspace.CurrentCamera.CFrame.p - self.props.cf.p).magnitude
	local scale = distance / 20
	local lengthScale = math.clamp(scale, 0, 4)
	local pointerModel = self.pointerModel
	pointerModel.X.Mesh.Scale = Vector3.new(lengthScale, scale, scale)
	pointerModel.Y.Mesh.Scale = Vector3.new(scale, lengthScale, scale)
	pointerModel.Z.Mesh.Scale = Vector3.new(scale, scale, lengthScale)
end

function Pointer:didMount()
	local props = self.props
	local handle = self.handleRef.current
	local part = self.partRef.current
	handle.PrimaryPart = part
	local cf = props.cf
	handle:SetPrimaryPartCFrame(cf)

	self:CreatePointerModel()

	self.rConn =
		RunService.RenderStepped:Connect(
		function()
			self:UpdatePointerScale()
		end
	)
end

function Pointer:didUpdate(previousProps)
	local handle = self.handleRef.current
	handle:SetPrimaryPartCFrame(self.props.cf)
end

function Pointer:willUnmount()
	self:ClearPointerModel()
	self.rConn:Disconnect()
end

return Pointer
