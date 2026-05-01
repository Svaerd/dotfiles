import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Widgets

Item {
  id: root

  property var pluginApi: null
  readonly property var mainInstance: pluginApi?.mainInstance ?? null
  readonly property var geometryPlaceholder: panelContainer
  property real contentPreferredWidth: 900 * Style.uiScaleRatio
  property real contentPreferredHeight: 700 * Style.uiScaleRatio
  readonly property bool allowAttach: true
  anchors.fill: parent

  property string backendPath: ""
  readonly property bool showOnlyConflicts: pluginApi?.pluginSettings?.showOnlyConflicts ?? true

  property bool loading: false
  property bool applying: false
  property string statusMessage: ""
  property int pendingApplyIndex: -1
  property int selectedGroupIndex: 0
  property var commonMimeTypes: [
    "inode/directory",
    "text/plain",
    "text/html",
    "application/pdf",
    "x-scheme-handler/http",
    "x-scheme-handler/https",
    "x-scheme-handler/mailto",
    "image/png",
    "image/jpeg",
    "image/gif",
    "video/mp4",
    "video/x-matroska",
    "audio/mpeg",
    "audio/flac",
    "application/zip",
    "application/x-tar",
    "application/gzip",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation"
  ]
  property var groupTabs: [
    { "key": "all", "name": pluginApi?.tr("panel.tab.all"), "count": 0 }
  ]

  property ListModel entriesModel: ListModel {}
  property ListModel filteredEntriesModel: ListModel {}
  property var allHandlers: ({})

  property var applyQueue: []
  property bool batchApplying: false

  property var commonTypesMeta: ({
    "x-scheme-handler/http":   { label: pluginApi?.tr("mime.http"),    category: pluginApi?.tr("category.internet"),   categoryOrder: 0 },
    "x-scheme-handler/https":  { label: pluginApi?.tr("mime.https"),  category: pluginApi?.tr("category.internet"),   categoryOrder: 0 },
    "x-scheme-handler/mailto": { label: pluginApi?.tr("mime.mailto"),   category: pluginApi?.tr("category.internet"),   categoryOrder: 0 },
    "image/png":               { label: pluginApi?.tr("mime.png"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "image/jpeg":              { label: pluginApi?.tr("mime.jpeg"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "image/gif":               { label: pluginApi?.tr("mime.gif"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "audio/mpeg":              { label: pluginApi?.tr("mime.mp3"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "audio/flac":              { label: pluginApi?.tr("mime.flac"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "video/mp4":               { label: pluginApi?.tr("mime.mp4"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "video/x-matroska":        { label: pluginApi?.tr("mime.mkv"),   category: pluginApi?.tr("category.multimedia"), categoryOrder: 1 },
    "text/plain":              { label: pluginApi?.tr("mime.text"),    category: pluginApi?.tr("category.documents"),  categoryOrder: 2 },
    "text/html":               { label: pluginApi?.tr("mime.html"),    category: pluginApi?.tr("category.documents"),  categoryOrder: 2 },
    "application/pdf":         { label: pluginApi?.tr("mime.pdf"),     category: pluginApi?.tr("category.documents"),  categoryOrder: 2 },
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document":   { label: pluginApi?.tr("mime.word"), category: pluginApi?.tr("category.documents"), categoryOrder: 2 },
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":         { label: pluginApi?.tr("mime.spreadsheet"),    category: pluginApi?.tr("category.documents"), categoryOrder: 2 },
    "application/vnd.openxmlformats-officedocument.presentationml.presentation": { label: pluginApi?.tr("mime.presentation"),   category: pluginApi?.tr("category.documents"), categoryOrder: 2 },
    "inode/directory":         { label: pluginApi?.tr("mime.directory"),   category: pluginApi?.tr("category.utilities"),  categoryOrder: 3 },
    "application/zip":         { label: pluginApi?.tr("mime.zip"), category: pluginApi?.tr("category.utilities"), categoryOrder: 3 },
    "application/x-tar":       { label: pluginApi?.tr("mime.tar"), category: pluginApi?.tr("category.utilities"), categoryOrder: 3 },
    "application/gzip":        { label: pluginApi?.tr("mime.gz"), category: pluginApi?.tr("category.utilities"), categoryOrder: 3 }
  })

  function updateBackendPath() {
    if (!pluginApi || !pluginApi.pluginDir) {
      backendPath = ""
      return
    }
    backendPath = pluginApi.pluginDir + "/mimeapps_backend.py"
  }

  function refreshList() {
    if (loading) return
    if (backendPath === "") {
      statusMessage = pluginApi?.tr("panel.status.backendNotReady")
      return
    }
    statusMessage = ""
    loading = true

    var args = ["python3", backendPath, "scan"]
    if (!showOnlyConflicts) {
      args.push("--all")
    }

    scanProcess.command = args
    scanProcess.running = true
  }

  function mimeGroupFromType(mimeType) {
    var text = String(mimeType || "")
    var slash = text.indexOf("/")
    if (slash <= 0) return "other"
    return text.substring(0, slash)
  }

  function selectedGroupKey() {
    if (!groupTabs || selectedGroupIndex < 0 || selectedGroupIndex >= groupTabs.length) {
      return "all"
    }
    return groupTabs[selectedGroupIndex].key
  }

  function rebuildGroupTabs() {
    var counts = {}
    var order = []
    var commonCount = 0

    for (var i = 0; i < entriesModel.count; i++) {
      var mimeType = entriesModel.get(i).mimeType
      if (commonMimeTypes.indexOf(mimeType) !== -1) {
        commonCount += 1
      }

      var group = mimeGroupFromType(entriesModel.get(i).mimeType)
      if (counts[group] === undefined) {
        counts[group] = 0
        order.push(group)
      }
      counts[group] += 1
    }

    order.sort()

    var tabs = [{ "key": "all", "name": pluginApi?.tr("panel.tab.all"), "count": entriesModel.count }]
    tabs.push({ "key": "common", "name": pluginApi?.tr("panel.tab.common"), "count": commonCount })
    for (var j = 0; j < order.length; j++) {
      var key = order[j]
      var trName = pluginApi?.tr("panel.tab." + key)
      // If translation is missing, fallback to capitalized key
      var name = (trName && !/^!!/.test(trName)) ? trName : key.charAt(0).toUpperCase() + key.slice(1)
      tabs.push({
        "key": key,
        "name": name,
        "count": counts[key]
      })
    }

    groupTabs = tabs

    selectedGroupIndex = 1
  }

  function rebuildFilteredEntries() {
    filteredEntriesModel.clear()

    var group = selectedGroupKey()
    var items = []
    for (var i = 0; i < entriesModel.count; i++) {
      var row = entriesModel.get(i)
      var include = group === "all"
        || (group === "common" && commonMimeTypes.indexOf(row.mimeType) !== -1)
        || mimeGroupFromType(row.mimeType) === group
      if (!include) continue

      var meta = commonTypesMeta[row.mimeType] || null
      items.push({
        sourceIndex: i,
        mimeType: row.mimeType,
        currentDefault: row.currentDefault,
        currentDefaultName: row.currentDefaultName,
        defaultSource: row.defaultSource,
        selectedDesktop: row.selectedDesktop,
        selectionDirty: row.selectionDirty,
        applying: row.applying,
        applyError: row.applyError,
        friendlyLabel: meta ? meta.label : row.mimeType,
        friendlyCategory: meta ? meta.category : mimeGroupFromType(row.mimeType),
        categoryOrder: meta ? meta.categoryOrder : 99
      })
    }

   
      items.sort(function(a, b) {
        if (a.categoryOrder !== b.categoryOrder) return a.categoryOrder - b.categoryOrder
        return a.friendlyLabel < b.friendlyLabel ? -1 : (a.friendlyLabel > b.friendlyLabel ? 1 : 0)
      })
    

    for (var j = 0; j < items.length; j++) {
      filteredEntriesModel.append(items[j])
    }
  }

  function syncFilteredRowFromSource(sourceIndex) {
    for (var i = 0; i < filteredEntriesModel.count; i++) {
      var item = filteredEntriesModel.get(i)
      if (item.sourceIndex !== sourceIndex) continue

      var src = entriesModel.get(sourceIndex)
      // handlers are now in allHandlers, not the model
      filteredEntriesModel.setProperty(i, "currentDefault", src.currentDefault)
      filteredEntriesModel.setProperty(i, "currentDefaultName", src.currentDefaultName)
      filteredEntriesModel.setProperty(i, "defaultSource", src.defaultSource)
      filteredEntriesModel.setProperty(i, "selectedDesktop", src.selectedDesktop)
      filteredEntriesModel.setProperty(i, "selectionDirty", src.selectionDirty)
      filteredEntriesModel.setProperty(i, "applying", src.applying)
      filteredEntriesModel.setProperty(i, "applyError", src.applyError)
      return
    }
  }

  function hasPendingCommonChanges() {
    for (var i = 0; i < entriesModel.count; i++) {
      var row = entriesModel.get(i)
      if (commonMimeTypes.indexOf(row.mimeType) !== -1 && row.selectionDirty) {
        return true
      }
    }
    return false
  }

  function handlerNameFor(index, desktopId) {
    var row = entriesModel.get(index)
    var handlers = row.handlers || []
    for (var i = 0; i < handlers.length; i++) {
      if (handlers[i].key === desktopId) {
        return handlers[i].name
      }
    }
    return desktopId
  }

  function applyDefault(sourceIndex) {
    if (applying || sourceIndex < 0 || sourceIndex >= entriesModel.count) return

    var row = entriesModel.get(sourceIndex)
    var selectedDesktop = row.selectedDesktop || ""
    if (!selectedDesktop) return

    pendingApplyIndex = sourceIndex
    applying = true
    statusMessage = ""

    entriesModel.setProperty(sourceIndex, "applyError", "")
    entriesModel.setProperty(sourceIndex, "applying", true)
    syncFilteredRowFromSource(sourceIndex)

    setProcess.command = [
      "python3",
      backendPath,
      "set-default",
      "--mime",
      row.mimeType,
      "--desktop",
      selectedDesktop
    ]
    setProcess.running = true
  }

  function startBatchApply() {
    if (applying || batchApplying) return
    var q = []
    for (var i = 0; i < entriesModel.count; i++) {
      var row = entriesModel.get(i)
      if (commonMimeTypes.indexOf(row.mimeType) !== -1 && row.selectionDirty) {
        q.push(i)
      }
    }
    if (q.length === 0) return
    batchApplying = true
    var first = q.shift()
    applyQueue = q
    applyDefault(first)
  }

  onPluginApiChanged: {
    updateBackendPath()
    if (backendPath !== "") {
      refreshList()
    }
  }

  Component.onCompleted: {
    updateBackendPath()
    if (backendPath !== "") {
      refreshList()
    }
  }

  Process {
    id: scanProcess
    running: false
    command: []

    stdout: StdioCollector {
      id: scanStdout
    }

    stderr: StdioCollector {
      id: scanStderr
    }

    onExited: (exitCode) => {
      root.loading = false

      if (exitCode !== 0) {
        root.statusMessage = scanStderr.text.trim() || pluginApi?.tr("panel.error.scanFailed")
        return
      }

      try {
        var payload = JSON.parse(scanStdout.text)
        if (!payload.ok) {
          root.statusMessage = payload.error || pluginApi?.tr("panel.error.scanFailedGeneric")
          return
        }

        root.entriesModel.clear()
        root.filteredEntriesModel.clear()

        var rows = payload.entries || []
        for (var i = 0; i < rows.length; i++) {
          var row = rows[i]
          var handlers = row.handlers || []
          var selectedDesktop = row.currentDefault || (handlers.length > 0 ? handlers[0].key : "")

          root.allHandlers[row.mimeType || ""] = handlers
          root.entriesModel.append({
            mimeType: row.mimeType || "",
            currentDefault: row.currentDefault || "",
            currentDefaultName: row.currentDefaultName || "",
            defaultSource: row.defaultSource || "",
            selectedDesktop: selectedDesktop,
            selectionDirty: false,
            applying: false,
            applyError: ""
          })
        }

        root.rebuildGroupTabs()
        root.rebuildFilteredEntries()

        if (root.filteredEntriesModel.count === 0) {
          root.statusMessage = root.showOnlyConflicts
            ? pluginApi?.tr("panel.status.noConflicts")
            : pluginApi?.tr("panel.status.noHandlers")
        }
      } catch (e) {
        root.statusMessage = pluginApi?.tr("panel.error.parseScanResult", { error: e })
      }
    }
  }

  Process {
    id: setProcess
    running: false
    command: []

    stdout: StdioCollector {
      id: setStdout
    }

    stderr: StdioCollector {
      id: setStderr
    }

    onExited: (exitCode) => {
      var index = root.pendingApplyIndex
      root.pendingApplyIndex = -1
      root.applying = false

      if (index >= 0 && index < root.entriesModel.count) {
        root.entriesModel.setProperty(index, "applying", false)
        root.syncFilteredRowFromSource(index)
      }

      if (exitCode !== 0) {
        var message = setStderr.text.trim() || pluginApi?.tr("panel.error.saveFailed")
        root.statusMessage = message
        if (index >= 0 && index < root.entriesModel.count) {
          root.entriesModel.setProperty(index, "applyError", message)
          root.syncFilteredRowFromSource(index)
        }
        root.batchApplying = false
        root.applyQueue = []
        return
      }

      try {
        var payload = JSON.parse(setStdout.text)
        if (!payload.ok) {
          var error = payload.error || pluginApi?.tr("panel.error.saveFailedGeneric")
          root.statusMessage = error
          if (index >= 0 && index < root.entriesModel.count) {
            root.entriesModel.setProperty(index, "applyError", error)
            root.syncFilteredRowFromSource(index)
          }
          root.batchApplying = false
          root.applyQueue = []
          return
        }

        if (index >= 0 && index < root.entriesModel.count) {
          var selected = root.entriesModel.get(index).selectedDesktop || ""
          root.entriesModel.setProperty(index, "currentDefault", selected)
          root.entriesModel.setProperty(index, "currentDefaultName", root.handlerNameFor(index, selected))
          root.entriesModel.setProperty(index, "defaultSource", payload.file || "")
          root.entriesModel.setProperty(index, "selectionDirty", false)
          root.entriesModel.setProperty(index, "applyError", "")
          root.syncFilteredRowFromSource(index)
        }

        root.statusMessage = pluginApi?.tr("panel.status.updatedDefault", { mimeType: payload.mimeType })
      } catch (e) {
        root.statusMessage = pluginApi?.tr("panel.status.updatedDefaultParseError", { error: e })
      }

      if (root.applyQueue.length > 0) {
        var q = root.applyQueue.slice()
        var next = q.shift()
        root.applyQueue = q
        root.applyDefault(next)
      } else {
        root.batchApplying = false
      }
    }
  }

  Rectangle {
    id: panelContainer
    anchors.fill: parent
    color: "transparent"

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL
      spacing: Style.marginM

      RowLayout {
        Layout.fillWidth: true

        NText {
          text: pluginApi?.tr("panel.title")
          pointSize: Style.fontSizeL
          font.weight: Font.DemiBold
          color: Color.mOnSurface
        }
      }

      NText {
        Layout.fillWidth: true
        text: pluginApi?.tr("panel.subtitle")
        pointSize: Style.fontSizeS
        color: Color.mOnSurfaceVariant
        wrapMode: Text.WordWrap
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Style.marginM

        Rectangle {
          Layout.preferredWidth: 220 * Style.uiScaleRatio
          Layout.fillHeight: true
          radius: Style.radiusM
          color: Color.mSurfaceVariant
          visible: root.groupTabs.length > 1

          ScrollView {
            anchors.fill: parent
            anchors.margins: Style.marginS
            clip: true

            ListView {
              id: groupListView
              model: root.groupTabs
              spacing: Style.marginS
              boundsBehavior: Flickable.StopAtBounds

              delegate: Rectangle {
                required property var modelData
                required property int index

                width: groupListView.width
                radius: Style.radiusS
                color: index === root.selectedGroupIndex ? Color.mPrimary : Color.mSurface
                implicitHeight: groupText.implicitHeight + (Style.marginS * 2)

                NText {
                  id: groupText
                  anchors.fill: parent
                  anchors.margins: Style.marginS
                  text: modelData.name + " (" + modelData.count + ")"
                  color: index === root.selectedGroupIndex ? Color.mOnPrimary : Color.mOnSurface
                  pointSize: Style.fontSizeS
                  font.weight: index === root.selectedGroupIndex ? Font.Medium : Font.Normal
                  wrapMode: Text.WordWrap
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.selectedGroupIndex = index
                    root.rebuildFilteredEntries()
                  }
                }
              }
            }
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: Style.marginM

          NText {
            Layout.fillWidth: true
            visible: root.loading
            text: pluginApi?.tr("panel.loading")
            pointSize: Style.fontSizeS
            color: Color.mOnSurfaceVariant
          }

          NText {
            Layout.fillWidth: true
            visible: root.statusMessage !== ""
            text: root.statusMessage
            pointSize: Style.fontSizeS
            color: root.statusMessage.toLowerCase().indexOf("failed") !== -1 ? Color.mError : Color.mOnSurfaceVariant
            wrapMode: Text.WordWrap
          }

          StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.selectedGroupKey() === "common" ? 1 : 0

            // ── Card view (all non-common groups) ──────────────────────────
            ScrollView {
              clip: true

              ListView {
                id: listView
                model: root.filteredEntriesModel
                spacing: Style.marginS
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                  required property int index
                  required property int sourceIndex
                  required property string mimeType
                  // handlers are now in allHandlers, not the model
                  required property string currentDefault
                  required property string currentDefaultName
                  required property string defaultSource
                  required property string selectedDesktop
                  required property bool selectionDirty
                  required property bool applying
                  required property string applyError

                  width: listView.width
                  color: Color.mSurfaceVariant
                  radius: Style.radiusM
                  implicitHeight: cardLayout.implicitHeight + (Style.marginM * 2)

                  ColumnLayout {
                    id: cardLayout
                    anchors.fill: parent
                    anchors.margins: Style.marginM
                    spacing: Style.marginS

                    NText {
                      Layout.fillWidth: true
                      text: mimeType
                      pointSize: Style.fontSizeM
                      font.weight: Font.Medium
                      color: Color.mOnSurface
                      wrapMode: Text.WordWrap
                    }

                    NText {
                      Layout.fillWidth: true
                      text: `${pluginApi?.tr("panel.current")}${currentDefaultName || currentDefault || pluginApi?.tr("panel.none")}`
                      pointSize: Style.fontSizeS
                      color: Color.mOnSurfaceVariant
                      wrapMode: Text.WordWrap
                    }

                    NText {
                      Layout.fillWidth: true
                      text: `${pluginApi?.tr("panel.source")}${defaultSource || pluginApi?.tr("panel.notConfigured")}`
                      pointSize: Style.fontSizeS
                      color: Color.mOnSurfaceVariant
                      wrapMode: Text.WordWrap
                    }

                    RowLayout {
                      Layout.fillWidth: true
                      spacing: Style.marginS

                      NComboBox {
                        Layout.fillWidth: true
                        label: pluginApi?.tr("panel.handler.label")
                        model: root.allHandlers[mimeType] || []
                        currentKey: selectedDesktop
                        enabled: !applying && !root.loading && !root.applying
                        onSelected: key => {
                          root.entriesModel.setProperty(sourceIndex, "selectedDesktop", key)
                          root.filteredEntriesModel.setProperty(index, "selectedDesktop", key)
                          root.entriesModel.setProperty(sourceIndex, "selectionDirty", key !== root.entriesModel.get(sourceIndex).currentDefault)
                          root.entriesModel.setProperty(sourceIndex, "applyError", "")
                          root.syncFilteredRowFromSource(sourceIndex)
                        }
                      }

                      NButton {
                        text: applying ? pluginApi?.tr("panel.apply.saving") : pluginApi?.tr("panel.apply.button")
                        icon: "check"
                        enabled: !applying && !root.loading && !root.applying && selectedDesktop !== "" && selectionDirty
                        onClicked: root.applyDefault(sourceIndex)
                      }
                    }

                    NText {
                      Layout.fillWidth: true
                      visible: applyError !== ""
                      text: applyError
                      pointSize: Style.fontSizeS
                      color: Color.mError
                      wrapMode: Text.WordWrap
                    }
                  }
                }
              }
            }

            // ── Common grouped form view ───────────────────────────────────
            ColumnLayout {
              spacing: Style.marginM

              ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ListView {
                  id: commonListView
                  model: root.filteredEntriesModel
                  spacing: Style.marginS
                  boundsBehavior: Flickable.StopAtBounds

                  section.property: "friendlyCategory"
                  section.criteria: ViewSection.FullString
                  section.delegate: Item {
                    width: commonListView.width
                    height: sectionLabel.implicitHeight + (Style.marginL * 2)

                    NText {
                      id: sectionLabel
                      anchors.centerIn: parent
                      text: section
                      pointSize: Style.fontSizeM
                      font.weight: Font.DemiBold
                      color: Color.mOnSurface
                    }
                  }

                  delegate: Rectangle {
                    required property int index
                    required property int sourceIndex
                    required property string mimeType
                    required property string selectedDesktop
                    required property bool selectionDirty
                    required property bool applying
                    required property string friendlyLabel

                    width: commonListView.width
                    height: innerRow.implicitHeight + Style.marginS
                    color: "transparent"

                    RowLayout {
                      id: innerRow
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: Style.marginM

                      NText {
                        Layout.preferredWidth: 180 * Style.uiScaleRatio
                        text: friendlyLabel + ":"
                        horizontalAlignment: Text.AlignRight
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                      }

                      NComboBox {
                        id: commonCombo
                        Layout.fillWidth: true
                        model: root.allHandlers[mimeType] || []
                        currentKey: selectedDesktop
                        enabled: !applying && !root.loading && !root.applying && !root.batchApplying
                        onSelected: key => {
                          root.entriesModel.setProperty(sourceIndex, "selectedDesktop", key)
                          root.filteredEntriesModel.setProperty(index, "selectedDesktop", key)
                          root.entriesModel.setProperty(sourceIndex, "selectionDirty", key !== root.entriesModel.get(sourceIndex).currentDefault)
                          root.entriesModel.setProperty(sourceIndex, "applyError", "")
                          root.syncFilteredRowFromSource(sourceIndex)
                        }
                      }
                    }
                  }
                }
              }

              RowLayout {
                Layout.fillWidth: true

                Item { Layout.fillWidth: true }

                NButton {
                  text: root.batchApplying ? pluginApi?.tr("panel.apply.saving") : pluginApi?.tr("panel.apply.button")
                  icon: "check"
                  enabled: !root.loading && !root.applying && !root.batchApplying && root.hasPendingCommonChanges()
                  onClicked: root.startBatchApply()
                }
              }
            }
          }
        }
      }
    }
  }
}
