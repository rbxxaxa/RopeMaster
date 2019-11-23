local Action = require(script.Parent.Action)

return Action(
	"CollapsibleSectionToggle",
	function(collasibleId)
		return {
			id = collasibleId
		}
	end
)
