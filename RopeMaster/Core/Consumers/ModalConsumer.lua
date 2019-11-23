local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)

local getModal = ContextGetter.getModal

local ModalConsumer = Roact.Component:extend("ModalConsumer")

-- TODO CLIDEVSRVS-1688: Improve this
local function getDataFromModalStatus(modalStatus)
	return {
		isDropdownOpen = modalStatus._isDropdownOpen
	}
end

function ModalConsumer:init()
	local modalData = getModal(self)
	self.modalTarget = modalData.modalTarget
	self.modalStatus = modalData.modalStatus

	-- TODO CLIDEVSRVS-1688: Fix this
	-- Duplicating data between this and modal status
	self.state = getDataFromModalStatus(self.modalStatus)
end

function ModalConsumer:render()
	return self.props.render(self.modalTarget, self.modalStatus)
end

function ModalConsumer:didMount()
	self.disconnectModalListener =
		self.modalStatus:subscribe(
		function()
			self:setState(getDataFromModalStatus(self.modalStatus))
		end
	)
end

function ModalConsumer:willUnmount()
	self.disconnectModalListener()
end

return ModalConsumer
