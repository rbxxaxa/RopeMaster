local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local Constants = require(Plugin.Core.Util.Constants)

local Pointer = Roact.PureComponent:extend("Pointer")

function Pointer:init()
	self.handleRef = Roact.createRef()
	self.partRef = Roact.createRef()
end

function Pointer:render()
	local props = self.props
	local ZIndex = props.ZIndex

	local color = Color3.new(0, 1, 0)

	return Roact.createElement(
		"ViewportFrame",
		{
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BackgroundColor3 = color,
			ImageColor3 = color,
			ZIndex = ZIndex,
			CurrentCamera = workspace.CurrentCamera
		},
		{
			Handle = Roact.createElement(
				"Model",
				{
					[Roact.Ref] = self.handleRef
				}
			)
		}
	)
end

function Pointer:ClearBufferModel()
	self.handleRef.current:ClearAllChildren()
end

function Pointer:UpdateBufferModel()
	self:ClearBufferModel()

	local props = self.props
	local handle = self.handleRef.current
	local points = props.points

	for _, point in next, points do
		local pObj = Constants.POINTER_MODEL:Clone()
		pObj:SetPrimaryPartCFrame(CFrame.new(point))
		pObj.Parent = handle
	end
end

function Pointer:didMount()
	local handle = self.handleRef.current
	local part = self.partRef.current
	handle.PrimaryPart = part

	self:UpdateBufferModel()
end

function Pointer:didUpdate(previousProps)
	self:UpdateBufferModel()
end

function Pointer:willUnmount()
	self:ClearBufferModel()
end

return Pointer
