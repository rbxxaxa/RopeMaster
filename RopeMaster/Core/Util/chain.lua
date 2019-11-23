local function chain(path, createChain)
	local vertices = path.vertices
	local rights = path.rights
	local pathlen = #vertices
	for i = 1, pathlen - 1 do
		local p_0 = vertices[i]
		local p_1 = vertices[i + 1]
		local p = (p_0 + p_1) / 2
		local look = (p_1 - p_0).unit
		local right = rights[i]
		local up = right:Cross(look).unit
		createChain(i, p, right, up)
	end
end

return chain
