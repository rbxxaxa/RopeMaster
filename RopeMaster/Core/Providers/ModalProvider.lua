local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local ContextGetter = require(Plugin.Core.Util.ContextGetter)
local ModalStatus = require(Plugin.Core.Util.ModalStatus)

local getPlugin = ContextGetter.getPlugin

local ModalProvider = Roact.PureComponent:extend("ModalProvider")

function ModalProvider:init(props)
	-- Must be created under PluginProvider
	local _, pluginGui = getPlugin(self)
	self._context.modalTarget = pluginGui

	local modalStatus = ModalStatus.new()
	self._context.modalStatus = modalStatus

	self._context.onDropdownOpened = function()
		modalStatus:onDropdownToggled(true)
	end

	self._context.onDropdownClosed = function()
		modalStatus:onDropdownToggled(false)
	end

	self._context.onModalOpened = function(modal, modalIndex)
		modalStatus:onModalOpened(modal, modalIndex)
	end

	self._context.onModalClosed = function(modal)
		modalStatus:onModalClosed(modal)
	end

	self._context.isShowingModal = function(modalIndex)
		return modalStatus:isShowingModal(modalIndex)
	end

	self._context.isAnyButtonPressed = function()
		return modalStatus:isAnyButtonPressed()
	end

	self._context.isButtonPressed = function(button)
		return modalStatus:isButtonPressed(button)
	end

	self._context.onButtonPressed = function(button)
		modalStatus:onButtonPressed(button)
	end

	self._context.onButtonReleased = function()
		modalStatus:onButtonReleased()
	end
end

function ModalProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return ModalProvider
