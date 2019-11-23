local wrapStrictTable = require(script.Parent.wrapStrictTable)

local Types = {}

Types.LockTo = {
	NONE = 1,
	PART_CENTERS = 2,
	GRID = 3,
	MIDPOINTS = 4,
	ATTACHMENTS = 5
}

Types.Curve = {
	CATENARY = 1,
	LINE = 2,
	LOOP = 3
}

Types.CatenaryLengthMode = {
	RELATIVE = 1,
	FIXED = 2
}

Types.LoopShape = {
	CIRCLE = 1,
	RECTANGLE = 2
}

Types.Preset = {
	BUILTIN = 1,
	INTERNAL = 2,
	CUSTOM = 3
}
Types.Rope = {
	ROPE = 1,
	CHAIN = 2
}

local ropeTypeToNameMapping = {
	"Rope",
	"Chain"
}

function Types.GetRopeNameFromRopeType(ropeType)
	return ropeTypeToNameMapping[ropeType]
end

Types.RopeTexture = {
	NONE = 1,
	REALISTIC_ROPE = 2,
	CARTOON_ROPE = 3,
	CUSTOM = 4
}

Types.Material = {
	PLASTIC = 1,
	WOOD = 2,
	SLATE = 3,
	CONCRETE = 4,
	CORRODEDMETAL = 5,
	DIAMONDPLATE = 6,
	FOIL = 7,
	GRASS = 8,
	ICE = 9,
	MARBLE = 10,
	GRANITE = 11,
	BRICK = 12,
	PEBBLE = 13,
	SAND = 14,
	FABRIC = 15,
	SMOOTHPLASTIC = 16,
	METAL = 17,
	WOODPLANKS = 18,
	COBBLESTONE = 19,
	NEON = 20,
	GLASS = 21,
	FORCEFIELD = 22
}

local em = Enum.Material
local materialTypeToEnumMapping = {
	em.Plastic,
	em.Wood,
	em.Slate,
	em.Concrete,
	em.CorrodedMetal,
	em.DiamondPlate,
	em.Foil,
	em.Grass,
	em.Ice,
	em.Marble,
	em.Granite,
	em.Brick,
	em.Pebble,
	em.Sand,
	em.Fabric,
	em.SmoothPlastic,
	em.Metal,
	em.WoodPlanks,
	em.Cobblestone,
	em.Neon,
	em.Glass,
	em.ForceField
}

Types.GetMaterialEnumFromMaterialType = function(materialType)
	return materialTypeToEnumMapping[materialType]
end

Types.ChainSegmentType = {
	CHAIN_SMOOTH = 1,
	CHAIN_SHARP = 2,
	GARLAND = 3,
	CUSTOM = 4
}

Types.Axis = {
	X = 1,
	Y = 2,
	Z = 3
}

Types.GetAxisNameFromAxisType = function(axisType)
	if axisType == 1 then
		return "X"
	elseif axisType == 2 then
		return "Y"
	else
		return "Z"
	end
end

Types.CarnivalFlagStyle = {
	DETAILED = 1,
	FLAT = 2
}

Types.GetStringFromCarnivalFlagStyleType = function(carnivalFlagStyleType)
	if carnivalFlagStyleType == Types.CarnivalFlagStyle.DETAILED then
		return "Detailed"
	else
		return "Flat"
	end
end

Types.RopeStyle = {
	SQUARE_SHARP = 1,
	SQUARE_SMOOTH = 2,
	DIAMOND_SHARP = 3,
	DIAMOND_SMOOTH = 4,
	ROUND_SHARP = 5,
	ROUND_SMOOTH = 6
}

Types.TextureMode = {
	REPEAT = 1,
	STRETCH = 2
}

Types.RopePartCount = {
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3
}

return wrapStrictTable(Types, "Types")
