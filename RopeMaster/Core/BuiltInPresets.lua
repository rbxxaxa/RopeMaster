local Plugin = script.Parent.Parent
local Types = require(Plugin.Core.Util.Types)

return {
	--	PowerLine = {
	--		name = "Power Line",
	--		type = Types.Preset.BUILTIN,
	--		rope = {
	--			type = Types.Rope.MESH_ROPE,
	--			params = {
	--				crossSection = Types.RopeCrossSection.ROUND,
	--				smoothingType = Types.RopeSmoothing.SMOOTH,
	--				shadingType = Types.RopeShading.DULL,
	--				height = 0.2,
	--				width = 0.2,
	--				baseColor = Color3.fromRGB(27, 42, 53),
	--				textured = false,
	--				texture = "",
	--				lengthMode = Types.RopeSegmentMode.SAME_BENDS,
	--				angleInterval = 8,
	--				lengthInterval = 2
	--			}
	--		},
	--		ornaments = {}
	--	},
	-- CarnivalFlags = {
	-- 	name = "Carnival Flags",
	-- 	type = Types.Preset.BUILTIN,
	-- 	rope = {
	-- 		type = Types.Rope.MESH_ROPE,
	-- 		params = {
	-- 			crossSection = Types.RopeCrossSection.SQUARE,
	-- 			smoothingType = Types.RopeSmoothing.SMOOTH,
	-- 			shadingType = Types.RopeShading.MATTE,
	-- 			height = 0.1,
	-- 			width = 0.05,
	-- 			baseColor = Color3.new(1, 1, 1),
	-- 			texture = Types.RopeTexture.NONE,
	-- 			textureRepeat = Types.TextureRepeat.X1,
	-- 			textureColor = Color3.new(1, 1, 1),
	-- 			lengthMode = Types.RopeSegmentMode.SAME_BENDS,
	-- 			angleInterval = 12,
	-- 			lengthInterval = 2
	-- 		}
	-- 	},
	-- 	ornaments = {
	-- 		A = {
	-- 			type = "CarnivalFlagSingle",
	-- 			params = {
	-- 				shape = "Triangle",
	-- 				shading = "Rough",
	-- 				width = 1,
	-- 				height = 1.25,
	-- 				thickness = .1,
	-- 				spacing = 6,
	-- 				spacingOffset = 0,
	-- 				baseColor = Color3.fromRGB(255, 196, 5),
	-- 				textured = false,
	-- 				texture = "",
	-- 				textureColor = Color3.new(1, 1, 1),
	-- 				verticalOffset = -0.1,
	-- 				carnivalFlagStyle = Types.CarnivalFlagStyle.DETAILED
	-- 			}
	-- 		},
	-- 		B = {
	-- 			type = "CarnivalFlagSingle",
	-- 			params = {
	-- 				shape = "Triangle",
	-- 				shading = "Rough",
	-- 				width = 1,
	-- 				height = 1.25,
	-- 				thickness = 0.1,
	-- 				spacing = 6,
	-- 				spacingOffset = 0.20,
	-- 				baseColor = Color3.fromRGB(255, 2, 149),
	-- 				textured = false,
	-- 				texture = "",
	-- 				textureColor = Color3.new(1, 1, 1),
	-- 				verticalOffset = -0.1,
	-- 				carnivalFlagStyle = Types.CarnivalFlagStyle.DETAILED
	-- 			}
	-- 		},
	-- 		C = {
	-- 			type = "CarnivalFlagSingle",
	-- 			params = {
	-- 				shape = "Triangle",
	-- 				shading = "Rough",
	-- 				width = 1,
	-- 				height = 1.25,
	-- 				thickness = 0.1,
	-- 				spacing = 6,
	-- 				spacingOffset = 0.40,
	-- 				baseColor = Color3.fromRGB(17, 160, 255),
	-- 				textured = false,
	-- 				texture = "",
	-- 				textureColor = Color3.new(1, 1, 1),
	-- 				verticalOffset = -0.1,
	-- 				carnivalFlagStyle = Types.CarnivalFlagStyle.DETAILED
	-- 			}
	-- 		},
	-- 		D = {
	-- 			type = "CarnivalFlagSingle",
	-- 			params = {
	-- 				shape = "Triangle",
	-- 				shading = "Rough",
	-- 				width = 1,
	-- 				height = 1.25,
	-- 				thickness = 0.1,
	-- 				spacing = 6,
	-- 				spacingOffset = 0.60,
	-- 				baseColor = Color3.fromRGB(35, 255, 72),
	-- 				textured = false,
	-- 				texture = "",
	-- 				textureColor = Color3.new(1, 1, 1),
	-- 				verticalOffset = -0.1,
	-- 				carnivalFlagStyle = Types.CarnivalFlagStyle.DETAILED
	-- 			}
	-- 		},
	-- 		E = {
	-- 			type = "CarnivalFlagSingle",
	-- 			params = {
	-- 				shape = "Triangle",
	-- 				shading = "Rough",
	-- 				width = 1,
	-- 				height = 1.25,
	-- 				thickness = 0.1,
	-- 				spacing = 6,
	-- 				spacingOffset = 0.80,
	-- 				baseColor = Color3.fromRGB(255, 2, 36),
	-- 				textured = false,
	-- 				texture = "",
	-- 				textureColor = Color3.new(1, 1, 1),
	-- 				verticalOffset = -0.1,
	-- 				carnivalFlagStyle = Types.CarnivalFlagStyle.DETAILED
	-- 			}
	-- 		}
	-- 	}
	-- },
	-- LowpolyChain = {
	-- 	name = "Lowpoly Chain",
	-- 	type = Types.Preset.BUILTIN,
	-- 	rope = {
	-- 		type = Types.Rope.MESH_CHAIN,
	-- 		params = {
	-- 			meshChainType = Types.MeshChain.CHAIN_SHARP,
	-- 			segmentScale = 1,
	-- 			baseColor = Color3.new(0.5, 0.5, 0.5),
	-- 			chainshadingType = Types.ChainShading.SHINY,
	-- 			rotationLinkAxis = Types.Axis.Z,
	-- 			rotationLinkOffset = 0,
	-- 			rotationPerLink = 90,
	-- 			rotationLinkRandomMin = -20,
	-- 			rotationLinkRandomMax = 20
	-- 		}
	-- 	},
	-- 	ornaments = {}
	-- },
	--	RustyChain = {
	--		name = "Rusty Chain",
	--		type = Types.Preset.BUILTIN,
	--		rope = {
	--			type = Types.Rope.MATERIAL_CHAIN,
	--			params = {
	--				materialChainType = Types.MaterialChain.CHAIN_SMOOTH,
	--				segmentScale = 1,
	--				baseColor = Color3.new(0.5, 0.5, 0.5),
	--				chainMaterial = Types.Material.CORRODEDMETAL,
	--				rotationLinkOffset = 0,
	--				rotationPerLink = 90,
	--				rotationLinkRandomMin = 0,
	--				rotationLinkRandomMax = 0,
	--			}
	--		},
	--		ornaments = {}
	--	},
	-- ChristmasGarland = {
	-- 	name = "Christmas Garland",
	-- 	type = Types.Preset.BUILTIN,
	-- 	rope = {
	-- 		type = Types.Rope.MESH_CHAIN,
	-- 		params = {
	-- 			meshChainType = Types.MeshChain.GARLAND,
	-- 			segmentScale = 1,
	-- 			baseColor = Color3.fromRGB(121, 150, 40),
	-- 			chainShadingType = Types.ChainShading.MATTE,
	-- 			rotationLinkAxis = Types.Axis.Z,
	-- 			rotationLinkOffset = 0,
	-- 			rotationPerLink = 0,
	-- 			rotationLinkRandomMin = -360,
	-- 			rotationLinkRandomMax = 360
	-- 		}
	-- 	},
	-- 	ornaments = {
	-- 		Blue = {
	-- 			type = "ChristmasLight",
	-- 			params = {
	-- 				scale = .8,
	-- 				lightColor = Color3.fromRGB(19, 157, 255),
	-- 				xRotationRandomMin = -10,
	-- 				xRotationRandomMax = 10,
	-- 				zRotationOffset = 0,
	-- 				zRotationPerObject = 280,
	-- 				zRotationRandomMin = -10,
	-- 				zRotationRandomMax = 10,
	-- 				spacing = 4,
	-- 				spacingOffset = 0
	-- 			}
	-- 		},
	-- 		Red = {
	-- 			type = "ChristmasLight",
	-- 			params = {
	-- 				scale = .8,
	-- 				lightColor = Color3.fromRGB(255, 50, 36),
	-- 				xRotationRandomMin = -10,
	-- 				xRotationRandomMax = 10,
	-- 				zRotationOffset = 70,
	-- 				zRotationPerObject = 280,
	-- 				zRotationRandomMin = -10,
	-- 				zRotationRandomMax = 10,
	-- 				spacing = 4,
	-- 				spacingOffset = 0.25
	-- 			}
	-- 		},
	-- 		Yellow = {
	-- 			type = "ChristmasLight",
	-- 			params = {
	-- 				scale = .8,
	-- 				lightColor = Color3.fromRGB(245, 205, 48),
	-- 				xRotationRandomMin = -10,
	-- 				xRotationRandomMax = 10,
	-- 				zRotationOffset = 140,
	-- 				zRotationPerObject = 280,
	-- 				zRotationRandomMin = -10,
	-- 				zRotationRandomMax = 10,
	-- 				spacing = 4,
	-- 				spacingOffset = 0.5
	-- 			}
	-- 		},
	-- 		Green = {
	-- 			type = "ChristmasLight",
	-- 			params = {
	-- 				scale = .8,
	-- 				lightColor = Color3.fromRGB(0, 255, 0),
	-- 				xRotationRandomMin = -10,
	-- 				xRotationRandomMax = 10,
	-- 				zRotationOffset = 210,
	-- 				zRotationPerObject = 280,
	-- 				zRotationRandomMin = -10,
	-- 				zRotationRandomMax = 10,
	-- 				spacing = 4,
	-- 				spacingOffset = 0.75
	-- 			}
	-- 		}
	-- 	}
	-- },
	-- ChristmasGarlandLame = {
	-- 	name = "Christmas Garland (Lame)",
	-- 	type = Types.Preset.BUILTIN,
	-- 	rope = {
	-- 		type = Types.Rope.MESH_CHAIN,
	-- 		params = {
	-- 			meshChainType = Types.MeshChain.GARLAND,
	-- 			segmentScale = 1,
	-- 			baseColor = Color3.fromRGB(121, 150, 40),
	-- 			chainShadingType = Types.ChainShading.MATTE,
	-- 			rotationLinkAxis = Types.Axis.Z,
	-- 			rotationLinkOffset = 0,
	-- 			rotationPerLink = 0,
	-- 			rotationLinkRandomMin = -360,
	-- 			rotationLinkRandomMax = 360
	-- 		}
	-- 	},
	-- 	ornaments = {
	-- 		Incan = {
	-- 			type = "ChristmasLight",
	-- 			params = {
	-- 				scale = 1,
	-- 				lightColor = Color3.fromRGB(211, 145, 100),
	-- 				xRotationRandomMin = -10,
	-- 				xRotationRandomMax = 10,
	-- 				zRotationOffset = 0,
	-- 				zRotationPerObject = 70,
	-- 				zRotationRandomMin = -10,
	-- 				zRotationRandomMax = 10,
	-- 				offset = Vector3.new(),
	-- 				spacing = 1,
	-- 				spacingOffset = 0
	-- 			}
	-- 		}
	-- 	}
	-- },
	--	StringLightsHanging = {
	--		name = "String Lights #1",
	--		type = Types.Preset.BUILTIN,
	--		rope = {
	--			type = Types.Rope.MESH_ROPE,
	--			params = {
	--				crossSection = Types.RopeCrossSection.ROUND,
	--				smoothingType = Types.RopeSmoothing.SMOOTH,
	--				shadingType = Types.RopeShading.MATTE,
	--				height = 0.06,
	--				width = 0.06,
	--				baseColor = Color3.fromRGB(27, 42, 53),
	--				textured = false,
	--				texture = "",
	--				textureColor = Color3.new(1, 1, 1),
	--				lengthMode = Types.RopeSegmentMode.SAME_BENDS,
	--				angleInterval = 8,
	--				lengthInterval = 2
	--			}
	--		},
	--		ornaments = {
	--			Bulb = {
	--				type = "DanglingGardenLight",
	--				params = {
	--					bulbType = "Round",
	--					scale = 0.7,
	--					lightColor = Color3.fromRGB(211, 145, 100),
	--					spacing = 2,
	--					spacingOffset = 0,
	--					dangleLength = 0.2,
	--				}
	--			}
	--		}
	--	},
	-- StringLightsAttached = {
	-- 	name = "String Lights #2",
	-- 	type = Types.Preset.BUILTIN,
	-- 	rope = {
	-- 		type = Types.Rope.MESH_ROPE,
	-- 		params = {
	-- 			crossSection = Types.RopeCrossSection.ROUND,
	-- 			smoothingType = Types.RopeSmoothing.SMOOTH,
	-- 			shadingType = Types.RopeShading.MATTE,
	-- 			height = 0.06,
	-- 			width = 0.06,
	-- 			baseColor = Color3.fromRGB(27, 42, 53),
	-- 			texture = Types.RopeTexture.NONE,
	-- 			textureColor = Color3.new(1, 1, 1),
	-- 			lengthMode = Types.RopeSegmentMode.SAME_BENDS,
	-- 			angleInterval = 8,
	-- 			lengthInterval = 2
	-- 		}
	-- 	},
	-- 	ornaments = {
	-- 		Bulb = {
	-- 			type = "AttachedGardenLight",
	-- 			params = {
	-- 				bulbType = "Round",
	-- 				scale = 0.7,
	-- 				lightColor = Color3.fromRGB(211, 145, 100),
	-- 				spacing = 2,
	-- 				spacingOffset = 0,
	-- 			}
	-- 		}
	-- 	}
	-- },
	FiberRope = {
		name = "Fiber Rope",
		type = Types.Preset.BUILTIN,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.ROUND_SMOOTH,
				material = Types.Material.FABRIC,
				height = 0.2,
				width = 0.2,
				baseColor = Color3.fromRGB(255, 178, 127),
				textured = true,
				textureId = "rbxassetid://3573417005",
				textureLength = 0.5
			}
		},
		ornaments = {}
	},
	CartoonRope = {
		name = "Toon Rope",
		type = Types.Preset.BUILTIN,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.DIAMOND_SHARP,
				material = Types.Material.FABRIC,
				height = 0.2,
				width = 0.2,
				partCount = Types.RopePartCount.LOW,
				baseColor = Color3.fromRGB(255, 178, 127),
				textured = true,
				textureId = "rbxassetid://3584068534",
				textureLength = 0.5
			}
		},
		ornaments = {}
	},
	SteelCable = {
		name = "Steel Cable",
		type = Types.Preset.BUILTIN,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.ROUND_SMOOTH,
				material = Types.Material.FABRIC,
				height = 0.25,
				width = 0.25,
				baseColor = Color3.fromRGB(200, 200, 200),
				textured = true,
				textureId = "rbxassetid://3584315030",
				textureLength = 0.5
			}
		},
		ornaments = {}
	},
	ElectricCable = {
		name = "Electric Cable",
		type = Types.Preset.BUILTIN,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.ROUND_SMOOTH,
				material = Types.Material.FABRIC,
				height = 0.1,
				width = 0.1,
				baseColor = Color3.fromRGB(27, 42, 53),
				textured = true,
				textureId = "rbxassetid://3075719181",
				textureLength = 1
			}
		},
		ornaments = {}
	},
	PoliceTape = {
		name = "Police Tape",
		type = Types.Preset.BUILTIN,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.SQUARE_SHARP,
				material = Types.Material.SMOOTHPLASTIC,
				height = 0.5,
				width = 0.1,
				baseColor = Color3.fromRGB(255, 255, 255),
				textured = true,
				textureId = "rbxassetid://3585683661",
				textureLength = 3
			}
		},
		ornaments = {}
	},
	PreviewOk = {
		name = "PreviewOk",
		type = Types.Preset.INTERNAL,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.ROUND_SMOOTH,
				material = Types.Material.NEON,
				height = 0.1,
				width = 0.1,
				baseColor = Color3.new(0, 1, 0),
				textured = false
			}
		},
		ornaments = {}
	},
	PreviewBad = {
		name = "PreviewBad",
		type = Types.Preset.INTERNAL,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.ROUND_SMOOTH,
				material = Types.Material.NEON,
				height = 0.1,
				width = 0.1,
				baseColor = Color3.new(1, 0, 0),
				textured = false
			}
		},
		ornaments = {}
	},
	NewRopeTemplate = {
		name = "New Rope",
		type = Types.Preset.INTERNAL,
		rope = {
			type = Types.Rope.ROPE,
			params = {
				style = Types.RopeStyle.ROUND_SMOOTH,
				material = Types.Material.SMOOTHPLASTIC,
				height = 0.2,
				width = 0.2,
				baseColor = Color3.new(0.5, 0.5, 0.5),
				textured = false,
				textureId = ""
			}
		},
		ornaments = {}
	}
}
