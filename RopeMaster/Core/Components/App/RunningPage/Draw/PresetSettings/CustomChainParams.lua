local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local spec = require(Plugin.Core.Util.specialize)
local Types = require(Plugin.Core.Util.Types)
local Utility = require(Plugin.Core.Util.Utility)
local Constants = require(Plugin.Core.Util.Constants)

local withTheme = ContextHelper.withTheme
local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local VerticalList = require(Foundation.VerticalList)
local ObjectThumbnail = require(Foundation.ObjectThumbnail)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local TextField = require(Foundation.TextField)

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)
local BaseNumericalSliderField = require(Specialized.BaseNumericalSliderField)
local BaseDropdownField = require(Specialized.BaseDropdownField)

local function truncateTrailingDecimal(n, precision)
	local s, _ = string.format("%." .. precision .. "f", n):gsub("%.?0+$", "")

	return s
end

local function formatVector3(x, y, z)
	return string.format("%s, %s, %s", truncateTrailingDecimal(x, 3), truncateTrailingDecimal(y, 3), truncateTrailingDecimal(z, 3))
end

local function vector3FocusLostCallbackFactory(decimalPlaces, getCurrentCallback, doUpdateCallback)
	decimalPlaces = decimalPlaces or 3
	local roundTo = 10 ^ (-decimalPlaces)
	return function(t)
		local x, y, z = string.match(t, "^%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*$")
		if not x or not y or not z then
			x, y, z = string.match(t, "^ *([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+) *$")
		end
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		if x and y and z then
			x, y, z = Utility.Round(x, roundTo), Utility.Round(y, roundTo), Utility.Round(z, roundTo)
			if x ~= 0 or y ~= 0 or z ~= 0 then
				local v = Vector3.new(x, y, z)
				doUpdateCallback(v)
				return formatVector3(v.x, v.y, v.z)
			else
				local current = getCurrentCallback()
				return formatVector3(current.x, current.y, current.z)
			end
		else
			local current = getCurrentCallback()
			return formatVector3(current.x, current.y, current.z)
		end
	end
end

local function vector3FormatCallbackFactory(decimalPlaces)
	decimalPlaces = decimalPlaces or 3
	local roundTo = 10 ^ (-decimalPlaces)
	return function(t)
		local x, y, z = string.match(t, "^%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*$")
		if not x or not y or not z then
			x, y, z = string.match(t, "^ *([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+)%s*([+-]?%d*%.?%d+) *$")
		end
		x, y, z = tonumber(x), tonumber(y), tonumber(z)
		x, y, z = Utility.Round(x, roundTo), Utility.Round(y, roundTo), Utility.Round(z, roundTo)
		return formatVector3(x, y, z)
	end
end

local function vector3ValidateCallback(t)
	return t:match("^[%d%s.,-]*$") ~= nil
end

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

local LinkSpacingSlider =
	spec.specialize(
	"LinkSpacingSlider",
	BaseNumericalSliderField,
	{
		label = "Link Spacing",
		minValue = 0.5,
		maxValue = 10,
		valueRound = 0.01,
		valueSnap = 0.1,
		maxCharacters = 5,
		LayoutOrder = 3
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

local CustomChainParams = Roact.PureComponent:extend("CustomChainParams")

function CustomChainParams:init()
	local mainManager = getMainManager(self)
	self.toggleRopeGeometrySection = function()
		mainManager:ToggleCollapsibleSection("RopeGeometry")
	end
	self.toggleRopeRotationSection = function()
		mainManager:ToggleCollapsibleSection("RopeRotation")
	end

	self.onSegmentScaleChanged = function(scale)
		mainManager:SetPresetRopeParams(self.props.presetId, {segmentScale = scale})
	end
	self.onLinkSpacingChanged = function(spacing)
		mainManager:SetPresetRopeParams(self.props.presetId, {linkSpacing = spacing})
	end
	self.onLinkOffsetChanged = function(spacing)
		mainManager:SetPresetRopeParams(self.props.presetId, {linkOffset = spacing})
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
	self.linkOffsetOnFocusLost =
		vector3FocusLostCallbackFactory(
		3,
		function()
			local ropeParams = mainManager:GetPresetRopeParams(self.props.presetId)
			local linkOffset = ropeParams.linkOffset
			return linkOffset
		end,
		function(v)
			mainManager:SetPresetRopeParams(self.props.presetId, {linkOffset = v})
		end
	)
	self.linkOffsetValidateCallback = vector3FormatCallbackFactory(3)
	self:UpdateStateFromMainManager()
	self:UpdateStateFromSelection()
end

function CustomChainParams:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local presetId = self.props.presetId
	local ropeParams = mainManager:GetPresetRopeParams(presetId)
	local segmentScale = ropeParams.segmentScale
	local linkSpacing = ropeParams.linkSpacing
	local linkOffset = ropeParams.linkOffset
	local originMode = ropeParams.originMode
	local rotationLinkAxis = ropeParams.rotationLinkAxis
	local rotationLinkOffset = ropeParams.rotationLinkOffset
	local rotationPerLink = ropeParams.rotationPerLink
	local rotationLinkRandomMin = ropeParams.rotationLinkRandomMin
	local rotationLinkRandomMax = ropeParams.rotationLinkRandomMax
	local geometryCollapsed = mainManager:IsSectionCollapsed("RopeGeometry")
	local rotationCollapsed = mainManager:IsSectionCollapsed("RopeRotation")

	SmartSetState(
		self,
		{
			geometryCollapsed = geometryCollapsed,
			rotationCollapsed = rotationCollapsed,
			segmentScale = segmentScale,
			linkSpacing = linkSpacing,
			linkOffset = linkOffset,
			originMode = originMode,
			rotationLinkAxis = rotationLinkAxis,
			rotationLinkOffset = rotationLinkOffset,
			rotationPerLink = rotationPerLink,
			rotationLinkRandomMin = rotationLinkRandomMin,
			rotationLinkRandomMax = rotationLinkRandomMax
		}
	)
end

local function isValidPartClass(inst)
	return inst:IsA("BasePart") and not inst:IsA("Terrain")
end

local function isValidModelClass(inst)
	return inst.ClassName == "Model"
end

function CustomChainParams:UpdateStateFromSelection()
	local mainManager = getMainManager(self)
	local selection = mainManager:GetSelection()
	local validSelection
	local invalidReason
	if #selection == 0 then
		invalidReason = "NoSelection"
	elseif #selection > 1 then
		invalidReason = "TooManySelected"
	else
		local selected = selection[1]
		if selected.Archivable == false then
			invalidReason = "NotArchivable"
		elseif isValidPartClass(selected) then
			validSelection = true
		elseif isValidModelClass(selected) then
			validSelection = false
			for _, v in next, selected:GetDescendants() do
				if isValidPartClass(v) and v.Archivable then
					validSelection = true
				end
			end
			if not validSelection then
				invalidReason = "ModelNoParts"
			end
		end
	end

	print(validSelection, invalidReason)

	SmartSetState(
		self,
		{
			validSelection = validSelection or Roact.None,
			invalidReason = invalidReason or Roact.None
		}
	)
end

local invalidReasonToTextMapping = {
	NoSelection = "Select one part or model.",
	TooManySelected = "Only one thing may be selected.",
	NotArchivable = "Selected must be archivable.",
	ModelNoParts = "Model has no parts."
}

function CustomChainParams:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder

	return withTheme(
		function(theme)
			local state = self.state
			local geometryCollapsed = state.geometryCollapsed
			local rotationCollapsed = state.rotationCollapsed
			local segmentScale = state.segmentScale
			local linkSpacing = state.linkSpacing
			local linkOffset = state.linkOffset
			local rotationLinkAxis = state.rotationLinkAxis
			local rotationLinkOffset = state.rotationLinkOffset
			local rotationPerLink = state.rotationPerLink
			local rotationLinkRandomMin = state.rotationLinkRandomMin
			local rotationLinkRandomMax = state.rotationLinkRandomMax
			local validSelection = state.validSelection
			local invalidReason = state.invalidReason
			local segmentName = "Placeholder segment name"
			local segmentButtonEnabled = validSelection
			local disabledText = invalidReasonToTextMapping[invalidReason] or "Selection isn't valid"

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
					SegmentFrame = Roact.createElement(
						"Frame",
						{
							Size = UDim2.new(1, 0, 0, 64),
							BackgroundTransparency = 1
						},
						{
							Thumb = Roact.createElement(
								ObjectThumbnail,
								{
									Size = UDim2.new(0, 64, 0, 64)
								}
							),
							RightFrame = Roact.createElement(
								"Frame",
								{
									BackgroundTransparency = 1,
									Size = UDim2.new(1, -64 - 4, 1, 0),
									Position = UDim2.new(1, 0, 0, 0),
									AnchorPoint = Vector2.new(1, 0)
								},
								{
									List = Roact.createElement(
										"UIListLayout",
										{
											SortOrder = Enum.SortOrder.LayoutOrder,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											Padding = UDim.new(0, 4)
										}
									),
									SegmentName = Roact.createElement(
										"TextLabel",
										{
											TextColor3 = theme.mainTextColor,
											BackgroundTransparency = 1,
											TextSize = Constants.FONT_SIZE_MEDIUM,
											Text = segmentName,
											LayoutOrder = 1,
											Font = Constants.FONT,
											Size = UDim2.new(1, 0, 0, Constants.FONT_SIZE_MEDIUM)
										}
									),
									SegmentSetterText = not segmentButtonEnabled and
										Roact.createElement(
											AutoHeightThemedText,
											{
												Text = disabledText,
												LayoutOrder = 2
											}
										),
									SegmentSetterButton = segmentButtonEnabled and
										Roact.createElement(
											ThemedTextButton,
											{
												Text = "Placeholder",
												Size = UDim2.new(1, 0, 0, 24),
												LayoutOrder = 2,
												onClick = self.onSegmentSetterClick
											}
										)
								}
							)
						}
					),
					SegmentScale = Roact.createElement(
						SegmentScaleSlider,
						{
							value = segmentScale,
							onValueChanged = self.onSegmentScaleChanged
						}
					),
					LinkSpacing = Roact.createElement(
						LinkSpacingSlider,
						{
							value = linkSpacing,
							onValueChanged = self.onLinkSpacingChanged
						}
					),
					LinkOffset = Roact.createElement(
						TextField,
						{
							label = "LinkOffset",
							LayoutOrder = 4,
							onFocusLost = self.linkOffsetOnFocusLost,
							textFormatCallback = self.linkOffsetValidateCallback,
							newTextValidateCallback = vector3ValidateCallback,
							textInput = formatVector3(linkOffset.x, linkOffset.y, linkOffset.z),
							labelWidth = 120
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

function CustomChainParams:didUpdate(oldProps)
	if oldProps.presetId ~= self.props.presetId then
		local mainManager = getMainManager(self)
		local color = mainManager:GetPresetRopeParams(self.props.presetId).baseColor
		self.h, self.s, self.v = Color3.toHSV(color)
	end
end

function CustomChainParams:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
	self.selectionDisconnect =
		mainManager:subscribeToSelection(
		function()
			self:UpdateStateFromSelection()
		end
	)
end

function CustomChainParams:willUnmount()
	self.mainManagerDisconnect()
	self.selectionDisconnect()
end

return CustomChainParams
