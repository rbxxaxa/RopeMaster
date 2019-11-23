local Action = require(script.Parent.Action)

return Action(
	"RopeCurveSet",
	function(curve)
		return {
			curveType = curve.curveType,
			dangleLengthMode = curve.dangleLengthMode,
			dangleLengthFixed = curve.dangleLengthFixed,
			dangleLengthRelative = curve.dangleLengthRelative,
			coilRotations = curve.coilRotations,
			coilDiameter = curve.coilDiameter
		}
	end
)
