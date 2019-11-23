local cats = require(script.Parent.cats)

local function lerp(a, b, alpha)
	return a + (b - a) * alpha
end

local catfuncs = cats.catfuncs
local catplot_solve_arc = cats.catplot_solve_arc
-- local catplot_solve_angle = cats.catplot_solve_angle

local UP = Vector3.new(0, 1, 0)
local VERTICAL_AVOIDANCE_FUDGE = 0.01
-- returns the point interpolated from the start of the path to the end.
local function trace_path(path, a)
	local vertices = path.vertices
	local pers = path.pers
	assert(a >= 0)
	assert(a <= 1)
	if pers == 0 then
		return vertices[1]
	end
	if pers == 1 then
		return vertices[#vertices]
	end

	for i, v in next, vertices do
		local per = pers[i]
		if per >= a or i == #vertices then
			if i == 1 then
				local next_v = vertices[i]
				local percent_in_segment = 0
				local p_0 = v
				local p_1 = next_v
				local p = lerp(p_0, p_1, percent_in_segment)
				local look = (p_1 - p_0).unit
				local right = look:Cross(UP).unit
				local up = right:Cross(look).unit
				return CFrame.fromMatrix(p, right, up, look)
			else
				local prev_v = vertices[i - 1]
				local prev_per = pers[i - 1]
				local percent_in_segment = (a - prev_per) / (per - prev_per)
				local p_0 = prev_v
				local p_1 = v
				local p = lerp(p_0, p_1, percent_in_segment)
				local look = (p_1 - p_0).unit
				local right = look:Cross(UP).unit
				local up = right:Cross(look).unit
				return CFrame.fromMatrix(p, right, up, look)
			end
		end
	end
end

local function create_simple_line_path(v0, v1)
	local look = (v1 - v0).unit
	local right
	if v0.X == v1.X and v0.Z == v1.Z then
		right = Vector3.new(1, 0, 0)
	else
		right = look:Cross(UP).unit
	end
	local start = v0
	--CFrame.fromMatrix(v0, right, up)
	local fin = v1
	--CFrame.fromMatrix(v1, right, up)
	local path = {}
	path.length = (v1 - v0).magnitude
	path.vertices = {start, fin}
	path.rights = {right, right}
	path.pers = {0, 1}

	return path
end

local function create_catenary_path(v0, v1, f, df, sols)
	-- nudge the second point horizontally when the points are perfectly vertical
	-- so that we don't glitch out.
	local vertical = false
	if v0.X == v1.X and v0.Z == v1.Z then
		vertical = true
		v1 = v1 + Vector3.new(0.001, 0, 0)
	end

	local dir = (v1 - v0) * Vector3.new(1, 0, 1)
	dir = dir.unit
	local dir_x, dir_z = dir.x, dir.z

	local total_length = 0
	local prev = nil
	for i = 1, #sols do
		local sol = sols[i]
		local x, y = f(sol)
		if prev == nil then
			prev = Vector2.new(x, y)
		else
			local v = Vector2.new(x, y)
			local dist = (v - prev).magnitude
			total_length = total_length + dist
			prev = v
		end
	end

	local path = {}
	path.length = total_length
	prev = nil
	local per = 0
	local vertices = {}
	path.vertices = vertices
	local pers = {}
	path.pers = pers
	local rights = {}
	path.rights = rights
	local right = (v1 - v0):Cross(Vector3.new(0, 1, 0)).unit
	for i, sol in next, sols do
		local x, y = f(sol)
		local p
		if vertical then
			p = v0 + Vector3.new(0, y, 0)
		else
			p = v0 + Vector3.new(dir_x * x, y, dir_z * x)
		end
		local v = Vector2.new(x, y)
		if prev ~= nil then
			local dist_from_prev = (v - prev).magnitude
			per = per + dist_from_prev / total_length
		end
		prev = v
		vertices[i] = p
		--CFrame.fromMatrix(p, right, up, look)
		pers[i] = per
		rights[i] = right
	end

	return path
end

local function create_arc_path(v0, v1, len, link_count)
	assert(link_count > 0)

	local a = {0, 0}
	local b = {(math.sqrt((v0.X - v1.X) ^ 2 + (v0.Z - v1.Z) ^ 2)), v1.Y - v0.Y}
	if cats.are_points_vertical(a, b) then
		b[1] = VERTICAL_AVOIDANCE_FUDGE
	end

	local dist2 = b[1] ^ 2 + b[2] ^ 2
	if dist2 > len ^ 2 then
		len = math.sqrt(dist2) + 0.01
	end

	local f, df = catfuncs(a, b, len)
	local sols = catplot_solve_arc(f, df, link_count + 1)
	return create_catenary_path(v0, v1, f, df, sols)
end

local function GetAngleBetweenVectors(start, goal)
	local dot = start:Dot(goal)
	local angle = math.acos(math.clamp(dot / (start.magnitude * goal.magnitude), -1, 1))
	return angle
end

local function smartify_path(sample_path, target_angle, target_length)
	local samples = sample_path.vertices
	local sample_count = #samples
	local sample_rights = sample_path.rights
	local new_path = {}
	local vertices = {samples[1], samples[sample_count]}
	local rights = {sample_rights[1], sample_rights[sample_count]}
	local pers = {0, 1}
	new_path.vertices = vertices
	new_path.rights = rights
	new_path.pers = pers
	local left_previous_look = (samples[2] - samples[1]).unit
	local right_previous_look = (samples[sample_count] - samples[sample_count - 1]).unit
	local left_sample_idx = 2
	local right_sample_idx = sample_count - 1
	local accumulated_delta = 0
	local accumulated_angle = 0
	local currentDirection = 1
	while true do
		if currentDirection == 1 then
			-- it would technically be more correct to break
			-- after checking if the current vertex should be inserted
			-- but if we let it get inserted then the final segment
			-- will be very short.
			if left_sample_idx == right_sample_idx then
				break
			end
			local point = samples[left_sample_idx]
			local right = sample_rights[left_sample_idx]
			local delta_from_previous = point - samples[left_sample_idx - 1]
			local dist_from_previous = (delta_from_previous).magnitude
			local look = delta_from_previous.unit
			local angle_from_previous = GetAngleBetweenVectors(left_previous_look, look)
			left_previous_look = look
			accumulated_delta = accumulated_delta + dist_from_previous
			accumulated_angle = accumulated_angle + angle_from_previous
			if accumulated_delta > target_length and accumulated_angle > target_angle then
				accumulated_delta = 0
				accumulated_angle = 0
				table.insert(vertices, math.ceil(#vertices / 2) + 1, point)
				table.insert(rights, math.ceil(#vertices / 2) + 1, right)
				currentDirection = 2
			end
			left_sample_idx = left_sample_idx + 1
		elseif currentDirection == 2 then
			if left_sample_idx == right_sample_idx then
				break
			end
			local point = samples[right_sample_idx]
			local right = sample_rights[left_sample_idx]
			local delta_from_previous = point - samples[right_sample_idx + 1]
			local dist_from_previous = (delta_from_previous).magnitude
			local look = -delta_from_previous.unit
			local angle_from_previous = GetAngleBetweenVectors(right_previous_look, look)
			right_previous_look = look
			accumulated_delta = accumulated_delta + dist_from_previous
			accumulated_angle = accumulated_angle + angle_from_previous
			if accumulated_delta > target_length and accumulated_angle > target_angle then
				accumulated_delta = 0
				accumulated_angle = 0
				table.insert(vertices, math.ceil(#vertices / 2) + 1, point)
				table.insert(rights, math.ceil(#vertices / 2) + 1, right)
				currentDirection = 1
			end
			right_sample_idx = right_sample_idx - 1
		end
	end

	local length_so_far = 0
	for i = 2, #vertices do
		length_so_far = length_so_far + (vertices[i - 1] - vertices[i]).magnitude
		pers[i] = length_so_far
	end

	local total_length = length_so_far
	for i = 2, #vertices do
		pers[i] = pers[i] / total_length
	end

	return new_path
end

local function create_smart_catenary_path(v0, v1, len, target_angle, target_length)
	-- if the points are closer than 0.001 in the x or z axis, then space them apart.
	local x_delta = v1.X - v0.X
	if x_delta > 0 and x_delta < 0.001 then
		v1 = v1 + Vector3.new(0.001 - x_delta, 0, 0)
	elseif x_delta <= 0 and x_delta > -0.001 then
		v1 = v1 + Vector3.new(-0.001 - x_delta, 0, 0)
	end

	local z_delta = v1.Z - v0.Z
	if z_delta > 0 and z_delta < 0.001 then
		v1 = v1 + Vector3.new(0.001 - z_delta, 0, 0)
	elseif z_delta <= 0 and z_delta > -0.001 then
		v1 = v1 + Vector3.new(-0.001 - z_delta, 0, 0)
	end

	local sample_path = create_arc_path(v0, v1, len, 400)
	local new_path = smartify_path(sample_path, target_angle, target_length)

	return new_path
end

local function create_simple_rectangular_loop_path(center, up, right, x, y)
	local look = up:Cross(right).unit
	local path = {}
	local length = x * 2 + y * 2
	path.length = length
	local v0 = center + right * x / 2 + look * y / 2
	local v1 = center + -right * x / 2 + look * y / 2
	local v2 = center + -right * x / 2 + -look * y / 2
	local v3 = center + right * x / 2 + -look * y / 2
	path.vertices = {
		v0,
		v1,
		v2,
		v3,
		v0
	}

	path.rights = {
		up,
		up,
		up,
		up,
		up
	}

	path.pers = {
		0,
		x / length,
		(x + y) / length,
		(x + y + x) / length,
		1
	}

	return path
end

local function create_round_angle_loop_path(center, up, right, x, y, segment_count)
	local look = up:Cross(right).unit
	local path = {}
	local vertices = {}
	path.vertices = vertices
	local rights = {}
	path.rights = rights
	local pers = {}
	path.pers = pers

	--	table.insert(vertices, v0)
	--	local length_so_far = 0
	--	table.insert(pers, length_so_far)
	--	table.insert(rights, -up)

	local count = segment_count + 1
	for i = 0, count do
		local theta = math.pi * 2 * i / count
		local x_fac = math.cos(theta)
		local y_fac = math.sin(theta)
		local right_off = right * x / 2 * x_fac
		local look_off = -look * y / 2 * y_fac
		local v = center + right_off + look_off
		table.insert(vertices, v)
		table.insert(rights, -up)
	end

	local totalLength = 0
	local prev = vertices[1]
	for i = 2, #vertices do
		local dist = (vertices[i] - prev).magnitude
		totalLength = totalLength + dist
		prev = vertices[i]
	end

	pers[1] = 0
	pers[count] = 1
	prev = vertices[1]
	local distSoFar = 0
	for i = 2, #vertices - 1 do
		local dist = (vertices[i] - prev).magnitude
		distSoFar = dist + distSoFar
		local per = distSoFar / totalLength
		pers[i] = per
		prev = vertices[i]
	end

	return path
end

local function create_smart_round_loop_path(center, up, right, x, y, target_angle, target_length)
	local sample_path = create_round_angle_loop_path(center, up, right, x, y, 400)
	local new_path = smartify_path(sample_path, target_angle, target_length)
	if #new_path.vertices >= 5 then
		return new_path
	else
		return create_round_angle_loop_path(center, up, right, x, y, 3)
	end
end

return {
	trace_path = trace_path,
	create_simple_rectangular_loop_path = create_simple_rectangular_loop_path,
	create_simple_line_path = create_simple_line_path,
	create_smart_catenary_path = create_smart_catenary_path,
	create_smart_round_loop_path = create_smart_round_loop_path
}

-- Obsolete, broken stuff goes here.

-- Sometimes creates vertices than expected.
-- Not really useful, anyway, since we have smart_loops now.
-- local function create_round_arc_loop_path(center, up, right, x, y, segment_count)
-- 	local look = up:Cross(right).unit
-- 	local path = {}
-- 	local vertices = {}
-- 	path.vertices = vertices
-- 	local rights = {}
-- 	path.rights = rights
-- 	local pers = {}
-- 	path.pers = pers

-- 	--	table.insert(vertices, v0)
-- 	--	local length_so_far = 0
-- 	--	table.insert(pers, length_so_far)
-- 	--	table.insert(rights, -up)

-- 	local sample_points = {}
-- 	local sample_count = math.max(100, segment_count * 2)
-- 	for i = 0, sample_count do
-- 		local theta = math.pi * 2 * ((i / sample_count) % sample_count)
-- 		local x_fac = math.cos(theta)
-- 		local y_fac = math.sin(theta)
-- 		local right_off = right * x / 2 * x_fac
-- 		local look_off = -look * y / 2 * y_fac
-- 		local v = center + right_off + look_off
-- 		table.insert(sample_points, v)
-- 	end

-- 	local sample_pos_along = {}
-- 	sample_pos_along[1] = 0
-- 	local sample_length = 0
-- 	for i = 2, #sample_points do
-- 		local dist = (sample_points[i - 1] - sample_points[i]).magnitude
-- 		sample_length = sample_length + dist
-- 		sample_pos_along[i] = sample_length
-- 	end

-- 	local segment_length = sample_length / segment_count
-- 	table.insert(vertices, sample_points[1])
-- 	table.insert(rights, -up)
-- 	local current_sample_idx = 2
-- 	for i = 1, segment_count do
-- 		local target_length = segment_length * i
-- 		while current_sample_idx <= #sample_points do
-- 			local left_sample_along = sample_pos_along[current_sample_idx - 1]
-- 			local right_sample_along = sample_pos_along[current_sample_idx]
-- 			if left_sample_along < target_length and right_sample_along >= target_length then
-- 				local delta = right_sample_along - left_sample_along
-- 				local target_in_sample = target_length - left_sample_along
-- 				local per_in_sample = target_in_sample / delta
-- 				local left_sample = sample_points[current_sample_idx - 1]
-- 				local right_sample = sample_points[current_sample_idx]
-- 				local final_vert = left_sample:lerp(right_sample, per_in_sample)
-- 				table.insert(vertices, final_vert)
-- 				table.insert(rights, -up)
-- 				break
-- 			else
-- 				current_sample_idx = current_sample_idx + 1
-- 			end
-- 		end
-- 	end

-- 	local totalLength = 0
-- 	local dists = {}
-- 	for i = 1, #vertices - 1 do
-- 		local v0 = path.vertices[i]
-- 		local v1 = path.vertices[i + 1]
-- 		local dist = (v1 - v0).magnitude
-- 		dists[i] = totalLength
-- 		totalLength = totalLength + dist
-- 	end

-- 	path.length = totalLength

-- 	for i = 1, #vertices - 1 do
-- 		path.pers[i] = dists[i] / totalLength
-- 	end
-- 	path.pers[#vertices] = 1

-- 	return path
-- end

-- Obsolete
-- local function create_segmented_rectangular_loop_path(center, up, right, x, y, segment_length)
-- 	local look = up:Cross(right).unit
-- 	local path = {}
-- 	local length = x * 2 + y * 2
-- 	path.length = length
-- 	local v0 = center + right * x / 2 + look * y / 2
-- 	local v1 = center + right * x / 2 + -look * y / 2
-- 	local v2 = center + -right * x / 2 + -look * y / 2
-- 	local v3 = center + -right * x / 2 + look * y / 2
-- 	local x_segments = math.ceil(x / segment_length)
-- 	local y_segments = math.ceil(y / segment_length)
-- 	local x_segment_length = x / x_segments
-- 	local y_segment_length = y / y_segments
-- 	local vertices = {}
-- 	path.vertices = vertices
-- 	local rights = {}
-- 	path.rights = rights
-- 	local pers = {}
-- 	path.pers = pers

-- 	table.insert(vertices, v0)
-- 	local length_so_far = 0
-- 	table.insert(pers, length_so_far)
-- 	table.insert(rights, -up)
-- 	for i = 1, y_segments do
-- 		table.insert(vertices, v0:Lerp(v1, i / y_segments))
-- 		length_so_far = length_so_far + y_segment_length
-- 		table.insert(pers, length_so_far / length)
-- 		table.insert(rights, -up)
-- 	end

-- 	for i = 1, x_segments do
-- 		table.insert(vertices, v1:Lerp(v2, i / x_segments))
-- 		length_so_far = length_so_far + x_segment_length
-- 		table.insert(pers, length_so_far / length)
-- 		table.insert(rights, -up)
-- 	end

-- 	for i = 1, y_segments do
-- 		table.insert(vertices, v2:Lerp(v3, i / y_segments))
-- 		length_so_far = length_so_far + y_segment_length
-- 		table.insert(pers, length_so_far / length)
-- 		table.insert(rights, -up)
-- 	end

-- 	for i = 1, x_segments do
-- 		table.insert(vertices, v3:Lerp(v0, i / x_segments))
-- 		length_so_far = length_so_far + x_segment_length
-- 		table.insert(pers, length_so_far / length)
-- 		table.insert(rights, -up)
-- 	end

-- 	return path
-- end

-- Obsolete
-- local function create_constant_arc_path(v0, v1, len, arc_len)
-- 	local link_count = math.ceil(len / arc_len)
-- 	--	len = link_count*arc_len
-- 	--	print(oldLen-len)
-- 	return create_arc_path(v0, v1, len, link_count)
-- end

-- Obsolete
-- local function create_segmented_line_path(v0, v1, link_count)
-- 	local look = (v1 - v0).unit
-- 	local right
-- 	if v0.X == v1.X and v0.Z == v1.Z then
-- 		right = Vector3.new(1, 0, 0)
-- 	else
-- 		right = look:Cross(UP).unit
-- 	end
-- 	local path = {}
-- 	path.length = (v1 - v0).magnitude
-- 	path.vertices = {}
-- 	path.rights = {}
-- 	path.pers = {}

-- 	local vert_count = link_count + 1
-- 	for i = 0, vert_count do
-- 		table.insert(path.vertices, lerp(v0, v1, i / vert_count))
-- 		table.insert(path.pers, i / vert_count)
-- 		table.insert(path.rights, right)
-- 	end

-- 	return path
-- end

-- Obsolete.
-- local function create_angle_path(v0, v1, len, link_count)
-- 	assert(link_count > 0)

-- 	local a = {0, 0}
-- 	local b = {(math.sqrt((v0.X - v1.X) ^ 2 + (v0.Z - v1.Z) ^ 2)), v1.Y - v0.Y}
-- 	if cats.are_points_vertical(a, b) then
-- 		b[1] = VERTICAL_AVOIDANCE_FUDGE
-- 	end

-- 	local dist2 = b[1] ^ 2 + b[2] ^ 2
-- 	if dist2 > len ^ 2 then
-- 		len = math.sqrt(dist2) + 0.01
-- 	end

-- 	local f, df = catfuncs(a, b, len)
-- 	local sols = catplot_solve_angle(f, df, link_count + 1)
-- 	return create_catenary_path(v0, v1, f, df, sols)
-- end

-- Obsolete
-- local function create_constant_angle_path(v0, v1, len, angle)
-- 	local a = {0, 0}
-- 	local b = {(math.sqrt((v0.X - v1.X) ^ 2 + (v0.Z - v1.Z) ^ 2)), v1.Y - v0.Y}
-- 	if cats.are_points_vertical(a, b) then
-- 		b[1] = VERTICAL_AVOIDANCE_FUDGE
-- 	end

-- 	local dist2 = b[1] ^ 2 + b[2] ^ 2
-- 	if dist2 > len ^ 2 then
-- 		len = math.sqrt(dist2) + 0.01
-- 	end

-- 	local _, df = catfuncs(a, b, len)
-- 	local slope_start = df(0)
-- 	local slope_end = df(1)
-- 	local theta_0 = math.atan(slope_start)
-- 	local theta_1 = math.atan(slope_end)
-- 	local delta = math.abs(theta_0 - theta_1)
-- 	local link_count = math.ceil(delta / angle)
-- 	return create_angle_path(v0, v1, len, link_count)
-- end
