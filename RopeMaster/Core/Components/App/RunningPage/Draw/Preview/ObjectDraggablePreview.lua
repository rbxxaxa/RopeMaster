local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local ObjectDraggablePreview = Roact.PureComponent:extend("ObjectDraggablePreview")

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local ThemedTextButton = require(Foundation.ThemedTextButton)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)

local defaultFOV = 40

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

local function panCFrame(cf, x, y)
	return cf * CFrame.new(-x, y, 0)
end

local function rotateCFrame(cf, x, y)
	cf = CFrame.fromAxisAngle(cf.RightVector, -y) * cf
	cf = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -x) * cf
	return cf
end

local function lerp(a, b, alpha)
	return a + (b - a) * alpha
end

function ObjectDraggablePreview:init()
	self:setState {
		cf = self.props.cf
	}

	self.skyRef = Roact.createRef()
	self.boxRef = Roact.createRef()
	self.blockerRef = Roact.createRef()

	self.onCFrameChanged = function(newCf)
		if self.props.onCFrameChanged then
			self.props.onCFrameChanged(newCf)
		end
	end

	self.onReset = function()
		if self.props.onReset then
			self.props.onReset()
		end
	end

	self.onInputChanged = function(rbx, input)
		local cf = self.props.cf
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.MouseMovement then
			local delta = input.delta
			if self.panning then
				local projected = Utility.ProjectPointToPlane(cf.p, Vector3.new(), -cf.lookVector)
				local dist = (cf.p - projected).magnitude
				local zoomFactor = lerp(0.008, 0.09, (dist - 2) / 22)
				local newCf = panCFrame(cf, delta.X * zoomFactor, delta.Y * zoomFactor)
				self.onCFrameChanged(newCf)
			elseif self.rotating then
				local newCf = rotateCFrame(cf, delta.X * 0.015, delta.Y * 0.015)
				self.onCFrameChanged(newCf)
			end
		elseif inputType == Enum.UserInputType.MouseWheel then
			local wheelDir = input.Position.Z
			local projected = Utility.ProjectPointToPlane(cf.p, Vector3.new(), -cf.lookVector)
			local dist = (cf.p - projected).magnitude
			local moveAmount = math.max(dist * 0.1, 0.1)
			-- prevent the camera from zooming too close...
			if wheelDir > 0 then
				-- and zooming too far.
				moveAmount = math.min(moveAmount, dist - 2)
			elseif wheelDir < 0 then
				moveAmount = math.min(moveAmount, 24 - dist)
			end
			local newCf = cf * CFrame.new(0, 0, -moveAmount * wheelDir)
			self.onCFrameChanged(newCf)
		end
	end

	self.onInputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.rotating = true
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.panning = true
		end
	end

	self.onInputEnded = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.rotating = false
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.panning = false
		end
	end
end

function ObjectDraggablePreview:render()
	local props = self.props
	local object = props.object
	local Position = props.Position
	local Size = props.Size
	local ZIndex = props.ZIndex
	assert(object == nil or (object:IsA("BasePart") or object.ClassName == "Model"))

	return withTheme(
		function(theme)
			return Roact.createElement(
				StatefulButtonDetector,
				{
					Size = Size,
					Position = Position,
					ZIndex = ZIndex,
					BackgroundTransparency = 1,
					[Roact.Event.InputBegan] = self.onInputBegan,
					[Roact.Event.InputEnded] = self.onInputEnded,
					[Roact.Event.InputChanged] = self.onInputChanged
				},
				{
					ScrollBlocker = Roact.createElement(
						"ScrollingFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							ScrollingEnabled = true,
							CanvasSize = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							ScrollBarThickness = 0,
							ZIndex = 1,
							[Roact.Ref] = self.blockerRef
						}
					),
					SkyboxFrame = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundColor3 = Color3.new(0, 0, 0),
							BorderColor3 = theme.borderColor,
							Ambient = Color3.new(1, 1, 1),
							LightColor = Color3.new(0, 0, 0),
							ZIndex = 2,
							[Roact.Ref] = self.skyRef
						}
					),
					Render = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, 0, 1, 0),
							BorderSizePixel = 0,
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(0, 0, 0),
							BorderColor3 = theme.borderColor,
							Ambient = Color3.new(0.5, 0.5, 0.5),
							LightColor = Color3.new(1, 1, 1),
							LightDirection = Vector3.new(-1, -1, -1),
							ZIndex = 3,
							[Roact.Ref] = self.boxRef
						}
					),
					ResetViewButton = Roact.createElement(
						ThemedTextButton,
						{
							Size = UDim2.new(0, 100, 0, Constants.BUTTON_HEIGHT),
							BorderSizePixel = 0,
							Position = UDim2.new(0, 8, 1, -8),
							AnchorPoint = Vector2.new(0, 1),
							Text = "Reset View",
							ZIndex = 4,
							onClick = self.onReset
						}
					)
				}
			)
		end
	)
end

function ObjectDraggablePreview:UpdateCamera()
	local camera = self.camera
	if camera == nil then
		camera = Instance.new("Camera")
		camera.FieldOfView = defaultFOV
		self.camera = camera
		self.boxRef.current.CurrentCamera = camera
		self.skyRef.current.CurrentCamera = camera
	end
	camera.CFrame = self.props.cf
	camera.FieldOfView = defaultFOV
end

function ObjectDraggablePreview:UpdateFrameContents()
	debug.profilebegin("ObjectDraggablePreview:UpdateFrameContents")
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

function ObjectDraggablePreview:UpdateSkybox()
	if self.skybox == nil then
		local frame = self.skyRef.current
		local skybox = Constants.SKYBOX_BALL:Clone()
		Utility.ScaleObject(skybox, 100)
		skybox.Parent = frame
		self.skybox = skybox
	end

	if self.camera then
		self.skybox:SetPrimaryPartCFrame(CFrame.new(self.camera.CFrame.p))
	else
		self.skybox:SetPrimaryPartCFrame(CFrame.new())
	end
end

function ObjectDraggablePreview:didMount()
	local props = self.props
	local object = props.object
	if object then
		self:UpdateFrameContents()
	end
	self:UpdateCamera()
	self:UpdateSkybox()
	self.blockerRef.current.CanvasPosition = Vector2.new(0, 500)
end

function ObjectDraggablePreview:willUnmount()
	if self.currentObject then
		self.currentObject:Destroy()
	end

	if self.camera then
		self.camera:Destroy()
	end

	self.skybox.Parent = nil
	self.previewObject:Destroy()
	self.previewObject = nil
end

function ObjectDraggablePreview:didUpdate(oldProps)
	local newProps = self.props
	local newObject, oldObject = newProps.object, oldProps.object
	if newObject ~= oldObject then
		self:UpdateFrameContents()
	end
	self:UpdateCamera()
	self:UpdateSkybox()
end

return ObjectDraggablePreview
