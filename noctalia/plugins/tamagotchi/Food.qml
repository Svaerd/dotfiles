import QtQuick
import qs.Commons

Rectangle {
    id: root

    property var pluginApi: null
    property bool _dragging: false
    property bool wasDropped: false
    property real _restX: x
    property real _restY: y

    width: 64
    height: 64
    radius: Style.radiusM
    color: "transparent"
    Drag.active: _dragging
    Drag.keys: ["food"]
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    Image {
        anchors.fill: parent
        anchors.margins: Style.marginXS
        z: 10
        scale: _dragging ? 0.7 : 1
        source: "assets/monster.png"
        fillMode: Image.PreserveAspectFit
        smooth: false

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutBack
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width + 6
        height: parent.height + 6
        radius: parent.radius + 3
        color: Color.mPrimary
        opacity: _dragging ? 0 : 1
        z: -1
    }

    MouseArea {
        anchors.fill: parent
        drag.target: root
        drag.axis: Drag.XAndYAxis
        onPressed: {
            root.Drag.active = true;
            root._dragging = true;
            root._restX = root.x;
            root._restY = root.y;
            if (pluginApi && pluginApi.mainInstance) {
                if (pluginApi.mainInstance.petState === "sleeping")
                    return;

                pluginApi.mainInstance.eating = true;
            }
        }
        onReleased: {
            root._dragging = false;
            root.Drag.drop();
            if (pluginApi && pluginApi.mainInstance)
                pluginApi.mainInstance.eating = false;

            if (root.wasDropped) {
                disappearAnim.start();
            } else {
                root.x = root._restX;
                root.y = root._restY;
            }
            root.wasDropped = false;
        }
    }

    SequentialAnimation {
        id: disappearAnim

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "scale"
                to: 1.6
                duration: 200
            }

            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: 200
            }
        }

        ScriptAction {
            script: {
                root.scale = 1;
                root.opacity = 1;
                root.x = root._restX;
                root.y = root._restY;
            }
        }
    }
}
