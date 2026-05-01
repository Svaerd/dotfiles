import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
	id: root

	property var pluginApi: null

	property ShellScreen screen
	property string widgetId: ""
	property string section: ""
	property int sectionWidgetIndex: -1
	property int sectionWidgetsCount: 0

	property var cfg: pluginApi?.pluginSettings || ({})
	property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

	readonly property string iconColorKey: cfg.iconColor ?? defaults.iconColor

	icon: "file-dots"
	tooltipText: pluginApi?.tr("bar.tooltip")
	tooltipDirection: BarService.getTooltipDirection(screen?.name)
	baseSize: Style.getCapsuleHeightForScreen(screen?.name)
	applyUiScale: false
	customRadius: Style.radiusL
	colorBg: Style.capsuleColor
	colorFg: Color.resolveColorKey(iconColorKey)

	border.color: Style.capsuleBorderColor
	border.width: Style.capsuleBorderWidth

	onClicked: {
		if (pluginApi) {
			pluginApi.togglePanel(root.screen, this);
		}
	}

	onRightClicked: {
		PanelService.showContextMenu(contextMenu, root, screen);
	}

	NPopupContextMenu {
		id: contextMenu

		model: [
			{
				"label": pluginApi?.tr("contextMenu.widget-settings"),
				"action": "widgetSettings",
				"icon": "settings"
			}
		]

		onTriggered: function (action) {
			contextMenu.close();
			PanelService.closeContextMenu(screen);
			if (action === "widgetSettings") {
				BarService.openPluginSettings(root.screen, pluginApi.manifest);
			}
		}
	}
}
