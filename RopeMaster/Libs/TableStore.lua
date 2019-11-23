-- TableStore
-- Makes sure that plugin data sticks with the place file.

-- we need to parent the thing under a service that can't be deleted.
local PluginStorageRoot = game:GetService("Geometry")
local HttpService = game:GetService("HttpService")

local TableStore = {}
TableStore.__index = TableStore
TableStore.StorageRoot = PluginStorageRoot

function TableStore.new(name)
	local self = setmetatable({}, TableStore)

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
		-- ensure that all children are string values
		if not v:IsA("StringValue") then
			-- and that they contain json strings
			v:Destroy()
		elseif
			pcall(
				function()
					HttpService:JSONDecode(v.Value)
				end
			) == false
		 then
			-- and that they're archivable
			v:Destroy()
		elseif not v.Archivable then
			-- and that there are no duplicates
			v:Destroy()
		elseif foundKeys[v.Name] then
			-- and clear children if they have any.
			v:Destroy()
		else
			foundKeys[v.Name] = true
			v:ClearAllChildren()
		end
	end

	self.root = root
	self.mountedRoot = root:Clone()
	self.mountedRoot.Parent = PluginStorageRoot
	self.jsonCache = {}
	self.jsonIdsToRemount = {}
	self.mountedJsons = {}

	self.remountDetectionBlock = false

	local function initializeMountedJsonInstance(jsonInstance)
		local id = jsonInstance.Name
		--print(id .. " json instance initialized")
		-- The changed signal for values only fires when it's Value is changed.
		jsonInstance:GetPropertyChangedSignal("Value"):Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.jsonIdsToRemount[id] = true
			end
		)

		jsonInstance:GetPropertyChangedSignal("Name"):Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.jsonIdsToRemount[id] = true
			end
		)

		jsonInstance:GetPropertyChangedSignal("Archivable"):Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.jsonIdsToRemount[id] = true
			end
		)

		jsonInstance.ChildAdded:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.jsonIdsToRemount[id] = true
			end
		)

		self.mountedJsons[id] = jsonInstance
	end

	local function initializeMountedRoot(root)
		--print("json root initialized")
		root.Changed:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.rootMustRemount = true
			end
		)

		root.ChildAdded:Connect(
			function()
				if self.remountDetectionBlock then
					return
				end
				self.rootMustRemount = true
			end
		)

		root.ChildRemoved:Connect(
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

		self.mountedJsons = {}

		for _, jsonInstance in next, root:GetChildren() do
			initializeMountedJsonInstance(jsonInstance)
		end
	end

	initializeMountedRoot(self.mountedRoot)

	local function mustSave()
		return self.rootMustRemount or next(self.jsonIdsToRemount) ~= nil
	end

	local function save()
		self.remountDetectionBlock = true

		if self.rootMustRemount then
			self.mountedRoot:Destroy()
			for _, mountedJson in next, self.mountedJsons do
				mountedJson:Destroy()
			end

			self.rootMustRemount = false
			self.jsonIdsToRemount = {}

			self.mountedRoot = root:Clone()
			self.mountedRoot.Parent = PluginStorageRoot
			initializeMountedRoot(self.mountedRoot)
		else
			for id, _ in next, self.jsonIdsToRemount do
				local jsonInstance = self.mountedJsons[id]
				if jsonInstance then
					jsonInstance:Destroy()
				end

				local originalJsonInstance = self.root:FindFirstChild(id)
				-- The table to remount may have been deleted.
				if originalJsonInstance then
					local jsonInstanceClone = originalJsonInstance:Clone()
					jsonInstanceClone.Parent = self.mountedRoot
					initializeMountedJsonInstance(jsonInstanceClone)
				end
			end
			self.jsonIdsToRemount = {}
		end

		self.remountDetectionBlock = false
	end

	self.mustSave = mustSave
	self.save = save

	return self
end

-- stolen from the lua website
local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

function TableStore:MustSave()
	return self.mustSave()
end

function TableStore:Save()
	self.save()
end

function TableStore:ReadTable(id)
	assert(typeof(id) == "string")

	local cached = self.jsonCache[id]
	if cached then
		return deepcopy(cached)
	else
		local jsonObj = self.root:FindFirstChild(id)
		if not jsonObj then
			return nil
		end

		local decoded = HttpService:JSONDecode(jsonObj.Value)
		self.jsonCache[id] = decoded

		return decoded
	end
end

function TableStore:WriteTable(id, tab)
	assert(typeof(id) == "string")
	assert(typeof(tab) == "table")
	local encoded = HttpService:JSONEncode(tab)

	local jsonObj = self.root:FindFirstChild(id)
	if not jsonObj then
		jsonObj = Instance.new("StringValue")
		jsonObj.Name = id
		jsonObj.Parent = self.root
	end

	if jsonObj.Value ~= encoded then
		jsonObj.Value = encoded
		self.jsonCache[id] = deepcopy(tab)

		self.jsonIdsToRemount[id] = true
	end
end

function TableStore:DeleteTable(id)
	assert(typeof(id) == "string")

	local jsonObj = self.root:FindFirstChild(id)
	if not jsonObj then
		return
	end

	jsonObj:Destroy()
	self.jsonCache[id] = nil

	local mountedJson = self.mountedJsons[id]
	if mountedJson then
		self.remountDetectionBlock = true
		mountedJson:Destroy()
		self.mountedJsons[id] = nil
		self.remountDetectionBlock = false
	end
end

function TableStore:GetTableIds()
	local ids = {}

	for _, jsonObject in next, self.root:GetChildren() do
		table.insert(ids, jsonObject.Name)
	end

	return ids
end

function TableStore:HasTable(id)
	assert(typeof(id) == "string")

	return self.root:FindFirstChild(id) ~= nil
end

function TableStore:Destroy()
	-- Disconnect all connections by re-creating the mounted root lol.
	local clone = self.mountedRoot:Clone()
	self.mountedRoot:Destroy()
	clone.Parent = PluginStorageRoot
end

function TableStore.ClearStore(name)
	while true do
		local store = PluginStorageRoot:FindFirstChild(name)
		if store then
			store:Destroy()
		else
			break
		end
	end
end

function TableStore.DoesStoreExist(name)
	return PluginStorageRoot:FindFirstChild(name) ~= nil
end

return TableStore
