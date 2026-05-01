import "./components"
import QtMultimedia
import QtQuick
import QtQuick.Layouts
import qs.Commons

Item {
    id: root

    property var pluginApi: null
    property real contentPreferredWidth: 400 * Style.uiScaleRatio
    property real contentPreferredHeight: 430 * Style.uiScaleRatio
    readonly property var geometryPlaceholder: root
    readonly property bool allowAttach: true

    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.marginXS
        spacing: Style.marginXL

        StatBars {
            Layout.fillWidth: true
            pluginApi: root.pluginApi
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 350

            Pet {
                pluginApi: root.pluginApi
                anchors.centerIn: parent
            }

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right

                Item {
                    Layout.fillWidth: true
                }

                Bed {
                    pluginApi: root.pluginApi
                }

                Item {
                    Layout.fillWidth: true
                }

                Food {
                    pluginApi: root.pluginApi
                }

                Item {
                    Layout.fillWidth: true
                }

                Soap {}

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        Ball {
            Layout.alignment: Qt.AlignHCenter
        }

        DebugButtons {
            pluginApi: root.pluginApi
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
