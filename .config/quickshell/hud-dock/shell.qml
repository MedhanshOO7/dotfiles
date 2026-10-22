// HUD dock — one per monitor. Run: qs -c hud-dock   Toggle: qs -c hud-dock ipc call dock toggle
//
// Follows the HUD design system (~/.config/hud/tokens.css): matugen colours read live from
// ~/.local/state/quickshell/user/generated/colors.json, chamfered corners (tight top-left /
// bottom-right), 1px primary edge, corner ticks, segmented running indicators, tinted icons.
// Pins: ~/.config/hud/dock-pins.json (desktop-file ids); right-click an icon to pin/unpin.
//
// Blur: Hyprland blurs this surface through ext-background-effect (BackgroundEffect below),
// clipped to the panel's exact chamfered shape — no layer rule needed.

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

ShellRoot {
    id: root

    // ── tunables ─────────────────────────────────────────────────────────
    readonly property int iconSize: 40
    readonly property real tint: 0.9          // 0 = original icon colours, 1 = fully accent-tinted
    readonly property real hoverTint: 0.25    // tint while hovered (shows the real icon a bit)
    readonly property int edgeGap: 8          // gap between dock and screen edge
    readonly property int revealDelay: 120    // ms the pointer must rest on the edge
    readonly property int hideDelay: 600      // ms before hiding after the pointer leaves

    property bool enabled: true

    // ── palette (matugen) ────────────────────────────────────────────────
    property var pal: ({})
    function col(name, fallback) { return pal[name] !== undefined ? pal[name] : fallback }
    readonly property color primary: col("primary", "#bdc7d4")
    readonly property color onPrimary: col("on_primary", "#28313b")
    readonly property color text: col("on_surface", "#e4e2e3")
    readonly property color muted: col("on_surface_variant", "#c8c6c7")
    readonly property color surfaceDim: col("surface_dim", "#131314")
    readonly property color container: col("primary_container", "#3e4852")
    function alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/quickshell/user/generated/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.pal = JSON.parse(text()) } catch (e) { console.warn("hud-dock: bad colors.json", e) }
        }
    }

    // ── pins ────────────────────────────────────────────────────────────
    property var pins: []
    FileView {
        id: pinsFile
        path: Quickshell.env("HOME") + "/.config/hud/dock-pins.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.pins = JSON.parse(text()) } catch (e) { console.warn("hud-dock: bad dock-pins.json", e) }
        }
    }
    function savePins(list) {
        root.pins = list
        pinsFile.setText(JSON.stringify(list) + "\n")
    }

    // ── apps: pinned first (in pin order), then running-but-unpinned ─────
    function entryFor(id) {
        if (!id) return null
        return DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id)
    }
    function keyOf(entry, appId) { return entry ? entry.id : String(appId).toLowerCase() }

    readonly property var apps: {
        const toplevels = Hyprland.toplevels.values   // dependency: re-evaluates on window changes
        const list = []
        const byKey = {}
        for (const pin of root.pins) {
            const entry = entryFor(pin)
            const key = keyOf(entry, pin)
            if (byKey[key]) continue
            byKey[key] = { key: key, entry: entry, appId: pin, pinned: true, windows: [] }
            list.push(byKey[key])
        }
        for (const t of toplevels) {
            const appId = t.wayland ? t.wayland.appId : ""
            if (!appId) continue
            const entry = entryFor(appId)
            const key = keyOf(entry, appId)
            if (!byKey[key]) {
                byKey[key] = { key: key, entry: entry, appId: appId, pinned: false, windows: [] }
                list.push(byKey[key])
            }
            byKey[key].windows.push(t)
        }
        return list
    }

    // theme icon -> absolute path -> /usr/share/pixmaps (Qt's theme lookup skips pixmaps,
    // e.g. VS Code ships only pixmaps/vscode.png) -> generic fallback
    function iconFor(app) {
        const names = []
        if (app.entry && app.entry.icon) names.push(app.entry.icon)
        names.push(app.appId, String(app.appId).toLowerCase())
        for (const n of names) {
            if (n.startsWith("/")) return "file://" + n
            const p = Quickshell.iconPath(n, true)
            if (p) return p
        }
        return "file:///usr/share/pixmaps/" + names[0] + ".png"
    }

    function activate(app) {
        const wins = app.windows
        if (wins.length === 0) { launch(app); return }
        // already focused → cycle to the app's next window
        let idx = wins.findIndex(w => w.activated)
        const next = wins[(idx + 1) % wins.length]
        if (next.wayland) next.wayland.activate()
    }
    function launch(app) {
        if (app.entry) app.entry.execute()
        else Quickshell.execDetached([app.appId])
    }
    function togglePin(app) {
        const list = root.pins.slice()
        const at = list.findIndex(p => keyOf(entryFor(p), p) === app.key)
        if (at >= 0) list.splice(at, 1)
        else list.push(app.entry ? app.entry.id : app.appId)
        savePins(list)
    }

    IpcHandler {
        target: "dock"
        function toggle(): void { root.enabled = !root.enabled }
        function on(): void { root.enabled = true }   // ("show" is taken by the qs ipc CLI)
        function off(): void { root.enabled = false }
    }

    // ── one dock per monitor ────────────────────────────────────────────
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            readonly property var hmon: Hyprland.monitorFor(modelData)
            readonly property var ws: hmon ? hmon.activeWorkspace : null
            readonly property bool wsEmpty: ws ? ws.toplevels.values.length === 0 : true
            readonly property bool fullscreen: ws ? ws.hasFullscreen : false
            property bool hold: false     // pointer is on the dock or its trigger edge
            readonly property bool shown: root.enabled && !fullscreen && (wsEmpty || hold)

            anchors { bottom: true; left: true; right: true }
            implicitHeight: root.iconSize + 26 + 34 + root.edgeGap   // panel + tooltip room + gap
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "hud-dock"
            WlrLayershell.layer: WlrLayer.Top

            // Only the panel (or, when hidden, a thin edge strip) takes input
            mask: Region { item: win.shown ? panel : edge }

            BackgroundEffect.blurRegion: Region {
                item: win.shown ? panel : null
                topLeftRadius: 6; bottomRightRadius: 6
                topRightRadius: 20; bottomLeftRadius: 20
            }

            Timer { id: revealTimer; interval: root.revealDelay; onTriggered: win.hold = true }
            Timer { id: hideTimer; interval: root.hideDelay; onTriggered: win.hold = false }
            function pointer(inside) {
                if (inside) { hideTimer.stop(); if (!win.hold) revealTimer.restart() }
                else { revealTimer.stop(); hideTimer.restart() }
            }

            // trigger strip along the bottom edge
            MouseArea {
                id: edge
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 3
                hoverEnabled: true
                onContainsMouseChanged: win.pointer(containsMouse)
            }

            // ── the panel ──
            Rectangle {
                id: panel
                anchors.horizontalCenter: parent.horizontalCenter
                y: win.shown ? win.height - height - root.edgeGap : win.height + 4
                Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                opacity: win.shown ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 180 } }

                width: row.width + 20
                height: root.iconSize + 26
                topLeftRadius: 6; bottomRightRadius: 6
                topRightRadius: 20; bottomLeftRadius: 20
                color: root.alpha(root.surfaceDim, 0.58)          // @panel
                border.width: 1
                border.color: root.alpha(root.primary, 0.16)      // @edge

                // top-down sheen
                Rectangle {
                    anchors.fill: parent
                    radius: 0; topLeftRadius: 6; topRightRadius: 20
                    bottomLeftRadius: 20; bottomRightRadius: 6
                    gradient: Gradient {
                        GradientStop { position: 0; color: root.alpha(root.primary, 0.07) }
                        GradientStop { position: 0.6; color: "transparent" }
                    }
                }
                // corner ticks on the two tight corners
                Rectangle { x: 0; y: 0; width: 12; height: 2; color: root.alpha(root.primary, 0.85) }
                Rectangle { x: 0; y: 0; width: 2; height: 12; color: root.alpha(root.primary, 0.85) }
                Rectangle { x: panel.width - 12; y: panel.height - 2; width: 12; height: 2; color: root.alpha(root.primary, 0.85) }
                Rectangle { x: panel.width - 2; y: panel.height - 12; width: 2; height: 12; color: root.alpha(root.primary, 0.85) }

                HoverHandler { onHoveredChanged: win.pointer(hovered) }

                Row {
                    id: row
                    anchors.centerIn: parent
                    spacing: 4
                    property string hoveredLabel: ""   // set by DockButton, read by the tooltip
                    property real hoveredX: 0

                    // launcher
                    DockButton {
                        label: "Apps"
                        onLeftClicked: Quickshell.execDetached(["vicinae", "toggle"])
                        Text {
                            anchors.centerIn: parent
                            text: "󰀻"
                            font.family: "GeistMono Nerd Font Propo"
                            font.pixelSize: root.iconSize * 0.62
                            color: parent.hovered ? root.primary : root.text
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    // divider
                    Rectangle {
                        width: 1; height: root.iconSize * 0.7
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.alpha(root.primary, 0.22)
                    }

                    Repeater {
                        model: root.apps
                        DockButton {
                            id: btn
                            required property var modelData
                            readonly property bool running: modelData.windows.length > 0
                            readonly property bool focused: modelData.windows.some(w => w.activated)
                            label: modelData.entry ? modelData.entry.name : modelData.appId
                            onLeftClicked: root.activate(modelData)
                            onMiddleClicked: root.launch(modelData)
                            onRightClicked: root.togglePin(modelData)

                            IconImage {
                                id: icon
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -2
                                implicitSize: root.iconSize
                                mipmap: true
                                source: root.iconFor(btn.modelData)
                                onStatusChanged: if (status === Image.Error) source = Quickshell.iconPath("application-x-executable")
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: btn.hovered ? root.hoverTint : root.tint
                                    colorizationColor: root.primary
                                    Behavior on colorization { NumberAnimation { duration: 180 } }
                                }
                                opacity: btn.running || btn.hovered ? 1 : 0.72
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }

                            // segmented running indicator: one cell per window (max 3)
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 1
                                spacing: 2
                                Repeater {
                                    model: Math.min(btn.modelData.windows.length, 3)
                                    Rectangle {
                                        width: btn.focused ? 10 : 6; height: 2
                                        color: btn.focused ? root.primary : root.alpha(root.primary, 0.55)
                                        Behavior on width { NumberAnimation { duration: 150 } }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // tooltip chip above the hovered item
            Rectangle {
                id: tip
                visible: opacity > 0
                opacity: win.shown && row.hoveredLabel !== "" ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 120 } }
                x: Math.max(4, Math.min(win.width - width - 4, row.hoveredX - width / 2))
                y: panel.y - height - 6
                width: tipText.implicitWidth + 18
                height: tipText.implicitHeight + 8
                topLeftRadius: 3; bottomRightRadius: 3; topRightRadius: 10; bottomLeftRadius: 10
                color: root.alpha(root.surfaceDim, 0.86)
                border.width: 1
                border.color: root.alpha(root.primary, 0.35)
                Rectangle { width: 3; height: parent.height; color: root.primary; topLeftRadius: 3; bottomLeftRadius: 10 }
                Text {
                    id: tipText
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 1
                    text: row.hoveredLabel
                    color: root.text
                    font.family: "GeistMono Nerd Font Propo"
                    font.pixelSize: 13
                }
            }
        }
    }

    // ── a dock slot: hover chip, scale, click routing ───────────────────
    component DockButton: Item {
        id: slot
        property string label: ""
        readonly property bool hovered: mouse.containsMouse
        signal leftClicked()
        signal middleClicked()
        signal rightClicked()

        width: root.iconSize + 12
        height: root.iconSize + 14

        Rectangle {
            anchors.fill: parent
            topLeftRadius: 3; bottomRightRadius: 3; topRightRadius: 10; bottomLeftRadius: 10
            color: slot.hovered ? root.alpha(root.container, 0.55) : "transparent"
            border.width: slot.hovered ? 1 : 0
            border.color: root.alpha(root.primary, 0.55)
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        scale: mouse.pressed ? 0.94 : (slot.hovered ? 1.06 : 1)
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: e => {
                if (e.button === Qt.LeftButton) slot.leftClicked()
                else if (e.button === Qt.MiddleButton) slot.middleClicked()
                else slot.rightClicked()
            }
            onContainsMouseChanged: {
                const r = slot.parent   // the Row
                if (containsMouse) {
                    r.hoveredLabel = slot.label
                    r.hoveredX = slot.mapToItem(null, slot.width / 2, 0).x
                } else if (r.hoveredLabel === slot.label) {
                    r.hoveredLabel = ""
                }
            }
        }
    }
}
