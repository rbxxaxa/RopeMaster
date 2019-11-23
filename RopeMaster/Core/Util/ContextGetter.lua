local Plugin = script.Parent.Parent.Parent

local Keys = require(Plugin.Core.Util.Keys)
local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)

local ContextGetter = {}

function ContextGetter.getModal(component)
	return {
		modalTarget = component._context.modalTarget,
		modalStatus = component._context.modalStatus,
		onDropdownOpened = component._context.onDropdownOpened,
		onDropdownClosed = component._context.onDropdownClosed,
		onModalOpened = component._context.onModalOpened,
		onModalClosed = component._context.onModalClosed,
		isShowingModal = component._context.isShowingModal,
		isAnyButtonPressed = component._context.isAnyButtonPressed,
		isButtonPressed = component._context.isButtonPressed,
		onButtonPressed = component._context.onButtonPressed,
		onButtonReleased = component._context.onButtonReleased
	}
end

function ContextGetter.getPlugin(component)
	return component._context[Keys.plugin], component._context[Keys.pluginGui]
end

function ContextGetter.getTheme(component)
	return component._context[Keys.theme]
end

function ContextGetter.getMainManager(component)
	return component._context[Keys.mainManager]
end

return wrapStrictTable(ContextGetter, "ContextGetter")
