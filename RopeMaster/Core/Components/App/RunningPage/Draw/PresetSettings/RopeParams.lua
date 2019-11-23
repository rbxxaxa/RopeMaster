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
local TextField = require(Foundation.TextField)
local CheckboxField = require(Foundation.CheckboxField)
local ColorSelector = require(Foundation.ColorSelector)
local ModalBase = require(Foundation.ModalBase)

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)
local BaseNumericalSliderField = require(Specialized.BaseNumericalSliderField)
local BaseDropdownField = require(Specialized.BaseDropdownField)

local spec = require(Plugin.Core.Util.specialize)

local StyleDropdown =
	spec.specialize(
	"StyleDropdown",
	BaseDropdownField,
	{
		label = "Rope Style",
		entries = {
			{id = Types.RopeStyle.SQUARE_SHARP, text = "Square, Sharp"},
			{id = Types.RopeStyle.SQUARE_SMOOTH, text = "Square, Smooth"},
			{id = Types.RopeStyle.DIAMOND_SHARP, text = "Diamond, Sharp"},
			{id = Types.RopeStyle.DIAMOND_SMOOTH, text = "Diamond, Smooth"},
			{id = Types.RopeStyle.ROUND_SHARP, text = "Round, Sharp"},
			{id = Types.RopeStyle.ROUND_SMOOTH, text = "Round, Smooth"}
		},
		LayoutOrder = 1
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local WidthSlider =
	spec.specialize(
	"WidthSlider",
	BaseNumericalSliderField,
	{
		label = "Width",
		minValue = 0.05,
		maxValue = 5,
		valueRound = 0.01,
		valueSnap = 0.05,
		maxCharacters = 4,
		LayoutOrder = 2
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
		minValue = 0.05,
		maxValue = 5,
		valueRound = 0.01,
		valueSnap = 0.05,
		maxCharacters = 4,
		LayoutOrder = 3
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local PartCountDropdown =
	spec.specialize(
	"PartCountDropdown",
	BaseDropdownField,
	{
		label = "Part Count",
		entries = {
			{id = Types.RopePartCount.LOW, text = "Low"},
			{id = Types.RopePartCount.MEDIUM, text = "Medium"},
			{id = Types.RopePartCount.HIGH, text = "High"}
		},
		LayoutOrder = 4
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local TextureLengthSlider =
	spec.specialize(
	"TextureLengthSlider",
	BaseNumericalSliderField,
	{
		label = "Texture Length",
		minValue = 0.25,
		maxValue = 10,
		valueRound = 0.01,
		valueSnap = 0.25,
		maxCharacters = 5,
		LayoutOrder = 4
	},
	{
		label = spec.auto,
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local TextureRotationSlider =
	spec.specialize(
	"TextureRotationSlider",
	BaseNumericalSliderField,
	{
		label = "Texture Rotation",
		minValue = 0,
		maxValue = 1,
		valueRound = 0.01,
		valueSnap = 0.05,
		maxCharacters = 5,
		LayoutOrder = 5
	},
	{
		label = spec.auto,
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local TextureOffsetSlider =
	spec.specialize(
	"TextureOffsetSlider",
	BaseNumericalSliderField,
	{
		label = "Texture Offset",
		minValue = 0,
		maxValue = 1,
		valueRound = 0.01,
		valueSnap = 0.05,
		maxCharacters = 5,
		LayoutOrder = 6
	},
	{
		label = spec.auto,
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local TextureSelectionModal
do
	local TextureEntry = Roact.PureComponent:extend("TextureEntry")

	function TextureEntry:render()
		return Roact.createElement(

		)
	end

	TextureSelectionModal = Roact.PureComponent:extend("TextureSelectionModal")

	function TextureSelectionModal:render()
	end
end

local materialEntries = {
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
}

table.sort(
	materialEntries,
	function(a, b)
		return a.text < b.text
	end
)

local MaterialDropdown =
	spec.specialize(
	"MaterialDropdown",
	BaseDropdownField,
	{
		label = "Material",
		entries = materialEntries,
		LayoutOrder = 7
	},
	{
		onSelected = spec.auto,
		selectedId = spec.auto
	}
)

local RopeParams = Roact.PureComponent:extend("RopeParams")

function RopeParams:init()
	local mainManager = getMainManager(self)
	self.toggleRopeGeometrySection = function()
		mainManager:ToggleCollapsibleSection("RopeGeometry")
	end
	self.toggleRopeAppearanceSection = function()
		mainManager:ToggleCollapsibleSection("RopeAppearance")
	end

	self.onStyleSelected = function(style)
		mainManager:SetPresetRopeParams(self.props.presetId, {style = style})
	end
	self.onWidthChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {width = value})
	end
	self.onHeightChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {height = value})
	end
	self.onPartCountSelected = function(partCount)
		mainManager:SetPresetRopeParams(self.props.presetId, {partCount = partCount})
	end
	self.onMaterialSelected = function(material)
		mainManager:SetPresetRopeParams(self.props.presetId, {material = material})
	end
	self.onTextureToggled = function()
		local textured = mainManager:GetPresetRopeParams(self.props.presetId).textured
		mainManager:SetPresetRopeParams(self.props.presetId, {textured = not textured})
	end
	self.textureIdValidateCallback = function(t)
		return string.len(t) <= 24
	end
	self.onFocusLostTextureId = function(t)
		mainManager:SetPresetRopeParams(self.props.presetId, {textureId = t})
		return t
	end
	self.onTextureLengthChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {textureLength = value})
	end
	self.onTextureRotationChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {textureRotation = value})
	end
	self.onTextureOffsetChanged = function(value)
		mainManager:SetPresetRopeParams(self.props.presetId, {textureOffset = value})
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

function RopeParams:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local geometryCollapsed = mainManager:IsSectionCollapsed("RopeGeometry")
	local appearanceCollapsed = mainManager:IsSectionCollapsed("RopeAppearance")

	SmartSetState(
		self,
		{
			geometryCollapsed = geometryCollapsed,
			appearanceCollapsed = appearanceCollapsed
		}
	)
end

function RopeParams:willUpdate(nextProps, nextState)
	local currentPresetId = self.props.presetId
	local nextPresetId = nextProps.presetId
	if currentPresetId ~= nextPresetId then
		local mainManager = getMainManager(self)
		local ropeType = mainManager:GetPresetRopeType(nextPresetId)
		if ropeType == Types.Rope.ROPE then
			local ropeParams = mainManager:GetPresetRopeParams(nextPresetId)
			local baseColor = ropeParams.baseColor
			local h, s, v = Color3.toHSV(baseColor)
			self.h, self.s, self.v = h, s, v
		end
	end
end

function RopeParams:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder

	return withTheme(
		function(theme)
			local state = self.state
			local ropeParams = props.ropeParams
			local style = ropeParams.style
			local width = ropeParams.width
			local height = ropeParams.height
			local partCount = ropeParams.partCount
			local textured = ropeParams.textured
			local textureId = ropeParams.textureId
			local textureLength = ropeParams.textureLength
			local textureRotation = ropeParams.textureRotation
			local textureOffset = ropeParams.textureOffset
			local material = ropeParams.material
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
					Style = Roact.createElement(
						StyleDropdown,
						{
							selectedId = style,
							onSelected = self.onStyleSelected
						}
					),
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
					PartCount = Roact.createElement(
						PartCountDropdown,
						{
							selectedId = partCount,
							onSelected = self.onPartCountSelected
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
									textured = textured,
									texture = textureId,
									LayoutOrder = 1
								}
							)
						end
					),
					Textured = Roact.createElement(
						CheckboxField,
						{
							label = "Textured?",
							indentLevel = 0,
							labelWidth = 120,
							checked = textured,
							onToggle = self.onTextureToggled,
							LayoutOrder = 2
						}
					),
					TextureId = textured and
						Roact.createElement(
							TextField,
							{
								label = "Texture Id",
								indentLevel = 0,
								labelWidth = 120,
								textInput = textureId,
								newTextValidateCallback = self.textureIdValidateCallback,
								onFocusLost = self.onFocusLostTextureId,
								LayoutOrder = 3
							}
						),
					TextureLength = textured and
						Roact.createElement(
							TextureLengthSlider,
							{
								value = textureLength,
								onValueChanged = self.onTextureLengthChanged
							}
						),
					TextureRotation = textured and
						Roact.createElement(
							TextureRotationSlider,
							{
								value = textureRotation,
								onValueChanged = self.onTextureRotationChanged
							}
						),
					TextureOffset = textured and
						Roact.createElement(
							TextureOffsetSlider,
							{
								value = textureOffset,
								onValueChanged = self.onTextureOffsetChanged
							}
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

function RopeParams:didUpdate(oldProps)
	if oldProps.presetId ~= self.props.presetId then
		local mainManager = getMainManager(self)
		local color = mainManager:GetPresetRopeParams(self.props.presetId).baseColor
		self.h, self.s, self.v = Color3.toHSV(color)
	end
end

function RopeParams:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function RopeParams:willUnmount()
	self.mainManagerDisconnect()
end

return RopeParams
