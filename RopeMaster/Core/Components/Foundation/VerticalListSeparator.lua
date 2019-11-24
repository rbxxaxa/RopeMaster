local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextHelper = require(Plugin.Core.Util.ContextHelper)

local withTheme = ContextHelper.withTheme

local VerticalListSeparator = Roact.PureComponent:extend("VerticalListSeparator")

function VerticalListSeparator:render()
	local props = self.props
	local height = props.height or 2
	return withTheme(
		function(theme)
			return Roact.createElement(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, height),
					LayoutOrder = props.LayoutOrder
				},
				{
					Line = props.lined and
						Roact.createElement(
							"Frame",
							{
								BorderSizePixel = 0,
								BackgroundColor3 = theme.separator.color,
								Size = UDim2.new(1, 0, 0, 1),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.new(0.5, 0, 0.5, 0)
							}
						)
				}
			)
		end
	)
end

return VerticalListSeparator
