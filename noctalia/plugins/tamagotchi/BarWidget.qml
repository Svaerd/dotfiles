import QtQuick
import Quickshell
import qs.Commons
import qs.Widgets
import QtQuick.Layouts

Item {
    id: root

    property var pluginApi: null
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0
    property ShellScreen screen

    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screen?.name ?? "")

    implicitHeight: capsuleHeight
    implicitWidth: content.implicitWidth + Style.marginM * 2

    readonly property int _minStat: Math.min(pluginApi?.mainInstance?.hunger, pluginApi?.mainInstance?.happiness, pluginApi?.mainInstance?.cleanliness)

    readonly property string _statIcon: {
        var ts = pluginApi?.mainInstance;
        var mn = Math.min(ts.hunger, ts.happiness, ts.cleanliness);
        if (mn === ts.hunger)
            return "🍗";
        else if (mn === ts.happiness)
            return "💛";
        else
            return "🧼";
    }

    readonly property string _petEmoji: {
        var s = pluginApi?.mainInstance?.petState;
        var map = {
            "idle": "🐸",
            "sleeping": "😴",
            "sad": "😢"
        };
        return map[s] ?? "🐸";
    }

    readonly property color _alertColor: {
        if (_minStat < 20)
            return "#E24B4A";
        if (_minStat < 40)
            return "#EF9F27";
        return Color.mOnSurface;
    }

    Rectangle {
        anchors.centerIn: parent
        height: capsuleHeight
        width: root.implicitWidth
        radius: Style.radiusL
        color: Color.mSurfaceVariant

        border.color: root._minStat < 20 ? "#E24B4A" : "transparent"
        border.width: root._minStat < 20 ? 1 : 0

        SequentialAnimation on border.width {
            running: root._minStat < 20
            loops: Animation.Infinite
            NumberAnimation {
                to: 2
                duration: 500
            }
            NumberAnimation {
                to: 0
                duration: 500
            }
        }

        RowLayout {
            id: content
            anchors.centerIn: parent
            spacing: Style.marginM
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: root._petEmoji
                font.pixelSize: Style.fontSizeM
                color: Color.mOnSurface
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root._statIcon
                font.pixelSize: Style.fontSizeM
                visible: root._minStat < 60
                color: root._alertColor
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: root._minStat + "%"
                font.pixelSize: Style.fontSizeM
                color: root._alertColor
                Layout.alignment: Qt.AlignVCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (pluginApi) {
                pluginApi.openPanel(root.screen, root);
            }
        }
    }
}
