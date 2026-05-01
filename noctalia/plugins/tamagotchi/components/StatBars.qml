import QtQuick
import QtQuick.Layouts
import qs.Commons

RowLayout {
    id: root
    spacing: Style.marginXS
    width: parent.width

    property var pluginApi: null
    property int hunger: pluginApi?.mainInstance?.hunger ?? 100
    property int happiness: pluginApi?.mainInstance?.happiness ?? 100
    property int cleanliness: pluginApi?.mainInstance?.cleanliness ?? 100
    property int energy: pluginApi?.mainInstance?.energy ?? 100

    component Gauge: Item {
        id: root

        property int value: 75
        property string icon: "🍗"

        width: 80
        height: 80

        readonly property real angle: (value / 100) * 360

        Canvas {
            id: bg
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var r = width / 2;
                ctx.beginPath();
                ctx.arc(r, r, r - 6, 0, 2 * Math.PI);
                ctx.strokeStyle = "rgba(255,255,255,0.1)";
                ctx.lineWidth = 8;
                ctx.stroke();
            }
        }

        Canvas {
            id: fg
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var r = width / 2;
                var start = -Math.PI / 2;
                var end = start + (root.angle * Math.PI / 180);

                ctx.beginPath();
                ctx.arc(r, r, r - 6, start, end);

                if (root.value < 25)
                    ctx.strokeStyle = "#E24B4A";
                else if (root.value < 50)
                    ctx.strokeStyle = "#EF9F27";
                else
                    ctx.strokeStyle = "#1D9E75";

                ctx.lineWidth = 8;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            Connections {
                target: root
                function onAngleChanged() {
                    fg.requestPaint();
                }
                function onValueChanged() {
                    fg.requestPaint();
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.icon
            font.pixelSize: Style.fontSizeXXL
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: Style.marginXS
            text: root.value + "%"
            opacity: (pluginApi?.pluginSettings?.showPercentage ?? false) ? 1 : 0
            font.pixelSize: Style.fontSizeM
            color: "white"
        }
    }

    Item {
        Layout.fillWidth: true
    }
    Gauge {
        value: hunger
        icon: "🍗"
    }
    Item {
        Layout.fillWidth: true
    }
    Gauge {
        value: happiness
        icon: "😃"
    }
    Item {
        Layout.fillWidth: true
    }
    Gauge {
        value: cleanliness
        icon: "🧼"
    }
    Item {
        Layout.fillWidth: true
    }
    Gauge {
        value: energy
        icon: "🛏️"
    }
    Item {
        Layout.fillWidth: true
    }
}
