local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getMainManager = ContextGetter.getMainManager

local RunService = game:GetService("RunService")

local Midpoints = Roact.PureComponent:extend("Midpoints")

function Midpoints:init()
	self.handleRef = Roact.createRef()
	self.partRef = Roact.createRef()
end

function Midpoints:render()
	local props = self.props
	local ZIndex = props.ZIndex

	return Roact.createElement(
		"ViewportFrame",
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
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

function Midpoints:ClearMidpointsModel()
	if self.midpointsModel then
		self.midpointsModel:Destroy()
	end
end

local lineBase = Instance.new("Part")
lineBase.Material = Enum.Material.SmoothPlastic
lineBase.Anchored = true
lineBase.CanCollide = false
lineBase.Color = Color3.new(1, 1, 1)
Instance.new("BlockMesh", lineBase)
local RIGHT = Vector3.new(1, 0, 0)
local UP = Vector3.new(0, 1, 0)
function Midpoints:CreateMidpointModel()
	local handle = self.handleRef.current
	local model = Instance.new("Model")
	local pp = Instance.new("Part")
	pp.CFrame = CFrame.fromMatrix(Vector3.new(), UP, RIGHT)
	pp.Transparency = 1
	pp.Parent = model
	model.PrimaryPart = pp

	self.xs = {}
	self.ys = {}
	self.zs = {}
	self.midpoints = {}
	for i = 1, 9 do
		local pModel = Instance.new("Model")
		local center = Instance.new("Part")
		center.Transparency = 1
		center.Anchored = true
		center.CanCollide = false
		center.Parent = pModel
		pModel.PrimaryPart = center

		local x = lineBase:Clone()
		x.Size = Vector3.new(1, 0.05, 0.05)
		x.Parent = pModel
		self.xs[i] = x

		local y = lineBase:Clone()
		y.Size = Vector3.new(0.05, 1, 0.05)
		y.Parent = pModel
		self.ys[i] = y

		local z = lineBase:Clone()
		z.Size = Vector3.new(0.05, 0.05, 1)
		z.Parent = pModel
		self.zs[i] = z

		pModel.Parent = model
		self.midpoints[i] = pModel
	end

	model.Parent = handle
	self.midpointsModel = model
end

function Midpoints:UpdateMidpointPositions()
	local props = self.props
	local face = props.face
	local part = props.part
	local partSizeHalf = part.Size / 2
	local s_x, s_y, s_z = partSizeHalf.X, partSizeHalf.Y, partSizeHalf.Z

	local cf = part.CFrame
	local cfs = {}
	local right, up
	local faceSizeX, faceSizeY, faceOffset
	if math.abs(face.X) == 1 then
		right, up = cf.lookVector, cf.upVector
		faceSizeX, faceSizeY, faceOffset = s_z, s_y, s_x
	elseif math.abs(face.Y) == 1 then
		right, up = cf.rightVector, cf.lookVector
		faceSizeX, faceSizeY, faceOffset = s_x, s_z, s_y
	else
		right, up = cf.rightVector, cf.upVector
		faceSizeX, faceSizeY, faceOffset = s_x, s_y, s_z
	end

	local worldFace = cf:vectorToWorldSpace(face)
	for x = -1, 1 do
		for y = -1, 1 do
			table.insert(cfs, CFrame.fromMatrix(cf.p + right * faceSizeX * x + up * faceSizeY * y + worldFace * faceOffset, right, up))
		end
	end

	for i, midpt in next, self.midpoints do
		if #midpt:GetDescendants() > 0 then
			midpt:SetPrimaryPartCFrame(cfs[i])
		end
	end
end

-- not used!
function Midpoints:UpdateMidpointsScale()
	for i, midpoint in next, self.midpoints do
		local distance = (workspace.CurrentCamera.CFrame.p - midpoint:GetPrimaryPartCFrame().p).magnitude
		local scale = distance / 20
		local thicknessScale = scale
		local lengthScale = math.clamp(scale, 0, 4)
		self.xs[i].Mesh.Scale = Vector3.new(lengthScale, thicknessScale, thicknessScale)
		self.ys[i].Mesh.Scale = Vector3.new(thicknessScale, lengthScale, thicknessScale)
		self.zs[i].Mesh.Scale = Vector3.new(thicknessScale, thicknessScale, lengthScale)
	end
end

function Midpoints:didMount()
	self:CreateMidpointModel()
	self:UpdateMidpointPositions()

	local mainManager = getMainManager(self)
	self.cursorUnsub =
		mainManager:subscribeToCursor(
		function()
			self:UpdateMidpointsScale()
		end
	)

	RunService:BindToRenderStep(
		"RopeMasterMidpointsUpdate",
		Enum.RenderPriority.Camera.Value + 1,
		function()
			self:UpdateMidpointsScale()
		end
	)
end

function Midpoints:didUpdate(previousProps)
	self:UpdateMidpointPositions()
end

function Midpoints:willUnmount()
	self:ClearMidpointsModel()
	RunService:UnbindFromRenderStep("RopeMasterMidpointsUpdate")
	self.cursorUnsub()
end

return Midpoints
