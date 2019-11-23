local Plugin = script.Parent.Parent.Parent.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local SmartSetState = require(Plugin.Core.Util.SmartSetState)
local Types = require(Plugin.Core.Util.Types)

local getMainManager = ContextGetter.getMainManager

local CursorPreview = Roact.PureComponent:extend("CursorPreview")
local Grid = require(script.Grid)
local Pointer = require(script.Pointer)
local Midpoints = require(script.Midpoints)
local PointBuffer = require(script.PointBuffer)

function CursorPreview:init()
	local mainManager = getMainManager(self)
	self:setState {
		cursorInfo = mainManager.cursorInfo,
		gridSize = mainManager:GetGridSize(),
		lockTo = mainManager:GetLockTo()
	}
	self:UpdatePointPositions()
end

function CursorPreview:UpdatePointPositions()
	local mainManager = getMainManager(self)
	local pointBuffer = mainManager.pointBuffer
	local points = {}
	for _, entry in next, pointBuffer do
		table.insert(points, entry.p)
	end

	self:setState {
		pointPositions = points
	}
end

function CursorPreview:render()
	local props = self.props
	local state = self.state
	local cursorInfo = state.cursorInfo
	local DisplayOrder = props.DisplayOrder

	local cursorCf = cursorInfo.cursorCf
	local lockTo = self.state.lockTo
	local shouldRenderGrid =
		lockTo == Types.LockTo.GRID and cursorInfo.hit ~= nil and not cursorInfo.hit:IsA("Terrain") and cursorInfo.cursorCf ~= nil
	local shouldRenderPointer = cursorInfo.cursorCf ~= nil
	local shouldRenderPartCenters =
		lockTo == Types.LockTo.PART_CENTERS and cursorInfo.hit ~= nil and not cursorInfo.hit:IsA("Terrain")
	local shouldRenderMidpoints =
		lockTo == Types.LockTo.MIDPOINTS and cursorInfo.hit ~= nil and not cursorInfo.hit:IsA("Terrain") and cursorInfo.cursorCf ~= nil
	local hit = cursorInfo.hit
	local face = cursorInfo.face
	local points = state.pointPositions

	return Roact.createElement(
		Roact.Portal,
		{
			target = game:GetService("CoreGui")
		},
		{
			ScreenGui = Roact.createElement(
				"ScreenGui",
				{
					DisplayOrder = DisplayOrder
				},
				{
					Grid = shouldRenderGrid and
						Roact.createElement(
							Grid,
							{
								cf = cursorCf,
								gridSize = self.state.gridSize,
								ZIndex = 1
							}
						),
					Midpoints = shouldRenderMidpoints and
						Roact.createElement(
							Midpoints,
							{
								part = hit,
								face = face,
								cf = cursorCf,
								ZIndex = 1
							}
						),
					PointBuffer = Roact.createElement(
						PointBuffer,
						{
							points = points
						}
					),
					Pointer = shouldRenderPointer and
						Roact.createElement(
							Pointer,
							{
								cf = cursorCf,
								ZIndex = 2
							}
						),
					PartCentersBox = shouldRenderPartCenters and
						Roact.createElement(
							"SelectionBox",
							{
								Color3 = Color3.new(1, 0.5, 0),
								SurfaceColor3 = Color3.new(1, 0.5, 0),
								SurfaceTransparency = 0.5,
								Adornee = hit,
								LineThickness = 0.05
							}
						)
				}
			)
		}
	)
end

function CursorPreview:didMount()
	local mainManager = getMainManager(self)
	self.cursorDisconnect =
		mainManager:subscribeToCursor(
		function()
			local cursorInfo = mainManager.cursorInfo
			SmartSetState(
				self,
				{
					cursorInfo = cursorInfo
				}
			)
		end
	)

	self.mainManagerDisconnect =
		mainManager:subscribe(
		function()
			SmartSetState(
				self,
				{
					gridSize = mainManager:GetGridSize(),
					lockTo = mainManager:GetLockTo()
				}
			)
		end
	)

	self.bufferConn =
		mainManager:subscribeToPointBuffer(
		function()
			self:UpdatePointPositions()
		end
	)
end

function CursorPreview:willUnmount()
	self.cursorDisconnect()
	self.mainManagerDisconnect()
	self.bufferConn()
end

return CursorPreview
