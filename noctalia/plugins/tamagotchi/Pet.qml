import QtQuick
import qs.Commons
import "./components"
import QtMultimedia

Item {
    id: root

    property var pluginApi: null

    width: animCtrl.frameW
    height: animCtrl.frameH

    AnimationController {
        id: animCtrl
        pluginApi: root.pluginApi
        anchors.centerIn: parent
        frameH: 220
        frameW: 220
    }

    Repeater {
        id: foodParticles
        model: 5
        delegate: Text {
            id: foodParticle

            text: ["🍗", "✨", "💛", "🌟", "💫"][index]
            font.pixelSize: Style.fontSizeXL

            property real startX: 0
            property real startY: 0

            opacity: 0
            visible: false

            Component.onCompleted: {
                resetPosition();
            }

            function resetPosition() {
                startX = root.width / 2 + (Math.random() * 60 - 30);
                startY = root.height / 2;

                x = startX;
                y = startY;
            }

            function burst() {
                resetPosition();

                visible = true;
                opacity = 1;
                burstAnim.restart();
            }

            SequentialAnimation {
                id: burstAnim

                ParallelAnimation {
                    NumberAnimation {
                        target: foodParticle
                        property: "y"
                        to: foodParticle.startY - 40 - Math.random() * 20
                        duration: 600
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: foodParticle
                        property: "opacity"
                        to: 0
                        duration: 600
                        easing.type: Easing.InQuad
                    }
                }

                ScriptAction {
                    script: {
                        foodParticle.visible = false;
                        foodParticle.x = foodParticle.startX;
                        foodParticle.y = foodParticle.startY;
                    }
                }
            }
        }
    }

    Repeater {
        id: cleanParticles
        model: 5
        delegate: Text {
            id: cleanParticle
            text: ["🧼", "✨", "💧", "⭐", "🫧"][index]
            font.pixelSize: Style.fontSizeXL

            property real startX: 0
            property real startY: 0

            opacity: 0
            visible: false

            Component.onCompleted: {
                resetPosition();
            }

            function resetPosition() {
                startX = root.width / 2 + (Math.random() * 60 - 30);
                startY = root.height / 2;

                x = startX;
                y = startY;
            }

            function burst() {
                resetPosition();

                visible = true;
                opacity = 1;
                burstAnim.restart();
            }

            SequentialAnimation {
                id: burstAnim

                ParallelAnimation {
                    NumberAnimation {
                        target: cleanParticle
                        property: "y"
                        to: cleanParticle.startY - 40 - Math.random() * 20
                        duration: 600
                        easing.type: Easing.OutCubic
                    }

                    NumberAnimation {
                        target: cleanParticle
                        property: "opacity"
                        to: 0
                        duration: 600
                        easing.type: Easing.InQuad
                    }
                }

                ScriptAction {
                    script: {
                        cleanParticle.visible = false;
                        cleanParticle.x = cleanParticle.startX;
                        cleanParticle.y = cleanParticle.startY;
                    }
                }
            }
        }
    }

    SoundEffect {
        id: soundEat
        source: "sounds/eat.wav"
        volume: pluginApi?.pluginSettings?.volume ?? 1.0
    }
    DropArea {
        anchors.fill: parent
        keys: ["food"]
        z: 999

        onDropped: drop => {
            drop.acceptProposedAction();

            if (drop.source) {
                drop.source.wasDropped = true;
            }

            if (pluginApi?.mainInstance?.petState === "sleeping")
                return;
            pluginApi?.mainInstance?.feed(10);
            soundEat.play();
            root.burstFood();
        }

        Rectangle {
            anchors.topMargin: 100
            anchors.fill: parent
            color: "transparent"
            radius: parent.width / 2
            opacity: 1
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }

    DropArea {
        id: soapDrop
        anchors.fill: parent
        keys: ["soap"]
        z: 999

        property bool active: containsDrag

        onEntered: {
            cleanTimer.start();
        }

        onExited: {
            cleanTimer.stop();
        }

        Rectangle {
            anchors.topMargin: 100
            anchors.fill: parent
            radius: parent.width / 2
            color: "transparent"
            opacity: 1
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }

    Timer {
        id: cleanTimer
        interval: 120
        repeat: true

        onTriggered: {
            pluginApi?.mainInstance?.clean(2.5);
            root.burstClean();
        }
    }

    function burstFood() {
        for (var i = 0; i < foodParticles.count; i++) {
            var item = foodParticles.itemAt(i);
            if (item)
                item.burst();
        }
    }

    function burstClean() {
        for (var i = 0; i < cleanParticles.count; i++) {
            var item = cleanParticles.itemAt(i);
            if (item)
                item.burst();
        }
    }
}
