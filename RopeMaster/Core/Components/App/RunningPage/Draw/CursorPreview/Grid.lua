local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getMainManager = ContextGetter.getMainManager

local RunService = game:GetService("RunService")

local Grid = Roact.PureComponent:extend("Grid")

function Grid:init()
	self.handleRef = Roact.createRef()
	self.partRef = Roact.createRef()
end

function Grid:render()
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
				},
				{
					Part = Roact.createElement(
						"Part",
						{
							Transparency = 1,
							CanCollide = false,
							Anchored = true,
							[Roact.Ref] = self.partRef
						}
					)
				}
			)
		}
	)
end

function Grid:ClearGridModel()
	if self.gridModel then
		self.gridModel:Destroy()
	end
end

local gridLineBase = Instance.new("Part")
gridLineBase.Material = Enum.Material.SmoothPlastic
gridLineBase.Anchored = true
gridLineBase.CanCollide = false
gridLineBase.Color = Color3.new(1, 1, 1)
Instance.new("BlockMesh", gridLineBase)
local RIGHT = Vector3.new(1, 0, 0)
local UP = Vector3.new(0, 1, 0)
function Grid:UpdateGridModelAppearance(gridSize)
	self:ClearGridModel()

	local model = Instance.new("Model")
	local pp = Instance.new("Part")
	pp.CFrame = CFrame.fromMatrix(Vector3.new(), UP, RIGHT)
	pp.Transparency = 1
	pp.Parent = model
	model.PrimaryPart = pp
	local lineCount = math.max(2 / gridSize, 2)

	local gridLen = gridSize * (lineCount * 2 + 1)
	self.X, self.Y = {}, {}
	for i = -lineCount, lineCount, 1 do
		local p = gridLineBase:Clone()
		p.CFrame = CFrame.fromMatrix(Vector3.new(0, i * gridSize, 0), UP, RIGHT)
		p.Size = Vector3.new(0.05, gridLen, 0.05)
		p.Parent = model
		table.insert(self.X, p)
	end

	for i = -lineCount, lineCount, 1 do
		local p = gridLineBase:Clone()
		p.CFrame = CFrame.fromMatrix(Vector3.new(i * gridSize, 0, 0), UP, RIGHT)
		p.Size = Vector3.new(gridLen, 0.05, 0.05)
		p.Parent = model
		table.insert(self.Y, p)
	end

	local handle = self.handleRef.current
	model:SetPrimaryPartCFrame(handle:GetPrimaryPartCFrame())
	model.Parent = handle
	self.gridModel = model
end

function Grid:UpdateGridScale()
	local distance = (workspace.CurrentCamera.CFrame.p - self.props.cf.p).magnitude
	local scale = distance / 20
	for _, x in next, self.X do
		x.Mesh.Scale = Vector3.new(scale, 1, scale)
	end

	for _, y in next, self.Y do
		y.Mesh.Scale = Vector3.new(1, scale, scale)
	end
end

function Grid:didMount()
	local props = self.props
	local handle = self.handleRef.current
	local part = self.partRef.current
	handle.PrimaryPart = part
	local cf = props.cf
	handle:SetPrimaryPartCFrame(cf)

	self:UpdateGridModelAppearance(props.gridSize)

	local mainManager = getMainManager(self)
	self.cursorUnsub =
		mainManager:subscribeToCursor(
		function()
			self:UpdateGridScale()
		end
	)

	RunService:BindToRenderStep(
		"RopeMasterGridUpdate",
		Enum.RenderPriority.Camera.Value + 1,
		function()
			self:UpdateGridScale()
		end
	)
end

function Grid:didUpdate(previousProps)
	local handle = self.handleRef.current
	local props = self.props

	if previousProps.gridSize ~= props.gridSize then
		self:UpdateGridModelAppearance(props.gridSize)
	end

	handle:SetPrimaryPartCFrame(props.cf)
end

function Grid:willUnmount()
	self:ClearGridModel()
	RunService:UnbindFromRenderStep("RopeMasterGridUpdate")
	self.cursorUnsub()
end

return Grid
