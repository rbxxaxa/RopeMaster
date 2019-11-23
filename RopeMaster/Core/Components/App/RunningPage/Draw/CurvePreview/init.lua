local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local RopePreview = Roact.PureComponent:extend("RopePreview")
local Dangle = require(script.Dangle)
local Line = require(script.Line)
local Loop = require(script.Loop)

function RopePreview:init()
	self:UpdateStateFromMainManager()
end

function RopePreview:UpdateStateFromMainManager()
	local mainManager = getMainManager(self)
	SmartSetState(
		self,
		{
			cursorInfo = mainManager.cursorInfo,
			pointBuffer = mainManager.pointBuffer,
			curveType = mainManager:GetCurveType(),
			dangleLengthMode = mainManager:GetDangleLengthMode(),
			dangleLengthFixed = mainManager:GetDangleLengthFixed(),
			dangleLengthRelative = mainManager:GetDangleLengthRelative(),
			dangleValid = mainManager:CanPlaceDangleAtCursor(),
			loopValid = mainManager:CanPlaceLoopAtCursor(),
			loopShape = mainManager:GetLoopShape(),
			loopOffset = mainManager:GetLoopOffset()
		}
	)
end

function RopePreview:render()
	local props = self.props
	local state = self.state
	local DisplayOrder = props.DisplayOrder

	local cursorInfo = state.cursorInfo
	local curveType = state.curveType
	local dangleLengthMode = state.dangleLengthMode
	local dangleLengthFixed = state.dangleLengthFixed
	local dangleLengthRelative = state.dangleLengthRelative
	local dangleValid = state.dangleValid
	local pointBuffer = state.pointBuffer
	local loopValid = state.loopValid
	local loopShape = state.loopShape
	local loopOffset = state.loopOffset
	local cursorCf = cursorInfo.cursorCf

	local shouldRenderDangle = curveType == Types.Curve.CATENARY and #pointBuffer == 1 and cursorCf
	local shouldRenderLine = curveType == Types.Curve.LINE and #pointBuffer == 1 and cursorCf
	local shouldRenderLoop = curveType == Types.Curve.LOOP and #pointBuffer == 1 and cursorCf

	return Roact.createElement(
		Roact.Portal,
		{
			target = game:GetService("CoreGui"),
			DisplayOrder = DisplayOrder
		},
		{
			ScreenGui = Roact.createElement(
				"ScreenGui",
				{},
				{
					Dangle = shouldRenderDangle and
						Roact.createElement(
							Dangle,
							{
								start = pointBuffer[1],
								fin = cursorCf,
								lengthMode = dangleLengthMode,
								lengthFixed = dangleLengthFixed,
								lengthRelative = dangleLengthRelative,
								valid = dangleValid
							}
						),
					Line = shouldRenderLine and
						Roact.createElement(
							Line,
							{
								start = pointBuffer[1],
								fin = cursorCf,
								valid = true
							}
						),
					Loop = shouldRenderLoop and
						Roact.createElement(
							Loop,
							{
								hit = pointBuffer[1].hit,
								p = pointBuffer[1].p,
								p2 = cursorCf.p,
								valid = loopValid,
								shape = loopShape,
								offset = loopOffset
							}
						)
				}
			)
		}
	)
end

function RopePreview:didMount()
	local mainManager = getMainManager(self)
	self.cursorDisconnect =
		mainManager:subscribeToCursor(
		function()
			local cursorInfo = mainManager.cursorInfo
			self:setState {
				cursorInfo = cursorInfo,
				dangleValid = mainManager:CanPlaceDangleAtCursor(),
				loopValid = mainManager:CanPlaceLoopAtCursor()
			}
		end
	)

	self.pointBufferDisconnect =
		mainManager:subscribeToPointBuffer(
		function()
			local pointBuffer = mainManager.pointBuffer
			self:setState {
				pointBuffer = pointBuffer,
				dangleValid = mainManager:CanPlaceDangleAtCursor(),
				loopValid = mainManager:CanPlaceLoopAtCursor()
			}
		end
	)

	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			self:UpdateStateFromMainManager()
		end
	)
end

function RopePreview:willUnmount()
	self.cursorDisconnect()
	self.pointBufferDisconnect()
	self.mainManagerDisconnect()
end

return RopePreview
