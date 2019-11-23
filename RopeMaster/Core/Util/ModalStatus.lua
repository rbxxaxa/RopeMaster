local Plugin = script.Parent.Parent.Parent

local createSignal = require(Plugin.Core.Util.createSignal)

local ModalStatus = {}
ModalStatus.__index = ModalStatus

function ModalStatus.new()
	return setmetatable(
		{
			_signal = createSignal(),
			_isDropdownOpen = false,
			_pressedButton = nil,
			openModals = {},
			cachedTopModal = nil
		},
		ModalStatus
	)
end

function ModalStatus:subscribe(...)
	return self._signal:subscribe(...)
end

function ModalStatus:isShowingModal(modalIndex)
	assert(modalIndex ~= nil, "modalIndex parameter is missing.")
	if self._isDropdownOpen then
		return self._isDropdownOpen
	end

	local topModal = self.cachedTopModal
	if topModal == nil then
		local max = 0
		for _, idx in pairs(self.openModals) do
			max = math.max(max, idx)
		end
		topModal = max
		self.cachedTopModal = topModal
	end
	return topModal > modalIndex
end

function ModalStatus:onDropdownToggled(shown)
	if shown ~= self._isDropdownOpen then
		self._isDropdownOpen = shown

		self._signal:fire()
	end
end

function ModalStatus:onModalOpened(modal, modalIndex)
	assert(modal)
	assert(modalIndex)
	self.openModals[modal] = modalIndex
	self.cachedTopModal = nil
end

function ModalStatus:onModalClosed(modal)
	self.openModals[modal] = nil
	self.cachedTopModal = nil
end

function ModalStatus:onButtonPressed(button)
	assert(button)
	if button ~= self._pressedButton then
		self._pressedButton = button

		self._signal:fire()
	end
end

function ModalStatus:onButtonReleased()
	if self._pressedButton ~= nil then
		self._pressedButton = nil

		self._signal:fire()
	end
end

function ModalStatus:isAnyButtonPressed()
	return self._pressedButton ~= nil
end

function ModalStatus:isButtonPressed(button)
	assert(button)
	return self._pressedButton == button
end

return ModalStatus
