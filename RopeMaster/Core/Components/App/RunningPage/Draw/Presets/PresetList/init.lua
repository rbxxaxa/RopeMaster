local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Utility = require(Plugin.Core.Util.Utility)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)
local Types = require(Plugin.Core.Util.Types)

local withTheme = ContextHelper.withTheme
local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local BorderedFrame = require(Foundation.BorderedFrame)
local PresetEntry = require(script.PresetEntry)
--local BrushObjectAddEntry = require(script.BrushObjectAddEntry)
--local BrushNote = require(script.BrushNote)
local ScrollingVerticalList = require(Foundation.ScrollingVerticalList)
local ThemedTextButton = require(Foundation.ThemedTextButton)
local VerticalList = require(Foundation.VerticalList)

local PresetList = Roact.PureComponent:extend("PresetList")

function PresetList:init()
	local mainManager = getMainManager(self)
	local presetIds = Utility.ShallowCopy(mainManager:GetPublicPresetIds())
	self:setState {
		presetIds = presetIds,
		filterString = mainManager:GetPresetsFilterString(),
		hideBuiltinPresets = mainManager:GetHideBuiltinPresets()
	}

	self.clearFilter = function()
		mainManager:SetPresetsFilterString("")
	end

	self.onAddNewPreset = function()
		local newPreset = mainManager:AddNewPreset()
		mainManager:SetActivePreset(newPreset)
	end
end

function PresetList:render()
	local props = self.props
	local LayoutOrder = props.LayoutOrder
	local Size = props.Size
	local Position = props.Position
	local filterString = self.state.filterString
	local presetIds = self.state.presetIds
	-- filter + sort the presets alphabetically
	local mainManager = getMainManager(self)
	local presetsToShow = {}
	do
		local pidToNameMapping = {}
		local hideBuiltinPresets = self.state.hideBuiltinPresets
		for _, presetId in next, presetIds do
			local name = mainManager:GetPresetName(presetId)
			pidToNameMapping[presetId] = name
			if string.lower(name):find(string.lower(filterString), 1, true) then
				if (hideBuiltinPresets == false) or (mainManager:GetPresetType(presetId) == Types.Preset.CUSTOM) then
					table.insert(presetsToShow, presetId)
				end
			end
		end

		table.sort(
			presetsToShow,
			function(a, b)
				return pidToNameMapping[a] < pidToNameMapping[b]
			end
		)
	end

	local listPadding = 4

	return withTheme(
		function(theme)
			return Roact.createElement(
				BorderedFrame,
				{
					Size = Size,
					LayoutOrder = LayoutOrder,
					BackgroundColor3 = theme.mainBackgroundColor,
					BorderColor3 = theme.borderColor,
					Position = Position
				},
				{
					NoResultsOverlay = filterString:len() > 0 and #presetsToShow == 0 and
						Roact.createElement(
							"Frame",
							{
								Size = UDim2.new(1, -Constants.SCROLL_BAR_THICKNESS, 1, 0),
								BackgroundTransparency = 1
							},
							{
								ClearText = Roact.createElement(
									"TextLabel",
									{
										Size = UDim2.new(1, 0, 0, Constants.FONT_SIZE_MEDIUM),
										BackgroundTransparency = 1,
										Font = Constants.FONT,
										TextColor3 = theme.mainTextColor,
										Position = UDim2.new(0.5, 0, 0.5, -24),
										Text = "Cannot find presets matching",
										AnchorPoint = Vector2.new(0.5, 0.5),
										TextSize = Constants.FONT_SIZE_MEDIUM,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextTruncate = Enum.TextTruncate.None,
										ZIndex = 2
									}
								),
								ClearName = Roact.createElement(
									"TextLabel",
									{
										Size = UDim2.new(1, 0, 0, Constants.FONT_SIZE_MEDIUM),
										BackgroundTransparency = 1,
										Font = Constants.FONT,
										TextColor3 = theme.mainTextColor,
										Position = UDim2.new(0.5, 0, 0.5, -24 + Constants.FONT_SIZE_MEDIUM),
										Text = string.format('"%s".', filterString),
										AnchorPoint = Vector2.new(0.5, 0.5),
										TextSize = Constants.FONT_SIZE_MEDIUM,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextTruncate = Enum.TextTruncate.None,
										ZIndex = 2
									}
								),
								ClearButton = Roact.createElement(
									ThemedTextButton,
									{
										Text = "Clear Filter",
										buttonStyle = "Default",
										Size = UDim2.new(0, 100, 0, 24),
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.new(0.5, 0, 0.5, 25),
										ZIndex = 2,
										onClick = self.clearFilter
									}
								)
							}
						),
					List = Roact.createElement(
						ScrollingVerticalList,
						{
							Size = UDim2.new(1, -1, 1, -2),
							Position = UDim2.new(0, 1, 0, 1),
							PaddingLeftPixel = listPadding,
							PaddingRightPixel = listPadding,
							PaddingBottomPixel = listPadding,
							PaddingTopPixel = listPadding,
							skipPercent = 0,
							skipPixel = 208 -- exactly enough to skip two entries
						},
						{
							List = Roact.createElement(
								VerticalList,
								{
									PaddingTopPixel = 4,
									PaddingBottomPixel = 4,
									PaddingLeftPixel = 4,
									PaddingRightPixel = 4,
									ElementPaddingPixel = 4,
									width = UDim.new(1, 0)
								},
								(function()
									local children = {}

									for i, presetId in next, presetsToShow do
										--										local presetType = mainManager:GetPresetType(presetId)
										children[presetId] =
											Roact.createElement(
											PresetEntry,
											{
												LayoutOrder = i,
												presetId = presetId
											}
										)
									end

									children.AddNewPresetButton =
										filterString:len() == 0 and
										Roact.createElement(
											ThemedTextButton,
											{
												LayoutOrder = #presetsToShow + 1,
												Size = UDim2.new(1, 0, 0, 40),
												Text = "+ Click to add a new preset!",
												-- buttonStyle = "Add",
												Font = Constants.FONT_BOLD,
												onClick = self.onAddNewPreset
											}
										)

									return children
								end) {}
							)
						}
					)
					--					NoResultsFoundFrame = Roact.createElement(
					--						"Frame",
					--						{
					--							Size = UDim2.new(1, -Constants.SCROLL_BAR_THICKNESS, 1, 0),
					--							Visible = filterCount == 0 and filter ~= "",
					--							BackgroundTransparency = 1
					--						},
					--						{
					--							NoResultsLabel = Roact.createElement(
					--								"TextLabel",
					--								{
					--									BackgroundTransparency = 1,
					--									Text = string.format("No results found for \"%s\".", filter),
					--									TextColor3 = listTheme.noResultsColor,
					--									Font = Enum.Font.SourceSans,
					--									TextSize = Constants.FONT_SIZE_MEDIUM,
					--									AnchorPoint = Vector2.new(0.5, 0.5),
					--									Size = UDim2.new(1, -20, 0, -Constants.FONT_SIZE_MEDIUM*2),
					--									Position = UDim2.new(0.5, 0, 0.5, -Constants.BUTTON_HEIGHT/2-Constants.FONT_SIZE_MEDIUM),
					--									TextTruncate = Enum.TextTruncate.AtEnd,
					--									TextWrapped = true,
					--									TextYAlignment = Enum.TextYAlignment.Bottom
					--								}
					--							),
					--							EnableButton = Roact.createElement(
					--								ThemedTextButton,
					--								{
					--									Size = UDim2.new(0, 100, 0, Constants.BUTTON_HEIGHT),
					--									Position = UDim2.new(0.5, 0, 0.5, Constants.BUTTON_HEIGHT/2),
					--									AnchorPoint = Vector2.new(0.5, 0.5),
					--									Text = "Clear Filter",
					--									onClick = props.clearFilter
					--								}
					--							),
					--						}
					--					)
				}
			)
		end
	)
end

function PresetList:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			local oldPresetIds = self.state.presetIds
			local newPresetIds = Utility.ShallowCopy(mainManager:GetPublicPresetIds())

			if #oldPresetIds ~= #newPresetIds then
				self:setState {
					presetIds = newPresetIds
				}
				return
			end

			local oldIdSet = {}
			for _, id in next, oldPresetIds do
				oldIdSet[id] = true
			end

			for i = 1, #newPresetIds do
				local id = newPresetIds[i]
				if oldIdSet[id] then
					oldIdSet[id] = nil
					newPresetIds[i] = nil
				end
			end

			if next(oldIdSet) then
				self:setState {
					presetIds = newPresetIds
				}
				return
			end

			if next(newPresetIds) then
				self:setState {
					presetIds = newPresetIds
				}
				return
			end
			local filterString = mainManager:GetPresetsFilterString()
			if self.state.filterString ~= filterString then
				self:setState {
					filterString = filterString
				}
			end

			local hideBuiltinPresets = mainManager:GetHideBuiltinPresets()
			if self.state.hideBuiltinPresets ~= hideBuiltinPresets then
				self:setState {
					hideBuiltinPresets = hideBuiltinPresets
				}
			end
		end
	)
end

function PresetList:willUnmount()
	self.mainManagerDisconnect()
end

return PresetList
