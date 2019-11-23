local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local getMainManager = ContextGetter.getMainManager
local withMainManager = ContextHelper.withMainManager
local withTheme = ContextHelper.withTheme

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local CollapsibleTitledSection = require(Foundation.CollapsibleTitledSection)
local VerticalList = require(Foundation.VerticalList)
local ThemedTextBox = require(Foundation.ThemedTextBox)
local PreciseButton = require(Foundation.PreciseButton)
local PresetList = require(script.PresetList)
local ThemedAutoWidthLineCheckbox = require(Foundation.ThemedAutoWidthLineCheckbox)

local Presets = Roact.PureComponent:extend("Presets")

function Presets:init()
	local mainManager = getMainManager(self)

	self.newTextValidateCallback = function(t)
		return t:len() <= 32
	end

	self.onInputChanged = function(t)
		mainManager:SetPresetsFilterString(t)
	end

	self.state = {
		clearButtonHovered = false
	}

	self.onMouseEnter = function()
		self:setState {
			clearButtonHovered = true
		}
	end

	self.onMouseLeave = function()
		self:setState {
			clearButtonHovered = false
		}
	end

	self.clearFilter = function()
		mainManager:SetPresetsFilterString("")
	end

	self.toggleHideBuiltins = function()
		mainManager:SetHideBuiltinPresets(not mainManager:GetHideBuiltinPresets())
	end

	self.togglePresetsSection = function()
		mainManager:ToggleCollapsibleSection("Presets")
	end
end

function Presets:render()
	return withTheme(
		function(theme)
			return withMainManager(
				function(mainManager)
					local filterString = mainManager:GetPresetsFilterString()
					--			local hideBuiltins = mainManager:GetHideBuiltinPresets()
					return Roact.createElement(
						CollapsibleTitledSection,
						{
							title = "Presets",
							LayoutOrder = self.props.LayoutOrder,
							collapsed = mainManager:IsSectionCollapsed("Presets"),
							onCollapseToggled = self.togglePresetsSection
						},
						{
							List = Roact.createElement(
								VerticalList,
								{
									width = UDim.new(1, 0),
									Visible = not mainManager:IsSectionCollapsed("Presets"),
									PaddingLeftPixel = 0,
									PaddingRightPixel = 0,
									PaddingBottomPixel = 0,
									PaddingTopPixel = 0,
									ElementPaddingPixel = 0
								},
								{
									FilterBox = Roact.createElement(
										VerticalList,
										{
											BackgroundTransparency = 1,
											width = UDim.new(1, 0),
											LayoutOrder = 1,
											ElementPaddingPixel = 4,
											PaddingTopPixel = 4,
											PaddingBottomPixel = 4,
											PaddingRightPixel = 4,
											PaddingLeftPixel = 4
										},
										{
											FilterFrame = Roact.createElement(
												"Frame",
												{
													Size = UDim2.new(1, 0, 0, 24),
													BackgroundTransparency = 1,
													LayoutOrder = 1
												},
												{
													FilterInput = Roact.createElement(
														ThemedTextBox,
														{
															Size = UDim2.new(1, 0, 1, 0),
															Position = UDim2.new(0, 0, 0, 0),
															placeholderText = "Filter...",
															textInput = filterString,
															newTextValidateCallback = self.newTextValidateCallback,
															onInputChanged = self.onInputChanged
														}
													),
													ClearButton = filterString:len() > 0 and
														Roact.createElement(
															PreciseButton,
															{
																Size = UDim2.new(0, 24, 0, 24),
																Position = UDim2.new(1, 0, 0.5, 0),
																AnchorPoint = Vector2.new(1, 0.5),
																BackgroundTransparency = 1,
																[Roact.Event.MouseEnter] = self.onMouseEnter,
																[Roact.Event.MouseLeave] = self.onMouseLeave,
																[Roact.Event.MouseButton1Down] = self.clearFilter
															},
															{
																Image = Roact.createElement(
																	"ImageLabel",
																	{
																		Image = self.state.clearButtonHovered and Constants.FILTER_CLEAR_ICON_HOVER or Constants.FILTER_CLEAR_ICON,
																		ImageColor3 = self.state.clearButtonHovered and theme.filterBox.clearButtonHovered or
																			theme.filterBox.clearButtonDefault,
																		Size = UDim2.new(0, 14, 0, 14),
																		Position = UDim2.new(0.5, 0, 0.5, 0),
																		AnchorPoint = Vector2.new(0.5, 0.5),
																		BackgroundTransparency = 1
																	}
																)
															}
														)
												}
											),
											CheckboxFrame = Roact.createElement(
												"Frame",
												{
													Size = UDim2.new(1, 0, 0, 16),
													BackgroundTransparency = 1,
													LayoutOrder = 2
												},
												{
													Checkbox = Roact.createElement(
														ThemedAutoWidthLineCheckbox,
														{
															Position = UDim2.new(0, 0, 0, 0),
															AnchorPoint = Vector2.new(0, 0),
															checked = mainManager:GetHideBuiltinPresets(),
															onToggle = self.toggleHideBuiltins,
															label = "Hide Built-in Presets",
															height = UDim.new(0, 16)
														}
													)
												}
											)
										}
									),
									FilterSep = Roact.createElement(
										"Frame",
										{
											BorderSizePixel = 0,
											Size = UDim2.new(1, 0, 0, 1),
											BackgroundColor3 = theme.borderColor,
											LayoutOrder = 2
										}
									),
									PresetBox = Roact.createElement(
										"Frame",
										{
											BackgroundTransparency = 1,
											Size = UDim2.new(1, 0, 0, 320 + 8),
											LayoutOrder = 3
										},
										{
											PresetList = Roact.createElement(
												PresetList,
												{
													Size = UDim2.new(1, -8, 1, -8),
													Position = UDim2.new(0, 4, 0, 4),
													LayoutOrder = 4
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

return Presets
