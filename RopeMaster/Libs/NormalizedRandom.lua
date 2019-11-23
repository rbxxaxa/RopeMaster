local NormalizedRandom = {}
NormalizedRandom.__index = NormalizedRandom

function NormalizedRandom.new(seed)
	local self = {}
	setmetatable(self, NormalizedRandom)

	self.r = seed and Random.new(seed) or Random.new()

	return self
end

function NormalizedRandom:NextNumber(min, max)
	if min == nil and max == nil then
		min, max = 0, 1
	end

	assert(max >= min)

	return min + self.r:NextNumber(0, 1) * (max - min)
end

function NormalizedRandom:NextInteger(min, max)
	assert(max >= min)
	assert(max % 1 == 0 and min % 1 == 0)

	return min + math.floor(self.r:NextNumber(0, 1) * (max - min + 1))
end

return NormalizedRandom
