local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local ObjectDraggablePreview = require(script.ObjectDraggablePreview)

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)

local RunService = game:GetService("RunService")

local Preview = Roact.PureComponent:extend("Preview")

local DEFAULT_VIEW = CFrame.new(Vector3.new(0, -1, 12), Vector3.new(0, -1, 0))

function Preview:init()
	local mainManager = getMainManager(self)

	self.togglePreviewSection = function()
		mainManager:ToggleCollapsibleSection("Preview")
	end

	self:UpdateStateFromMainManager()

	self.state = {
		shouldRenderOnFloater = false,
		cf = DEFAULT_VIEW,
		height = 0,
		verticalOffsetFromFloater = 0
	}

	self.spacerRef = Roact.createRef()
	self.movableRef = Roact.createRef()

	self.onCFrameChanged = function(newCf)
		self:setState {
			cf = newCf
		}
	end

	self.onReset = function()
		self:setState {
			cf = DEFAULT_VIEW
		}
	end
end

function Preview:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local previewCollapsed = mainManager:IsSectionCollapsed("Preview")
	SmartSetState(
		self,
		{
			previewCollapsed = previewCollapsed,
		}
	)
end

function Preview:render()
	local state = self.state
	local previewCollapsed = state.previewCollapsed
	local presetId = self.props.presetId
	local floater = self.props.floater
	local shouldRenderOnFloater = self.state.shouldRenderOnFloater
	local height = self.state.height
	local verticalOffsetFromFloater = self.state.verticalOffsetFromFloater
	return Roact.createElement(
		"Frame",
		{
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 0, height),
			BackgroundTransparency = 1,
			[Roact.Ref] = self.spacerRef,
			LayoutOrder = self.props.LayoutOrder,
			Visible = presetId ~= nil
		},
		{
			Movable = Roact.createElement(
				Roact.Portal,
				{
					target = floater
				},
				{
					DropShadow = shouldRenderOnFloater and
						Roact.createElement(
							"ImageLabel",
							{
								Size = UDim2.new(1, 0, 0, height + 8),
								Position = UDim2.new(0, 0, 0, verticalOffsetFromFloater - 4),
								BackgroundTransparency = 1,
								Image = "rbxassetid://3136399270",
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = Rect.new(5, 5, 14, 14),
								Visible = presetId ~= nil
							}
						),
					List = Roact.createElement(
						VerticalList,
						{
							Position = UDim2.new(0, 0, 0, verticalOffsetFromFloater),
							width = UDim.new(1, 0),
							[Roact.Ref] = self.movableRef,
							PaddingLeftPixel = 4,
							PaddingRightPixel = 4,
							ZIndex = 2,
							Visible = presetId ~= nil
						},
						{
							Collapse = Roact.createElement(
								PaddedCollapsibleSection,
								{
									title = "Preview",
									collapsed = previewCollapsed,
									onCollapseToggled = self.togglePreviewSection,
									LayoutOrder = 1
								},
								{
									PreviewFrame = Roact.createElement(
										"Frame",
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, 0, 0, 200)
										},
										{
											Preview = Roact.createElement(
												ObjectDraggablePreview,
												{
													Size = UDim2.new(1, -2, 1, -2),
													Position = UDim2.new(0, 1, 0, 1),
													object = self.previewObject,
													cf = self.state.cf,
													onCFrameChanged = self.onCFrameChanged,
													onReset = self.onReset
												}
											)
										}
									)
								}
							)
						}
					)
				}
			)
		}
	)
end

function Preview:willUpdate(nextProps, nextState)
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
	end
end

function Preview:UpdatePreviewObject()
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

function Preview:UpdateHeight()
	local movable = self.movableRef.current
	self:setState {
		height = movable.AbsoluteSize.Y
	}
end

function Preview:UpdatePositionOnFloater()
	local spacer = self.spacerRef.current
	local floater = self.props.floater
	local movable = self.movableRef.current
	if floater and spacer and movable then
		local floaterTopLeft = floater.AbsolutePosition
		local spacerTopLeft = spacer.AbsolutePosition

		local verticalOffsetFromFloater = (spacerTopLeft - floaterTopLeft).Y
		local shouldRenderOnFloater = false
		if verticalOffsetFromFloater < 4 then
			verticalOffsetFromFloater = 4
			shouldRenderOnFloater = true
		end

		self:setState {
			verticalOffsetFromFloater = verticalOffsetFromFloater,
			shouldRenderOnFloater = shouldRenderOnFloater
		}
	end
end

function Preview:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)

	local spacer = self.spacerRef.current

	self.positionChangedConn =
		spacer:GetPropertyChangedSignal("AbsolutePosition"):Connect(
		function()
			self:UpdatePositionOnFloater()
		end
	)

	local movable = self.movableRef.current
	self.sizeChangedConn =
		movable:GetPropertyChangedSignal("AbsoluteSize"):Connect(
		function()
			self:UpdateHeight()
		end
	)

	self:UpdateHeight()
	self:UpdatePositionOnFloater()

	self.hConn =
		RunService.Heartbeat:Connect(
		function()
			self:UpdateHeight()
			self:UpdatePositionOnFloater()
		end
	)
end

function Preview:willUnmount()
	self.mainManagerDisconnect()
	self.presetChangedDisconnect()
	self.sizeChangedConn:Disconnect()
	self.positionChangedConn:Disconnect()
	self.hConn:Disconnect()
end

return Preview
