local Plugin = script.Parent.Parent
local Libs = Plugin.Libs

local Utility = require(Plugin.Core.Util.Utility)
local Constants = require(Plugin.Core.Util.Constants)
local semver = require(Libs.semver)
local Maid = require(Libs.Maid)
local sd = require(Libs.sd)
local Cryo = require(Libs.Cryo)
local NormalizedRandom = require(Libs.NormalizedRandom)
local Types = require(Plugin.Core.Util.Types)

local HttpService = game:GetService("HttpService") -- Just used to generate GUIDs
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Selection = game:GetService("Selection")

local CURSOR_FIELD_NAMES = {"face", "cursorCf", "active", "hit", "p", "norm"}

-- local MIN_PART_SIZE
-- do
-- 	local _p = Instance.new("Part")
-- 	_p.Size = Vector3.new(0, 0, 0)
-- 	MIN_PART_SIZE = _p.Size.X
-- end

local BuiltInPresets = require(Plugin.Core.BuiltInPresets)

local createSignal = require(Plugin.Core.Util.createSignal)

local MainManager = {}

local function createGuid()
	return HttpService:GenerateGUID()
end

local function constructPointEntryFromCursorInfo(cursorInfo)
	local hit, p, norm = cursorInfo.hit, cursorInfo.cursorCf.p, cursorInfo.cursorCf.lookVector
	return {
		hit = hit,
		p = p,
		norm = norm
	}
end

-- local function constructOrientationCFrameForOrnamentParams(params, r, objectIdx)
-- 	local yRotationOffset = params.yRotationOffset
-- 	local yRotationPerObject = params.yRotationPerObject
-- 	local yRotationRandomMin = params.yRotationRandomMin
-- 	local yRotationRandomMax = params.yRotationRandomMax
-- 	local xRotationOffset = params.xRotationOffset
-- 	local xRotationPerObject = params.xRotationPerObject
-- 	local xRotationRandomMin = params.xRotationRandomMin
-- 	local xRotationRandomMax = params.xRotationRandomMax
-- 	local zRotationOffset = params.zRotationOffset
-- 	local zRotationPerObject = params.zRotationPerObject
-- 	local zRotationRandomMin = params.zRotationRandomMin
-- 	local zRotationRandomMax = params.zRotationRandomMax

-- 	local y = yRotationOffset + yRotationPerObject * objectIdx + r:NextNumber(yRotationRandomMin, yRotationRandomMax)

-- 	local x = xRotationOffset + xRotationPerObject * objectIdx + r:NextNumber(xRotationRandomMin, xRotationRandomMax)

-- 	local z = zRotationOffset + zRotationPerObject * objectIdx + r:NextNumber(zRotationRandomMin, zRotationRandomMax)

-- 	return CFrame.fromOrientation(math.rad(x), math.rad(y), math.rad(z))
-- end

function MainManager.new(plugin)
	local self = setmetatable({}, {__index = MainManager})
	self._signal = createSignal()
	self._cursorSignal = createSignal()
	self._pointBufferSignal = createSignal()
	self._selectionSignal = createSignal()
	self._presetChangedSignals = {}
	self.plugin = plugin
	self.maid = Maid.new()
	self.mode = "None"
	self.mouse = plugin:GetMouse()
	self.ready = false
	self.cursorInfo = {active = false}
	self.collapsibleSections = {}
	self.activePreset = "FiberRope"

	self.pointBuffer = {}

	self.hConn =
		RunService.RenderStepped:Connect(
		function(dt)
			self:_DoCursorLoop(dt)
		end
	)

	self.dConn =
		self.mouse.Button1Down:Connect(
		function()
			local cursorInfo = self.cursorInfo
			if not cursorInfo.active then
				return
			end

			local cursorCf = cursorInfo.cursorCf
			if cursorCf == nil then
				return
			end

			self._cursorSignal:fire()
			if self.mode == "Draw" then
				local curveType = self:GetCurveType()
				if curveType == Types.Curve.CATENARY then
					if #self.pointBuffer == 0 then
						table.insert(self.pointBuffer, constructPointEntryFromCursorInfo(cursorInfo))
					elseif self:CanPlaceDangleAtPoints(self.pointBuffer[1].p, cursorCf.p) then
						table.insert(self.pointBuffer, constructPointEntryFromCursorInfo(cursorInfo))
					end

					if #self.pointBuffer == 2 then
						local start, fin = self.pointBuffer[1].p, self.pointBuffer[2].p

						local length
						do
							local lengthMode = self:GetDangleLengthMode()
							if lengthMode == Types.CatenaryLengthMode.RELATIVE then
								local dist = (start - fin).magnitude
								length = dist * self:GetDangleLengthRelative()
							elseif lengthMode == Types.CatenaryLengthMode.FIXED then
								length = self:GetDangleLengthFixed()
							end
						end

						ChangeHistoryService:SetWaypoint("DrawRope")
						local model =
							self:DrawPreset(
							self:GetActivePreset(),
							{
								curveType = Types.Curve.CATENARY,
								points = {self.pointBuffer[1].p, self.pointBuffer[2].p},
								length = length
							}
						)
						model.Parent = workspace
						ChangeHistoryService:SetWaypoint("DrawRope")
						self:ClearPointBuffer()
					end
				elseif curveType == Types.Curve.LINE then
					if #self.pointBuffer == 0 then
						table.insert(self.pointBuffer, constructPointEntryFromCursorInfo(cursorInfo))
					elseif self:CanPlaceDangleAtPoints(self.pointBuffer[1].p, cursorCf.p) then
						table.insert(self.pointBuffer, constructPointEntryFromCursorInfo(cursorInfo))
					end

					if #self.pointBuffer == 2 then
						ChangeHistoryService:SetWaypoint("DrawRope")
						local model =
							self:DrawPreset(
							self:GetActivePreset(),
							{
								curveType = Types.Curve.LINE,
								points = {self.pointBuffer[1].p, self.pointBuffer[2].p}
							}
						)
						model.Parent = workspace
						ChangeHistoryService:SetWaypoint("DrawRope")
						self:ClearPointBuffer()
					end
				elseif curveType == Types.Curve.LOOP then
					if #self.pointBuffer == 0 then
						table.insert(self.pointBuffer, constructPointEntryFromCursorInfo(cursorInfo))
					elseif self:CanPlaceLoopAtPoints(self.pointBuffer[1].p, cursorCf.p) then
						table.insert(self.pointBuffer, constructPointEntryFromCursorInfo(cursorInfo))
					end

					if #self.pointBuffer == 2 then
						local a, b = self.pointBuffer[1], self.pointBuffer[2]
						ChangeHistoryService:SetWaypoint("DrawRope")
						local model =
							self:DrawPreset(
							self:GetActivePreset(),
							{
								curveType = Types.Curve.LOOP,
								hit = a.hit,
								p = a.p,
								p2 = b.p,
								offset = self:GetLoopOffset(),
								shape = self:GetLoopShape()
							}
						)
						model.Parent = workspace
						ChangeHistoryService:SetWaypoint("DrawRope")
						self:ClearPointBuffer()
					end
				elseif curveType == "Coil" then
					error("Not implemented")
				end
			end

			self._pointBufferSignal:fire()
		end
	)

	self.deactivationConn =
		plugin.Deactivation:Connect(
		function()
			self.mode = "None"
			self._signal:fire()
			self:ClearPointBuffer()
		end
	)

	self.selection = Selection:Get()
	self.selectionConn =
		Selection.SelectionChanged:Connect(
		function()
			self.selection = Selection:Get()
			self._selectionSignal:fire()
		end
	)

	self.maid:GiveTask(self.hConn)
	self.maid:GiveTask(self.deactivationConn)
	self.maid:GiveTask(self.dConn)
	self.maid:GiveTask(self.selectionConn)
	self.presets = BuiltInPresets
	self.cachedPresetRopeParams = {}
	-- self.cachedSerializedPresets = {}
	return self
end

function MainManager:_DoCursorLoop(dt)
	if self.mode == "Draw" then
		local cursorInfo = {active = true}
		local hit, p, norm
		local ignoreRope = self:GetIgnoreRope()
		do
			local ray = self.mouse.UnitRay
			local origin, direction = ray.Origin, ray.Direction
			direction = direction.unit * 500
			ray = Ray.new(origin, direction)
			local target = origin + direction
			local ignoreList = {}
			while true do
				hit, p, norm = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
				if not hit then
					break
				end

				local current = hit
				while current ~= nil do
					if ignoreRope then
						if CollectionService:HasTag(current, Constants.ROPE_MODEL_TAG) then
							local newOrigin, newDirection = p, target - p
							ray = Ray.new(newOrigin - newDirection.unit * 0.1, newDirection)
							table.insert(ignoreList, hit)
							break
						end
					end
					current = current.Parent
				end

				if current == nil then
					break
				end
			end
		end
		cursorInfo.hit = hit
		cursorInfo.p = p
		cursorInfo.norm = norm
		local lockTo = self:GetLockTo()
		local lockDistance = self:GetLockDistance()
		local cursorCf, face = nil, nil
		if hit then
			cursorCf = CFrame.new(p, p + norm)
			face = Utility.PointToLocalNormal(hit, p)
			if lockTo == Types.LockTo.NONE then
				-- nothing.
			elseif lockTo == Types.LockTo.PART_CENTERS then
				if not hit:IsA("Terrain") then
					cursorCf = hit.CFrame
				end
			elseif lockTo == Types.LockTo.GRID then
				local gridSize = self:GetGridSize()
				if not hit:IsA("Terrain") then
					local sizeHalf = hit.Size / 2
					local cf = hit.CFrame
					local oSpace = cf:PointToObjectSpace(p)
					local o_x, o_y, o_z = oSpace.X, oSpace.Y, oSpace.Z
					local lock_p
					local up, right
					if math.abs(face.X) == 1 then
						lock_p = cf:PointToWorldSpace(Vector3.new(face.X * sizeHalf.X, Utility.Round(o_y, gridSize), Utility.Round(o_z, gridSize)))
						up, right = cf.upVector, cf.lookVector
					elseif math.abs(face.Y) == 1 then
						lock_p = cf:PointToWorldSpace(Vector3.new(Utility.Round(o_x, gridSize), face.Y * sizeHalf.Y, Utility.Round(o_z, gridSize)))
						up, right = cf.lookVector, cf.rightVector
					else
						lock_p = cf:PointToWorldSpace(Vector3.new(Utility.Round(o_x, gridSize), Utility.Round(o_y, gridSize), face.Z * sizeHalf.Z))
						up, right = cf.upVector, cf.rightVector
					end
					cursorCf = CFrame.fromMatrix(lock_p, up, right)
				end
			elseif lockTo == Types.LockTo.MIDPOINTS then
				if not hit:IsA("Terrain") then
					local sizeHalf = hit.Size / 2
					local cf = hit.CFrame
					local oSpace = cf:PointToObjectSpace(p)
					local o_x, o_y, o_z = oSpace.X, oSpace.Y, oSpace.Z
					local lock_p
					local up, right
					if math.abs(face.X) == 1 then
						lock_p =
							cf:PointToWorldSpace(Vector3.new(face.X * sizeHalf.X, Utility.Round(o_y, sizeHalf.Y), Utility.Round(o_z, sizeHalf.Z)))
						up, right = cf.upVector, cf.lookVector
					elseif math.abs(face.Y) == 1 then
						lock_p =
							cf:PointToWorldSpace(Vector3.new(Utility.Round(o_x, sizeHalf.X), face.Y * sizeHalf.Y, Utility.Round(o_z, sizeHalf.Z)))
						up, right = cf.lookVector, cf.rightVector
					else
						lock_p =
							cf:PointToWorldSpace(Vector3.new(Utility.Round(o_x, sizeHalf.X), Utility.Round(o_y, sizeHalf.Y), face.Z * sizeHalf.Z))
						up, right = cf.upVector, cf.rightVector
					end
					local nearP = Utility.ProjectPointToPart(hit, p)
					if (nearP - lock_p).magnitude < lockDistance then
						cursorCf = CFrame.fromMatrix(lock_p, up, right)
					end
				end
			elseif lockTo == Types.LockTo.ATTACHMENTS then
				local distVec = Vector3.new(lockDistance, lockDistance, lockDistance)
				local min, max = p - distVec, p + distVec
				local region = Region3.new(min, max)

				local ignore = {}
				local attachmentsFound = {}
				while true do
					local parts = workspace:FindPartsInRegion3WithIgnoreList(region, ignore, 100)
					local willBreak = false
					if #parts < 100 then
						willBreak = true
					end

					for _, part in next, parts do
						for _, desc in next, part:GetDescendants() do
							if desc:IsA("Attachment") then
								table.insert(attachmentsFound, desc)
							end
						end
						if not willBreak then
							table.insert(ignore, part)
						end
					end

					if willBreak then
						break
					end
				end

				if #attachmentsFound > 0 then
					local closestAttachment = nil
					local closestDistance = math.huge
					for _, attachment in next, attachmentsFound do
						local a_p = attachment.WorldPosition
						local dist = (p - a_p).magnitude
						if dist < lockDistance then
							if closestAttachment == nil or dist < closestDistance then
								closestAttachment = attachment
								closestDistance = dist
							end
						end
					end

					if closestAttachment ~= nil then
						cursorCf = closestAttachment.WorldCFrame
					end
				end
			end
		end
		cursorInfo.cursorCf = cursorCf
		cursorInfo.face = face

		for _, key in next, CURSOR_FIELD_NAMES do
			if self.cursorInfo[key] ~= cursorInfo[key] then
				self.cursorInfo = cursorInfo
				self._cursorSignal:fire()
				break
			end
		end
	else
		if self.cursorInfo.active == true then
			self.cursorInfo = {active = false}
			self._cursorSignal:fire()
		end
	end
end

function MainManager:subscribe(...)
	return self._signal:subscribe(...)
end

function MainManager:subscribeToCursor(...)
	return self._cursorSignal:subscribe(...)
end

function MainManager:subscribeToPointBuffer(...)
	return self._pointBufferSignal:subscribe(...)
end

function MainManager:subscribeToSelection(...)
	return self._selectionSignal:subscribe(...)
end

function MainManager:CalculateDangleLengthAtCursor()
	local start = self.pointBuffer[1]
	if start == nil then
		return 0
	end
	local fin = self.cursorInfo.cursorCf
	if fin == nil then
		return 0
	end

	start, fin = start.p, fin.p
	local distance = (start - fin).magnitude
	local lengthMode = self:GetDangleLengthMode()
	local length
	if lengthMode == Types.CatenaryLengthMode.FIXED then
		length = self:GetDangleLengthFixed()
	else
		length = distance * self:GetDangleLengthRelative() + Constants.DANGLE_LENGTH_FUDGE
	end

	return length
end

function MainManager:CanPlaceDangleAtPoints(start, fin)
	local distance = (start - fin).magnitude
	local length = self:CalculateDangleLengthAtCursor()

	return length <= Constants.DANGLE_LENGTH_LIMIT and distance <= length and length > 0.1
end

function MainManager:CanPlaceLoopAtPoints(start, fin)
	return true
end

function MainManager:CanPlaceDangleAtCursor()
	local start = self.pointBuffer[1] and self.pointBuffer[1].p
	if start == nil then
		return false
	end
	local fin = self.cursorInfo.cursorCf and self.cursorInfo.cursorCf.p
	if fin == nil then
		return false
	end

	return self:CanPlaceDangleAtPoints(start, fin)
end

function MainManager:CanPlaceLoopAtCursor()
	local hit = self.cursorInfo.hit
	if hit == nil then
		return false
	end

	if #self.pointBuffer == 0 then
		return hit:IsA("Terrain") == false
	else
		return true
	end
end

function MainManager:IsInEditMode()
	if RunService:IsStudio() and RunService:IsEdit() then
		return true
	else
		return false
	end
end

function MainManager:destroy()
	self.maid:Destroy()
end

function MainManager:GetMode()
	return self.mode
end

function MainManager:Activate(mode)
	self.mode = mode
	self.plugin:Activate(true)
	self._signal:fire()
	self:ClearPointBuffer()
end

function MainManager:Deactivate()
	self.mode = "None"
	self.plugin:Deactivate()
	self._signal:fire()
	self:ClearPointBuffer()
end

function MainManager:IsActive()
	return self.mode ~= "None"
end

function MainManager:IsUpdateAvailable()
	local cachedUpdate = self.cachedUpdate
	if cachedUpdate == nil then
		local pid = Constants.PLUGIN_PRODUCT_ID
		local ok, _ =
			pcall(
			function()
				local pInfo = MarketplaceService:GetProductInfo(pid)
				local desc = pInfo.Description
				-- Description is empty. Maybe we got cd'ed?
				if not desc then
					warn(string.format("[%s] Can't retrieve plugin version. A new update may be available.", Constants.DEBUG_LABEL))
					cachedUpdate = false
					return
				else
					local semverMatch = desc:match("semver ([0-9]+%.[0-9]+%.[0-9]+)")
					if semverMatch then
						local websitePluginVersion = semver(semverMatch)
						local thisPluginVersion = semver(Constants.PLUGIN_VERSION)
						if thisPluginVersion < websitePluginVersion then
							cachedUpdate = true
							return
						else
							cachedUpdate = false
							return
						end
					else
						-- Typo, maybe? Accidentally cleared?
						warn(string.format("[%s] Can't retrieve plugin version. A new update may be available.", Constants.DEBUG_LABEL))
						cachedUpdate = false
						return
					end
				end
			end
		)

		if not ok then
			warn(string.format("[%s] Can't retrieve plugin version. A new update may be available.", Constants.DEBUG_LABEL))
			cachedUpdate = false
		end

		self.cachedUpdate = cachedUpdate
	end

	return cachedUpdate
end

function MainManager:DismissUpdateReminder()
	self.updateReminderDismissed = true
	self._signal:fire()
end

function MainManager:IsUpdateReminderDismissed()
	if self.updateReminderDismissed == nil then
		return false
	end

	return true
end

function MainManager:DismissInDevelopmentReminder()
	self.inDevelopmentReminderDismissed = true
	self._signal:fire()
end

function MainManager:IsInDevelopmentReminderDismissed()
	if self.inDevelopmentReminderDismissed == nil then
		return false
	end

	return true
end

function MainManager:ToggleCollapsibleSection(sectionId)
	local isCollapsed = self.collapsibleSections[sectionId]
	if isCollapsed == nil then
		self.collapsibleSections[sectionId] = true
		self._signal:fire()
	else
		self.collapsibleSections[sectionId] = not isCollapsed
		self._signal:fire()
	end
end

function MainManager:IsSectionCollapsed(sectionId)
	local isCollapsed = self.collapsibleSections[sectionId]
	if isCollapsed == nil then
		return false
	end

	return isCollapsed
end

function MainManager:SetActivePreset(presetId)
	if self.activePreset ~= presetId then
		self.activePreset = presetId
		self._signal:fire()
	end

	if presetId == nil and self:IsActive() then
		self:Deactivate()
	end
end

function MainManager:GetActivePreset()
	if self:_GetPresetEntry(self.activePreset) == nil then
		return nil
	end

	return self.activePreset
end

function MainManager:_GetPresetEntry(presetId)
	return self.presets[presetId]
end

function MainManager:_SetPresetEntry(presetId, presetEntry)
	self.presets[presetId] = presetEntry
	self.cachedPublicPresetIds = nil
end

function MainManager:GetPresetType(presetId)
	local entry = self:_GetPresetEntry(presetId)
	assert(entry ~= nil)
	return entry.type
end

local function getDefaultParamsForRopeType(ropeType)
	if ropeType == Types.Rope.ROPE then
		-- elseif ropeType == Types.Rope.MESH_CHAIN then
		-- 	return {
		-- 		meshChainType = Types.MeshChain.CHAIN_SMOOTH,
		-- 		chainShadingType = Types.ChainShading.SHINY,
		-- 		segmentScale = 1,
		-- 		baseColor = Color3.new(1, 1, 1),
		-- 		rotationLinkAxis = Types.Axis.Z,
		-- 		rotationLinkOffset = 0,
		-- 		rotationPerLink = 0,
		-- 		rotationLinkRandomMin = 0,
		-- 		rotationLinkRandomMax = 0
		-- 	}
		-- elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 	return {
		-- 		materialChainType = Types.MaterialChain.CHAIN_SMOOTH,
		-- 		chainMaterial = Types.Material.PLASTIC,
		-- 		segmentScale = 1,
		-- 		baseColor = Color3.new(1, 1, 1),
		-- 		rotationLinkAxis = Types.Axis.Z,
		-- 		rotationLinkOffset = 0,
		-- 		rotationPerLink = 0,
		-- 		rotationLinkRandomMin = 0,
		-- 		rotationLinkRandomMax = 0
		-- 	}
		-- elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 	return {
		-- 		customSegmentInstanceKey = Constants.CUSTOM_CHAIN_DEFAULT_KEY,
		-- 		segmentScale = 1,
		-- 		linkSpacing = 1,
		-- 		linkOffset = Vector3.new(0, 0, 0),
		-- 		rotationLinkAxis = Types.Axis.Z,
		-- 		rotationLinkOffset = 0,
		-- 		rotationPerLink = 0,
		-- 		rotationLinkRandomMin = 0,
		-- 		rotationLinkRandomMax = 0
		-- 	}
		return {
			style = Types.RopeStyle.ROUND_SMOOTH,
			material = Types.Material.SMOOTHPLASTIC,
			height = 0.06,
			width = 0.06,
			partCount = Types.RopePartCount.MEDIUM,
			baseColor = Color3.new(0.5, 0.5, 0.5),
			textured = false,
			textureMode = Types.TextureMode.REPEAT,
			textureId = "",
			textureLength = 1,
			textureRotation = 0,
			textureOffset = 0
		}
	else
		error("Unknown rope type: " .. ropeType)
	end
end

-- local function getDefaultParamsForOrnamentType(ornamentType)
-- 	if ornamentType == "ChristmasLight" then
-- 		return {
-- 			yRotationOffset = 0,
-- 			yRotationPerObject = 0,
-- 			yRotationRandomMin = 0,
-- 			yRotationRandomMax = 0,
-- 			xRotationOffset = 0,
-- 			xRotationPerObject = 0,
-- 			xRotationRandomMin = 0,
-- 			xRotationRandomMax = 0,
-- 			zRotationOffset = 0,
-- 			zRotationPerObject = 0,
-- 			zRotationRandomMin = 0,
-- 			zRotationRandomMax = 0,
-- 			gravityInfluence = 0,
-- 			startOffset = 1,
-- 			endOffset = 1,
-- 			bias = 0.5,
-- 			scale = 1,
-- 			lightColor = Color3.fromRGB(211, 145, 100),
-- 			socketColor = Color3.fromRGB(39, 70, 45),
-- 			offset = 0,
-- 			spacing = 1,
-- 			spacingOffset = 0
-- 		}
-- 	elseif ornamentType == "CarnivalFlagSingle" then
-- 		return {
-- 			yRotationOffset = 0,
-- 			yRotationPerObject = 0,
-- 			yRotationRandomMin = 0,
-- 			yRotationRandomMax = 0,
-- 			xRotationOffset = 0,
-- 			xRotationPerObject = 0,
-- 			xRotationRandomMin = 0,
-- 			xRotationRandomMax = 0,
-- 			zRotationOffset = 0,
-- 			zRotationPerObject = 0,
-- 			zRotationRandomMin = 0,
-- 			zRotationRandomMax = 0,
-- 			gravityInfluence = 0,
-- 			startOffset = 1,
-- 			endOffset = 1,
-- 			bias = 0.5,
-- 			shape = "Triangle",
-- 			shading = "Rough",
-- 			width = 1,
-- 			height = 1.25,
-- 			thickness = .1,
-- 			spacing = 1,
-- 			spacingOffset = 0,
-- 			baseColor = Color3.fromRGB(255, 196, 5),
-- 			textured = false,
-- 			texture = "",
-- 			textureColor = Color3.new(1, 1, 1),
-- 			verticalOffset = -0.1,
-- 			carnivalFlagStyle = Types.CarnivalFlagStyle.DETAILED
-- 		}
-- 	elseif ornamentType == "DanglingGardenLight" then
-- 		return {
-- 			yRotationOffset = 0,
-- 			yRotationPerObject = 0,
-- 			yRotationRandomMin = 0,
-- 			yRotationRandomMax = 0,
-- 			xRotationOffset = 0,
-- 			xRotationPerObject = 0,
-- 			xRotationRandomMin = 0,
-- 			xRotationRandomMax = 0,
-- 			zRotationOffset = 0,
-- 			zRotationPerObject = 0,
-- 			zRotationRandomMin = 0,
-- 			zRotationRandomMax = 0,
-- 			gravityInfluence = 1,
-- 			startOffset = 1,
-- 			endOffset = 1,
-- 			bias = 0.5,
-- 			bulbType = "Round",
-- 			scale = 1,
-- 			lightColor = Color3.fromRGB(211, 145, 100),
-- 			socketColor = Color3.fromRGB(27, 42, 53),
-- 			spacing = 2,
-- 			spacingOffset = 0,
-- 			dangleLength = 0.4
-- 		}
-- 	elseif ornamentType == "AttachedGardenLight" then
-- 		return {
-- 			yRotationOffset = 0,
-- 			yRotationPerObject = 0,
-- 			yRotationRandomMin = 0,
-- 			yRotationRandomMax = 0,
-- 			xRotationOffset = 0,
-- 			xRotationPerObject = 0,
-- 			xRotationRandomMin = 0,
-- 			xRotationRandomMax = 0,
-- 			zRotationOffset = 0,
-- 			zRotationPerObject = 0,
-- 			zRotationRandomMin = 0,
-- 			zRotationRandomMax = 0,
-- 			gravityInfluence = 0,
-- 			startOffset = 1,
-- 			endOffset = 1,
-- 			bias = 0.5,
-- 			bulbType = "Round",
-- 			scale = 1,
-- 			lightColor = Color3.fromRGB(211, 145, 100),
-- 			socketColor = Color3.fromRGB(27, 42, 53),
-- 			spacing = 2,
-- 			spacingOffset = 0
-- 		}
-- 	end
-- end

function MainManager:SetPresetRopeType(presetId, ropeType)
	local preset = self:_GetPresetEntry(presetId)
	local rope = preset.rope
	if rope.type ~= ropeType then
		rope.type = ropeType
		local newDefaultParams = getDefaultParamsForRopeType(ropeType)
		for paramId, defaultV in next, newDefaultParams do
			if rope.params[paramId] == nil then
				rope.params[paramId] = defaultV
			end
		end
		self.cachedPresetRopeParams[presetId] = nil
		self:_getPresetChangedSignal(presetId):fire()
		self._signal:fire()
	end
end

function MainManager:SetPresetRopeParams(presetId, paramChangeList)
	local preset = self:_GetPresetEntry(presetId)
	local rope = preset.rope
	local ropeParams = rope.params
	local changed = false
	for paramId, val in next, paramChangeList do
		if ropeParams[paramId] ~= val then
			ropeParams[paramId] = val
			changed = true
		end
	end

	if changed then
		self.cachedPresetRopeParams[presetId] = nil
		self._signal:fire()
		self:_getPresetChangedSignal(presetId):fire()
	end
end

-- function MainManager:SetPresetOrnamentType(presetId, ornamentId, ornamentType)
-- 	local preset = self:_GetPresetEntry(presetId)
-- 	local ornament = preset.ornaments[ornamentId]
-- 	if ornament.type ~= ornamentType then
-- 		ornament.type = ornamentType
--		self:_getPresetChangedSignal(presetId):fire()
-- 		self._signal:fire()
-- 	end
-- end

-- function MainManager:SetPresetOrnamentParams(presetId, ornamentId, paramChangeList)
-- 	local preset = self:_GetPresetEntry(presetId)
-- 	local ornament = preset.ornaments[ornamentId]
-- 	local ornamentParams = ornament.params
-- 	local changed = false
-- 	for paramId, val in next, paramChangeList do
-- 		if ornamentParams[paramId] ~= val then
-- 			ornamentParams[paramId] = val
-- 			changed = true
-- 		end
-- 	end

-- 	if changed then
--		self:_getPresetChangedSignal(presetId):fire()
-- 		self._signal:fire()
-- 	end
-- end

function MainManager:SetPresetName(presetId, name)
	local preset = self:_GetPresetEntry(presetId)
	if preset.name ~= name then
		preset.name = name
		self._signal:fire()
		self:_getPresetChangedSignal(presetId):fire()
	end
end

function MainManager:GenerateNameForDuplicate(targetName)
	local strippedName = string.match(targetName, "(.*)%(%d+%)") or targetName
	local existingNameSet = {}
	for _, presetId in next, self:GetPublicPresetIds() do
		local name = self:GetPresetName(presetId)
		existingNameSet[name] = true
	end

	if existingNameSet[targetName] == nil then
		return targetName
	end

	local i = 2
	local newName
	while true do
		newName = string.format("%s(%d)", strippedName, i)
		if not existingNameSet[newName] then
			break
		end
		i = i + 1
	end

	return string.sub(newName, 1, Constants.PRESET_NAME_MAX_LENGTH)
end

function MainManager:DuplicatePreset(presetId)
	local target = self:_GetPresetEntry(presetId)
	local copy = {}
	copy.name = self:GenerateNameForDuplicate(target.name)
	copy.type = Types.Preset.CUSTOM
	copy.rope = {
		type = target.rope.type,
		params = Utility.ShallowCopy(target.rope.params)
	}
	copy.ornaments = {}
	for ornamentId, _ in next, target.ornaments do
		copy.ornaments[ornamentId] = {}
		copy.ornaments[ornamentId].type = target.ornaments[ornamentId].type
		copy.ornaments[ornamentId].params = Utility.ShallowCopy(target.ornaments[ornamentId].params)
	end

	local copyId = createGuid()
	self:_SetPresetEntry(copyId, copy)
	self._signal:fire()
	return copyId
end

function MainManager:AddNewPreset()
	local newId = self:DuplicatePreset("NewRopeTemplate")
	return newId
end

function MainManager:GetPresetRopeType(presetId)
	return self:_GetPresetEntry(presetId).rope.type
end

function MainManager:GetPresetRopeParams(presetId)
	local params = self.cachedPresetRopeParams[presetId]
	if params == nil then
		local ropeType = self:_GetPresetEntry(presetId).rope.type
		params = getDefaultParamsForRopeType(ropeType)
		for k, v in next, self:_GetPresetEntry(presetId).rope.params do
			if params[k] ~= nil then
				params[k] = v
			end
		end

		self.cachedPresetRopeParams[presetId] = params
	end

	return params
end

-- function MainManager:GetPresetOrnamentIds(presetId)
-- 	local ornaments = self:_GetPresetEntry(presetId).ornaments
-- 	local ornamentIds = {}
-- 	for ornamentId, _ in next, ornaments do
-- 		table.insert(ornamentIds, ornamentId)
-- 	end

-- 	return ornamentIds
-- end

-- function MainManager:GetPresetOrnamentType(presetId, ornamentId)
-- 	return self:_GetPresetEntry(presetId).ornaments[ornamentId].type
-- end

-- function MainManager:GetPresetOrnamentParams(presetId, ornamentId)
-- 	local ornamentType = self:_GetPresetEntry(presetId).ornaments[ornamentId].type
-- 	local params = getDefaultParamsForOrnamentType(ornamentType)
-- 	for k, v in next, self:_GetPresetEntry(presetId).ornaments[ornamentId].params do
-- 		if params[k] ~= nil then
-- 			params[k] = v
-- 		end
-- 	end

-- 	return params
-- end

function MainManager:GetPresetName(presetId)
	return self:_GetPresetEntry(presetId).name
end

function MainManager:GetPublicPresetIds()
	if self.cachedPublicPresetIds == nil then
		local presetIds = {}
		for presetId, _ in next, self.presets do
			if self:GetPresetType(presetId) ~= Types.Preset.INTERNAL then
				table.insert(presetIds, presetId)
			end
		end

		self.cachedPublicPresetIds = presetIds
	end

	return self.cachedPublicPresetIds
end

-- function MainManager:SerializePreset(presetId)
-- 	local serialized = self.cachedSerializedPresets[presetId]
-- 	if serialized == nil then
-- 		debug.profilebegin("Do SerializePreset")
-- 		local presetEntry = self:_GetPresetEntry(presetId)
-- 		serialized = sd.serialize(presetEntry)
-- 		self.cachedSerializedPresets[presetId] = serialized
-- 		debug.profileend()
-- 	end

-- 	return self.cachedSerializedPresets[presetId]
-- end

local function spacePointsOnPathEvenly(path, params)
	local width = params.width or 0
	local spacing = params.spacing
	local spacingOffset = params.spacingOffset or 0
	local spacingAtEnds = params.spacingAtEnds or 0

	local length = path.length
	local widthPer = width / length
	local spacingPer = spacing / length
	-- local remaining = 1
	-- do -- ... why did I do this thing again? This was probably important at one point.
	-- 	local ct = 0
	-- 	while true do
	-- 		if ct == 0 then
	-- 			remaining = remaining - widthPer
	-- 		else
	-- 			remaining = remaining - spacingPer
	-- 		end

	-- 		if remaining > 0 then
	-- 			ct = ct + 1
	-- 		else
	-- 			break
	-- 		end
	-- 	end
	-- end

	local spacingAtEndsPer = spacingAtEnds / length
	local initSpacingFromOffset = spacing * (spacingOffset % 1)
	local initSpacingPer = initSpacingFromOffset / length
	local pts = {}
	local current = 0
	while true do
		local left_per = initSpacingPer + current * spacingPer + spacingAtEndsPer
		local right_per = left_per + widthPer + spacingAtEndsPer
		if right_per <= 1 - spacingAtEndsPer then
			table.insert(pts, {left_per, right_per})
		else
			break
		end
		current = current + 1
	end

	return pts
end

local pathlib = require(Plugin.Core.Util.path)
-- local simple_rope = require(Plugin.Core.Util.simple_rope)
-- local simple_loop = require(Plugin.Core.Util.simple_loop)
-- local chain = require(Plugin.Core.Util.chain)
-- local UP = Vector3.new(0, 1, 0)

local ROPE_QUEUE_SHAFT = 1
local ROPE_QUEUE_ELBOW = 2

local function create_rope_shaft(
	style,
	cf,
	size,
	materialEnum,
	baseColor,
	textured,
	textureId,
	textureLength,
	textureOffset,
	textureRotation)
	local shaft = Constants.ROPE_SHAFTS[style]:Clone()
	shaft.Material = materialEnum
	shaft.Color = baseColor
	shaft.Size = size
	shaft.CFrame = cf
	local width = size.X
	local height = size.Z
	if textured and textureId ~= "" then
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Back
			tex.Name = "Back"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * width
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = 0 + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = shaft
		end
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Left
			tex.Name = "Left"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * height
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = -wrap + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = shaft
		end
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Front
			tex.Name = "Front"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * width
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = -wrap * 2 + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = shaft
		end
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Right
			tex.Name = "Right"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * height
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = -wrap * 3 + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = shaft
		end
	end

	return shaft
end

local function create_rope_elbow(
	style,
	cf,
	size,
	materialEnum,
	baseColor,
	textured,
	textureId,
	textureLength,
	textureOffset,
	textureRotation)
	local elbow = Constants.ROPE_ELBOWS[style]:Clone()
	elbow.Material = materialEnum
	elbow.Color = baseColor
	elbow.Size = size
	elbow.CFrame = cf
	local width = size.X
	local height = size.Z
	if textured and textureId ~= "" then
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Back
			tex.Name = "Back"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * width
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = 0 + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = elbow
		end
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Left
			tex.Name = "Left"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * height
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = -wrap + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = elbow
		end
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Front
			tex.Name = "Front"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * width
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = -wrap * 2 + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = elbow
		end
		do
			local tex = Instance.new("Texture")
			tex.Face = Enum.NormalId.Right
			tex.Name = "Right"
			tex.Texture = textureId
			local wrap = Constants.ROPE_TEXTURE_STUDS_PER_TILE[style] * height
			tex.StudsPerTileU = wrap * 4
			tex.StudsPerTileV = textureLength
			tex.OffsetStudsU = -wrap * 3 + textureRotation * wrap * 4 + wrap * 1.5
			tex.OffsetStudsV = textureOffset
			tex.Color3 = baseColor
			tex.Parent = elbow
		end
	end

	return elbow
end

function MainManager:DrawRope(ropeParams, path)
	local ropeModel = Instance.new("Model")
	ropeModel.Name = Types.GetRopeNameFromRopeType(Types.Rope.ROPE)

	local style = ropeParams.style
	local height = ropeParams.height
	local width = ropeParams.width
	local partCount = ropeParams.partCount
	local baseColor = ropeParams.baseColor
	local textured = ropeParams.textured
	local textureId = ropeParams.textureId
	local textureLength = ropeParams.textureLength
	local textureRotation = ropeParams.textureRotation
	local textureOffset = ropeParams.textureOffset
	local material = ropeParams.material
	local materialEnum = Types.GetMaterialEnumFromMaterialType(material)

	local vertices = path.vertices
	local rights = path.rights
	local next_shaft_backwards_extension = 0
	local renderQueue = {}
	local min_elbow_length do
		if partCount == Types.RopePartCount.LOW then
			min_elbow_length = math.max(0.05, height)
		elseif partCount == Types.RopePartCount.MEDIUM then
			min_elbow_length = math.max(0.05, height/2)
		else
			min_elbow_length = math.max(0.05, height/4)
		end
	end
	local min_elbow_height = 0.05
	for i = 1, #vertices - 1 do
		local p_0 = vertices[i]
		local p_1 = vertices[i + 1]
		local p = (p_0 + p_1) / 2
		local dist = (p_0 - p_1).magnitude
		local look = (p_1 - p_0).unit
		local right = rights[i]
		local up = right:Cross(look).unit
		local shaft_length = dist + next_shaft_backwards_extension
		local shaft_p = p - up * height / 2 - look * next_shaft_backwards_extension / 2
		local shaft_size = Vector3.new(width, shaft_length, height)
		local shaft_cframe = CFrame.fromMatrix(shaft_p, right, look)

		local should_draw_elbow = false
		local elbow_size, elbow_cframe, elbow_length
		if i ~= #vertices - 1 then
			local p_2 = vertices[i + 2]
			local nextLook = (p_2 - p_1).unit
			local elbowUp = (-look):lerp(nextLook, 0.5).unit
			local angle_half = Utility.GetAngleBetweenVectors(up, elbowUp)
			local hyp = height
			elbow_length = hyp * math.sin(angle_half) * 2
			local elbow_height = hyp * math.cos(angle_half)
			if elbow_length > min_elbow_length and elbow_height > min_elbow_height then
				should_draw_elbow = true
				local elbow_p = p_1 - elbowUp * elbow_height / 2
				local look = elbowUp:Cross(right)
				elbow_size = Vector3.new(width, elbow_length, elbow_height)
				elbow_cframe = CFrame.fromMatrix(elbow_p, right, look)
				next_shaft_backwards_extension = 0
			else
				local elbow_bend = Utility.GetAngleBetweenVectors(look, nextLook)
				local extension = math.tan(elbow_bend / 2) * height
				shaft_length = shaft_length + extension
				shaft_size = shaft_size + Vector3.new(0, extension, 0)
				shaft_cframe = shaft_cframe * CFrame.new(0, extension / 2, 0)
				next_shaft_backwards_extension = extension
			end
		end

		table.insert(
			renderQueue,
			{
				ROPE_QUEUE_SHAFT,
				shaft_cframe,
				shaft_size,
				shaft_length
			}
		)

		if should_draw_elbow then
			table.insert(
				renderQueue,
				{
					ROPE_QUEUE_ELBOW,
					elbow_cframe,
					elbow_size,
					elbow_length
				}
			)
		end
	end

	local shouldDrawCaps = true
	if vertices[1] == vertices[#vertices] then
		local p_0 = vertices[#vertices - 1]
		local p_1 = vertices[1]
		local p_2 = vertices[2]
		local look = (p_1 - p_0).unit
		local nextLook = (p_2 - p_1).unit
		local right = look:Cross(nextLook).unit
		local up = right:Cross(look).unit
		local elbowUp = (-look):lerp(nextLook, 0.5).unit
		local angle_half = Utility.GetAngleBetweenVectors(up, elbowUp)
		local hyp = height
		local elbow_length = hyp * math.sin(angle_half) * 2
		local elbow_height = hyp * math.cos(angle_half)
		if elbow_length > min_elbow_length and elbow_height > min_elbow_height then
			local look = elbowUp:Cross(right)
			local right = (look:Cross(elbowUp)).unit
			local elbow_p = p_1 - elbowUp * elbow_height / 2
			local elbow_size = Vector3.new(width, elbow_length, elbow_height)
			local elbow_cframe = CFrame.fromMatrix(elbow_p, right, look)
			table.insert(
				renderQueue,
				{
					ROPE_QUEUE_ELBOW,
					elbow_cframe,
					elbow_size,
					elbow_length
				}
			)
		else
			local elbow_bend = Utility.GetAngleBetweenVectors(look, nextLook)
			local extension = math.tan(elbow_bend / 2) * height
			local first_shaft, last_shaft = renderQueue[1], renderQueue[#renderQueue]
			do
				first_shaft[4] = first_shaft[4] + extension
				first_shaft[3] = first_shaft[3] + Vector3.new(0, extension, 0)
				first_shaft[2] = first_shaft[2] * CFrame.new(0, -extension / 2, 0)
			end
			do
				last_shaft[4] = last_shaft[4] + extension
				last_shaft[3] = last_shaft[3] + Vector3.new(0, extension, 0)
				last_shaft[2] = last_shaft[2] * CFrame.new(0, extension / 2, 0)
			end
		end
	elseif shouldDrawCaps then
		local capBase = Constants.ROPE_CAPS[style]
		do
			local leftCap = capBase:Clone()
			leftCap.Color = baseColor
			leftCap.Material = materialEnum
			if textured and textureId ~= "" then
				local decal = Instance.new("Decal")
				decal.Face = Enum.NormalId.Top
				decal.Texture = textureId
				decal.Color3 = baseColor
				decal.Parent = leftCap
			end
			leftCap.Parent = ropeModel
			local first_shaft = renderQueue[1]
			leftCap.Size = Vector3.new(width, 0.05, height)
			leftCap.CFrame = first_shaft[2] * CFrame.Angles(0, 0, math.pi) * CFrame.new(0, first_shaft[4] / 2 - 0.025, 0)
		end
		do
			local rightCap = capBase:Clone()
			rightCap.Color = baseColor
			rightCap.Material = materialEnum
			if textured and textureId ~= "" then
				local decal = Instance.new("Decal")
				decal.Face = Enum.NormalId.Top
				decal.Texture = textureId
				decal.Color3 = baseColor
				decal.Parent = rightCap
			end
			local last_shaft = renderQueue[#renderQueue]
			rightCap.Size = Vector3.new(width, 0.05, height)
			rightCap.CFrame = last_shaft[2] * CFrame.new(0, last_shaft[4] / 2 - 0.025, 0)
			rightCap.Parent = ropeModel
		end
	end

	local totalLength = 0
	for _, entry in ipairs(renderQueue) do
		local length = entry[4]
		totalLength = totalLength + length
	end

	local finalTextureLength = totalLength / math.ceil(totalLength / textureLength)
	local lengthProgress = 0
	for _, entry in ipairs(renderQueue) do
		if entry[1] == ROPE_QUEUE_SHAFT then
			local cf, size, length = unpack(entry, 2)
			local finalTextureOffset =
				finalTextureLength - length / 2 + finalTextureLength - (lengthProgress % finalTextureLength) + textureOffset * textureLength
			local shaft =
				create_rope_shaft(
				style,
				cf,
				size,
				materialEnum,
				baseColor,
				textured,
				textureId,
				finalTextureLength,
				finalTextureOffset,
				textureRotation
			)
			shaft.Parent = ropeModel
			lengthProgress = lengthProgress + length
		elseif entry[1] == ROPE_QUEUE_ELBOW then
			local cf, size, length = unpack(entry, 2)
			local finalTextureOffset =
				finalTextureLength - length / 2 + finalTextureLength - (lengthProgress % finalTextureLength) + textureOffset * textureLength
			local elbow =
				create_rope_elbow(
				style,
				cf,
				size,
				materialEnum,
				baseColor,
				textured,
				textureId,
				finalTextureLength,
				finalTextureOffset,
				textureRotation
			)
			elbow.Parent = ropeModel
			lengthProgress = lengthProgress + length
		end
	end

	return ropeModel
end

-- function MainManager:DrawMeshChain(ropeParams, path, r)
-- 	local ropeModel = Instance.new("Model")
-- 	ropeModel.Name = Types.GetRopeNameFromRopeType(Types.Rope.MESH_CHAIN)

-- 	local meshChainType = ropeParams.meshChainType
-- 	local segmentScale = ropeParams.segmentScale
-- 	local baseColor = ropeParams.baseColor
-- 	local rotationLinkAxis = ropeParams.rotationLinkAxis
-- 	local rotationLinkOffset = ropeParams.rotationLinkOffset
-- 	local rotationPerLink = ropeParams.rotationPerLink
-- 	local rotationLinkRandomMin = ropeParams.rotationLinkRandomMin
-- 	local rotationLinkRandomMax = ropeParams.rotationLinkRandomMax
-- 	local chainShadingType = ropeParams.chainShadingType

-- 	local material = Types.GetMaterialEnumFromChainShadingType(chainShadingType)
-- 	local linkBase = Constants.MESH_CHAIN_LINK[meshChainType]:Clone()
-- 	linkBase.Size = linkBase.Size * segmentScale
-- 	linkBase.Color = baseColor
-- 	linkBase.Material = material
-- 	local linkMesh = linkBase.Mesh
-- 	linkMesh.Scale = linkMesh.Scale * segmentScale
-- 	linkMesh.Offset = linkMesh.Offset * segmentScale
-- 	linkMesh.VertexColor = Vector3.new(baseColor.r, baseColor.g, baseColor.b)

-- 	chain(
-- 		path,
-- 		function(i, p, right, up)
-- 			local link = linkBase:Clone()
-- 			local cf = CFrame.fromMatrix(p, right, up)
-- 			local rotOffset
-- 			if rotationLinkAxis == Types.Axis.X then
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax)),
-- 					0,
-- 					0
-- 				)
-- 			elseif rotationLinkAxis == Types.Axis.Y then
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					0,
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax)),
-- 					0
-- 				)
-- 			else
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					0,
-- 					0,
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax))
-- 				)
-- 			end
-- 			cf = cf * rotOffset
-- 			link.CFrame = cf
-- 			link.Parent = ropeModel
-- 		end
-- 	)

-- 	return ropeModel
-- end

-- function MainManager:GetCustomChainSegmentFromKey(key)
-- 	if key == Constants.CUSTOM_CHAIN_DEFAULT_KEY then
-- 		return Constants.CUSTOM_CHAIN_SEGMENT_DEFAULT
-- 	else
-- 		error("Not implemented.")
-- 	end
-- end

-- function MainManager:DrawCustomChain(ropeParams, path, r)
-- 	local ropeModel = Instance.new("Model")
-- 	ropeModel.Name = Types.GetRopeNameFromRopeType(Types.Rope.CUSTOM_CHAIN)

-- 	local segmentScale = ropeParams.segmentScale
-- 	local customSegmentInstanceKey = ropeParams.customSegmentInstanceKey
-- 	local rotationLinkAxis = ropeParams.rotationLinkAxis
-- 	local rotationLinkOffset = ropeParams.rotationLinkOffset
-- 	local rotationPerLink = ropeParams.rotationPerLink
-- 	local rotationLinkRandomMin = ropeParams.rotationLinkRandomMin
-- 	local rotationLinkRandomMax = ropeParams.rotationLinkRandomMax
-- 	local linkOffset = ropeParams.linkOffset * segmentScale

-- 	local segmentBase = self:GetCustomChainSegmentFromKey(customSegmentInstanceKey):Clone()
-- 	Utility.ScaleObject(segmentBase, segmentScale)
-- 	local setCf
-- 	if segmentBase:IsA("BasePart") then
-- 		setCf = function(i, cf)
-- 			i.CFrame = cf
-- 		end
-- 	else
-- 		if segmentBase.PrimaryPart == nil then
-- 			local min, max = Utility.GetModelAABBFast(segmentBase)
-- 			local handleBase = Instance.new("Part")
-- 			local centerCf = CFrame.new((min + max) / 2)
-- 			setCf = function(i, cf)
-- 				local handle = handleBase:Clone()
-- 				handle.CFrame = centerCf
-- 				local originalPrimaryPart = i.PrimaryPart
-- 				segmentBase.PrimaryPart = handle
-- 				segmentBase:SetPrimaryPartCFrame(cf)
-- 				segmentBase.PrimaryPart = originalPrimaryPart
-- 			end
-- 		else
-- 			setCf = function(i, cf)
-- 				i:SetPrimaryPartCFrame(cf)
-- 			end
-- 		end
-- 	end

-- 	chain(
-- 		path,
-- 		function(i, p, right, up)
-- 			local link = segmentBase:Clone()
-- 			local cf = CFrame.fromMatrix(p, right, up) * CFrame.new(linkOffset)
-- 			local rotOffset
-- 			if rotationLinkAxis == Types.Axis.X then
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax)),
-- 					0,
-- 					0
-- 				)
-- 			elseif rotationLinkAxis == Types.Axis.Y then
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					0,
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax)),
-- 					0
-- 				)
-- 			else
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					0,
-- 					0,
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax))
-- 				)
-- 			end
-- 			cf = cf * rotOffset
-- 			setCf(link, cf)
-- 			link.Parent = ropeModel
-- 		end
-- 	)

-- 	return ropeModel
-- end

-- function MainManager:DrawMaterialChain(ropeParams, path, r)
-- 	local ropeModel = Instance.new("Model")
-- 	ropeModel.Name = Types.GetRopeNameFromRopeType(Types.Rope.MATERIAL_CHAIN)

-- 	local materialChainType = ropeParams.materialChainType
-- 	local segmentScale = ropeParams.segmentScale
-- 	local baseColor = ropeParams.baseColor
-- 	local chainMaterial = ropeParams.chainMaterial
-- 	local rotationLinkAxis = ropeParams.rotationLinkAxis
-- 	local rotationLinkOffset = ropeParams.rotationLinkOffset
-- 	local rotationPerLink = ropeParams.rotationPerLink
-- 	local rotationLinkRandomMin = ropeParams.rotationLinkRandomMin
-- 	local rotationLinkRandomMax = ropeParams.rotationLinkRandomMax
-- 	local linkOffset = Constants.MATERIAL_CHAIN_OFFSET[materialChainType] * segmentScale

-- 	local linkBase = Constants.MATERIAL_CHAIN_LINK[materialChainType]:Clone()
-- 	linkBase.Material = Types.GetMaterialEnumFromMaterialType(chainMaterial)
-- 	linkBase.Size = linkBase.Size * segmentScale
-- 	linkBase.Color = baseColor

-- 	chain(
-- 		path,
-- 		function(i, p, right, up)
-- 			local link = linkBase:Clone()
-- 			local cf = CFrame.fromMatrix(p, right, up) * CFrame.new(linkOffset)
-- 			local rotOffset
-- 			if rotationLinkAxis == Types.Axis.X then
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax)),
-- 					0,
-- 					0
-- 				)
-- 			elseif rotationLinkAxis == Types.Axis.Y then
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					0,
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax)),
-- 					0
-- 				)
-- 			else
-- 				rotOffset =
-- 					CFrame.Angles(
-- 					0,
-- 					0,
-- 					math.rad(rotationLinkOffset + rotationPerLink * i + r:NextNumber(rotationLinkRandomMin, rotationLinkRandomMax))
-- 				)
-- 			end
-- 			cf = cf * rotOffset
-- 			link.CFrame = cf
-- 			link.Parent = ropeModel
-- 		end
-- 	)

-- 	return ropeModel
-- end

-- function MainManager:DrawCarnivalFlagSingle(ornamentParams, path, pts, r)
-- 	local ornamentModel = Instance.new("Model")
-- 	ornamentModel.Name = "CarnivalFlagSingle"
-- 	local shape = ornamentParams.shape
-- 	local width = ornamentParams.width
-- 	local height = ornamentParams.height
-- 	local thickness = ornamentParams.thickness
-- 	local baseColor = ornamentParams.baseColor
-- 	local textured = ornamentParams.textured
-- 	local texture = ornamentParams.texture
-- 	local textureColor = ornamentParams.textureColor
-- 	local verticalOffset = ornamentParams.verticalOffset
-- 	local canivalFlagStyle = ornamentParams.carnivalFlagStyle

-- 	local styleString = Types.GetStringFromCarnivalFlagStyleType(canivalFlagStyle)
-- 	local carnivalFlagBase = Constants.CARNIVAL_FLAG_SINGLE[styleString][shape]:Clone()
-- 	carnivalFlagBase.Color = baseColor
-- 	local vertexColor = Vector3.new(baseColor.r, baseColor.g, baseColor.b)
-- 	local carnivalFlagMesh = carnivalFlagBase.Mesh
-- 	carnivalFlagBase.Size = Vector3.new(thickness, height, width)
-- 	carnivalFlagMesh.Scale = Vector3.new(thickness, height, width)
-- 	carnivalFlagMesh.VertexColor = vertexColor
-- 	if textured then
-- 		local baseDecal = Instance.new("Decal")
-- 		baseDecal.Texture = texture
-- 		baseDecal.Color3 = textureColor
-- 		baseDecal.Parent = carnivalFlagBase
-- 	end

-- 	for _, pt in next, pts do
-- 		local left_per, right_per = pt[1], pt[2]
-- 		local left_v = pathlib.trace_path(path, left_per)
-- 		local right_v = pathlib.trace_path(path, right_per)
-- 		local left_p = left_v.p + left_v.upVector * verticalOffset
-- 		local right_p = right_v.p + right_v.upVector * verticalOffset
-- 		local flag = carnivalFlagBase:Clone()
-- 		local look = (right_p - left_p).unit
-- 		local right = look:Cross(UP).unit
-- 		local up = right:Cross(look).unit
-- 		local p = right_p:lerp(left_p, 0.5)
-- 		flag.CFrame = CFrame.fromMatrix(p - up * (height / 2), right, up)
-- 		flag.Parent = ornamentModel
-- 	end
-- 	return ornamentModel
-- end

-- function MainManager:DrawDanglingGardenLight(ornamentParams, path, pts, r)
-- 	local ornamentModel = Instance.new("Model")
-- 	ornamentModel.Name = "DanglingGardenLight"
-- 	local bulbType = ornamentParams.bulbType
-- 	local scale = ornamentParams.scale
-- 	local lightColor = ornamentParams.lightColor
-- 	local socketColor = ornamentParams.socketColor
-- 	local dangleLength = ornamentParams.dangleLength

-- 	local bulbBase = Constants.DANGLING_LIGHTS_SINGLE[bulbType]:Clone()
-- 	bulbBase.Bulb.Color = lightColor
-- 	bulbBase.Bulb.PointLight.Color = lightColor
-- 	bulbBase.Socket.Color = socketColor
-- 	local socketVtx = Vector3.new(socketColor.r, socketColor.g, socketColor.b)
-- 	bulbBase.Socket.Mesh.VertexColor = socketVtx
-- 	Utility.ScaleObject(bulbBase, scale)

-- 	local shaftBase = Constants.ROPE_MESH_SHAFTS["Round"]["Smooth"]:Clone()
-- 	shaftBase.Color = socketColor
-- 	shaftBase.Material = Enum.Material.Plastic
-- 	shaftBase.Mesh.VertexColor = socketVtx
-- 	local shaftSize = Vector3.new(scale * 0.08, scale * 0.08, dangleLength)
-- 	shaftBase.Size = shaftSize
-- 	shaftBase.Mesh.Scale = shaftSize

-- 	local rodBase = shaftBase:Clone()
-- 	local rodSize = Vector3.new(scale * 0.16, scale * 0.16, scale * 0.3)
-- 	rodBase.Size = rodSize
-- 	rodBase.Mesh.Scale = rodSize

-- 	for _, pt in next, pts do
-- 		local per = pt[1]
-- 		local v = pathlib.trace_path(path, per)
-- 		local p_0 = v.p
-- 		local bulb = bulbBase:Clone()
-- 		local look = v.lookVector
-- 		local right = look:Cross(UP).unit
-- 		local p_1 = p_0 - UP * (dangleLength)
-- 		bulb:SetPrimaryPartCFrame(CFrame.fromMatrix(p_1, right, UP))
-- 		bulb.Parent = ornamentModel

-- 		local shaft = shaftBase:Clone()
-- 		shaft.CFrame = CFrame.fromMatrix((p_0 + p_1) / 2, right, (look * Vector3.new(1, 0, 1)).unit)
-- 		shaft.Parent = ornamentModel
-- 	end
-- 	return ornamentModel
-- end

-- function MainManager:DrawAttachedGardenLight(ornamentParams, path, pts, r)
-- 	local ornamentModel = Instance.new("Model")
-- 	ornamentModel.Name = "AttachedGardenLight"
-- 	local bulbType = ornamentParams.bulbType
-- 	local scale = ornamentParams.scale
-- 	local lightColor = ornamentParams.lightColor
-- 	local socketColor = ornamentParams.socketColor

-- 	local bulbBase = Constants.ATTACHED_LIGHTS_SINGLE[bulbType]:Clone()
-- 	bulbBase.Bulb.Color = lightColor
-- 	bulbBase.Bulb.PointLight.Color = lightColor
-- 	bulbBase.Socket.Color = socketColor
-- 	local socketVtx = Vector3.new(socketColor.r, socketColor.g, socketColor.b)
-- 	bulbBase.Socket.Mesh.VertexColor = socketVtx
-- 	Utility.ScaleObject(bulbBase, scale)

-- 	for _, pt in next, pts do
-- 		local per = pt[1]
-- 		local v = pathlib.trace_path(path, per)
-- 		local p_0 = v.p
-- 		local bulb = bulbBase:Clone()
-- 		local look = v.lookVector
-- 		local right = look:Cross(UP).unit
-- 		bulb:SetPrimaryPartCFrame(CFrame.fromMatrix(p_0, right, UP))
-- 		bulb.Parent = ornamentModel
-- 	end
-- 	return ornamentModel
-- end

-- function MainManager:DrawChristmasLight(ornamentParams, path, pts, r)
-- 	local ornamentModel = Instance.new("Model")
-- 	ornamentModel.Name = "ChristmasLight"
-- 	local scale = ornamentParams.scale
-- 	local lightColor = ornamentParams.lightColor

-- 	local bulbBase = Constants.CHRISTMAS_LIGHT_BULB:Clone()
-- 	bulbBase.Color = lightColor
-- 	Utility.ScaleObject(bulbBase, scale)

-- 	for idx, pt in next, pts do
-- 		local per = pt[1]
-- 		local v = pathlib.trace_path(path, per)
-- 		local p_0 = v.p
-- 		local bulb = bulbBase:Clone()
-- 		local look = v.lookVector
-- 		local right = look:Cross(UP).unit
-- 		local up = right:Cross(look).unit
-- 		bulb.CFrame =
-- 			CFrame.fromMatrix(p_0, right, up) * constructOrientationCFrameForOrnamentParams(ornamentParams, r, idx - 1) *
-- 			CFrame.new(0, 0.3 * scale, 0)
-- 		bulb.Parent = ornamentModel
-- 	end
-- 	return ornamentModel
-- end

local function solveRectangleLoop(hit, p, p2, offset)
	local origin, planeP, planeP2, planeSize, localRight, localUp
	--[[
		Procedure:
			Project two points onto the nearest face part.
			Get the intersection of the line formed by the two points and
				the rectangle formed by the part's face.
	--]]
	local partCf = hit.CFrame
	local partSize = hit.Size
	partSize = partSize + Vector3.new(offset * 2, offset * 2, offset * 2)
	local localNorm = Utility.PointToLocalNormal(hit, p)
	local thickness
	if math.abs(localNorm.X) == 1 then
		origin = partCf * CFrame.new(0, -partSize.Y / 2, -partSize.Z / 2)
		local p_ospace = origin:PointToObjectSpace(p)
		local p2_ospace = origin:PointToObjectSpace(p2)
		planeP = Vector2.new(p_ospace.Z, p_ospace.Y)
		planeP2 = Vector2.new(p2_ospace.Z, p2_ospace.Y)
		planeSize = Vector2.new(partSize.Z, partSize.Y)
		localRight = Vector3.new(0, 0, 1)
		localUp = Vector3.new(0, 1, 0)
		thickness = partSize.X
	elseif math.abs(localNorm.Y) == 1 then
		origin = partCf * CFrame.new(-partSize.X / 2, 0, -partSize.Z / 2)
		local p_ospace = origin:PointToObjectSpace(p)
		local p2_ospace = origin:PointToObjectSpace(p2)
		planeP = Vector2.new(p_ospace.X, p_ospace.Z)
		planeP2 = Vector2.new(p2_ospace.X, p2_ospace.Z)
		planeSize = Vector2.new(partSize.X, partSize.Z)
		localRight = Vector3.new(1, 0, 0)
		localUp = Vector3.new(0, 0, 1)
		thickness = partSize.Y
	else
		origin = partCf * CFrame.new(-partSize.X / 2, -partSize.Y / 2, 0)
		local p_ospace = origin:PointToObjectSpace(p)
		local p2_ospace = origin:PointToObjectSpace(p2)
		planeP = Vector2.new(p_ospace.X, p_ospace.Y)
		planeP2 = Vector2.new(p2_ospace.X, p2_ospace.Y)
		planeSize = Vector2.new(partSize.X, partSize.Y)
		localRight = Vector3.new(1, 0, 0)
		localUp = Vector3.new(0, 1, 0)
		thickness = partSize.Z
	end

	local contacts
	if planeP == planeP2 then
		contacts = {planeP * Vector2.new(0, 1), planeP * Vector2.new(0, 1) + planeSize * Vector2.new(1, 0)}
	else
		contacts = Utility.FindLineRectIntersection(planeP, planeP2, Vector2.new(), planeSize)
		if #contacts == 0 then
			contacts = {planeP * Vector2.new(0, 1), planeP * Vector2.new(0, 1) + planeSize * Vector2.new(1, 0)}
		end
	end
	local entry = contacts[1]
	local exit = contacts[2]
	local entryWorld = origin:pointToWorldSpace(localRight * entry.X + localUp * entry.Y + localNorm * thickness / 2)
	local exitWorld = origin:pointToWorldSpace(localRight * exit.X + localUp * exit.Y + localNorm * thickness / 2)
	local delta = (entryWorld - exitWorld)
	local look = delta.unit
	local right = origin:vectorToWorldSpace(localNorm).unit
	local up = right:Cross(look).unit
	local wPos = (entryWorld + exitWorld) / 2 - right * thickness / 2
	local x = thickness
	local y = delta.magnitude

	return wPos, up, right, x, y, thickness
end

local function solveCircleLoop(hit, p, p2, offset)
	--[[
		Procedure:
			Project two points onto the plane formed by the two points. This plane will be
				centered at the cylinder's main axis.
			Get the intersection of the line formed by the two points and
				the rectangle formed by the aformentioned plane.
	--]]
	local partCf = hit.CFrame
	local partSize = hit.Size
	partSize = partSize + Vector3.new(offset * 2, offset * 2, offset * 2)
	local norm
	do
		local oSpace = partCf:pointToObjectSpace((p + p2) / 2)
		local vec = oSpace * Vector3.new(0, 1, 1)
		if vec.magnitude < 0.0001 then
			vec = Vector3.new(0, 1, 0)
		end
		vec = vec.unit
		norm = partCf:vectorToWorldSpace(vec)
	end
	local partUp = partCf.rightVector
	local planeWorldRight = partUp:Cross(norm)
	local origin = CFrame.fromMatrix(partCf.p - planeWorldRight * partSize.Y / 2 - partUp * partSize.X / 2, planeWorldRight, partUp)
	local p_ospace = origin:PointToObjectSpace(p)
	local p2_ospace = origin:PointToObjectSpace(p2)
	local planeP = Vector2.new(p_ospace.X, p_ospace.Y)
	local planeP2 = Vector2.new(p2_ospace.X, p2_ospace.Y)
	local planeSize = Vector2.new(partSize.Y, partSize.X)

	local contacts
	if planeP == planeP2 then
		contacts = {planeP * Vector2.new(0, 1), planeP * Vector2.new(0, 1) + planeSize * Vector2.new(1, 0)}
	else
		contacts = Utility.FindLineRectIntersection(planeP, planeP2, Vector2.new(), planeSize)
		if #contacts == 0 then
			contacts = {planeP * Vector2.new(0, 1), planeP * Vector2.new(0, 1) + planeSize * Vector2.new(1, 0)}
		end
	end
	local entry = contacts[1]
	local exit = contacts[2]
	local thickness = partSize.Y
	local entryWorld = origin.p + (planeWorldRight * entry.X) + (partUp * entry.Y)
	local exitWorld = origin.p + (planeWorldRight * exit.X) + (partUp * exit.Y)
	local delta = (entryWorld - exitWorld)
	local look = delta.unit
	local right = norm
	local up = right:Cross(look).unit
	local wPos = (entryWorld + exitWorld) / 2
	local x = thickness
	local y = delta.magnitude

	return wPos, up, right, x, y, thickness
end

local ROPE_PART_COUNT_TO_TARGET_ANGLE_MAP = {
	[Types.RopePartCount.LOW] = math.rad(20),
	[Types.RopePartCount.MEDIUM] = math.rad(10),
	[Types.RopePartCount.HIGH] = math.rad(5),
}

local ROPE_PART_COUNT_TO_TARGET_LENGTH_MAP = {
	[Types.RopePartCount.LOW] = 0.8,
	[Types.RopePartCount.MEDIUM] = 0.4,
	[Types.RopePartCount.HIGH] = 0.2,
}

function MainManager:DrawPreset(presetId, params)
	local rootModel = Instance.new("Model")
	CollectionService:AddTag(rootModel, Constants.ROPE_MODEL_TAG)
	rootModel.Name = self:GetPresetName(presetId)
	local ropeType = self:GetPresetRopeType(presetId)
	local ropeParams = self:GetPresetRopeParams(presetId)
	-- local ornamentIds = self:GetPresetOrnamentIds(presetId)
	local curveType = params.curveType
	local r
	if params.seed then
		r = NormalizedRandom.new(params.seed)
	else
		r = NormalizedRandom.new()
	end

	local path
	local ropeModel
	if curveType == Types.Curve.CATENARY then
		if ropeType == Types.Rope.ROPE then
			local points = params.points
			local start, fin = points[1], points[2]
			fin, start = start, fin
			local length = params.length
			local partCount = ropeParams.partCount
			local targetAngle = ROPE_PART_COUNT_TO_TARGET_ANGLE_MAP[partCount]
			local targetLength = ROPE_PART_COUNT_TO_TARGET_LENGTH_MAP[partCount]
			path = pathlib.create_smart_catenary_path(start, fin, length, targetAngle, targetLength)
			ropeModel = self:DrawRope(ropeParams, path)
		-- elseif ropeType == Types.Rope.MESH_CHAIN or ropeType == Types.Rope.MATERIAL_CHAIN or ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 	local points = params.points
		-- 	local start, fin = points[1], points[2]
		-- 	local length = params.length
		-- 	local segmentScale = ropeParams.segmentScale
		-- 	local linkSpacing
		-- 	if ropeType == Types.Rope.MESH_CHAIN then
		-- 		local meshChainType = ropeParams.meshChainType
		-- 		linkSpacing = Constants.MESH_CHAIN_SPACING[meshChainType]
		-- 	elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 		local materialChainType = ropeParams.materialChainType
		-- 		linkSpacing = Constants.MATERIAL_CHAIN_SPACING[materialChainType]
		-- 	elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 		linkSpacing = ropeParams.linkSpacing
		-- 	end
		-- 	path = pathlib.create_constant_arc_path(start, fin, length, linkSpacing * segmentScale)

		-- 	if ropeType == Types.Rope.MESH_CHAIN then
		-- 		ropeModel = self:DrawMeshChain(ropeParams, path, r)
		-- 	elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 		ropeModel = self:DrawMaterialChain(ropeParams, path, r)
		-- 	elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 		ropeModel = self:DrawCustomChain(ropeParams, path, r)
		-- 	end
		end
	elseif curveType == Types.Curve.LINE then
		if ropeType == Types.Rope.ROPE then
			local points = params.points
			local start, fin = points[1], points[2]
			fin, start = start, fin
			path = pathlib.create_simple_line_path(start, fin)
			ropeModel = self:DrawRope(ropeParams, path)
		-- elseif ropeType == Types.Rope.MESH_CHAIN or ropeType == Types.Rope.MATERIAL_CHAIN or ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 	local points = params.points
		-- 	local start, fin = points[1], points[2]
		-- 	local length = (start - fin).magnitude
		-- 	local segmentScale = ropeParams.segmentScale
		-- 	local linkSpacing
		-- 	if ropeType == Types.Rope.MESH_CHAIN then
		-- 		local meshChainType = ropeParams.meshChainType
		-- 		linkSpacing = Constants.MESH_CHAIN_SPACING[meshChainType]
		-- 	elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 		local materialChainType = ropeParams.materialChainType
		-- 		linkSpacing = Constants.MATERIAL_CHAIN_SPACING[materialChainType]
		-- 	elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 		linkSpacing = ropeParams.linkSpacing
		-- 	end
		-- 	path = pathlib.create_segmented_line_path(start, fin, math.ceil(length / (linkSpacing * segmentScale)))

		-- 	if ropeType == Types.Rope.MESH_CHAIN then
		-- 		ropeModel = self:DrawMeshChain(ropeParams, path, r)
		-- 	elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 		ropeModel = self:DrawMaterialChain(ropeParams, path, r)
		-- 	end
		end
	elseif curveType == Types.Curve.LOOP then
		local hit = params.hit
		local p = params.p
		local p2 = params.p2
		local offset = params.offset
		local loopShape = params.shape
		local wPos, up, right, x, y
		do
			if (loopShape == Types.LoopShape.RECTANGLE) or hit.ClassName ~= "Part" or hit.Shape ~= Enum.PartType.Cylinder then
				wPos, up, right, x, y = solveRectangleLoop(hit, p, p2, offset)
			else
				-- p and p2 are swapped so that the direction of the loop is consistent w/ the other loop shape.
				p, p2 = p2, p
				wPos, up, right, x, y = solveCircleLoop(hit, p, p2, offset)
			end
		end

		if ropeType == Types.Rope.ROPE then
			if loopShape == Types.LoopShape.RECTANGLE then
				path = pathlib.create_simple_rectangular_loop_path(wPos, up, right, x, y)
			else
				local partCount = ropeParams.partCount
				local targetAngle = ROPE_PART_COUNT_TO_TARGET_ANGLE_MAP[partCount]
				local targetLength = ROPE_PART_COUNT_TO_TARGET_LENGTH_MAP[partCount]
				path = pathlib.create_smart_round_loop_path(wPos, up, right, x, y, targetAngle, targetLength)
			end

			local loopRopeParams =
				Cryo.Dictionary.join(
				ropeParams,
				{
					height = ropeParams.width,
					width = ropeParams.height,
					textureRotation = (ropeParams.textureRotation + 0.25) % 1
				}
			)
			ropeModel = self:DrawRope(loopRopeParams, path)
		-- elseif ropeType == Types.Rope.MESH_CHAIN or ropeType == Types.Rope.MATERIAL_CHAIN or ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 	local segmentScale = ropeParams.segmentScale
		-- 	local loopShape = params.shape
		-- 	local linkSpacing
		-- 	if loopShape == Types.LoopShape.RECTANGLE then
		-- 		if ropeType == Types.Rope.MESH_CHAIN then
		-- 			local meshChainType = ropeParams.meshChainType
		-- 			linkSpacing = Constants.MESH_CHAIN_SPACING[meshChainType]
		-- 		elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 			local materialChainType = ropeParams.materialChainType
		-- 			linkSpacing = Constants.MATERIAL_CHAIN_SPACING[materialChainType]
		-- 		elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 			linkSpacing = ropeParams.linkSpacing
		-- 		end
		-- 		path = pathlib.create_segmented_rectangular_loop_path(wPos, up, right, x, y, linkSpacing * segmentScale)
		-- 	else
		-- 		if ropeType == Types.Rope.MESH_CHAIN then
		-- 			local meshChainType = ropeParams.meshChainType
		-- 			linkSpacing = Constants.MESH_CHAIN_SPACING[meshChainType]
		-- 		elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 			local materialChainType = ropeParams.materialChainType
		-- 			linkSpacing = Constants.MATERIAL_CHAIN_SPACING[materialChainType]
		-- 		elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 			linkSpacing = ropeParams.linkSpacing
		-- 		end
		-- 		local circumference = Utility.ApproximateEllipsePerimeter(x / 2, y / 2)
		-- 		local segmentCount = math.ceil(circumference / (linkSpacing * segmentScale))
		-- 		path = pathlib.create_round_arc_loop_path(wPos, up, right, x, y, math.max(4, segmentCount))
		-- 	end

		-- 	if ropeType == Types.Rope.MESH_CHAIN then
		-- 		ropeModel = self:DrawMeshChain(ropeParams, path, r)
		-- 	elseif ropeType == Types.Rope.MATERIAL_CHAIN then
		-- 		ropeModel = self:DrawMaterialChain(ropeParams, path, r)
		-- 	elseif ropeType == Types.Rope.CUSTOM_CHAIN then
		-- 		ropeModel = self:DrawCustomChain(ropeParams, path, r)
		-- 	end
		end
	elseif curveType == "Coil" then
		error("Not implemented")
	elseif curveType == "Spline" then
		error("Not implemented")
	end

	-- local ornamentToPtMapping = {}
	-- for _, ornamentId in next, ornamentIds do
	-- 	local ornamentType, ornamentParams =
	-- 		self:GetPresetOrnamentType(presetId, ornamentId),
	-- 		self:GetPresetOrnamentParams(presetId, ornamentId)
	-- 	if ornamentType == "CarnivalFlagSingle" then
	-- 		local width = ornamentParams.width
	-- 		local spacing = ornamentParams.spacing
	-- 		local spacingOffset = ornamentParams.spacingOffset

	-- 		local pts =
	-- 			spacePointsOnPathEvenly(
	-- 			path,
	-- 			{
	-- 				width = width,
	-- 				spacing = spacing,
	-- 				begin = 0,
	-- 				fin = 0,
	-- 				spacingOffset = spacingOffset
	-- 			}
	-- 		)
	-- 		ornamentToPtMapping[ornamentId] = pts
	-- 	elseif ornamentType == "DanglingGardenLight" then
	-- 		local spacing = ornamentParams.spacing
	-- 		local spacingOffset = ornamentParams.spacingOffset

	-- 		local pts =
	-- 			spacePointsOnPathEvenly(
	-- 			path,
	-- 			{
	-- 				width = 0,
	-- 				spacing = spacing,
	-- 				begin = 0,
	-- 				fin = 0,
	-- 				spacingOffset = spacingOffset
	-- 			}
	-- 		)
	-- 		ornamentToPtMapping[ornamentId] = pts
	-- 	elseif ornamentType == "AttachedGardenLight" then
	-- 		local spacing = ornamentParams.spacing
	-- 		local spacingOffset = ornamentParams.spacingOffset

	-- 		local pts =
	-- 			spacePointsOnPathEvenly(
	-- 			path,
	-- 			{
	-- 				width = 0,
	-- 				spacing = spacing,
	-- 				begin = 0,
	-- 				fin = 0,
	-- 				spacingOffset = spacingOffset
	-- 			}
	-- 		)
	-- 		ornamentToPtMapping[ornamentId] = pts
	-- 	elseif ornamentType == "ChristmasLight" then
	-- 		local spacing = ornamentParams.spacing
	-- 		local spacingOffset = ornamentParams.spacingOffset

	-- 		local pts =
	-- 			spacePointsOnPathEvenly(
	-- 			path,
	-- 			{
	-- 				width = 0,
	-- 				spacing = spacing,
	-- 				begin = 0,
	-- 				fin = 0,
	-- 				spacingOffset = spacingOffset
	-- 			}
	-- 		)
	-- 		ornamentToPtMapping[ornamentId] = pts
	-- 	end
	-- end

	-- local rightmost = 0
	-- for _, ornamentPts in next, ornamentToPtMapping do
	-- 	if #ornamentPts > 0 then
	-- 		local lastPt = ornamentPts[#ornamentPts]
	-- 		local right = lastPt[2]
	-- 		if right > rightmost then
	-- 			rightmost = right
	-- 		end
	-- 	end
	-- end

	-- local centerBias = (1 - rightmost) / 2

	-- for _, pts in next, ornamentToPtMapping do
	-- 	for _, pt in next, pts do
	-- 		pt[1] = pt[1] + centerBias
	-- 		pt[2] = pt[2] + centerBias
	-- 	end
	-- end

	-- local ornamentsModel = Instance.new("Model", rootModel)
	-- ornamentsModel.Name = "OrnamentsModel"

	-- for _, ornamentId in next, ornamentIds do
	-- 	local ornamentType, ornamentParams =
	-- 		self:GetPresetOrnamentType(presetId, ornamentId),
	-- 		self:GetPresetOrnamentParams(presetId, ornamentId)
	-- 	local pts = ornamentToPtMapping[ornamentId]
	-- 	if ornamentType == "CarnivalFlagSingle" then
	-- 		local model = self:DrawCarnivalFlagSingle(ornamentParams, path, pts, r)
	-- 		model.Parent = ornamentsModel
	-- 	elseif ornamentType == "DanglingGardenLight" then
	-- 		local model = self:DrawDanglingGardenLight(ornamentParams, path, pts, r)
	-- 		model.Parent = ornamentsModel
	-- 	elseif ornamentType == "AttachedGardenLight" then
	-- 		local model = self:DrawAttachedGardenLight(ornamentParams, path, pts, r)
	-- 		model.Parent = ornamentsModel
	-- 	elseif ornamentType == "ChristmasLight" then
	-- 		local model = self:DrawChristmasLight(ornamentParams, path, pts, r)
	-- 		model.Parent = ornamentsModel
	-- 	end
	-- end

	ropeModel.Parent = rootModel

	return rootModel
end

local function _createSimpleGetterSetter(propertyName, defaultValue)
	MainManager[string.format("Set%s", propertyName)] = function(self, newValue)
		if self[propertyName] == nil and defaultValue ~= newValue then
			self[propertyName] = newValue
			self._signal:fire()
			return
		end

		if self[propertyName] ~= newValue then
			self[propertyName] = newValue
			self._signal:fire()
			return
		end
	end

	MainManager[string.format("Get%s", propertyName)] = function(self)
		if self[propertyName] == nil then
			return defaultValue
		end
		return self[propertyName]
	end
end

function MainManager:SetPresetIdBeingDeleted(presetId)
	local presetType = self:GetPresetType(presetId)
	assert(presetType == Types.Preset.CUSTOM)
	self.presetBeingDeleted = presetId
	self._signal:fire()
end

function MainManager:ClearPresetIdBeingDeleted()
	self.presetBeingDeleted = nil
	self._signal:fire()
end

function MainManager:GetPresetIdBeingDeleted()
	if self:_GetPresetEntry(self.presetBeingDeleted) then
		return self.presetBeingDeleted
	end

	return nil
end

function MainManager:DeletePreset(presetId)
	local presetType = self:GetPresetType(presetId)
	assert(presetType == Types.Preset.CUSTOM)
	if self:GetActivePreset() == presetId then
		self:SetActivePreset(nil)
	end
	self:_SetPresetEntry(presetId, nil)
	self._signal:fire()
end

function MainManager:HasPreset(presetId)
	return self:_GetPresetEntry(presetId) ~= nil
end

function MainManager:GetCurveType()
	if self.curveType == nil then
		return Constants.CURVE_TYPE_DEFAULT
	end

	return self.curveType
end

function MainManager:SetCurveType(curveType)
	if self.curveType ~= curveType then
		self.curveType = curveType
		self._signal:fire()
		self:ClearPointBuffer()
	end
end

function MainManager:ClearPointBuffer()
	if #self.pointBuffer > 0 then
		self.pointBuffer = {}
		self._pointBufferSignal:fire()
	end
end

function MainManager:GetSelection()
	return self.selection
end

function MainManager:_getPresetChangedSignal(presetId)
	local signal = self._presetChangedSignals[presetId]
	if signal == nil then
		signal = createSignal()
		self._presetChangedSignals[presetId] = signal
	end
	return signal
end

function MainManager:subscribeToPresetChanged(presetId, f)
	local signal = self:_getPresetChangedSignal(presetId)
	return signal:subscribe(f)
end

function MainManager:OpenPresetEntryContextMenu(presetId)
	local plugin = self.plugin
	-- This is how the toolbox does it in ContextMenuHelper.lua
	local menu = plugin:CreatePluginMenu("PresetContextMenu")

	menu:AddNewAction("ClonePreset", "Clone and Edit Preset", "rbxassetid://3645133081").Triggered:connect(
		function()
			local newId = self:DuplicatePreset(presetId)
			self:SetActivePreset(newId)
		end
	)

	local presetType = self:GetPresetType(presetId)
	if presetType == Types.Preset.CUSTOM then
		menu:AddNewAction("DeletePreset", "Delete Preset", "rbxassetid://3645133603").Triggered:connect(
			function()
				self:SetPresetIdBeingDeleted(presetId)
			end
		)
	end

	menu:ShowAsync()
	menu:Destroy()
end

_createSimpleGetterSetter("PresetsFilterString", "")
_createSimpleGetterSetter("HideBuiltinPresets", false)
_createSimpleGetterSetter("LockTo", Constants.LOCK_TO_DEFAULT)
_createSimpleGetterSetter("IgnoreRope", Constants.IGNORE_ROPE_DEFAULT)
_createSimpleGetterSetter("GridSize", Constants.GRID_SIZE_DEFAULT)
_createSimpleGetterSetter("LockDistance", Constants.LOCK_DISTANCE_DEFAULT)
_createSimpleGetterSetter("DangleLengthMode", Constants.DANGLE_LENGTH_MODE_DEFAULT)
_createSimpleGetterSetter("DangleLengthFixed", Constants.DANGLE_LENGTH_FIXED_DEFAULT)
_createSimpleGetterSetter("DangleLengthRelative", Constants.DANGLE_LENGTH_RELATIVE_DEFAULT)
_createSimpleGetterSetter("LoopShape", Constants.LOOP_SHAPE_DEFAULT)
_createSimpleGetterSetter("LoopOffset", Constants.LOOP_OFFSET_DEFAULT)

return MainManager
