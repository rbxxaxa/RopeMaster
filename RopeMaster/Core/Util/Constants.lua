local Plugin = script.Parent.Parent.Parent
local InstanceStorage = Plugin.InstanceStorage

local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)
local Types = require(Plugin.Core.Util.Types)

local Constants = {}

Constants.DEBUG_LABEL = "RopeMaster"
Constants.PLUGIN_MIN_WIDTH = 320
Constants.TOOLBAR_ICON = "rbxassetid://3578081823"
Constants.MAIN_ICON = "rbxassetid://0"
Constants.PLUGIN_PRODUCT_ID = 3585926833
Constants.PLUGIN_VERSION = "0.0.6"

-- Fields
Constants.DEFAULT_LABEL_WIDTH = 80

-- Font
Constants.FONT = Enum.Font.SourceSans
Constants.FONT_BOLD = Enum.Font.SourceSansBold
Constants.FONT_SIZE_VERY_SMALL = 12
Constants.FONT_SIZE_SMALL = 14
Constants.FONT_SIZE_MEDIUM = 16
Constants.FONT_SIZE_LARGE = 18

-- Tabber
Constants.TAB_HEIGHT = 40
Constants.TAB_WIDTH = 40
Constants.TAB_ICON_SIZE = UDim2.new(0, 32, 0, 32)

-- Scrollbar
Constants.SCROLL_BAR_THICKNESS = 16
Constants.SCROLL_BAR_ARROW_DOWN = "rbxassetid://3645604472"

-- Input fields
Constants.INPUT_FIELD_TEXT_PADDING = 4
Constants.INPUT_FIELD_BOX_PADDING = 4
Constants.INPUT_FIELD_LABEL_PADDING = 12
Constants.INPUT_FIELD_HEIGHT = 24
Constants.INPUT_FIELD_BOX_HEIGHT = 24
Constants.FIELD_LABEL_WIDTH = 110

Constants.BUTTON_HEIGHT = 24

-- Checkbox
Constants.CHECKBOX_SIZE = 18
Constants.CHECK_IMAGE = "rbxassetid://2773796198"
Constants.DROP_SHADOW_SLICE_IMAGE = "rbxassetid://2950485059" -- 69x69, Rect(23, 23, 46, 46)

-- Dropdowns
Constants.DROPDOWN_ARROW_IMAGE = "rbxassetid://3646123659"
Constants.DROPDOWN_ENTRY_HEIGHT = 24

-- Collapsible titled section
Constants.COLLAPSIBLE_SECTION_HEIGHT = 32
Constants.COLLAPSIBLE_ARROW_RIGHT_IMAGE = "rbxassetid://3010958455"
Constants.COLLAPSIBLE_ARROW_DOWN_IMAGE = "rbxassetid://3010958148"
Constants.COLLAPSIBLE_ARROW_SIZE = 10

-- Precise button
Constants.DOUBLE_CLICK_DELAY = 0.5

-- Numerical slider
Constants.SLIDER_BUTTON_WIDTH = 10
Constants.SLIDER_BUTTON_HEIGHT = 20

-- Non-Foundation constants go here
Constants.ROPE_TAB_ICON = "rbxassetid://180785318"
Constants.ADVANCED_TAB_ICON = "rbxassetid://180785318"

Constants.LOCK_TO_DEFAULT = Types.LockTo.NONE
Constants.IGNORE_ROPE_DEFAULT = true
Constants.CURVE_TYPE_DEFAULT = Types.Curve.CATENARY
Constants.DANGLE_LENGTH_MODE_DEFAULT = Types.CatenaryLengthMode.RELATIVE

Constants.DANGLE_LENGTH_FUDGE = 0.01
Constants.DANGLE_LENGTH_LIMIT = 400

Constants.POINTER_MODEL = InstanceStorage.PointerModel
Constants.POINT_MODEL = InstanceStorage.PointModel

Constants.LOCK_DISTANCE_MIN = 0.1
Constants.LOCK_DISTANCE_MAX = 5
Constants.LOCK_DISTANCE_DEFAULT = 1

Constants.GRID_SIZE_MIN = 0.25
Constants.GRID_SIZE_MAX = 5
Constants.GRID_SIZE_DEFAULT = 1

Constants.DANGLE_LENGTH_FIXED_MIN = 5
Constants.DANGLE_LENGTH_FIXED_MAX = 400
Constants.DANGLE_LENGTH_FIXED_DEFAULT = 20

Constants.DANGLE_LENGTH_RELATIVE_MIN = 1
Constants.DANGLE_LENGTH_RELATIVE_MAX = 2
Constants.DANGLE_LENGTH_RELATIVE_DEFAULT = 1.1

Constants.LOOP_SHAPE_DEFAULT = Types.LoopShape.CIRCLE

Constants.LOOP_OFFSET_MIN = 0
Constants.LOOP_OFFSET_MAX = 5
Constants.LOOP_OFFSET_DEFAULT = 0

Constants.DELETE_ICON = "rbxassetid://2821308140"
Constants.DUPLICATE_ICON = "rbxassetid://3137308851"

-- Constants.ROPE_MESH_CAPS = {
-- 	[Types.RopeCrossSection.SQUARE] = InstanceStorage.RopeCapSquareBase,
-- 	[Types.RopeCrossSection.DIAMOND] = InstanceStorage.RopeCapDiamondBase,
-- 	[Types.RopeCrossSection.ROUND] = InstanceStorage.RopeCapRoundBase
-- }

Constants.CARNIVAL_FLAG_SINGLE = {
	Detailed = {
		Triangle = InstanceStorage.CarnivalFlagTriangle,
		Square = InstanceStorage.CarnivalFlagSquare,
		Swallowtail = InstanceStorage.CarnivalFlagSwallowtail
	},
	Flat = {
		Triangle = InstanceStorage.CarnivalFlagFlatTriangle,
		Square = InstanceStorage.CarnivalFlagFlatSquare,
		Swallowtail = InstanceStorage.CarnivalFlagFlatSwallowtail
	}
}

Constants.DANGLING_LIGHTS_SINGLE = {
	Long = InstanceStorage.DanglingBulbLong,
	Pointy = InstanceStorage.DanglingBulbPointy,
	Round = InstanceStorage.DanglingBulbRound
}

Constants.ATTACHED_LIGHTS_SINGLE = {
	Long = InstanceStorage.AttachedBulbLong,
	Pointy = InstanceStorage.AttachedBulbPointy,
	Round = InstanceStorage.AttachedBulbRound
}

-- Constants.MESH_CHAIN_LINK = {
-- 	[Types.MaterialChain.CHAIN_SHARP] = InstanceStorage.SharpChainMeshBase,
-- 	[Types.MaterialChain.CHAIN_SMOOTH] = InstanceStorage.SmoothChainMeshBase,
-- 	[Types.MaterialChain.GARLAND] = InstanceStorage.GarlandMeshBase
-- }

-- Constants.MATERIAL_CHAIN_LINK = {
-- 	[Types.MaterialChain.CHAIN_SHARP] = InstanceStorage.SharpChainMaterialBase,
-- 	[Types.MaterialChain.CHAIN_SMOOTH] = InstanceStorage.SmoothChainMaterialBase,
-- 	[Types.MaterialChain.GARLAND] = InstanceStorage.GarlandMaterialBase
-- }

-- Constants.MESH_CHAIN_SPACING = {
-- 	[Types.MeshChain.CHAIN_SHARP] = 1.25 / 2,
-- 	[Types.MeshChain.CHAIN_SMOOTH] = 1.25 / 2,
-- 	[Types.MeshChain.GARLAND] = 1
-- }

-- Constants.MATERIAL_CHAIN_SPACING = {
-- 	[Types.MaterialChain.CHAIN_SHARP] = 1.25 / 2,
-- 	[Types.MaterialChain.CHAIN_SMOOTH] = 1.25 / 2,
-- 	[Types.MaterialChain.GARLAND] = 1
-- }

-- Constants.MATERIAL_CHAIN_OFFSET = {
-- 	[Types.MaterialChain.CHAIN_SHARP] = Vector3.new(0, 0, 0),
-- 	[Types.MaterialChain.CHAIN_SMOOTH] = Vector3.new(0, 0, 0),
-- 	[Types.MaterialChain.GARLAND] = Vector3.new(0, 0, 0.223)
-- }

Constants.CHRISTMAS_LIGHT_BULB = InstanceStorage.ChristmasLightBulb

Constants.SKYBOX_BALL = InstanceStorage.Skybox

Constants.SKY_BACKGROUND_IMAGE = "rbxassetid://3078073659"

Constants.ROPE_MODEL_TAG = "RopeMasterObject"

-- Constants.ROPE_TEXTURES = {
-- 	[Types.RopeTexture.REALISTIC_ROPE] = {
-- 		[Types.TextureRepeat.X1] = "rbxassetid://3024298725",
-- 		[Types.TextureRepeat.X2] = "rbxassetid://3024520402",
-- 		[Types.TextureRepeat.X4] = "rbxassetid://3024520486",
-- 		[Types.TextureRepeat.X8] = "rbxassetid://3024520561"
-- 	},
-- 	[Types.RopeTexture.CARTOON_ROPE] = {
-- 		[Types.TextureRepeat.X1] = "rbxassetid://3024373208",
-- 		[Types.TextureRepeat.X2] = "rbxassetid://3024540308",
-- 		[Types.TextureRepeat.X4] = "rbxassetid://3024540378",
-- 		[Types.TextureRepeat.X8] = "rbxassetid://3024520332"
-- 	}
-- }

Constants.FILTER_CLEAR_ICON = "rbxassetid://3645457731"
Constants.FILTER_CLEAR_ICON_HOVER = "rbxassetid://3652821665"

Constants.CUSTOM_CHAIN_DEFAULT_KEY = "CustomChainDefault"
Constants.CUSTOM_CHAIN_SEGMENT_DEFAULT = InstanceStorage.CustomChainDefaultBase

Constants.PRESET_NAME_MAX_LENGTH = 32

Constants.ROPE_SHAFTS = {
	[Types.RopeStyle.SQUARE_SMOOTH] = InstanceStorage.RopeShaftSquareSmoothBase,
	[Types.RopeStyle.SQUARE_SHARP] = InstanceStorage.RopeShaftSquareSharpBase,
	[Types.RopeStyle.DIAMOND_SMOOTH] = InstanceStorage.RopeShaftDiamondSmoothBase,
	[Types.RopeStyle.DIAMOND_SHARP] = InstanceStorage.RopeShaftDiamondSharpBase,
	[Types.RopeStyle.ROUND_SMOOTH] = InstanceStorage.RopeShaftRoundSmoothBase,
	[Types.RopeStyle.ROUND_SHARP] = InstanceStorage.RopeShaftRoundSharpBase
}

Constants.ROPE_ELBOWS = {
	[Types.RopeStyle.SQUARE_SMOOTH] = InstanceStorage.RopeElbowSquareSmoothBase,
	[Types.RopeStyle.SQUARE_SHARP] = InstanceStorage.RopeElbowSquareSharpBase,
	[Types.RopeStyle.DIAMOND_SMOOTH] = InstanceStorage.RopeElbowDiamondSmoothBase,
	[Types.RopeStyle.DIAMOND_SHARP] = InstanceStorage.RopeElbowDiamondSharpBase,
	[Types.RopeStyle.ROUND_SMOOTH] = InstanceStorage.RopeElbowRoundSmoothBase,
	[Types.RopeStyle.ROUND_SHARP] = InstanceStorage.RopeElbowRoundSharpBase
}

Constants.ROPE_CAPS = {
	[Types.RopeStyle.SQUARE_SMOOTH] = InstanceStorage.RopeCapSquareBase,
	[Types.RopeStyle.SQUARE_SHARP] = InstanceStorage.RopeCapSquareBase,
	[Types.RopeStyle.DIAMOND_SMOOTH] = InstanceStorage.RopeCapDiamondBase,
	[Types.RopeStyle.DIAMOND_SHARP] = InstanceStorage.RopeCapDiamondBase,
	[Types.RopeStyle.ROUND_SMOOTH] = InstanceStorage.RopeCapRoundBase,
	[Types.RopeStyle.ROUND_SHARP] = InstanceStorage.RopeCapRoundBase
}

Constants.ROPE_TEXTURE_STUDS_PER_TILE = {
	[Types.RopeStyle.SQUARE_SMOOTH] = 1,
	[Types.RopeStyle.SQUARE_SHARP] = 1,
	[Types.RopeStyle.DIAMOND_SMOOTH] = 0.5,
	[Types.RopeStyle.DIAMOND_SHARP] = 0.5,
	[Types.RopeStyle.ROUND_SMOOTH] = 0.35355 * 2,
	[Types.RopeStyle.ROUND_SHARP] = 0.35355 * 2
}

Constants.ROPE_ELBOW_THRESHOLD = 0.05

return wrapStrictTable(Constants, "Constants")
