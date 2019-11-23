local function GetAngleBetweenVectors(start, goal)
	local dot = start:Dot(goal)
	local angle = math.acos(math.clamp(dot / (start.magnitude * goal.magnitude), -1, 1))
	return angle
end

local function elbowed_loop(path, ropeHeight, createShaft, createElbow, createStartCap, createEndCap)
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

		if i ~= #vertices - 1 then
			local p_2 = vertices[i + 2]
			local nextLook = (p_2 - p_1).unit
			if look:Cross(nextLook).magnitude > 0.00001 then
				local elbowUp = (-look):lerp(nextLook, 0.5).unit
				local angle_half = GetAngleBetweenVectors(up, elbowUp)
				local hyp = ropeHeight
				local true_length = hyp * math.sin(angle_half) * 2
				local true_height = hyp * math.cos(angle_half)
				local right = (look:Cross(elbowUp)).unit

				createElbow(i, p_1 - elbowUp * true_height / 2, right, elbowUp, true_length, true_height)
			end
		end
	end

	-- create the final elbow that closes the loop
	do
		local p_0 = vertices[#vertices - 1]
		local p_1 = vertices[1]
		local p_2 = vertices[2]
		local look = (p_1 - p_0).unit
		local nextLook = (p_2 - p_1).unit
		local right = look:Cross(nextLook).unit
		local up = right:Cross(look).unit
		if look:Cross(nextLook).magnitude > 0.00001 then
			local elbowUp = (-look):lerp(nextLook, 0.5).unit
			local angle_half = GetAngleBetweenVectors(up, elbowUp)
			local hyp = ropeHeight
			local true_length = hyp * math.sin(angle_half) * 2
			local true_height = hyp * math.cos(angle_half)
			local right = (look:Cross(elbowUp)).unit

			createElbow(#vertices, p_1 - elbowUp * true_height / 2, right, elbowUp, true_length, true_height)
		end
	end
end

return elbowed_loop
