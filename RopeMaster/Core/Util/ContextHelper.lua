local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Roact = require(Libs.Roact)

local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)

local ModalConsumer = require(Plugin.Core.Consumers.ModalConsumer)
local ThemeConsumer = require(Plugin.Core.Consumers.ThemeConsumer)
local MainManagerConsumer = require(Plugin.Core.Consumers.MainManagerConsumer)

local ContextHelper = {}

function ContextHelper.withModal(callback)
	return Roact.createElement(
		ModalConsumer,
		{
			render = callback
		}
	)
end

function ContextHelper.withTheme(callback)
	return Roact.createElement(
		ThemeConsumer,
		{
			render = callback
		}
	)
end

function ContextHelper.withMainManager(callback)
	return Roact.createElement(
		MainManagerConsumer,
		{
			render = callback
		}
	)
end

return wrapStrictTable(ContextHelper, "ContextHelper")
