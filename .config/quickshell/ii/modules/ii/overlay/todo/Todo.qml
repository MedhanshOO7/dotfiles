pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.modules.common
import qs.modules.ii.overlay

StyledOverlayWidget {
    id: root
    title: Translation.tr("To-do List")
    showCenterButton: true
    showClickabilityButton: true
    minimumWidth: 320
    minimumHeight: 280

    contentItem: TodoContent {
        radius: root.contentRadius
        isClickthrough: root.clickthrough
    }
}
