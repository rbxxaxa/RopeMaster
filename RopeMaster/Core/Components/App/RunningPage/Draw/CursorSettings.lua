local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local Components = Plugin.Core.Components
local Foundation = Components.Foundation
local DropdownField = require(Foundation.DropdownField)
local NumericalSliderField = require(Foundation.NumericalSliderField)
local CheckboxField = require(Foundation.CheckboxField)

local Specialized = Components.Specialized
local PaddedCollapsibleSection = require(Specialized.PaddedCollapsibleSection)

local CursorSettings = Roact.PureComponent:extend("CursorSettings")

function CursorSettings:init()
	local mainManager = getMainManager(self)

	self.toggleCursorSettingsSection = function()
		mainManager:ToggleCollapsibleSection("CursorSettings")
	end
	self.setLockTo = function(lockTo)
		mainManager:SetLockTo(lockTo)
	end
	self.setGridSize = function(gridSize)
		mainManager:SetGridSize(gridSize)
	end
	self.setLockDistance = function(lockDistance)
		mainManager:SetLockDistance(lockDistance)
	end
	self.onIgnoreRopeToggled = function()
		local ignoreRope = mainManager:GetIgnoreRope()
		mainManager:SetIgnoreRope(not ignoreRope)
	end

	self:UpdateStateFromMainManager()
end

function CursorSettings:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	local cursorSettingsCollapsed = mainManager:IsSectionCollapsed("CursorSettings")
	local lockTo = mainManager:GetLockTo()
	local lockDistance = mainManager:GetLockDistance()
	local gridSize = mainManager:GetGridSize()
	local ignoreRope = mainManager:GetIgnoreRope()

	SmartSetState(
		self,
		{
			cursorSettingsCollapsed = cursorSettingsCollapsed,
			lockTo = lockTo,
			lockDistance = lockDistance,
			gridSize = gridSize,
			ignoreRope = ignoreRope
		}
	)
end

function CursorSettings:render()
	local state = self.state
	local cursorSettingsCollapsed = state.cursorSettingsCollapsed
	local lockTo = state.lockTo
	local lockDistance = state.lockDistance
	local gridSize = state.gridSize
	local ignoreRope = state.ignoreRope

	return Roact.createElement(
		PaddedCollapsibleSection,
		{
			title = "Cursor Settings",
			LayoutOrder = self.props.LayoutOrder,
			collapsed = cursorSettingsCollapsed,
			onCollapseToggled = self.toggleCursorSettingsSection
		},
		{
			LockDropdown = Roact.createElement(
				DropdownField,
				{
					label = "Lock To",
					selectedId = lockTo,
					entries = {
						{id = Types.LockTo.NONE, text = "None"},
						{id = Types.LockTo.PART_CENTERS, text = "Part Centers"},
						{id = Types.LockTo.GRID, text = "Grid"},
						{id = Types.LockTo.MIDPOINTS, text = "Midpoints"},
						{id = Types.LockTo.ATTACHMENTS, text = "Attachments"}
					},
					onSelected = self.setLockTo,
					LayoutOrder = 1
				}
			),
			IgnoreRope = Roact.createElement(
				CheckboxField,
				{
					label = "Ignore Rope?",
					checked = ignoreRope,
					LayoutOrder = 2,
					onToggle = self.onIgnoreRopeToggled
				}
			),
			LockDistance = (lockTo == Types.LockTo.ATTACHMENTS or lockTo == Types.LockTo.MIDPOINTS) and
				Roact.createElement(
					NumericalSliderField,
					{
						label = "Lock Distance",
						value = lockDistance,
						minValue = Constants.LOCK_DISTANCE_MIN,
						maxValue = Constants.LOCK_DISTANCE_MAX,
						valueRound = 0.1,
						valueSnap = 0.5,
						onValueChanged = self.setLockDistance,
						LayoutOrder = 3
					}
				),
			GridSize = lockTo == Types.LockTo.GRID and
				Roact.createElement(
					NumericalSliderField,
					{
						label = "Grid Size",
						value = gridSize,
						minValue = Constants.GRID_SIZE_MIN,
						maxValue = Constants.GRID_SIZE_MAX,
						valueRound = 0.01,
						valueSnap = 0.25,
						onValueChanged = self.setGridSize,
						LayoutOrder = 4
					}
				)
		}
	)
end

function CursorSettings:didMount()
	local mainManager = getMainManager(self)
	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function CursorSettings:willUnmount()
	self.mainManagerDisconnect()
end

return CursorSettings
