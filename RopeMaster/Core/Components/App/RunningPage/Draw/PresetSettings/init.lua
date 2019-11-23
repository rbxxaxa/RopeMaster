local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)
local Constants = require(Plugin.Core.Util.Constants)

local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local DropdownField = require(Foundation.DropdownField)
local TextField = require(Foundation.TextField)
local RopeParams = require(script.RopeParams)
local AutoHeightThemedText = require(Foundation.AutoHeightThemedText)
local ThemedTextButton = require(Foundation.ThemedTextButton)

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)

local PresetSettings = Roact.PureComponent:extend("PresetSettings")

function PresetSettings:init()
	local mainManager = getMainManager(self)

	self.togglePresetSettingsSection = function()
		mainManager:ToggleCollapsibleSection("PresetSettings")
	end
	self.toggleRopeSection = function()
		mainManager:ToggleCollapsibleSection("RopeSettings")
	end
	self.toggleOrnamentsSection = function()
		mainManager:ToggleCollapsibleSection("Ornaments")
	end
	self.setPresetRopeType = function(id)
		local activePresetId = mainManager:GetActivePreset()
		mainManager:SetPresetRopeType(activePresetId, id)
	end
	self.nameValidateCallback = function(t)
		return string.len(t) <= Constants.PRESET_NAME_MAX_LENGTH
	end
	self.nameOnFocusLost = function(t)
		local activePresetId = mainManager:GetActivePreset()
		if string.len(t) == 0 then
			return mainManager:GetPresetName(activePresetId)
		end
		mainManager:SetPresetName(activePresetId, t)
		return t
	end

	self.onClickDelete = function()
		local presetId = mainManager:GetActivePreset()
		mainManager:SetPresetIdBeingDeleted(presetId)
	end

	self.onClickDuplicate = function()
		local presetId = mainManager:GetActivePreset()
		local newId = mainManager:DuplicatePreset(presetId)
		mainManager:SetActivePreset(newId)
	end

	self:UpdateStateFromMainManager()
end

function PresetSettings:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local activePresetId = mainManager:GetActivePreset()
	local activePresetName = activePresetId and mainManager:GetPresetName(activePresetId)
	local presetType = activePresetId and mainManager:GetPresetType(activePresetId)
	local ropeType = activePresetId and mainManager:GetPresetRopeType(activePresetId)
	local ropeParams = activePresetId and mainManager:GetPresetRopeParams(activePresetId)
	local presetSettingsCollapsed = mainManager:IsSectionCollapsed("PresetSettings")
	local ropeSettingsCollapsed = mainManager:IsSectionCollapsed("RopeSettings")

	SmartSetState(
		self,
		{
			activePresetId = activePresetId or Roact.None,
			activePresetName = activePresetName,
			presetType = presetType,
			ropeType = ropeType,
			ropeParams = ropeParams,
			presetSettingsCollapsed = presetSettingsCollapsed,
			ropeSettingsCollapsed = ropeSettingsCollapsed
			-- ornamentsCollapsed = ornamentsCollapsed
		}
	)
end

function PresetSettings:render()
	local state = self.state
	local activePresetId = state.activePresetId
	local activePresetName = state.activePresetName
	local presetType = state.presetType
	local ropeType = state.ropeType
	local presetSettingsCollapsed = state.presetSettingsCollapsed
	local ropeSettingsCollapsed = state.ropeSettingsCollapsed
	-- local ornamentsCollapsed = state.ornamentsCollapsed

	return activePresetId and
		Roact.createElement(
			PaddedCollapsibleSection,
			{
				title = string.format("%s-%s", activePresetName, "Settings"),
				LayoutOrder = self.props.LayoutOrder,
				collapsed = presetSettingsCollapsed,
				onCollapseToggled = self.togglePresetSettingsSection
			},
			(function()
				local children = {}

				if presetType == Types.Preset.BUILTIN then
					children.CantEdit =
						Roact.createElement(
						AutoHeightThemedText,
						{
							Text = "This preset is built-in with the plugin. Clone the preset to edit it!",
							TextXAlignment = Enum.TextXAlignment.Left,
							LayoutOrder = 1
						}
					)

					children.CloneButton =
						Roact.createElement(
						ThemedTextButton,
						{
							Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
							LayoutOrder = 2,
							Text = "Clone and Edit Preset",
							onClick = self.onClickDuplicate
						}
					)

					return children
				else
					children.Name =
						Roact.createElement(
						TextField,
						{
							label = "Name",
							labelWidth = 120,
							LayoutOrder = 1,
							textInput = activePresetName,
							newTextValidateCallback = self.nameValidateCallback,
							onFocusLost = self.nameOnFocusLost
						}
					)

					children.CloneButton =
						Roact.createElement(
						ThemedTextButton,
						{
							Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
							LayoutOrder = 2,
							Text = "Clone and Edit Preset",
							onClick = self.onClickDuplicate
						}
					)

					children.DeleteButton =
						Roact.createElement(
						ThemedTextButton,
						{
							Size = UDim2.new(1, 0, 0, Constants.BUTTON_HEIGHT),
							LayoutOrder = 3,
							Text = "Delete Preset",
							onClick = self.onClickDelete
						}
					)

					children.Rope =
						Roact.createElement(
						PaddedCollapsibleSection,
						{
							title = "Rope Settings",
							collapsed = ropeSettingsCollapsed,
							onCollapseToggled = self.toggleRopeSection,
							LayoutOrder = 4
						},
						(function()
							local children = {}
							children.RopeType =
								Roact.createElement(
								DropdownField,
								{
									label = "Rope Type",
									labelWidth = 120,
									selectedId = ropeType,
									entries = {
										{id = Types.Rope.ROPE, text = "Rope"}
									},
									onSelected = self.setPresetRopeType,
									LayoutOrder = 1
								}
							)

							if ropeType == Types.Rope.ROPE then
								children.RopeParams =
									Roact.createElement(
									RopeParams,
									{
										presetId = activePresetId,
										ropeParams = state.ropeParams,
										LayoutOrder = 2
									}
								)
							end
							return children
						end)()
					)
					-- children.Ornaments =
					-- 	Roact.createElement(
					-- 	PaddedCollapsibleSection,
					-- 	{
					-- 		title = "Ornaments",
					-- 		LayoutOrder = 3,
					-- 		collapsed = ornamentsCollapsed,
					-- 		onCollapseToggled = self.toggleOrnamentsSection
					-- 	},
					-- 	{}
					-- )

					return children
				end
			end)()
		)
end

function PresetSettings:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function PresetSettings:willUnmount()
	self.mainManagerDisconnect()
end

return PresetSettings
