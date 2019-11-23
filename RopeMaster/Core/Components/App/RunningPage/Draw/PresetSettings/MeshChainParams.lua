local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local SignalHelper = require(Plugin.Core.Util.SignalHelper)
local createSignal = require(Plugin.Core.Util.createSignal)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)

local withTheme = ContextHelper.withTheme
local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local ColorSelector = require(Foundation.ColorSelector)

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)
local BaseNumericalSliderField = require(Specialized.BaseNumericalSliderField)
local BaseDropdownField = require(Specialized.BaseDropdownField)

local spec = require(Plugin.Core.Util.specialize)

local ChainTypeDropdown =
	spec.specialize(
	"ChainTypeDropdown",
	BaseDropdownField,
	{
		label = "Chain Type",
		entries = {
			{id = Types.MeshChain.CHAIN_SMOOTH, text = "Chain Smooth"},
			{id = Types.MeshChain.CHAIN_SHARP, text = "Chain Sharp"},
			{id = Types.MeshChain.GARLAND, text = "Garland"}
		},
		LayoutOrder = 1
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local SegmentScaleSlider =
	spec.specialize(
	"SegmentScaleSlider",
	BaseNumericalSliderField,
	{
		label = "Segment Scale",
		minValue = 0.5,
		maxValue = 5,
		valueRound = 0.01,
		valueSnap = 0.1,
		maxCharacters = 4,
		LayoutOrder = 2
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local RotationAxisDropdown =
	spec.specialize(
	"RotationAxisDropdown",
	BaseDropdownField,
	{
		label = "Rotation Axis",
		entries = {
			{id = Types.Axis.X, text = "X"},
			{id = Types.Axis.Y, text = "Y"},
			{id = Types.Axis.Z, text = "Z"}
		},
		LayoutOrder = 1
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local RotationOffsetSlider =
	spec.specialize(
	"RotationOffsetSlider",
	BaseNumericalSliderField,
	{
		label = "Offset",
		minValue = -360,
		maxValue = 360,
		valueRound = 0.01,
		valueSnap = 15,
		maxCharacters = 6,
		LayoutOrder = 3
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local RotationPerLinkSlider =
	spec.specialize(
	"RotationPerLinkSlider",
	BaseNumericalSliderField,
	{
		label = "Per Link",
		minValue = -360,
		maxValue = 360,
		valueRound = 0.01,
		valueSnap = 15,
		maxCharacters = 6,
		LayoutOrder = 4
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local RotationRandomMinSlider =
	spec.specialize(
	"RotationRandomMinSlider",
	BaseNumericalSliderField,
	{
		label = "Random, Min",
		minValue = -360,
		maxValue = 360,
		valueRound = 0.01,
		valueSnap = 15,
		maxCharacters = 6,
		LayoutOrder = 5
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local RotationRandomMaxSlider =
	spec.specialize(
	"RotationRandomMaxSlider",
	BaseNumericalSliderField,
	{
		label = "Random, Max",
		minValue = -360,
		maxValue = 360,
		valueRound = 0.01,
		valueSnap = 15,
		maxCharacters = 6,
		LayoutOrder = 6
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local ShadingDropdown =
	spec.specialize(
	"ShadingDropdown",
	BaseDropdownField,
	{
		label = "Shading",
		entries = {
			{id = Types.ChainShading.SHINY, text = "Shiny"},
			{id = Types.ChainShading.DULL, text = "Dull"},
			{id = Types.ChainShading.MATTE, text = "Matte"},
			{id = Types.ChainShading.FORCEFIELD, text = "ForceField"}
		},
		LayoutOrder = 2
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local MeshChainParams = Roact.PureComponent:extend("MeshChainParams")

function MeshChainParams:init()
	local mainManager = getMainManager(self)
	self.toggleRopeGeometrySection = function()
		mainManager:ToggleCollapsibleSection("RopeGeometry")
	end
	self.toggleRopeAppearanceSection = function()
		mainManager:ToggleCollapsibleSection("RopeAppearance")
	end
	self.toggleRopeRotationSection = function()
		mainManager:ToggleCollapsibleSection("RopeRotation")
	end

	self.onChainTypeSelected = function(chainType)
		mainManager:SetPresetRopeParams(self.props.presetId, {meshChainType = chainType})
	end
	self.onSegmentScaleChanged = function(scale)
		mainManager:SetPresetRopeParams(self.props.presetId, {segmentScale = scale})
	end
	self.onRotationLinkAxisChanged = function(axis)
		mainManager:SetPresetRopeParams(self.props.presetId, {rotationLinkAxis = axis})
	end
	self.onRotationLinkOffsetChanged = function(offset)
		mainManager:SetPresetRopeParams(self.props.presetId, {rotationLinkOffset = offset})
	end
	self.onRotationPerLinkChanged = function(perLink)
		mainManager:SetPresetRopeParams(self.props.presetId, {rotationPerLink = perLink})
	end
	self.onRotationLinkRandomMinChanged = function(min)
		local max = mainManager:GetPresetRopeParams(self.props.presetId).rotationLinkRandomMax
		mainManager:SetPresetRopeParams(
			self.props.presetId,
			{
				rotationLinkRandomMin = min,
				rotationLinkRandomMax = math.max(min, max)
			}
		)
	end
	self.onRotationLinkRandomMaxChanged = function(max)
		local min = mainManager:GetPresetRopeParams(self.props.presetId).rotationLinkRandomMin
		mainManager:SetPresetRopeParams(
			self.props.presetId,
			{
				rotationLinkRandomMax = max,
				rotationLinkRandomMin = math.min(min, max)
			}
		)
	end
	self.onShadingTypeSelected = function(shading)
		mainManager:SetPresetRopeParams(self.props.presetId, {chainShadingType = shading})
	end

	-- When the hue changes but its saturation or value is 0 (e.g. pure gray/black),
	-- the resulting color doesn't change, so mainManager doesn't fire its signal.
	-- Right now, we store h, s, v in the component (via self.h not self:setState{h = h})
	-- We could use setState to force an update, but this would make the rest of the components
	-- to update, too.
	-- We still have to update the props of the ColorSelector, so we fire and listen to a signal.
	self.colorHackSignal = createSignal()
	local ropeParams = mainManager:GetPresetRopeParams(self.props.presetId)
	local h, s, v = Color3.toHSV(ropeParams.baseColor)
	self.h, self.s, self.v = h, s, v
	self.onColorChanged = function(color_t)
		local h, s, v = color_t.h, color_t.s, color_t.v
		self.h, self.s, self.v = h, s, v
		local color = Color3.fromHSV(h, s, v)
		mainManager:SetPresetRopeParams(self.props.presetId, {baseColor = color})
		self.colorHackSignal:fire()
	end

	self:UpdateStateFromMainManager()
end

function MeshChainParams:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local presetId = self.props.presetId
	local ropeParams = mainManager:GetPresetRopeParams(presetId)
	local chainType = ropeParams.meshChainType
	local segmentScale = ropeParams.segmentScale
	local rotationLinkAxis = ropeParams.rotationLinkAxis
	local rotationLinkOffset = ropeParams.rotationLinkOffset
	local rotationPerLink = ropeParams.rotationPerLink
	local rotationLinkRandomMin = ropeParams.rotationLinkRandomMin
	local rotationLinkRandomMax = ropeParams.rotationLinkRandomMax
	local baseColor = ropeParams.baseColor
	local shadingType = ropeParams.chainShadingType
	local geometryCollapsed = mainManager:IsSectionCollapsed("RopeGeometry")
	local rotationCollapsed = mainManager:IsSectionCollapsed("RopeRotation")
	local appearanceCollapsed = mainManager:IsSectionCollapsed("RopeAppearance")
	SmartSetState(
		self,
		{
			chainType = chainType,
			segmentScale = segmentScale,
			rotationLinkAxis = rotationLinkAxis,
			rotationLinkOffset = rotationLinkOffset,
			rotationPerLink = rotationPerLink,
			rotationLinkRandomMin = rotationLinkRandomMin,
			rotationLinkRandomMax = rotationLinkRandomMax,
			baseColor = baseColor,
			shadingType = shadingType,
			geometryCollapsed = geometryCollapsed,
			rotationCollapsed = rotationCollapsed,
			appearanceCollapsed = appearanceCollapsed
		}
	)
end

function MeshChainParams:willUpdate(nextProps, nextState)
	local currentPresetId = self.props.presetId
	local nextPresetId = nextProps.presetId
	if currentPresetId ~= nextPresetId then
		local mainManager = getMainManager(self)
		local ropeType = mainManager:GetPresetRopeType(nextPresetId)
		if ropeType == Types.Rope.MESH_ROPE then
			local ropeParams = mainManager:GetPresetRopeParams(nextPresetId)
			local baseColor = ropeParams.baseColor
			local h, s, v = Color3.toHSV(baseColor)
			self.h, self.s, self.v = h, s, v
		end
	end
end

function MeshChainParams:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder

	return withTheme(
		function(theme)
			local state = self.state
			local chainType = state.chainType
			local segmentScale = state.segmentScale
			local rotationLinkAxis = state.rotationLinkAxis
			local rotationLinkOffset = state.rotationLinkOffset
			local rotationPerLink = state.rotationPerLink
			local rotationLinkRandomMin = state.rotationLinkRandomMin
			local rotationLinkRandomMax = state.rotationLinkRandomMax
			local shadingType = state.shadingType
			local geometryCollapsed = state.geometryCollapsed
			local rotationCollapsed = state.rotationCollapsed
			local appearanceCollapsed = state.appearanceCollapsed

			local children = {}
			children.Geometry =
				Roact.createElement(
				PaddedCollapsibleSection,
				{
					title = "Geometry",
					collapsed = geometryCollapsed,
					onCollapseToggled = self.toggleRopeGeometrySection,
					LayoutOrder = 1
				},
				{
					ChainType = Roact.createElement(
						ChainTypeDropdown,
						{
							selectedId = chainType,
							onSelected = self.onChainTypeSelected
						}
					),
					Scale = Roact.createElement(
						SegmentScaleSlider,
						{
							value = segmentScale,
							onValueChanged = self.onSegmentScaleChanged
						}
					)
				}
			)

			children.Rotation =
				Roact.createElement(
				PaddedCollapsibleSection,
				{
					title = "Rotation",
					collapsed = rotationCollapsed,
					onCollapseToggled = self.toggleRopeRotationSection,
					LayoutOrder = 2
				},
				{
					Axis = Roact.createElement(
						RotationAxisDropdown,
						{
							selectedId = rotationLinkAxis,
							onSelected = self.onRotationLinkAxisChanged
						}
					),
					RotationOffset = Roact.createElement(
						RotationOffsetSlider,
						{
							value = rotationLinkOffset,
							onValueChanged = self.onRotationLinkOffsetChanged
						}
					),
					RotationPerLink = Roact.createElement(
						RotationPerLinkSlider,
						{
							value = rotationPerLink,
							onValueChanged = self.onRotationPerLinkChanged
						}
					),
					RotationRandomMin = Roact.createElement(
						RotationRandomMinSlider,
						{
							value = rotationLinkRandomMin,
							onValueChanged = self.onRotationLinkRandomMinChanged
						}
					),
					RotationRandomMax = Roact.createElement(
						RotationRandomMaxSlider,
						{
							value = rotationLinkRandomMax,
							onValueChanged = self.onRotationLinkRandomMaxChanged
						}
					)
				}
			)

			children.Appearance =
				Roact.createElement(
				PaddedCollapsibleSection,
				{
					title = "Appearance",
					collapsed = appearanceCollapsed,
					onCollapseToggled = self.toggleRopeAppearanceSection,
					LayoutOrder = 3
				},
				{
					Color = SignalHelper(
						function(f)
							return self.colorHackSignal:subscribe(f)
						end,
						function()
							return {}
						end,
						function()
							return Roact.createElement(
								ColorSelector,
								{
									h = self.h,
									s = self.s,
									v = self.v,
									onColorChanged = self.onColorChanged,
									textured = false,
									texture = "",
									LayoutOrder = 1
								}
							)
						end
					),
					ShadingType = Roact.createElement(
						ShadingDropdown,
						{
							selectedId = shadingType,
							onSelected = self.onShadingTypeSelected
						}
					)
				}
			)

			return Roact.createElement(
				VerticalList,
				{
					width = UDim.new(1, 0),
					LayoutOrder = LayoutOrder,
					ElementPaddingPixel = 4
				},
				children
			)
		end
	)
end

function MeshChainParams:didUpdate(oldProps)
	if oldProps.presetId ~= self.props.presetId then
		local mainManager = getMainManager(self)
		local color = mainManager:GetPresetRopeParams(self.props.presetId).baseColor
		self.h, self.s, self.v = Color3.toHSV(color)
	end
end

function MeshChainParams:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function MeshChainParams:willUnmount()
	self.mainManagerDisconnect()
end

return MeshChainParams
