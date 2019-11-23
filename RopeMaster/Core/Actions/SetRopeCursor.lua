local Action = require(script.Parent.Action)

return Action(
	"RopeCursorSet",
	function(cursor)
		return {
			lockTo = cursor.lockTo,
			lockDistance = cursor.lockDistance,
			gridSize = cursor.gridSize
		}
	end
)
