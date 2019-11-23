local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Types = require(Plugin.Core.Util.Types)
local Constants = require(Plugin.Core.Util.Constants)
local Utility = require(Plugin.Core.Util.Utility)

local withTheme = ContextHelper.withTheme
local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)

local PresetPreview = Roact.PureComponent:extend("PresetPreview")

function PresetPreview:init()
	self.skyRef = Roact.createRef()
	self.boxRef = Roact.createRef()

	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(Vector3.new(0, -1.75, 6), Vector3.new(0, -1.75, -1))
	camera.FieldOfView = 40
	self.camera = camera

	local skybox = Constants.SKYBOX_BALL:Clone()
	Utility.ScaleObject(skybox, 100)
	self.skybox = skybox
	self.skybox:SetPrimaryPartCFrame(CFrame.new(self.camera.CFrame.p))
end

function PresetPreview:render()
	local props = self.props
	local Position = props.Position
	local Size = props.Size
	return withTheme(
		function(theme)
			return Roact.createElement(
				BorderedFrame,
				{
					Size = Size,
					Position = Position,
					BackgroundColor3 = theme.mainBackgroundColor,
					BorderColor3 = theme.borderColor,
					ZIndex = 2
				},
				{
					SkyboxFrame = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, -2, 1, -2),
							Position = UDim2.new(0, 1, 0, 1),
							BorderSizePixel = 0,
							BackgroundColor3 = Color3.new(0, 0, 0),
							Ambient = Color3.new(2, 2, 2),
							LightColor = Color3.new(0, 0, 0),
							ZIndex = 2,
							CurrentCamera = self.camera,
							[Roact.Ref] = self.skyRef
						}
					),
					Render = Roact.createElement(
						"ViewportFrame",
						{
							Size = UDim2.new(1, -2, 1, -2),
							Position = UDim2.new(0, 1, 0, 1),
							BorderSizePixel = 0,
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.new(0, 0, 0),
							Ambient = Color3.new(0.5, 0.5, 0.5),
							LightColor = Color3.new(1, 1, 1),
							LightDirection = Vector3.new(-1, -1, -1),
							ZIndex = 3,
							CurrentCamera = self.camera,
							[Roact.Ref] = self.boxRef
						}
					)
				}
			)
		end
	)
end

function PresetPreview:UpdatePreviewObject()
	debug.profilebegin("PresetPreview:UpdatePreviewObject")
	if self.previewObject then
		self.previewObject:Destroy()
	end

	local mainManager = getMainManager(self)

	local presetId = self.props.presetId
	local previewObjectModel =
		mainManager:DrawPreset(
		presetId,
		{
			curveType = Types.Curve.CATENARY,
			length = 15,
			points = {Vector3.new(-6.5, 0, 0), Vector3.new(6.5, 0, 0)},
			seed = 0
		}
	)
	local previewObject = Instance.new("Model")
	previewObjectModel.Parent = previewObject

	self.previewObject = previewObject
	self.previewObject.Parent = self.boxRef.current

	debug.profileend()
end

function PresetPreview:didMount()
	self.skybox.Parent = self.skyRef.current

	local mainManager = getMainManager(self)
	if self.props.presetId then
		self.presetChangedDisconnect =
			mainManager:subscribeToPresetChanged(
			self.props.presetId,
			function()
				self:UpdatePreviewObject()
			end
		)
		self:UpdatePreviewObject()
	end
end

function PresetPreview:willUpdate(nextProps, nextState)
	local currentPresetId = self.props.presetId
	local nextPresetId = nextProps.presetId
	if nextPresetId ~= currentPresetId then
		self.presetChangedDisconnect()
		local mainManager = getMainManager(self)
		self.presetChangedDisconnect =
			mainManager:subscribeToPresetChanged(
			nextPresetId,
			function()
				self:UpdatePreviewObject()
			end
		)
		self.shouldUpdatePreviewObject = true
	end
end

function PresetPreview:didUpdate()
	if self.shouldUpdatePreviewObject then
		self:UpdatePreviewObject()
		self.shouldUpdatePreviewObject = false
	end
end

function PresetPreview:willUnmount()
	self.skybox.Parent = nil
	self.previewObject:Destroy()
	self.previewObject = nil
	self.presetChangedDisconnect()
end

return PresetPreview
