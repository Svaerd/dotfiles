import QtQuick

Item {
    id: root
    property var pluginApi: null

    readonly property var cfg: pluginApi?.pluginSettings ?? ({})

    property int hunger: cfg.hunger ?? 100
    property int happiness: cfg.happiness ?? 100
    property int cleanliness: cfg.cleanliness ?? 100
    property int energy: cfg.energy ?? 100

    property real difficulty: pluginApi?.pluginSettings?.difficulty ?? 50
    readonly property real difficultyFactor: {
        // 0 = too slow, 100 = fast
        return 0.3 + (difficulty / 100) * 1.7;
    }

    property bool _sleeping: false
    property bool eating: false
    readonly property bool isDirty: cleanliness < 20
    property string lastPetState: "idle"
    readonly property string petState: {
        if (root._sleeping && energy > 98)
            return lastPetState;

        if (root._sleeping)
            return "sleeping";

        const isSad = happiness < 30;
        const isTired = energy < 30;
        const isHungry = hunger < 20;

        if (isSad && isHungry && isTired)
            return "angry";
        else if (isHungry)
            return "hungry";
        else if (isSad)
            return "sad";
        else if (isTired)
            return "tired";
        else
            return "idle";
    }

    function save() {
        if (!pluginApi)
            return;
        pluginApi.pluginSettings.hunger = hunger;
        pluginApi.pluginSettings.happiness = happiness;
        pluginApi.pluginSettings.cleanliness = cleanliness;
        pluginApi.pluginSettings.energy = energy;
        pluginApi.saveSettings();
    }

    function sleep() {
        if (root._sleeping) {
            root._sleeping = false;
        } else {
            lastPetState = petState;
            root._sleeping = true;
        }
        save();
    }

    function clean(c) {
        cleanliness = Math.min(100, cleanliness + c);
        save();
    }

    function feed(v) {
        hunger = Math.min(100, hunger + v);
        save();
    }

    function play(h, e = 3) {
        if (energy < 10 || happiness >= 99)
            return;
        happiness = Math.min(100, happiness + h);
        energy = Math.max(0, energy - e);
        save();
    }

    function _randFactor(min = 0.5, max = 1.7) {
        return min + Math.random() * (max - min);
    }

    function decay() {
        const f = difficultyFactor;

        if (_sleeping) {
            energy = Math.min(100, energy + 3.5 * _randFactor());
            hunger = Math.max(0, hunger - 0.03 * f * _randFactor());
            happiness = Math.max(0, happiness - 0.005 * f * _randFactor());
            cleanliness = Math.max(0, cleanliness - 0.02 * f * _randFactor());
        } else {
            energy = Math.max(0, energy - 0.03 * f * _randFactor());
            hunger = Math.max(0, hunger - 0.05 * f * _randFactor());
            happiness = Math.max(0, happiness - 0.005 * f * _randFactor());
            cleanliness = Math.max(0, cleanliness - 0.05 * f * _randFactor());
        }

        save();
    }

    Timer {
        interval: 30000 // 30 segs
        running: true
        repeat: true
        onTriggered: root.decay()
    }
}
