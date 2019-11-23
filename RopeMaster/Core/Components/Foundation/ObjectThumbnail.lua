local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local ObjectThumbnail = Roact.PureComponent:extend("ObjectThumbnail")

local function prepareForThumbnail(object, _isRoot)
	for _, child in next, object:GetChildren() do
		if child:IsA("Script") then
			child.Disabled = true
		end
	end
end

local function moveObjectForCamera(object)
	if #object:GetChildren() == 0 and object:IsA("Model") then
		return
	end

	if object:IsA("Model") then
		local min, max = Utility.GetModelAABBFast(object)
		local handle = Instance.new("Part")
		handle.CFrame = CFrame.new((min + max) / 2)
		local originalPrimaryPart = object.PrimaryPart
		object.PrimaryPart = handle
		object:SetPrimaryPartCFrame(CFrame.new())
		object.PrimaryPart = originalPrimaryPart
	else
		object.CFrame = object.CFrame - object.Position
	end
end

local function GetZoomOffset(fov, aspectRatio, targetSize, percentOfScreen)
	local x, y, z = targetSize.x, targetSize.y, targetSize.Z
	local sorted = {x, y, z}
	table.sort(sorted)
	local maxSize = math.sqrt(sorted[3] ^ 2 + sorted[2] ^ 2)
	local heightFactor = math.tan(math.rad(fov) / 2)
	local widthFactor = aspectRatio * heightFactor

	local depth = 0.5 * maxSize / (percentOfScreen.x * widthFactor)
	local depthTwo = 0.5 * maxSize / (percentOfScreen.y * heightFactor)

	return math.max(depth, depthTwo) + maxSize / 2
end

ObjectThumbnail.defaultProps = {
	scaleFudge = 1,
	fov = 20,
	look = Vector3.new(-0.5, -0.4, -0.5),
	autoCf = false,
	Ambient = Color3.new(1, 1, 1),
	LightDirection = Vector3.new(0, -1, 0),
	LightColor = Color3.new(0, 0, 0)
}

function ObjectThumbnail:init()
	self.boxRef = Roact.createRef()
end

function ObjectThumbnail:render()
	local props = self.props
	local object = props.object
	local BackgroundColor3 = props.BackgroundColor3
	local ImageTransparency = props.ImageTransparency or 0
	local ImageColor3 = props.ImageColor3
	local Position = props.Position
	local Size = props.Size
	local ZIndex = props.ZIndex
	local Ambient = props.Ambient
	local LightColor = props.LightColor
	local LightDirection = props.LightDirection
	assert(object == nil or (object:IsA("BasePart") or object.ClassName == "Model"))

	return Roact.createElement(
		"ViewportFrame",
		{
			Size = Size,
			Position = Position,
			BackgroundColor3 = BackgroundColor3,
			BackgroundTransparency = 1,
			ImageColor3 = ImageColor3,
			ImageTransparency = ImageTransparency,
			ZIndex = ZIndex,
			Ambient = Ambient,
			LightColor = LightColor,
			LightDirection = LightDirection,
			[Roact.Ref] = self.boxRef
		}
	)
end

function ObjectThumbnail:UpdateCamera()
	local props = self.props
	local frame = self.boxRef.current
	if self.camera == nil then
		self.camera = Instance.new("Camera")
		frame.CurrentCamera = self.camera
	end
	self.camera.FieldOfView = props.fov
	local currentObject = self.currentObject
	if currentObject then
		local min, max
		if currentObject:IsA("Model") then
			min, max = Utility.GetModelAABBFast(currentObject)
		else
			min, max = Utility.GetPartAABB(currentObject)
		end

		if props.autoCf then
			local look = props.look
			local offset =
				GetZoomOffset(
				props.fov,
				frame.AbsoluteSize.X / frame.AbsoluteSize.Y,
				(max - min),
				Vector2.new(props.scaleFudge, props.scaleFudge)
			)
			self.camera.CFrame = CFrame.new(-look * offset, Vector3.new())
		else
			self.camera.CFrame = props.cf
		end
	end
end

function ObjectThumbnail:UpdateFrameContents()
	debug.profilebegin("ObjectThumbnail:UpdateFrameContents")
	local frame = self.boxRef.current
	local currentObject = self.currentObject
	if currentObject then
		currentObject:Destroy()
		self.currentObject = nil
	end

	local props = self.props
	local object = props.object
	if object then
		local copy = object:Clone()
		prepareForThumbnail(copy)
		moveObjectForCamera(copy)
		self.currentObject = copy
		copy.Parent = frame
	end
	debug.profileend()
end

function ObjectThumbnail:didMount()
	local props = self.props
	local viewportFrame = self.boxRef.current
	local object = props.object

	if object then
		self:UpdateFrameContents()
		self:UpdateCamera()
	end

	self.resizeConn =
		viewportFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			if self.props.object then
				self:UpdateCamera()
			end
		end
	)
end

function ObjectThumbnail:willUnmount()
	if self.currentObject then
		self.currentObject:Destroy()
	end

	if self.camera then
		self.camera:Destroy()
	end

	self.resizeConn:Disconnect()
end

function ObjectThumbnail:didUpdate(oldProps)
	local newProps = self.props
	local newObject, oldObject = newProps.object, oldProps.object
	if newObject ~= oldObject then
		self:UpdateFrameContents()
	end
	self:UpdateCamera()
end

return ObjectThumbnail
