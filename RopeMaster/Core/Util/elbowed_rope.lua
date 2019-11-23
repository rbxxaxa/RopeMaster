local function GetAngleBetweenVectors(start, goal)
	local dot = start:Dot(goal)
	local angle = math.acos(math.clamp(dot / (start.magnitude * goal.magnitude), -1, 1))
	return angle
end

local function elbowed_rope(path, ropeHeight, createShaft, createElbow, createStartCap, createEndCap)
	local vertices = path.vertices
	local rights = path.rights
	for i = 1, #vertices - 1 do
		local p_0 = vertices[i]
		local p_1 = vertices[i + 1]
		local p = (p_0 + p_1) / 2
		local dist = (p_0 - p_1).magnitude
		local look = (p_1 - p_0).unit
		local right = rights[i]
		local up = right:Cross(look).unit
		createShaft(i, p - up * ropeHeight / 2, right, up, dist)

		if i == 1 and createStartCap then
			createStartCap(p_0 - up * ropeHeight / 2, right, up)
		end

		if i ~= #vertices - 1 then
			local p_2 = vertices[i + 2]
			local nextLook = (p_2 - p_1).unit
			if look:Cross(nextLook).magnitude > 0.0001 then
				local elbowUp = (-look):lerp(nextLook, 0.5).unit
				local angle_half = GetAngleBetweenVectors(up, elbowUp)
				local hyp = ropeHeight
				local true_length = hyp * math.sin(angle_half) * 2
				local true_height = hyp * math.cos(angle_half)
				local right = (look:Cross(elbowUp)).unit

				createElbow(i, p_1 - elbowUp * true_height / 2, right, elbowUp, true_length, true_height)
			end
		end

		if i == #vertices - 1 and createEndCap then
			createEndCap(p_1 - up * ropeHeight / 2, right, up)
		end
	end
end

return elbowed_rope
