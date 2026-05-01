import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
	id: root

	property var pluginApi: null

	property var cfg: pluginApi?.pluginSettings || ({})
	property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

	property string valueIconColor: cfg.iconColor ?? defaults.iconColor

	spacing: Style.marginM

	NColorChoice {
		label: pluginApi?.tr("settings.iconColor.label")
		description: pluginApi?.tr("settings.iconColor.desc")
		currentKey: root.valueIconColor
		onSelected: key => root.valueIconColor = key
	}

	NDivider {
		Layout.fillWidth: true
		Layout.topMargin: Style.marginS
		Layout.bottomMargin: Style.marginS
	}

	ColumnLayout {
		Layout.fillWidth: true

		NLabel {
			label: pluginApi?.tr("settings.ipcCommands.label")
			description: pluginApi?.tr("settings.ipcCommands.desc")
		}

		Rectangle {
			Layout.fillWidth: true
			Layout.preferredHeight: commandText.implicitHeight + Style.marginM * 2
			color: Color.mSurfaceVariant
			radius: Style.radiusM

			TextEdit {
				id: commandText
				anchors.fill: parent
				anchors.margins: Style.marginM
				text: "qs -c noctalia-shell ipc call plugin:mimeapp-gui openPanel"
				font.pointSize: Style.fontSizeS
				font.family: Settings.data.ui.fontFixed
				color: Color.mPrimary
				wrapMode: TextEdit.WrapAnywhere
				readOnly: true
				selectByMouse: true
				selectionColor: Color.mPrimary
				selectedTextColor: Color.mOnPrimary
			}
		}
	}

	function saveSettings() {
		if (!pluginApi) {
			Logger.e("MimeApp GUI", "Cannot save settings: pluginApi is null");
			return;
		}

		pluginApi.pluginSettings.iconColor = root.valueIconColor;
		pluginApi.saveSettings();

		Logger.d("MimeApp GUI", "Settings saved");
	}
}
