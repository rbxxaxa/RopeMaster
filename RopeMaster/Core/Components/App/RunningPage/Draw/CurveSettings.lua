local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local spec = require(Plugin.Core.Util.specialize)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)
local BaseNumericalSliderField = require(Specialized.BaseNumericalSliderField)
local BaseDropdownField = require(Specialized.BaseDropdownField)

local CurveDropdown =
	spec.specialize(
	"CurveDropdown",
	BaseDropdownField,
	{
		label = "Curve Type",
		labelWidth = 120,
		entries = {
			{id = Types.Curve.CATENARY, text = "Catenary"},
			{id = Types.Curve.LINE, text = "Line"},
			{id = Types.Curve.LOOP, text = "Loop"}
			--			{ id = "Coil", text = "Coil" }
		},
		LayoutOrder = 1
	},
	{
		selectedId = spec.auto,
		onSelected = spec.auto
	}
)

local DangleLengthModeDropdown =
	spec.specialize(
	"DangleLengthModeDropdown",
	BaseDropdownField,
	{
		label = "Length Mode",
		entries = {
			{id = Types.CatenaryLengthMode.RELATIVE, text = "Relative"},
			{id = Types.CatenaryLengthMode.FIXED, text = "Fixed"}
		},
		LayoutOrder = 2
	},
	{
		selectedId = spec.auto,
		onSelected = spec.auto
	}
)

local DangleLengthFixedSlider =
	spec.specialize(
	"DangleLengthFixedSlider",
	BaseNumericalSliderField,
	{
		label = "Studs",
		minValue = Constants.DANGLE_LENGTH_FIXED_MIN,
		maxValue = Constants.DANGLE_LENGTH_FIXED_MAX,
		valueRound = 0.1,
		valueSnap = 5,
		maxCharacters = 3,
		LayoutOrder = 3
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local DangleLengthRelativeSlider =
	spec.specialize(
	"DangleLengthRelativeSlider",
	BaseNumericalSliderField,
	{
		label = "Factor",
		minValue = Constants.DANGLE_LENGTH_RELATIVE_MIN,
		maxValue = Constants.DANGLE_LENGTH_RELATIVE_MAX,
		valueRound = 0.01,
		valueSnap = 0.05,
		maxCharacters = 4,
		LayoutOrder = 4
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local LoopShapeDropdown =
	spec.specialize(
	"LoopShapeDropdown",
	BaseDropdownField,
	{
		label = "Shape",
		entries = {
			{id = Types.LoopShape.RECTANGLE, text = "Rectangle"},
			{id = Types.LoopShape.CIRCLE, text = "Circle"}
		},
		LayoutOrder = 5
	},
	{
		selectedId = spec.auto,
		onSelected = spec.auto
	}
)

local LoopOffsetSlider =
	spec.specialize(
	"LoopOffsetSlider",
	BaseNumericalSliderField,
	{
		label = "Offset",
		minValue = Constants.LOOP_OFFSET_MIN,
		maxValue = Constants.LOOP_OFFSET_MAX,
		valueRound = 0.01,
		valueSnap = 0.1,
		maxCharacters = 4,
		LayoutOrder = 7
	},
	{
		value = spec.auto,
		onValueChanged = spec.auto
	}
)

local CurveSettings = Roact.PureComponent:extend("CurveSettings")

function CurveSettings:init()
	local mainManager = getMainManager(self)

	self.toggleCurveSettingsSection = function()
		mainManager:ToggleCollapsibleSection("CurveSettings")
	end
	self.setCurveType = function(curveType)
		mainManager:SetCurveType(curveType)
	end
	self.setDangleLengthMode = function(lengthMode)
		mainManager:SetDangleLengthMode(lengthMode)
	end
	self.setDangleLengthFixed = function(fixed)
		mainManager:SetDangleLengthFixed(fixed)
	end
	self.setDangleLengthRelative = function(relative)
		mainManager:SetDangleLengthRelative(relative)
	end
	self.setLoopShape = function(shape)
		mainManager:SetLoopShape(shape)
	end
	self.setLoopOffset = function(thickness)
		mainManager:SetLoopOffset(thickness)
	end

	self:UpdateStateFromMainManager()
end

function CurveSettings:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local curveSettingsCollapsed = mainManager:IsSectionCollapsed("CurveSettings")
	local curveType = mainManager:GetCurveType()
	local dangleLengthMode = mainManager:GetDangleLengthMode()
	local dangleLengthRelative = mainManager:GetDangleLengthRelative()
	local dangleLengthFixed = mainManager:GetDangleLengthFixed()
	local loopShape = mainManager:GetLoopShape()
	local loopOffset = mainManager:GetLoopOffset()

	SmartSetState(
		self,
		{
			curveSettingsCollapsed = curveSettingsCollapsed,
			curveType = curveType,
			dangleLengthMode = dangleLengthMode,
			dangleLengthRelative = dangleLengthRelative,
			dangleLengthFixed = dangleLengthFixed,
			loopShape = loopShape,
			loopOffset = loopOffset
		}
	)
end

function CurveSettings:render()
	local state = self.state
	local curveSettingsCollapsed = state.curveSettingsCollapsed
	local curveType = state.curveType
	local dangleLengthMode = state.dangleLengthMode
	local dangleLengthRelative = state.dangleLengthRelative
	local dangleLengthFixed = state.dangleLengthFixed
	local loopShape = state.loopShape
	local loopOffset = state.loopOffset

	return Roact.createElement(
		PaddedCollapsibleSection,
		{
			title = "Curve Settings",
			LayoutOrder = self.props.LayoutOrder,
			collapsed = curveSettingsCollapsed,
			onCollapseToggled = self.toggleCurveSettingsSection
		},
		{
			CurveDropdown = Roact.createElement(
				CurveDropdown,
				{
					selectedId = curveType,
					onSelected = self.setCurveType
				}
			),
			DangleLengthMode = curveType == Types.Curve.CATENARY and
				Roact.createElement(
					DangleLengthModeDropdown,
					{
						selectedId = dangleLengthMode,
						onSelected = self.setDangleLengthMode
					}
				),
			DangleLengthFixed = curveType == Types.Curve.CATENARY and dangleLengthMode == Types.CatenaryLengthMode.FIXED and
				Roact.createElement(
					DangleLengthFixedSlider,
					{
						value = dangleLengthFixed,
						onValueChanged = self.setDangleLengthFixed
					}
				),
			DangleLengthRelative = curveType == Types.Curve.CATENARY and dangleLengthMode == Types.CatenaryLengthMode.RELATIVE and
				Roact.createElement(
					DangleLengthRelativeSlider,
					{
						value = dangleLengthRelative,
						onValueChanged = self.setDangleLengthRelative
					}
				),
			LoopShape = curveType == Types.Curve.LOOP and
				Roact.createElement(
					LoopShapeDropdown,
					{
						selectedId = loopShape,
						onSelected = self.setLoopShape
					}
				),
			LoopOffset = curveType == Types.Curve.LOOP and
				Roact.createElement(
					LoopOffsetSlider,
					{
						value = loopOffset,
						onValueChanged = self.setLoopOffset
					}
				)
		}
	)
end

function CurveSettings:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function CurveSettings:willUnmount()
	self.mainManagerDisconnect()
end

return CurveSettings
