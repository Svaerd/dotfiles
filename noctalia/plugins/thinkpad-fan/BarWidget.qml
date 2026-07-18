import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    // ===== NOCTALIA REQUIRED PROPERTIES =====
    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property string screenName: screen ? (screen.name ?? "") : ""
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(root.screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(root.screenName)
    readonly property string fixedFont: Settings.data.ui.fontFixed

    // Special fan level identifiers as reported by /proc/acpi/ibm/fan
    readonly property string levelAuto: "auto"
    readonly property string levelOff: "0"
    readonly property string levelUnknown: "unknown"

    // procfs/sysfs don't emit inotify events — values must be polled
    readonly property int pollIntervalMs: 2000
    readonly property int refreshDelayMs: 300

    property int fanRpm: 0
    property string fanLevel: levelAuto
    property int currentTemp: 0
    property bool isInitialized: false

    // ===== READING NATIVE NOCTALIA SETTINGS =====
    readonly property bool colorizeByStatus:
        pluginApi?.pluginSettings?.colorizeByStatus ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorizeByStatus ??
        true

    readonly property bool allowPopupOpening:
        pluginApi?.pluginSettings?.allowPopupOpening ??
        pluginApi?.manifest?.metadata?.defaultSettings?.allowPopupOpening ??
        true

    // Per-mode colors. An empty value means "neutral" (match the bar): off and
    // forced-speed default to a theme color, automatic defaults to neutral.
    readonly property var rawColorLevel0:
        pluginApi?.pluginSettings?.colorLevel0 ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorLevel0 ??
        Color.mError
    readonly property var rawColorActive:
        pluginApi?.pluginSettings?.colorActive ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorActive ??
        Color.mPrimary
    readonly property var rawColorAuto:
        pluginApi?.pluginSettings?.colorAuto ??
        pluginApi?.manifest?.metadata?.defaultSettings?.colorAuto ??
        ""

    readonly property bool level0IsNeutral: String(rawColorLevel0).length === 0
    readonly property bool activeIsNeutral: String(rawColorActive).length === 0
    readonly property bool autoIsNeutral: String(rawColorAuto).length === 0

    readonly property string colorLevel0: level0IsNeutral ? Style.capsuleColor : rawColorLevel0
    readonly property string colorActive: activeIsNeutral ? Style.capsuleColor : rawColorActive
    readonly property string colorAuto: autoIsNeutral ? Style.capsuleColor : rawColorAuto

    readonly property real contentWidth: layout.implicitWidth + Style.marginS * 2
    readonly property real contentHeight: capsuleHeight
    implicitWidth: contentWidth
    implicitHeight: Style.barHeight

    Component.onCompleted: {
        if (pluginApi) {
            pluginApi.mainInstance = root;
        }
        fanLoader.reload();
        tempLoader.reload();
    }

    // Hardware fan monitoring (passive tracking bound to thinkfan)
    FileView {
        id: fanLoader
        path: "/proc/acpi/ibm/fan"
        printErrors: false
        onLoaded: {
            let content = text();
            if (content) {
                let lines = content.split("\n");
                let parsedRpm = 0;
                let parsedLevel = root.levelAuto;

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (line.indexOf("speed:") === 0) {
                        parsedRpm = parseInt(line.split(":")[1].trim());
                        if (isNaN(parsedRpm)) parsedRpm = 0;
                    } else if (line.indexOf("level:") === 0) {
                        parsedLevel = line.split(":")[1].replace(/[\r\n\t]/g, "").trim().toLowerCase();
                    }
                }

                root.fanRpm = parsedRpm;
                root.fanLevel = parsedLevel;
                root.isInitialized = true;
            }
        }
    }

    // System temperature monitoring
    FileView {
        id: tempLoader
        path: "/sys/class/thermal/thermal_zone0/temp"
        printErrors: false
        onLoaded: {
            let val = text();
            if (val) {
                let parsed = parseInt(val.trim());
                if (!isNaN(parsed)) {
                    root.currentTemp = Math.round(parsed / 1000);
                }
            }
        }
    }

    // Persistent process responsible for applying fan level changes
    Process {
        id: fanProcess
        onExited: (exitCode, exitStatus) => {
            refreshTimer.start();
        }
    }

    // Executing ACPI fan commands
    function setFanSpeed(targetLevel) {
        if (!root.isInitialized) {
            return;
        }

        let cleanLevel = String(targetLevel).replace(/[\r\n\t]/g, "").trim().toLowerCase();
        if (!cleanLevel || cleanLevel === root.levelUnknown) {
            return;
        }

        root.fanLevel = cleanLevel;
        fanProcess.running = false;
        fanProcess.command = ["sh", "-c", "echo level " + cleanLevel + " > /proc/acpi/ibm/fan"];
        fanProcess.running = true;
    }

    Timer { id: refreshTimer; interval: root.refreshDelayMs; repeat: false; onTriggered: { fanLoader.reload(); tempLoader.reload(); } }
    Timer { interval: root.pollIntervalMs; running: true; repeat: true; triggeredOnStart: true; onTriggered: { fanLoader.reload(); tempLoader.reload(); } }

    readonly property bool isCustomActive: root.fanLevel !== root.levelAuto && root.fanLevel !== root.levelOff
    readonly property bool isOff: root.fanLevel === root.levelOff

    // Resolved color + neutral flag for the currently active fan mode
    readonly property bool currentIsNeutral:
        !root.colorizeByStatus
        || (root.isCustomActive ? root.activeIsNeutral
            : (root.isOff ? root.level0IsNeutral : root.autoIsNeutral))
    readonly property string currentColor:
        root.isCustomActive ? root.colorActive
        : (root.isOff ? root.colorLevel0 : root.colorAuto)

    // ===== NATIVE NOCTALIA CONTEXT MENU =====
    NPopupContextMenu {
        id: contextMenu

        model: [
            {
                "label": pluginApi?.tr("menu.widget-settings"),
                "action": "settings",
                "icon": "settings"
            }
        ]

        onTriggered: action => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)

            if (action === "settings") {
                if (pluginApi?.manifest) {
                    BarService.openPluginSettings(screen, pluginApi.manifest)
                }
            }
        }
    }

    // ===== GRAPHICAL INTERFACE (CAPSULE) =====
    Rectangle {
        id: visualCapsule
        anchors.centerIn: parent
        width: root.contentWidth
        height: root.contentHeight
        radius: Style.radiusL
        
        color: root.currentIsNeutral ? Style.capsuleColor : root.currentColor
        border.color: root.currentIsNeutral ? Style.capsuleBorderColor : root.currentColor
        border.width: Style.capsuleBorderWidth

        RowLayout {
            id: layout
            anchors.centerIn: parent
            spacing: Style.marginXS

            NIcon {
                id: fanIcon
                icon: "car-fan"
                color: root.currentIsNeutral ? Color.mOnSurface : Color.mOnPrimary
            }

            NText {
                id: fanText
                text: root.fanRpm + " RPM"
                pointSize: barFontSize
                font.family: root.fixedFont
                font.weight: Font.Bold
                color: root.currentIsNeutral ? Color.mOnSurface : Color.mOnPrimary
            }
        }
    }

    // ===== INTERACTION MANAGEMENT =====
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                PanelService.showContextMenu(contextMenu, root, screen)
            } else if (mouse.button === Qt.LeftButton) {
                if (root.allowPopupOpening && pluginApi && typeof pluginApi.openPanel === "function") {
                    pluginApi.openPanel(root.screen, root);
                }
            }
        }
    }
}
