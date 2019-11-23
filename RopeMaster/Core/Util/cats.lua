-- lerps from a to b with given alpha
local function lerp(a, b, alpha)
	return a + (b - a) * alpha
end

-- bisection search
-- looks for the root of f that's between a and b
-- with a tolerance of e.
-- Optional starting point c, which much be between a and b. default (a+b)/2
-- optional retry limit of retries (default 10). If the algo exceeds this number
-- of retries then it returns whatever the last answer was.
local function bisection(f, a, b, e, c, retries)
	c = c or (a + b) / 2
	retries = retries or 10
	local iter = 0
	while (b - a) / 2 > e and iter < retries do
		iter = iter + 1
		local fc = f(c)
		if fc == 0 then
			return c
		elseif f(a) * fc < 0 then
			b = c
		else
			a = c
		end
		c = (a + b) / 2.0
	end

	return c
end

local VERTICAL_TOLERANCE = 1e-4
local FAR_TOLERANCE = 1e-4

local function are_points_vertical(a, b)
	return math.abs(a[1] - b[1]) < VERTICAL_TOLERANCE
end

local function are_points_too_far(a, b, r_length)
	local delta_x = a[1] - b[1]
	local delta_y = a[2] - b[2]
	return math.sqrt(delta_x ^ 2 + delta_y ^ 2) > r_length + FAR_TOLERANCE
end

-- adapted from
-- https://www.mathworks.com/matlabcentral/fileexchange/38550-catenary-hanging-rope-between-two-points
-- returns two functions, f, and df.
-- f takes an alpha and returns the offset from a.
-- df takes an alpha and returns the slope from a.
-- if a and b are farther than r_length, or a and b are completely vertical, then this
-- will error.
local catfuncs
do
	local MAX_ITER = 1000
	local MIN_GRAD = 1e-10
	local MIN_VAL = 1e-8
	local STEP_DEC = 0.5
	local MIN_STEP = 1e-9
	catfuncs = function(a, b, r_length)
		local abs = math.abs
		local sqrt = math.sqrt
		local sinh = math.sinh
		local cosh = math.cosh
		local log = math.log

		if are_points_too_far(a, b, r_length) then
			error("a and b are too far apart.")
		end

		if are_points_vertical(a, b) then
			error("a and b are completely vertical")
		end

		local sag = 1
		local flipped = false
		if a[1] > b[1] then
			a, b = b, a
			flipped = true
		end
		local a_x, b_x, a_y, b_y = a[1], b[1], a[2], b[2]

		local d = b_x - a_x
		local h = b_y - a_y

		local delta_x = b_x - a_x

		local g = function(s)
			return 2 * sinh(s * d / 2) / s - sqrt(r_length ^ 2 - h ^ 2)
		end
		local dg = function(s)
			return 2 * cosh(s * d / 2) * d / (2 * s) - 2 * sinh(s * d / 2) / (s ^ 2)
		end

		local iters = 0
		for _ = 1, MAX_ITER do
			iters = iters + 1
			local val = g(sag)
			local grad = dg(sag)
			if abs(val) < MIN_VAL or abs(grad) < MIN_GRAD then
				break
			end

			local search = -val / grad
			local alpha = 1
			local sag_new = sag + alpha * search

			while sag_new < 0 or abs(g(sag_new)) > abs(val) do
				alpha = STEP_DEC * alpha
				if alpha < MIN_STEP then
					break
				end

				sag_new = sag + alpha * search
			end

			sag = sag_new
		end

		local x_left = 1 / 2 * (log((r_length + h) / (r_length - h)) / sag - d)
		local x_min = a_x - x_left
		local bias = a_y - cosh(x_left * sag) / sag

		if not flipped then
			return function(alpha)
				local x = a_x + delta_x * alpha
				return x, cosh((x - x_min) * sag) / sag + bias
			end, function(alpha)
				local x = (a_x + delta_x * alpha) - x_min
				return sinh(sag * x)
			end, function(alpha)
				local x = (a_x + delta_x * alpha) - x_min
				return sag * cosh(sag * x)
			end
		else
			return function(alpha)
				alpha = 1 - alpha
				local x = a_x + delta_x * alpha
				return x, cosh((x - x_min) * sag) / sag + bias
			end, function(alpha)
				alpha = 1 - alpha
				local x = (a_x + delta_x * alpha) - x_min
				return sinh(sag * x)
			end, function(alpha)
				alpha = 1 - alpha
				local x = (a_x + delta_x * alpha) - x_min
				return sag * cosh(sag * x)
			end
		end
	end
end

-- plots points given f and df, such that
-- the change in angle between the points are the same.
local function catplot_solve_angle(f, df, count, start_a, fin_a)
	assert(count > 1)

	start_a = start_a or 0
	fin_a = fin_a or 1

	local pts = {}
	pts[1] = start_a
	pts[count] = fin_a

	local start = math.atan(df(start_a))
	local fin = math.atan(df(fin_a))
	local last = start_a
	for i = 2, count - 1 do
		local target = lerp(start, fin, (i - 1) / (count - 1))
		local ans =
			bisection(
			function(ans)
				local slope = df(ans)
				return math.atan(slope) - target
			end,
			last,
			fin_a,
			1e-5,
			lerp(last, fin_a, 1 / (count - i + 1), 10)
		)
		last = ans
		pts[i] = ans
	end
	return pts
end

-- plots points given f and df, such that
-- the change in arc length between the points are the same.
local function catplot_solve_arc(f, df, count, start_a, fin_a)
	assert(count > 1)

	start_a = start_a or 0
	fin_a = fin_a or 1

	local pts = {}
	pts[1] = start_a
	local start = df(start_a)
	local fin = df(fin_a)
	local last = start_a
	for i = 2, count do
		local target = lerp(start, fin, (i - 1) / (count - 1))
		local ans =
			bisection(
			function(ans)
				local slope = df(ans)
				return slope - target
			end,
			last,
			fin_a,
			1e-5,
			lerp(last, fin_a, 1 / (count - i + 1), 10)
		)
		last = ans
		pts[i] = ans
	end

	pts[count] = fin_a
	return pts
end

--local function catplot_solve_chord(f, df, count, start_a, fin_a)
--	assert(count > 1)
--
--	start_a = start_a or 0
--	fin_a = fin_a or 1
--
--	local a, b = 0, fin_a-start_a
--	local clen = (b-a)/2
--	local pts
--	local chord_iters = 0
--	while (b-a)/2 > 0.0001 do
--		pts = {}
--		pts[1] = start_a
--		pts[count] = fin_a
--
--		local last = start_a
--		local fin_iter
--		for i = 2, count-1 do
--			local last_x, last_y = f(last)
--			local ans = bisection(
--				function(ans)
--					local x, y = f(ans)
--					local dist = math.sqrt((x-last_x)^2 + (y-last_y)^2)
--					return dist-clen
--				end,
--				last, fin_a, 1e-5, lerp(last, fin_a, 1/(count-i+1), 10)
--			)
--			last = ans
--			pts[i] = ans
--			if ans > fin_a then
--				break
--			end
--			fin_iter = i
--		end
--
--		if fin_iter < count-1 then
--			b = clen
--		else
--			a = clen
--		end
--		clen = (a+b)/2
--		chord_iters = chord_iters + 1
--	end
--
--	return pts
--end

--local function catplot_autochord(a, b, len, chord_len)
--	local count = Round(len/chord_len)+1
--	local min_len, max_len = 0, len*2
--
--	local f, df
--	local pts
--	local iters = 0
--	while (max_len-min_len)/2 > 1e-5 do
--		iters = iters+1
--		pts = {}
--		pts[1] = 0
--		f, df = catfuncs(a, b, len)
--		local last = 0
--		for i = 2, count do
--			local last_pt = {f(last)}
--			local ans = bisection(
--				function(ans)
--					local x, y = f(ans)
--					local dist = point_dist({x, y}, last_pt)
--					return dist-chord_len
--				end,
--				last, 2, 1e-5, nil, 100
--			)
--			last = ans
--			pts[i] = ans
--		end
--
--		if last < 1 then
--			max_len = len
--		else
--			min_len = len
--		end
--		len = (min_len+max_len)/2
--	end
--
--	pts[count] = 1
--	return f, df, len, count, pts
--end

return {
	are_points_vertical = are_points_vertical,
	are_points_too_far = are_points_too_far,
	catfuncs = catfuncs,
	catplot_solve_angle = catplot_solve_angle,
	catplot_solve_arc = catplot_solve_arc
	--	catplot_solve_chord = catplot_solve_chord,
	--	catplot_autochord = catplot_autochord
}
