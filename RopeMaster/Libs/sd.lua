local HttpService = game:GetService("HttpService")

local typeToKeyMap = {
	Vector3 = string.char(0),
	Color3 = string.char(1),
	Vector2 = string.char(2),
	CFrame = string.char(3)
}

local keyToTypeMap = {
	[string.char(0)] = "Vector3",
	[string.char(1)] = "Color3",
	[string.char(2)] = "Vector2",
	[string.char(3)] = "CFrame"
}

local function isRobloxDataTypeSerializable(vType)
	return typeToKeyMap[vType] ~= nil
end

local SEP = "|"
local function serializeRobloxData(vType, v)
	local serialized
	if vType == "Vector3" then
		serialized =
			table.concat(
			{
				typeToKeyMap.Vector3,
				tostring(v.x),
				tostring(v.y),
				tostring(v.z)
			},
			SEP
		)
	elseif vType == "Color3" then
		serialized =
			table.concat(
			{
				typeToKeyMap.Color3,
				tostring(v.r),
				tostring(v.g),
				tostring(v.b)
			},
			SEP
		)
	elseif vType == "Vector2" then
		serialized =
			table.concat(
			{
				typeToKeyMap.Vector2,
				tostring(v.x),
				tostring(v.y)
			},
			SEP
		)
	elseif vType == "CFrame" then
		local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = v:GetComponents()
		serialized =
			table.concat(
			{
				typeToKeyMap.CFrame,
				tostring(x),
				tostring(y),
				tostring(z),
				tostring(R00),
				tostring(R01),
				tostring(R02),
				tostring(R10),
				tostring(R11),
				tostring(R12),
				tostring(R20),
				tostring(R21),
				tostring(R22)
			},
			SEP
		)
	end

	return serialized
end

local function deserializeRobloxData(dat)
	local s = string.split(dat, SEP)
	local key, params = s[1], {unpack(s, 2)}
	local deserialized
	local dType = keyToTypeMap[key]

	if dType == "Vector3" then
		deserialized = Vector3.new(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]))
	elseif dType == "Color3" then
		deserialized = Color3.new(tonumber(params[1]), tonumber(params[2]), tonumber(params[3]))
	elseif dType == "Vector2" then
		deserialized = Vector2.new(tonumber(params[1]), tonumber(params[2]))
	elseif dType == "CFrame" then
		deserialized =
			CFrame.new(
			tonumber(params[1]),
			tonumber(params[2]),
			tonumber(params[3]),
			tonumber(params[4]),
			tonumber(params[5]),
			tonumber(params[6]),
			tonumber(params[7]),
			tonumber(params[8]),
			tonumber(params[9]),
			tonumber(params[10]),
			tonumber(params[11]),
			tonumber(params[12])
		)
	end

	return dType, deserialized
end

local function serialize(t)
	local reservedStrings = {}

	-- first phase: populate reservedStrings with all the strings in the table to be serialized.
	-- We use this to prevent them from being used as keys.
	do
		local visited = {}
		local toVisit = {t}
		while true do
			local current = table.remove(toVisit)
			if not current then
				break
			end
			visited[current] = true
			for _, v in next, current do
				local vType = typeof(v)
				if vType == "table" then
					if not visited[v] then
						table.insert(toVisit, v)
					end
				elseif vType == "string" then
					reservedStrings[v] = true
				end
			end
		end
	end

	-- second phase: create a new table + a map containing the serialized Roblox data.
	local baseTable = {}
	local robloxTable = {}
	do
		local currentKeyIdx = 0
		local function generateNewDataKey()
			while true do
				local key = ""
				local counter = currentKeyIdx
				while true do
					key = key .. string.char(math.min(counter, 127))
					counter = counter - 128
					if counter < 0 then
						break
					end
				end
				currentKeyIdx = currentKeyIdx + 1
				if not reservedStrings[key] then
					return key
				end
			end
		end

		local visited = {}
		local toVisit = {{baseTable, t}}
		while true do
			local nextEntry = table.remove(toVisit)
			if not nextEntry then
				break
			end

			local parent, current = unpack(nextEntry)
			if not visited[current] then
				visited[current] = true
				for k, v in next, current do
					local vType = typeof(v)
					if vType == "table" then
						if not visited[v] then
							local newTab = {}
							parent[k] = newTab
							table.insert(toVisit, {newTab, v})
						else
							error("Cannot serialize table with circular references.")
						end
					else
						if vType == "boolean" then
							parent[k] = v
						elseif vType == "number" then
							parent[k] = v
						elseif vType == "string" then
							parent[k] = v
						elseif isRobloxDataTypeSerializable(vType) then
							local newKey = generateNewDataKey()
							parent[k] = newKey
							robloxTable[newKey] = serializeRobloxData(vType, v)
						else
							error(vType .. " type cannot be serialized.")
						end
					end
				end
			end
		end
	end

	-- combine the two tables and serialize
	local serialized = HttpService:JSONEncode({base = baseTable, roblox = robloxTable})

	return serialized
end

local function deserialize(s)
	local deserialized = HttpService:JSONDecode(s)
	local base, roblox = deserialized.base, deserialized.roblox
	for k, serialized in next, roblox do
		local _, deserialized = deserializeRobloxData(serialized)
		roblox[k] = deserialized
	end

	do
		local visited = {}
		local toVisit = {base}
		while true do
			local current = table.remove(toVisit)
			if not current then
				break
			end
			visited[current] = true
			for k, v in next, current do
				local vType = typeof(v)
				if vType == "table" then
					if not visited[v] then
						table.insert(toVisit, v)
					end
				elseif vType == "string" then
					local deserializedMatch = roblox[v]
					if deserializedMatch then
						current[k] = deserializedMatch
					end
				end
			end
		end
	end

	return base
end

return {
	serialize = serialize,
	deserialize = deserialize
}
