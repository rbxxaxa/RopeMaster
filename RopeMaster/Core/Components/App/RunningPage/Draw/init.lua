local Plugin = script.Parent.Parent.Parent.Parent.Parent

local RunService = game:GetService("RunService")

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Utility = require(Plugin.Core.Util.Utility)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager
local withTheme = ContextHelper.withTheme
local withModal = ContextHelper.withModal

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local ModalBase = require(Foundation.ModalBase)
local ThemedTextButtonWithIcon = require(Foundation.ThemedTextButtonWithIcon)
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local StatefulButtonDetector = require(Foundation.StatefulButtonDetector)
local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)
local CursorPreview = require(script.CursorPreview)
local CurvePreview = require(script.CurvePreview)
local ScrollingVerticalList = require(Foundation.ScrollingVerticalList)
local CurveSettings = require(script.CurveSettings)
local CursorSettings = require(script.CursorSettings)
local Presets = require(script.Presets)
local PresetSettings = require(script.PresetSettings)

local Draw = Roact.PureComponent:extend("Draw")

local DeletePresetModal
do
	local ModalBase = require(Foundation.ModalBase)
	local ModalWindow = require(Foundation.ModalWindow)
	local PresetPreview = require(Components.PresetPreview)

	DeletePresetModal = Roact.PureComponent:extend("DeletePresetModal")

	function DeletePresetModal:init()
		local mainManager = getMainManager(self)
		self.onDeleteCancelled = function()
			mainManager:ClearPresetIdBeingDeleted()
		end

		self.onDeleteConfirmed = function()
			mainManager:DeletePreset(self.props.presetId)
		end
	end

	function DeletePresetModal:render()
		return withTheme(
			function(theme)
				return withModal(
					function(modalTarget, modalStatus)
						return Roact.createElement(
							ModalBase,
							{
								target = modalTarget,
								ZIndex = 10,
								modalIndex = 1
							},
							{
								Shader = Roact.createElement(
									"Frame",
									{
										BackgroundTransparency = 0.3,
										BackgroundColor3 = theme.shaderColor,
										BorderSizePixel = 0,
										Size = UDim2.new(1, 0, 1, 0),
										ZIndex = 1
									}
								),
								Window = Roact.createElement(
									ModalWindow,
									{
										title = "Deleting Preset...",
										ZIndex = 2
									},
									{
										PresetPreview = Roact.createElement(
											PresetPreview,
											{
												Size = UDim2.new(1, 0, 0, 72),
												LayoutOrder = 1,
												presetId = self.props.presetId
											}
										),
										AreYouSure = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = ('Are you sure you want to delete "%s"?'):format(self.props.presetName),
												LayoutOrder = 2,
												TextXAlignment = Enum.TextXAlignment.Center,
												Font = Constants.FONT
											}
										),
										ButtonFrame = Roact.createElement(
											"Frame",
											{
												LayoutOrder = 3,
												Size = UDim2.new(1, 0, 0, 24),
												BackgroundTransparency = 1
											},
											{
												Delete = Roact.createElement(
													ThemedTextButton,
													{
														Text = "Delete",
														Size = UDim2.new(0, 120, 0, 24),
														Position = UDim2.new(0.5, -3, 0, 0),
														AnchorPoint = Vector2.new(1, 0),
														onClick = self.onDeleteConfirmed,
														buttonStyle = "Delete",
														modalIndex = 1
													}
												),
												Cancel = Roact.createElement(
													ThemedTextButton,
													{
														Text = "Cancel",
														Size = UDim2.new(0, 120, 0, 24),
														Position = UDim2.new(0.5, 3, 0, 0),
														AnchorPoint = Vector2.new(0, 0),
														onClick = self.onDeleteCancelled,
														modalIndex = 1
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
		)
	end
end

local UpdateReminderModal
do
	local ModalWindow = require(Foundation.ModalWindow)

	UpdateReminderModal = Roact.PureComponent:extend("UpdateReminderModal")
	function UpdateReminderModal:init()
		local mainManager = getMainManager(self)
		self.onDismiss = function()
			mainManager:DismissUpdateReminder()
		end
	end

	function UpdateReminderModal:render()
		return withTheme(
			function(theme)
				return withModal(
					function(modalTarget, modalStatus)
						return Roact.createElement(
							ModalBase,
							{
								target = modalTarget,
								ZIndex = 10,
								modalIndex = 1
							},
							{
								Shader = Roact.createElement(
									"Frame",
									{
										BackgroundTransparency = 0.3,
										BackgroundColor3 = theme.shaderColor,
										BorderSizePixel = 0,
										Size = UDim2.new(1, 0, 1, 0),
										ZIndex = 1
									}
								),
								Window = Roact.createElement(
									ModalWindow,
									{
										title = "Update Available",
										ZIndex = 2
									},
									{
										help1 = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = "An update is available!",
												LayoutOrder = 1,
												TextXAlignment = Enum.TextXAlignment.Left,
												Font = Constants.FONT_BOLD
											}
										),
										help2 = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = "Go to 'Manage Plugins' and update the plugin.",
												LayoutOrder = 2,
												TextXAlignment = Enum.TextXAlignment.Left,
												Font = Constants.FONT
											}
										),
										okButton = Roact.createElement(
											VerticalList,
											{
												HorizontalAlignment = Enum.HorizontalAlignment.Center,
												LayoutOrder = 3,
												width = UDim.new(1, 0)
											},
											{
												OKGotItButton = Roact.createElement(
													ThemedTextButton,
													{
														Text = "OK, got it.",
														Size = UDim2.new(0, 120, 0, 24),
														onClick = self.onDismiss,
														modalIndex = 1
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
		)
	end
end

local InDevelopmentReminderModal
do
	local ModalWindow = require(Foundation.ModalWindow)

	InDevelopmentReminderModal = Roact.PureComponent:extend("InDevelopmentReminderModal")
	function InDevelopmentReminderModal:init()
		local mainManager = getMainManager(self)
		self.onDismiss = function()
			mainManager:DismissInDevelopmentReminder()
		end
	end

	function InDevelopmentReminderModal:render()
		return withTheme(
			function(theme)
				return withModal(
					function(modalTarget, modalStatus)
						return Roact.createElement(
							ModalBase,
							{
								target = modalTarget,
								ZIndex = 20,
								modalIndex = 1
							},
							{
								Shader = Roact.createElement(
									"Frame",
									{
										BackgroundTransparency = 0.3,
										BackgroundColor3 = theme.shaderColor,
										BorderSizePixel = 0,
										Size = UDim2.new(1, 0, 1, 0),
										ZIndex = 1
									}
								),
								Border = Roact.createElement(
									ModalWindow,
									{
										title = "Warning",
										ZIndex = 2
									},
									{
										help1 = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = "This plugin is still in development!",
												LayoutOrder = 1,
												TextXAlignment = Enum.TextXAlignment.Left,
												Font = Constants.FONT_BOLD
											}
										),
										help2 = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = "In order to speed up development, massive, sweeping changes will happen in-between updates.",
												LayoutOrder = 2,
												TextXAlignment = Enum.TextXAlignment.Left,
												Font = Constants.FONT
											}
										),
										help3 = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = "Settings will disappear or behave differently. Save data (not yet implemented) will " ..
													"be wiped or overwritten without warning.",
												LayoutOrder = 3,
												TextXAlignment = Enum.TextXAlignment.Left,
												Font = Constants.FONT
											}
										),
										help4 = Roact.createElement(
											AutoHeightThemedText,
											{
												width = UDim.new(1, 0),
												Text = "If you want to keep your settings in-between sessions, it's recomended that you write them down for now.",
												LayoutOrder = 4,
												TextXAlignment = Enum.TextXAlignment.Left,
												Font = Constants.FONT
											}
										),
										okButton = Roact.createElement(
											VerticalList,
											{
												HorizontalAlignment = Enum.HorizontalAlignment.Center,
												LayoutOrder = 5,
												width = UDim.new(1, 0)
											},
											{
												OKGotItButton = Roact.createElement(
													ThemedTextButton,
													{
														Text = "Gotcha.",
														Size = UDim2.new(0, 120, 0, 24),
														onClick = self.onDismiss,
														modalIndex = 1
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
		)
	end
end

local DEFAULT_CAMERA_CF = CFrame.new(Vector3.new(0, -1, 12), Vector3.new(0, -1, 0))
function Draw:init()
	self.state = {
		spacerHeight = 0,
		floaterOffset = 0,
		shouldRenderShadow = false
	}

	local mainManager = getMainManager(self)

	self.onMainButtonClicked = function()
		if mainManager:IsActive() then
			mainManager:Deactivate()
		else
			mainManager:Activate("Draw")
		end
	end

	self.togglePreviewSection = function()
		mainManager:ToggleCollapsibleSection("Preview")
	end

	self:UpdateStateFromMainManager()

	self.frameRef = Roact.createRef()
	self.floaterFrameRef = Roact.createRef()
	self.spacerFrameRef = Roact.createRef()
	self.floaterListRef = Roact.createRef()

	self.onSpacerAbsolutePositionChanged = function()
		self:DoPreviewFloaterUpdate()
	end

	self.onContentSizeChanged = function()
		self:DoPreviewFloaterUpdate()
		-- lame hack
		-- If the thing changes size multiple times in the same frame,
		-- then only the first change is fed into render.
		-- this fixes that.
		RunService.Heartbeat:Wait()
		self:DoPreviewFloaterUpdate()
	end

	self.floaterSkyboxFrameRef = Roact.createRef()
	self.floaterRenderFrameRef = Roact.createRef()

	local camera = Instance.new("Camera")
	camera.CFrame = DEFAULT_CAMERA_CF
	camera.FieldOfView = 40
	self.camera = camera

	local skybox = Constants.SKYBOX_BALL:Clone()
	Utility.ScaleObject(skybox, 100)
	self.skybox = skybox
	self.skybox:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.p))

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

	local rotating, panning = false, false
	self.onInputChanged = function(rbx, input)
		local cf = camera.CFrame
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.MouseMovement then
			local delta = input.delta
			if panning then
				local projected = Utility.ProjectPointToPlane(cf.p, Vector3.new(), -cf.lookVector)
				local dist = (cf.p - projected).magnitude
				local zoomFactor = lerp(0.008, 0.09, (dist - 2) / 22)
				local newCf = panCFrame(cf, delta.X * zoomFactor, delta.Y * zoomFactor)
				camera.CFrame = newCf
				skybox:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.p))
			elseif rotating then
				local newCf = rotateCFrame(cf, delta.X * 0.015, delta.Y * 0.015)
				camera.CFrame = newCf
				skybox:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.p))
			end
		elseif inputType == Enum.UserInputType.MouseWheel then
			local wheelDir = input.Position.Z
			local projected = Utility.ProjectPointToPlane(cf.p, Vector3.new(), -cf.lookVector)
			local dist = (cf.p - projected).magnitude
			local moveAmount = math.max(dist * 0.1, 0.1)
			-- prevent the camera from zooming too close or too far.
			if wheelDir > 0 then
				moveAmount = math.min(moveAmount, dist - 2)
			elseif wheelDir < 0 then
				moveAmount = math.min(moveAmount, 24 - dist)
			end
			local newCf = cf * CFrame.new(0, 0, -moveAmount * wheelDir)
			camera.CFrame = newCf
			skybox:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.p))
		end
	end

	self.onInputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			rotating = true
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			panning = true
		end
	end

	self.onInputEnded = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			rotating = false
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			panning = false
		end
	end

	self.onClickReset = function(rbx, input)
		camera.CFrame = DEFAULT_CAMERA_CF
		skybox:SetPrimaryPartCFrame(CFrame.new(camera.CFrame.p))
	end
end

function Draw:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local active = mainManager:IsActive()
	local mode = mainManager:GetMode()
	local activePreset = mainManager:GetActivePreset()
	local isUpdateAvailable = mainManager:IsUpdateAvailable()
	local isUpdateReminderDismissed = mainManager:IsUpdateReminderDismissed()
	local isInDevelopmentReminderDismissed = mainManager:IsInDevelopmentReminderDismissed()
	local presetIdBeingDeleted = mainManager:GetPresetIdBeingDeleted()
	local presetBeingDeletedName = presetIdBeingDeleted ~= nil and mainManager:GetPresetName(presetIdBeingDeleted)
	local previewCollapsed = mainManager:IsSectionCollapsed("Preview")
	SmartSetState(
		self,
		{
			mode = mode,
			active = active,
			activePreset = activePreset or Roact.None,
			isUpdateAvailable = isUpdateAvailable,
			isUpdateReminderDismissed = isUpdateReminderDismissed,
			isInDevelopmentReminderDismissed = isInDevelopmentReminderDismissed,
			presetIdBeingDeleted = presetIdBeingDeleted or Roact.None,
			presetBeingDeletedName = presetBeingDeletedName or Roact.None,
			previewCollapsed = previewCollapsed
		}
	)
end

function Draw:render()
	return withTheme(
		function(theme)
			local state = self.state
			local mode = state.mode
			local active = state.active
			local activePreset = state.activePreset
			local previewCollapsed = state.previewCollapsed
			return Roact.createElement(
				"Frame",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					[Roact.Ref] = self.frameRef
				},
				{
					InDevelopmentReminder = not state.isInDevelopmentReminderDismissed and Roact.createElement(InDevelopmentReminderModal),
					UpdateReminder = state.isUpdateAvailable and not state.isUpdateReminderDismissed and Roact.createElement(UpdateReminderModal),
					DeletePreset = state.presetIdBeingDeleted and
						Roact.createElement(
							DeletePresetModal,
							{
								presetId = state.presetIdBeingDeleted,
								presetName = state.presetBeingDeletedName
							}
						),
					Floater = Roact.createElement(
						"Frame",
						{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -8 - Constants.SCROLL_BAR_THICKNESS, 1, -8),
							Position = UDim2.new(0, 4, 0, 4),
							[Roact.Change.AbsolutePosition] = self.onFloaterAbsolutePositionChanged,
							[Roact.Ref] = self.floaterFrameRef,
							ZIndex = 2
						},
						{
							Anchor = Roact.createElement(
								"Frame",
								{
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 1, 0),
									Position = UDim2.new(0, 0, 0, state.floaterOffset)
								},
								{
									Wrap = self.state.activePreset and
										Roact.createElement(
											"Frame",
											{
												Size = UDim2.new(1, 0, 0, state.spacerHeight),
												Position = UDim2.new(0, 0, 0, 0),
												BackgroundTransparency = 1,
												ZIndex = 2
											},
											{
												List = Roact.createElement(
													"UIListLayout",
													{
														[Roact.Change.AbsoluteContentSize] = self.onContentSizeChanged,
														[Roact.Ref] = self.floaterListRef
													}
												),
												Collapse = Roact.createElement(
													PaddedCollapsibleSection,
													{
														title = "Preview",
														collapsed = previewCollapsed,
														onCollapseToggled = self.togglePreviewSection,
														LayoutOrder = 1
													},
													{
														PreviewFrame = not previewCollapsed and
															Roact.createElement(
																"Frame",
																{
																	BackgroundTransparency = 1,
																	Size = UDim2.new(1, 0, 0, 200)
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
																			ZIndex = 2
																		}
																	),
																	Detector = Roact.createElement(
																		StatefulButtonDetector,
																		{
																			Size = UDim2.new(1, 0, 1, 0),
																			BackgroundTransparency = 1,
																			[Roact.Event.InputBegan] = self.onInputBegan,
																			[Roact.Event.InputEnded] = self.onInputEnded,
																			[Roact.Event.InputChanged] = self.onInputChanged
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
																			ZIndex = 3,
																			onClick = self.onClickReset
																		}
																	),
																	SkyboxFrame = Roact.createElement(
																		"ViewportFrame",
																		{
																			Size = UDim2.new(1, 0, 1, 0),
																			BorderSizePixel = 0,
																			BackgroundColor3 = Color3.new(0, 0, 0),
																			Ambient = Color3.new(2, 2, 2),
																			LightColor = Color3.new(0, 0, 0),
																			ZIndex = 2,
																			CurrentCamera = self.camera,
																			[Roact.Ref] = function(rbx)
																				if rbx then
																					self.skybox.Parent = rbx
																				else
																					self.skybox.Parent = nil
																				end
																			end
																		}
																	),
																	Render = Roact.createElement(
																		"ViewportFrame",
																		{
																			Size = UDim2.new(1, 0, 1, 0),
																			BorderSizePixel = 0,
																			BackgroundTransparency = 1,
																			BackgroundColor3 = Color3.new(0, 0, 0),
																			Ambient = Color3.new(0.5, 0.5, 0.5),
																			LightColor = Color3.new(1, 1, 1),
																			LightDirection = Vector3.new(-1, -1, -1),
																			ZIndex = 3,
																			CurrentCamera = self.camera,
																			[Roact.Ref] = function(rbx)
																				if self.previewObject then
																					if rbx then
																						self.previewObject.Parent = rbx
																					else
																						self.previewObject.Parent = nil
																					end
																				end
																			end
																		}
																	)
																}
															)
													}
												)
											}
										),
									DropShadow = state.shouldRenderShadow and
										Roact.createElement(
											"ImageLabel",
											{
												Size = UDim2.new(1, 8, 0, state.spacerHeight + 8),
												Position = UDim2.new(0, -4, 0, -4),
												BackgroundTransparency = 1,
												Image = "rbxassetid://3136399270",
												ScaleType = Enum.ScaleType.Slice,
												SliceCenter = Rect.new(5, 5, 14, 14)
											}
										)
								}
							)
						}
					),
					Scroller = Roact.createElement(
						ScrollingVerticalList,
						{
							BackgroundTransparency = 1
						},
						{
							CursorPreview = mode == "Draw" and
								Roact.createElement(
									CursorPreview,
									{
										DisplayOrder = 2
									}
								),
							CurvePreview = mode == "Draw" and
								Roact.createElement(
									CurvePreview,
									{
										DisplayOrder = 1
									}
								),
							List = Roact.createElement(
								VerticalList,
								{
									width = UDim.new(1, 0),
									PaddingLeftPixel = 4,
									PaddingRightPixel = 4,
									PaddingBottomPixel = 4,
									PaddingTopPixel = 4,
									ElementPaddingPixel = 4
								},
								{
									Button = Roact.createElement(
										ThemedTextButtonWithIcon,
										{
											Text = active and "Stop Drawing" or "Begin Drawing",
											icon = "rbxassetid://3578127314",
											Size = UDim2.new(1, 0, 0, 80),
											TextSize = Constants.FONT_SIZE_LARGE,
											onClick = activePreset and self.onMainButtonClicked,
											disabled = activePreset == nil
										}
									),
									CursorSettings = Roact.createElement(
										CursorSettings,
										{
											LayoutOrder = 1
										}
									),
									CurveSettings = Roact.createElement(
										CurveSettings,
										{
											LayoutOrder = 2
										}
									),
									Presets = Roact.createElement(
										Presets,
										{
											LayoutOrder = 3
										}
									),
									Spacer = Roact.createElement(
										"Frame",
										{
											Size = UDim2.new(1, 0, 0, state.spacerHeight),
											BackgroundTransparency = 1,
											LayoutOrder = 4,
											[Roact.Change.AbsolutePosition] = self.onSpacerAbsolutePositionChanged,
											[Roact.Ref] = self.spacerFrameRef
										}
									),
									-- Preview = Roact.createElement(
									-- 	Preview,
									-- 	{
									-- 		LayoutOrder = 4,
									-- 		floater = self.floater,
									-- 		presetId = activePreset
									-- 	}
									-- ),
									PresetSettings = Roact.createElement(
										PresetSettings,
										{
											LayoutOrder = 5
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

function Draw:didMount()
	local floater = self.floater
	local frame = self.frameRef.current
	floater.Parent = frame
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function Draw:UpdatePreviewObject()
	debug.profilebegin("PresetPreview:UpdatePreviewObject")
	local oldPreviewParent = self.previewObject and self.previewObject.Parent or nil
	if self.previewObject then
		self.previewObject:Destroy()
		self.previewObject = nil
	end

	local mainManager = getMainManager(self)

	local presetId = self.state.activePreset
	if presetId then
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
		self.previewObject.Parent = oldPreviewParent
	end

	debug.profileend()
end

function Draw:DoPreviewFloaterUpdate()
	local floaterList = self.floaterListRef.current
	if floaterList then
		local floaterFrame = self.floaterFrameRef.current
		local spacerFrame = self.spacerFrameRef.current
		local newState = {}
		newState.spacerHeight = floaterList.AbsoluteContentSize.Y
		local spacerY = spacerFrame.AbsolutePosition.Y
		local floaterY = floaterFrame.AbsolutePosition.Y
		if spacerY < floaterY then
			newState.floaterOffset = 0
			newState.shouldRenderShadow = true
		else
			newState.floaterOffset = spacerY - floaterY
			newState.shouldRenderShadow = false
		end

		SmartSetState(self, newState)
	else
		SmartSetState(self, {spacerHeight = 0})
	end
end

function Draw:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
	if self.state.activePreset then
		self.presetChangedDisconnect =
			mainManager:subscribeToPresetChanged(
			self.state.activePreset,
			function()
				self:UpdatePreviewObject()
			end
		)
		self:UpdatePreviewObject()
	end
end

function Draw:willUpdate(nextProps, nextState)
	local currentPresetId = self.state.activePreset
	local nextPresetId = nextState.activePreset
	if nextPresetId ~= currentPresetId then
		if self.presetChangedDisconnect then
			self.presetChangedDisconnect()
			self.presetChangedDisconnect = nil
		end
		if nextPresetId then
			local mainManager = getMainManager(self)
			self.presetChangedDisconnect =
				mainManager:subscribeToPresetChanged(
				nextPresetId,
				function()
					self:UpdatePreviewObject()
				end
			)
		end
		self.shouldUpdatePreviewObject = true
	end
end

function Draw:didUpdate()
	if self.shouldUpdatePreviewObject then
		self:UpdatePreviewObject()
		self.shouldUpdatePreviewObject = false
	end
end

function Draw:willUnmount()
	self.skybox.Parent = nil
	if self.previewObject then
		self.previewObject:Destroy()
		self.previewObject = nil
	end
	if self.presetChangedDisconnect then
		self.presetChangedDisconnect()
		self.presetChangedDisconnect = nil
	end
	self.mainManagerDisconnect()
end

return Draw
