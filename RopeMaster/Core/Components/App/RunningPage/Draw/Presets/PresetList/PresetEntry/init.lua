local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)
local Utility = require(Plugin.Core.Util.Utility)

local withTheme = ContextHelper.withTheme
local getMainManager = ContextGetter.getMainManager
local getModal = ContextGetter.getModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local PresetPreview = require(Components.PresetPreview)
-- local BorderedFrame = require(Foundation.BorderedFrame)
local RoundedBorderedFrame = require(Foundation.RoundedBorderedFrame)
local RoundedBorderedVerticalList = require(Foundation.RoundedBorderedVerticalList)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)
local PreciseFrame = require(Foundation.PreciseFrame)

local RunService = game:GetService("RunService")

local PresetEntry = Roact.PureComponent:extend("PresetEntry")

function PresetEntry:init()
	local mainManager = getMainManager(self)

	self:setState(
		{
			buttonState = "Default",
			dotState = "Default",
			stale = false,
			hovering = false
		}
	)

	self.boxRef = Roact.createRef()
	self.skyRef = Roact.createRef()

	local modal = getModal(self)
	self.hoveringInternal = false
	self.onHoverDetectorMouseEnter = function()
		self.hoveringInternal = true
		self:UpdateHovering()
	end

	self.onHoverDetectorMouseLeave = function()
		self.hoveringInternal = false
		self:UpdateHovering()
	end

	self.onStateChanged = function(buttonState)
		RunService.Heartbeat:Wait()
		self:setState {
			buttonState = buttonState
		}
	end

	self.onDotStateChanged = function(dotState)
		self:setState {
			dotState = dotState
		}
	end

	self.onCancelButtonClicked = function()
		mainManager:ClearPresetIdBeingDelete()
	end

	self.onClickDetector = function()
		local presetId = self.props.presetId
		local activePreset = mainManager:GetActivePreset()
		if activePreset ~= presetId then
			mainManager:SetActivePreset(presetId)
		end
	end

	self.onDotsClicked = function()
		local presetId = self.props.presetId
		mainManager:OpenPresetEntryContextMenu(presetId)
	end

	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.new(Vector3.new(0, -1.75, 6), Vector3.new(0, -1.75, -1))
	camera.FieldOfView = 40
	self.camera = camera

	local skybox = Constants.SKYBOX_BALL:Clone()
	Utility.ScaleObject(skybox, 100)
	self.skybox = skybox
	self.skybox:SetPrimaryPartCFrame(CFrame.new(self.camera.CFrame.p))

	self:UpdateStateFromMainManager()
end

function PresetEntry:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local presetId = self.props.presetId

	local hasPreset = mainManager:HasPreset(presetId)
	if not hasPreset then
		SmartSetState(
			self,
			{
				stale = true
			}
		)
		return
	end

	local presetType = mainManager:GetPresetType(presetId)
	local active = mainManager:GetActivePreset() == presetId
	local presetName = mainManager:GetPresetName(presetId)

	SmartSetState(
		self,
		{
			presetType = presetType,
			active = active,
			presetName = presetName,
			stale = false
		}
	)
end

function PresetEntry:render()
	if self.state.stale then
		return
	end

	local props = self.props

	return withTheme(
		function(theme)
			local entryTheme = theme.presetEntry

			local entryHeight = 120
			local entryPadding = 4

			local state = self.state
			local presetName = state.presetName
			local active = state.active

			local buttonState = state.buttonState
			local boxState
			if active then
				boxState = "Selected"
			else
				local map = {
					Default = "Default",
					Hovered = "Hovered",
					PressedInside = "PressedInside",
					PressedOutside = "PressedOutside"
				}

				boxState = map[buttonState]
			end

			local bgColors = entryTheme.backgroundColor
			local bgColor = bgColors[boxState]

			return Roact.createElement(
				RoundedBorderedVerticalList,
				{
					width = UDim.new(1, 0),
					LayoutOrder = props.LayoutOrder,
					BackgroundColor3 = theme.mainBackgroundColor,
					BorderColor3 = theme.borderColor
				},
				{
					Wrap = Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, 0, 0, entryHeight),
							BackgroundTransparency = 1,
							LayoutOrder = 1
						},
						{
							Border = Roact.createElement(
								RoundedBorderedFrame,
								{
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundColor3 = bgColor,
									BorderColor3 = theme.borderColor,
									LayoutOrder = props.LayoutOrder,
									slice = "Center"
								}
							),
							HoverDetector = Roact.createElement(
								PreciseFrame,
								{
									[Roact.Event.MouseEnter] = self.onHoverDetectorMouseEnter,
									[Roact.Event.MouseLeave] = self.onHoverDetectorMouseLeave,
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1
								}
							),
							ClickDetector = Roact.createElement(
								StatefulButtonDetector,
								{
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1,
									onClick = self.onClickDetector,
									onStateChanged = self.onStateChanged
								}
							),
							ImageFrame = Roact.createElement(
								"Frame",
								{
									Size = UDim2.new(1, -entryPadding * 2, 1, -entryPadding * 3 - Constants.FONT_SIZE_MEDIUM),
									Position = UDim2.new(0, entryPadding, 0, entryPadding),
									BackgroundTransparency = 1
								},
								{
									PresetPreview = Roact.createElement(
										PresetPreview,
										{
											Size = UDim2.new(1, 0, 1, 0),
											presetId = props.presetId,
											presetParams = props.presetParams
										}
									),
									DotDetector = self.state.hovering and
										Roact.createElement(
											StatefulButtonDetector,
											{
												Size = UDim2.new(0, 32, 0, 32),
												Position = UDim2.new(1, -8, 1, -0),
												BackgroundTransparency = 1,
												AnchorPoint = Vector2.new(1, 1),
												onStateChanged = self.onDotStateChanged,
												onClick = self.onDotsClicked,
												ZIndex = 2
											},
											{
												Shadow = Roact.createElement(
													"ImageLabel",
													{
														BackgroundTransparency = 1,
														Size = UDim2.new(1, 0, 1, 0),
														Position = UDim2.new(0, 2, 0, 2),
														Image = "rbxassetid://3670819736",
														ImageColor3 = Color3.new(0, 0, 0),
														ImageTransparency = 0.25
													}
												),
												Dots = Roact.createElement(
													"ImageLabel",
													{
														BackgroundTransparency = 1,
														Size = UDim2.new(1, 0, 1, 0),
														Position = UDim2.new(0, 0, 0, 0),
														Image = "rbxassetid://3670819736",
														ImageColor3 = state.dotState == "Default" and entryTheme.dotColor.Default or entryTheme.dotColor.Hovered,
														ZIndex = 2
													}
												)
											}
										)
								}
							),
							ContentFrame = Roact.createElement(
								"Frame",
								{
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 1, 0),
									Position = UDim2.new(0, 0, 0, 0),
									ZIndex = 2
								},
								{
									TextLabel = Roact.createElement(
										"TextLabel",
										{
											BackgroundTransparency = 1,
											Font = Constants.FONT_BOLD,
											TextColor3 = entryTheme.textColorEnabled,
											Size = UDim2.new(1, -entryPadding * 2, 0, Constants.FONT_SIZE_MEDIUM + entryPadding * 2),
											Position = UDim2.new(0, entryPadding, 1, -Constants.FONT_SIZE_MEDIUM - entryPadding * 2),
											TextSize = Constants.FONT_SIZE_MEDIUM,
											TextXAlignment = Enum.TextXAlignment.Center,
											TextYAlignment = Enum.TextYAlignment.Center,
											TextTruncate = Enum.TextTruncate.None,
											ZIndex = 9,
											Text = presetName
										}
									)
								}
							)
						}
					)
				}
			)
		end
	)
end

function PresetEntry:CreatePreviewObject()
	debug.profilebegin("PresetEntry:CreatePreviewObject")
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

	debug.profileend()

	return previewObject
end

function PresetEntry:UpdateHovering()
	local modal = getModal(self)
	local hoveringInternal = self.hoveringInternal

	if modal.isAnyButtonPressed() then
		return
	end

	if modal.isShowingModal(0) then
		SmartSetState(self, {hovering=false})
	else
		SmartSetState(self, {hovering=hoveringInternal})
	end
end

function PresetEntry:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
	self.modalDisconnect =
		getModal(self).modalStatus:subscribe(
		function()
			self:UpdateHovering()
		end
	)

	self.skybox.Parent = self.skyRef.current

	local previewObject = self:CreatePreviewObject()
	self.previewObject = previewObject
	self.previewObject.Parent = self.boxRef.current
end

function PresetEntry:willUnmount()
	self.skybox.Parent = nil
	self.previewObject:Destroy()
	self.previewObject = nil
	self.mainManagerDisconnect()
	self.modalDisconnect()
end

return PresetEntry
