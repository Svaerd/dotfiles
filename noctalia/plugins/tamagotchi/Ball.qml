import QtQuick
import qs.Commons

Rectangle {
    id: root
    width: 40
    height: 40
    radius: Style.radiusM
    color: "transparent"
    property real vx: 3
    property real vy: 0
    property real gravity: 0.7
    property real bounce: 0.9
    property real friction: 0.98
    property real forceMultiplier: 1.8

    property real rotationAngle: 0

    property bool canTriggerPlay: true
    property real speedThreshold: 15

    Image {
        id: sprite
        anchors.centerIn: parent

        width: root.width
        height: root.height

        source: "assets/ball.png"

        fillMode: Image.PreserveAspectFit
        smooth: false
        opacity: pluginApi?.mainInstance?.petState === "sleeping" ? 0 : 1
        rotation: root.rotationAngle
    }

    Timer {
        id: playCooldown
        interval: 500
        repeat: false

        onTriggered: {
            root.canTriggerPlay = true;
        }
    }

    Timer {
        id: physicsTimer
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            if (!root.parent)
                return;
            root.vy += root.gravity;
            root.x += root.vx * root.forceMultiplier;
            root.y += root.vy * root.forceMultiplier;

            var speed = Math.sqrt(root.vx * root.vx + root.vy * root.vy);

            if (speed > root.speedThreshold && root.canTriggerPlay) {
                root.canTriggerPlay = false;
                if (pluginApi?.mainInstance?.petState !== "sleeping") {
                    pluginApi?.mainInstance?.play(18);
                }
                playCooldown.start();
            }

            if (root.y + root.height >= root.parent.height) {
                root.y = root.parent.height - root.height;
                root.vy *= -root.bounce;
            }

            if (root.x <= 0) {
                root.x = 0;
                root.vx *= -1;
            }

            if (root.x + root.width >= root.parent.width) {
                root.x = root.parent.width - root.width;
                root.vx *= -1;
            }

            root.vx *= root.friction;
        }
    }

    MouseArea {
        anchors.fill: parent
        drag.target: root
        drag.axis: Drag.XAndYAxis
        preventStealing: true
        drag.filterChildren: true

        property real lastAbsX
        property real lastAbsY
        property real vxTemp
        property real vyTemp

        onPressed: mouse => {
            physicsTimer.running = false;
            root.vx = 0;
            root.vy = 0;
            var abs = mapToItem(root.parent, mouse.x, mouse.y);
            lastAbsX = abs.x;
            lastAbsY = abs.y;
            vxTemp = 0;
            vyTemp = 0;
        }

        onPositionChanged: mouse => {
            var abs = mapToItem(root.parent, mouse.x, mouse.y);

            abs.x = Math.max(0, Math.min(root.parent.width, abs.x));
            abs.y = Math.max(0, Math.min(root.parent.height, abs.y));

            vxTemp = abs.x - lastAbsX;
            vyTemp = abs.y - lastAbsY;

            lastAbsX = abs.x;
            lastAbsY = abs.y;
        }

        onReleased: {
            root.vx = vxTemp * 1.5;
            root.vy = vyTemp * 1.5;
            physicsTimer.running = true;
        }
    }
}
