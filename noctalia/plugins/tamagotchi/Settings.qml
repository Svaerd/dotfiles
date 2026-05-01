import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    spacing: Style.marginM

    property var pluginApi: null
    property real editVolume: pluginApi?.pluginSettings?.volume ?? 0.5
    property real editDifficulty: pluginApi?.pluginSettings?.difficulty ?? 50
    property bool editShowDebug: pluginApi?.pluginSettings?.showDebug ?? false
    property bool showPercentage: pluginApi?.pluginSettings?.showPercentage ?? false

    function saveSettings() {
        pluginApi.pluginSettings.volume = root.editVolume;
        pluginApi.pluginSettings.difficulty = root.editDifficulty;
        pluginApi.pluginSettings.showDebug = root.editShowDebug;
        pluginApi.pluginSettings.showPercentage = root.showPercentage;
        pluginApi.saveSettings();
    }

    NLabel {
        label: pluginApi?.tr("settings.volume")
        description: pluginApi?.tr("settings.volume-desc")
    }

    NSlider {
        Layout.fillWidth: true
        from: 0
        to: 1
        value: root.editVolume
        onValueChanged: root.editVolume = value
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    NLabel {
        label: pluginApi?.tr("settings.difficulty")
        description: pluginApi?.tr("settings.difficulty-desc")
    }

    NSlider {
        Layout.fillWidth: true
        from: 0
        to: 100
        value: root.editDifficulty
        onValueChanged: root.editDifficulty = value
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.debug")
        description: pluginApi?.tr("settings.debug-desc")
        checked: root.editShowDebug
        onToggled: checked => root.editShowDebug = checked
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    NToggle {
        Layout.fillWidth: true
        label: pluginApi?.tr("settings.percentage")
        description: pluginApi?.tr("settings.percentage-desc")
        checked: root.showPercentage ?? false
        onToggled: checked => root.showPercentage = checked
    }

    Item {
        Layout.fillHeight: true
    }
}
