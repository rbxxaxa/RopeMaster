-- InstanceStore
-- Makes sure that plugin data sticks with the place file.

-- we need to parent the thing under a service that can't be deleted.
local PluginStorageRoot = game:GetService("Geometry")

local InstanceStore = {}
InstanceStore.__index = InstanceStore
InstanceStore.StorageRoot = PluginStorageRoot

function InstanceStore.new(name)
	local self = setmetatable({}, InstanceStore)

	local storedRoot = PluginStorageRoot:FindFirstChild(name)
	local root
	if not storedRoot or storedRoot.Archivable == false then
		if storedRoot then
			storedRoot:Destroy()
		end
		root = Instance.new("Folder")
		root.Name = name
	else
		root = storedRoot:Clone()
		storedRoot:Destroy()
	end

	local foundKeys = {}
	for _, v in next, root:GetChildren() do
		-- ensure that all instances are archivable
		if not v.Archivable then
			-- and that there are no duplicates
			v:Destroy()
		elseif foundKeys[v.Name] then
			-- and that there are exactly one children
			v:Destroy()
		elseif #v:GetChildren() > 1 then
			-- and that the only child is archivable
			v:Destroy()
		elseif not v:GetChildren()[1].Archivable then
			v:Destroy()
		else
			foundKeys[v.Name] = true
		end
	end

	self.root = root
	self.mountedRoot = root:Clone()
	self.mountedRoot.Parent = PluginStorageRoot
	self.instanceIdsToRemount = {}
	self.mountedInstances = {}
	self.instanceCache = {}

	self.remountDetectionBlock = false
	local function initializeMountedInstance(instanceFolder)
		local id = instanceFolder.Name
		--print(id .. " instance initialized")
		instanceFolder.ChildAdded:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.instanceIdsToRemount[id] = true
			end
		)

		instanceFolder.ChildRemoved:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.instanceIdsToRemount[id] = true
			end
		)

		instanceFolder.Changed:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.instanceIdsToRemount[id] = true
			end
		)

		for _, v in next, instanceFolder:GetDescendants() do
			if not v:IsA("ValueBase") then
				-- Waaay too buggy.
				-- Things such as joint updates and absolute size of UIs can
				-- trigger this.
				--v.Changed:Connect(function(prop)
				--	print(prop)
				--	if self.remountDetectionBlock then return end
				--	self.instanceIdsToRemount[id] = true
				--end)
				v:GetPropertyChangedSignal("Archivable"):Connect(
					function()
						if self.remountDetectionBlock then
							return
						end
						self.instanceIdsToRemount[id] = true
					end
				)
			else
				-- The changed signal for values only fires when it's Value is changed.
				v:GetPropertyChangedSignal("Value"):Connect(
					function()
						if self.remountDetectionBlock then
							return
						end
						self.instanceIdsToRemount[id] = true
					end
				)

				v:GetPropertyChangedSignal("Name"):Connect(
					function()
						if self.remountDetectionBlock then
							return
						end
						self.instanceIdsToRemount[id] = true
					end
				)

				v:GetPropertyChangedSignal("Archivable"):Connect(
					function()
						if self.remountDetectionBlock then
							return
						end
						self.instanceIdsToRemount[id] = true
					end
				)
			end

			v.ChildAdded:Connect(
				function()
					if self.remountDetectionBlock then
						return
					end
					self.instanceIdsToRemount[id] = true
				end
			)

			v.ChildRemoved:Connect(
				function()
					if self.remountDetectionBlock then
						return
					end
					self.instanceIdsToRemount[id] = true
				end
			)
		end

		self.mountedInstances[id] = {
			instanceFolder,
			instanceFolder:GetChildren()[1]
		}
	end

	local function initializeMountedRoot(instanceRoot)
		--print("instance root initialized")
		instanceRoot.Changed:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.rootMustRemount = true
			end
		)

		instanceRoot.ChildAdded:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.rootMustRemount = true
			end
		)

		instanceRoot.ChildRemoved:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.rootMustRemount = true
			end
		)

		root.AncestryChanged:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.rootMustRemount = true
			end
		)

		self.mountedInstances = {}

		for _, instanceFolder in next, instanceRoot:GetChildren() do
			initializeMountedInstance(instanceFolder)
		end
	end

	initializeMountedRoot(self.mountedRoot)

	local function mustSave()
		return self.rootMustRemount or next(self.instanceIdsToRemount) ~= nil
	end

	local function save()
		self.remountDetectionBlock = true

		if self.rootMustRemount then
			self.mountedRoot:Destroy()
			for _, instanceEntry in next, self.mountedInstances do
				instanceEntry[1]:Destroy()
				instanceEntry[2]:Destroy()
			end

			self.rootMustRemount = false
			self.instanceIdsToRemount = {}

			self.mountedRoot = root:Clone()
			self.mountedRoot.Parent = PluginStorageRoot
			initializeMountedRoot(self.mountedRoot)
		else
			for id, _ in next, self.instanceIdsToRemount do
				local instanceEntry = self.mountedInstances[id]
				if instanceEntry then
					instanceEntry[1]:Destroy()
					instanceEntry[2]:Destroy()
				end

				local originalInstanceFolder = self.root:FindFirstChild(id)
				-- The instance to remount may have been deleted.
				if originalInstanceFolder then
					local mountedInstance = originalInstanceFolder:Clone()
					mountedInstance.Parent = self.mountedRoot
					initializeMountedInstance(mountedInstance)
				end
			end
			self.instanceIdsToRemount = {}
		end

		self.remountDetectionBlock = false
	end

	self.mustSave = mustSave
	self.save = save

	return self
end

function InstanceStore:MustSave()
	return self.mustSave()
end

function InstanceStore:Save()
	self.save()
end

function InstanceStore:WriteInstance(id, instance)
	assert(typeof(id) == "string")
	assert(typeof(instance) == "Instance")
	assert(instance.Archivable)

	local instanceFolder = self.root:FindFirstChild(id)
	if instanceFolder then
		instanceFolder:ClearAllChildren()
	else
		instanceFolder = Instance.new("Folder")
		instanceFolder.Parent = self.root
		instanceFolder.Name = id
	end

	local instanceClone = instance:Clone()
	instanceClone.Parent = instanceFolder
	self.instanceCache[id] = instanceClone

	self.instanceIdsToRemount[id] = true
end

function InstanceStore:ReadInstance(id)
	assert(typeof(id) == "string")

	local cached = self.instanceCache[id]
	if cached then
		return cached:Clone()
	else
		local instanceFolder = self.root:FindFirstChild(id)
		if not instanceFolder then
			return nil
		end

		local instance = instanceFolder:GetChildren()[1]
		self.instanceCache[id] = instance

		return instance:Clone()
	end
end

function InstanceStore:DeleteInstance(id)
	assert(typeof(id) == "string")

	local instanceFolder = self.root:FindFirstChild(id)
	if not instanceFolder then
		return
	end

	instanceFolder:Destroy()
	self.instanceCache[id] = nil

	local instanceEntry = self.mountedInstances[id]
	if instanceEntry then
		self.remountDetectionBlock = true
		instanceEntry[1]:Destroy()
		instanceEntry[2]:Destroy()
		self.mountedInstances[id] = nil
		self.remountDetectionBlock = false
	end
end

function InstanceStore:GetInstanceIds()
	local ids = {}
	for _, instanceFolder in next, self.root:GetChildren() do
		table.insert(ids, instanceFolder.Name)
	end

	return ids
end

function InstanceStore:HasInstance(id)
	assert(typeof(id) == "string")
	return self.instanceCache[id] ~= nil or self.root:FindFirstChild(id) ~= nil
end

function InstanceStore:Destroy()
	-- Disconnect all connections by re-creating the mounted root lol.
	local clone = self.mountedRoot:Clone()
	self.mountedRoot:Destroy()
	clone.Parent = PluginStorageRoot
end

function InstanceStore.ClearStore(name)
	while true do
		local store = PluginStorageRoot:FindFirstChild(name)
		if store then
			store:Destroy()
		else
			break
		end
	end
end

function InstanceStore.DoesStoreExist(name)
	return PluginStorageRoot:FindFirstChild(name) ~= nil
end

return InstanceStore
