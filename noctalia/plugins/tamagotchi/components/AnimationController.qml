import QtQuick

Item {
    id: root

    property var pluginApi: null
    property int frameH: 64
    property int frameW: 64
    property int spriteH: 40
    property int spriteW: 40
    readonly property var _imageMap: ({
            "idle": "../assets/sapo_idle.png",
            "sleeping": "../assets/sapo_sleeping.png",
            "sad": "../assets/sapo_sad.png",
            "tired": "../assets/sapo_tired.png",
            "hungry": "../assets/sapo_hungry.png",
            "angry": "../assets/sapo_angry.png"
        })
    readonly property var _spriteStates: ["idle", "sad", "hungry", "tired", "angry"]

    implicitWidth: frameW
    implicitHeight: frameH

    Image {
        id: sprite

        property string currentState: pluginApi.mainInstance.petState

        anchors.centerIn: parent
        width: root.frameW
        height: root.frameH
        source: root._imageMap[currentState] ?? "../assets/sapo_idle.png"
        fillMode: Image.PreserveAspectFit
        smooth: false
        sourceClipRect: {
            const state = pluginApi.mainInstance;
            const DIRTY_SPRITE_COORDS = root.spriteW * 2;
            const DIRTY_EATING_SPRITE_COORDS = root.spriteW * 3;
            if (state.isDirty && root._spriteStates.includes(currentState)) {
                if (state.eating && root._spriteStates.includes(currentState))
                    return Qt.rect(DIRTY_EATING_SPRITE_COORDS, 0, root.spriteW, root.spriteH);

                return Qt.rect(DIRTY_SPRITE_COORDS, 0, root.spriteW, root.spriteH);
            }
            if (state.eating && root._spriteStates.includes(currentState))
                return Qt.rect(root.spriteW, 0, root.spriteW, root.spriteH);

            return Qt.rect(0, 0, root.spriteW, root.spriteH);
        }
    }

    Image {
        anchors.centerIn: parent
        width: root.frameW
        height: root.frameH
        source: "../assets/flies.png"
        fillMode: Image.PreserveAspectFit
        smooth: false
        visible: pluginApi.mainInstance.isDirty && pluginApi.mainInstance.petState != "angry" && root._spriteStates.includes(pluginApi.mainInstance.petState)
        z: 1
    }
}
