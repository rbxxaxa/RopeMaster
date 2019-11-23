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

local WidthSlider =
	spec.specialize(
	"WidthSlider",
	BaseNumericalSliderField,
	{
		label = "Width",
		minValue = 0.1,
		maxValue = 5,
		valueRound = 0.01,
		valueSnap = 0.1,
		maxCharacters = 4,
		LayoutOrder = 1
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local HeightSlider =
	spec.specialize(
	"HeightSlider",
	BaseNumericalSliderField,
	{
		label = "Height",
		minValue = 0.1,
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

local SegmentModeDropdown =
	spec.specialize(
	"SegmentModeDropdown",
	BaseDropdownField,
	{
		label = "Segment Mode",
		entries = {
			{id = Types.RopeSegmentMode.SAME_BENDS, text = "Same Bend Angles"},
			{id = Types.RopeSegmentMode.SAME_LENGTHS, text = "Same Lengths"}
		},
		LayoutOrder = 3
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local BendAngleSlider =
	spec.specialize(
	"BendAngleSlider",
	BaseNumericalSliderField,
	{
		label = "Bend Angle",
		minValue = 2,
		maxValue = 30,
		valueRound = 0.01,
		valueSnap = 1,
		maxCharacters = 5,
		LayoutOrder = 4
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local LengthSlider =
	spec.specialize(
	"LengthSlider",
	BaseNumericalSliderField,
	{
		label = "Segment Length",
		minValue = 0.5,
		maxValue = 5,
		valueRound = 0.01,
		valueSnap = 0.5,
		maxCharacters = 5,
		LayoutOrder = 5
	},
	{
		label = spec.auto,
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local MaterialDropdown =
	spec.specialize(
	"MaterialDropdown",
	BaseDropdownField,
	{
		label = "Material",
		entries = {
			{id = Types.Material.PLASTIC, text = "Plastic"},
			{id = Types.Material.WOOD, text = "Wood"},
			{id = Types.Material.SLATE, text = "Slate"},
			{id = Types.Material.CONCRETE, text = "Concrete"},
			{id = Types.Material.CORRODEDMETAL, text = "CorrodedMetal"},
			{id = Types.Material.DIAMONDPLATE, text = "DiamondPlate"},
			{id = Types.Material.FOIL, text = "Foil"},
			{id = Types.Material.GRASS, text = "Grass"},
			{id = Types.Material.ICE, text = "Ice"},
			{id = Types.Material.MARBLE, text = "Marble"},
			{id = Types.Material.GRANITE, text = "Granite"},
			{id = Types.Material.BRICK, text = "Brick"},
			{id = Types.Material.PEBBLE, text = "Pebble"},
			{id = Types.Material.SAND, text = "Sand"},
			{id = Types.Material.FABRIC, text = "Fabric"},
			{id = Types.Material.SMOOTHPLASTIC, text = "SmoothPlastic"},
			{id = Types.Material.METAL, text = "Metal"},
			{id = Types.Material.WOODPLANKS, text = "WoodPlanks"},
			{id = Types.Material.COBBLESTONE, text = "Cobblestone"},
			{id = Types.Material.NEON, text = "Neon"},
			{id = Types.Material.GLASS, text = "Glass"},
			{id = Types.Material.FORCEFIELD, text = "ForceField"}
		},
		LayoutOrder = 1
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local MaterialRopeParams = Roact.PureComponent:extend("MaterialRopeParams")

function MaterialRopeParams:init()
	local mainManager = getMainManager(self)
	self.toggleRopeGeometrySection = function()
		mainManager:ToggleCollapsibleSection("RopeGeometry")
	end
	self.toggleRopeAppearanceSection = function()
		mainManager:ToggleCollapsibleSection("RopeAppearance")
	end

	self.onWidthChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {width = value})
	end
	self.onHeightChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {height = value})
	end
	self.onSegmentModeSelected = function(mode)
		mainManager:SetPresetRopeParams(self.props.presetId, {lengthMode = mode})
	end
	self.onBendAngleChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {angleInterval = value})
	end
	self.onLengthIntervalChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {lengthInterval = value})
	end
	self.onMaterialSelected = function(material)
		mainManager:SetPresetRopeParams(self.props.presetId, {material = material})
	end
	self.onFocusLostCustomTexture = function(t)
		mainManager:SetPresetRopeParams(self.props.presetId, {customTexture = t})
		return t
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

function MaterialRopeParams:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local presetId = self.props.presetId
	local ropeParams = mainManager:GetPresetRopeParams(presetId)
	local width = ropeParams.width
	local height = ropeParams.height
	local lengthMode = ropeParams.lengthMode
	local lengthInterval = ropeParams.lengthInterval
	local material = ropeParams.material
	local angleInterval = ropeParams.angleInterval
	local geometryCollapsed = mainManager:IsSectionCollapsed("RopeGeometry")
	local appearanceCollapsed = mainManager:IsSectionCollapsed("RopeAppearance")
	SmartSetState(
		self,
		{
			width = width,
			height = height,
			lengthMode = lengthMode,
			lengthInterval = lengthInterval,
			angleInterval = angleInterval,
			material = material,
			geometryCollapsed = geometryCollapsed,
			appearanceCollapsed = appearanceCollapsed
		}
	)
end

function MaterialRopeParams:willUpdate(nextProps, nextState)
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

function MaterialRopeParams:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder

	return withTheme(
		function(theme)
			local state = self.state
			local width = state.width
			local height = state.height
			local lengthMode = state.lengthMode
			local lengthInterval = state.lengthInterval
			local angleInterval = state.angleInterval
			local material = state.material
			local geometryCollapsed = state.geometryCollapsed
			local appearanceCollapsed = state.appearanceCollapsed

			local children = {}
			children.Geometry =
				Roact.createElement(
				PaddedCollapsibleSection,
				{
					title = "Geometry",
					collapsed = geometryCollapsed,
					onCollapseToggled = self.toggleRopeGeometrySection
				},
				{
					Width = Roact.createElement(
						WidthSlider,
						{
							value = width,
							onValueChanged = self.onWidthChanged
						}
					),
					Height = Roact.createElement(
						HeightSlider,
						{
							value = height,
							onValueChanged = self.onHeightChanged
						}
					),
					SegmentMode = Roact.createElement(
						SegmentModeDropdown,
						{
							selectedId = lengthMode,
							onSelected = self.onSegmentModeSelected
						}
					),
					BendAngle = lengthMode == Types.RopeSegmentMode.SAME_BENDS and
						Roact.createElement(
							BendAngleSlider,
							{
								value = angleInterval,
								onValueChanged = self.onBendAngleChanged
							}
						),
					Length = lengthMode == Types.RopeSegmentMode.SAME_LENGTHS and
						Roact.createElement(
							LengthSlider,
							{
								value = lengthInterval,
								onValueChanged = self.onLengthIntervalChanged
							}
						)
				}
			)
			--
			children.Appearance =
				Roact.createElement(
				PaddedCollapsibleSection,
				{
					title = "Appearance",
					collapsed = appearanceCollapsed,
					onCollapseToggled = self.toggleRopeAppearanceSection,
					LayoutOrder = 2
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
					Material = Roact.createElement(
						MaterialDropdown,
						{
							selectedId = material,
							onSelected = self.onMaterialSelected
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

function MaterialRopeParams:didUpdate(oldProps)
	if oldProps.presetId ~= self.props.presetId then
		local mainManager = getMainManager(self)
		local color = mainManager:GetPresetRopeParams(self.props.presetId).baseColor
		self.h, self.s, self.v = Color3.toHSV(color)
	end
end

function MaterialRopeParams:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function MaterialRopeParams:willUnmount()
	self.mainManagerDisconnect()
end

return MaterialRopeParams
