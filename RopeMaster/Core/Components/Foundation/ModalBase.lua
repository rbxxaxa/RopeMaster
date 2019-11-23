local Plugin = script.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getModal = ContextGetter.getModal

local ModalBase = Roact.PureComponent:extend("ModalBase")

function ModalBase:render()
	local props = self.props
	local modalTarget = props.target
	local ZIndex = props.ZIndex
	return Roact.createElement(
		Roact.Portal,
		{
			target = modalTarget
		},
		{
			ScrollBlocker = Roact.createElement(
				"ScrollingFrame",
				{
					Size = UDim2.new(1, 0, 1, 0),
					-- We need to have ScrollingEnabled = true for this frame for it to block
					-- But we don't want it to actually scroll, so its canvas must be same size as the frame
					ScrollingEnabled = true,
					CanvasSize = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 0,
					ZIndex = ZIndex
				}
			),
			ButtonBlocker = Roact.createElement(
				"TextButton",
				{
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					ZIndex = ZIndex
				}
			),
			Contents = Roact.createElement(
				"Frame",
				{
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = ZIndex
				},
				self.props[Roact.Children]
			)
		}
	)
end

function ModalBase:didMount()
	local modalIndex = self.props.modalIndex
	local modal = getModal(self)
	modal.onModalOpened(self, modalIndex)
end

function ModalBase:willUnmount()
	local modal = getModal(self)
	modal.onModalClosed(self)
end

return ModalBase
