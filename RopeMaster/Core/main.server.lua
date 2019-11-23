local Plugin = script.Parent.Parent
local Libs = Plugin.Libs
local Roact = require(Libs.Roact)
local Rodux = require(Libs.Rodux)

local MainTheme = require(Plugin.Core.Util.MainTheme)

local Components = Plugin.Core.Components
local MainPlugin = require(Components.MainPlugin)

local MainManager = require(Plugin.Core.MainManager)

local function createTheme()
	return MainTheme.new(
		{
			getTheme = function()
				return settings().Studio.Theme
			end,
			isDarkerTheme = function(theme)
				-- Assume "darker" theme if the average main background colour is darker
				local mainColour = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
				return (mainColour.r + mainColour.g + mainColour.b) / 3 < 0.5
			end,
			themeChanged = settings().Studio.ThemeChanged
		}
	)
end

local function main()
	local theme = createTheme()

	local pluginHandle

	local function onPluginWillDestroy()
		if pluginHandle then
			Roact.unmount(pluginHandle)
		end
	end

	local mainManager = MainManager.new(plugin)

	local pluginComponent =
		Roact.createElement(
		MainPlugin,
		{
			plugin = plugin,
			theme = theme,
			mainManager = mainManager,
			onPluginWillDestroy = onPluginWillDestroy
		}
	)

	pluginHandle = Roact.mount(pluginComponent)
end

main()
