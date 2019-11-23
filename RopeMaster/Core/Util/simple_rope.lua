local function GetAngleBetweenVectors(start, goal)
	local dot = start:Dot(goal)
	local angle = math.acos(math.clamp(dot / (start.magnitude * goal.magnitude), -1, 1))
	return angle
end

local function simple_rope(path, ropeHeight, createShaft)
	local vertices = path.vertices
	local rights = path.rights
	for i = 1, #vertices - 1 do
		local p_0 = vertices[i]
		local p_1 = vertices[i + 1]
		local dist = (p_0 - p_1).magnitude
		local look = (p_1 - p_0).unit
		local right = rights[i]
		local up = right:Cross(look).unit

		local left_ext, right_ext = 0, 0
		if i ~= 1 then
			local p_before = vertices[i - 1]
			local before_look = (p_0 - p_before).unit
			local before_angle = GetAngleBetweenVectors(before_look, look) / 2
			local hyp = ropeHeight / math.cos(before_angle)
			left_ext = math.sin(before_angle) * hyp
		end
		if i ~= #vertices - 1 then
			local p_2 = vertices[i + 2]
			local after_look = (p_2 - p_1).unit
			local after_angle = GetAngleBetweenVectors(look, after_look) / 2
			local hyp = ropeHeight / math.cos(after_angle)
			right_ext = math.sin(after_angle) * hyp
		end
		left_ext = math.abs(left_ext)
		right_ext = math.abs(right_ext)

		local final_p = p_0 - up * ropeHeight / 2 + look * (dist + right_ext - left_ext) / 2
		local final_length = dist + left_ext + right_ext
		createShaft(i, final_p, right, up, final_length)
	end
end

return simple_rope
