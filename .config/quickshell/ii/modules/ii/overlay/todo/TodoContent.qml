pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.ii.overlay

OverlayBackground {
    id: root

    required property real radius
    required property bool isClickthrough

    readonly property var allTasks: Todo.list.map((item, i) => Object.assign({}, item, {originalIndex: i}))
    readonly property var unfinishedTasks: allTasks.filter(item => !item.done)
    readonly property var doneTasks: allTasks.filter(item => item.done)
    readonly property int totalCount: allTasks.length
    readonly property int unfinishedCount: unfinishedTasks.length
    readonly property int doneCount: doneTasks.length
    readonly property real progress: totalCount > 0 ? (doneCount / totalCount) : 0
    readonly property var currentTaskList: tabBar.currentIndex === 0 ? unfinishedTasks : doneTasks

    property real padding: 10

    ColumnLayout {
        anchors {
            fill: parent
            margins: root.padding
        }
        spacing: 8

        // Tab bar for switching between Unfinished and Done tasks
        SecondaryTabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: Persistent.states.overlay?.todo?.tabIndex ?? 0
            onCurrentIndexChanged: {
                if (Persistent.states.overlay?.todo) {
                    Persistent.states.overlay.todo.tabIndex = tabBar.currentIndex;
                }
            }

            SecondaryTabButton {
                buttonIcon: "checklist"
                buttonText: Translation.tr("Unfinished (%1)").arg(root.unfinishedCount)
            }

            SecondaryTabButton {
                buttonIcon: "check_circle"
                buttonText: Translation.tr("Done (%1)").arg(root.doneCount)
            }
        }

        // Progress bar & summary
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.totalCount > 0

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                        text: Translation.tr("%1 of %2 completed").arg(root.doneCount).arg(root.totalCount)
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        Layout.fillWidth: true
                    }
                    StyledText {
                        text: `${Math.round(root.progress * 100)}%`
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colPrimary
                    }
                }

                StyledProgressBar {
                    Layout.fillWidth: true
                    value: root.progress
                    valueBarHeight: 4
                    highlightColor: Appearance.colors.colPrimary
                }
            }

            RippleButton {
                id: clearDoneBtn
                visible: root.doneCount > 0 && tabBar.currentIndex === 1
                implicitHeight: 28
                implicitWidth: 28
                buttonRadius: 14
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colErrorContainer

                onClicked: {
                    Todo.clearCompleted();
                }

                contentItem: Item {
                    anchors.centerIn: parent
                    implicitWidth: 18
                    implicitHeight: 18
                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "delete_sweep"
                        iconSize: 18
                        color: clearDoneBtn.hovered ? Appearance.colors.colError : Appearance.colors.colOutline
                    }
                }

                StyledToolTip {
                    text: Translation.tr("Clear completed tasks")
                }
            }
        }

        // Add task input row
        Rectangle {
            id: inputCard
            Layout.fillWidth: true
            implicitHeight: 42
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer2
            border.width: 1
            border.color: todoInput.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant
            visible: !root.isClickthrough || GlobalStates.overlayOpen

            Behavior on border.color {
                ColorAnimation { duration: Appearance.animation.elementMoveFast.duration }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 6
                spacing: 6

                MaterialSymbol {
                    text: "add_task"
                    iconSize: 18
                    color: Appearance.colors.colOutline
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: Translation.tr("Add a task... (Press Enter)")
                    placeholderTextColor: Appearance.colors.colSubtext
                    color: Appearance.colors.colOnLayer1
                    background: Item {}
                    font {
                        family: Appearance.font.family.main
                        pixelSize: Appearance.font.pixelSize.small
                    }
                    renderType: Text.QtRendering
                    selectedTextColor: Appearance.colors.colOnSecondaryContainer
                    selectionColor: Appearance.colors.colSecondaryContainer
                    verticalAlignment: Text.AlignVCenter

                    onAccepted: root.addNewTask()
                }

                RippleButton {
                    id: addBtn
                    implicitWidth: 30
                    implicitHeight: 30
                    buttonRadius: 15
                    colBackground: Appearance.colors.colPrimaryContainer
                    colBackgroundHover: Appearance.colors.colPrimaryContainerHover
                    enabled: todoInput.text.trim().length > 0
                    opacity: enabled ? 1 : 0.4

                    onClicked: root.addNewTask()

                    contentItem: Item {
                        anchors.centerIn: parent
                        implicitWidth: 18
                        implicitHeight: 18
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "add"
                            iconSize: 18
                            color: Appearance.colors.colOnPrimaryContainer
                        }
                    }

                    StyledToolTip {
                        text: Translation.tr("Add task")
                    }
                }
            }
        }

        // Task items list
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            StyledListView {
                id: taskListView
                anchors.fill: parent
                spacing: 6
                model: ScriptModel {
                    values: root.currentTaskList
                }

                delegate: Item {
                    id: taskItem
                    required property var modelData
                    width: taskListView.width
                    implicitHeight: itemCard.implicitHeight

                    Rectangle {
                        id: itemCard
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        implicitHeight: itemRow.implicitHeight + 12
                        radius: Appearance.rounding.small
                        color: itemMouseArea.containsMouse ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1Base
                        border.width: 1
                        border.color: itemMouseArea.containsMouse ? Appearance.colors.colOutlineVariant : Appearance.colors.colLayer0Border

                        Behavior on color {
                            ColorAnimation { duration: Appearance.animation.elementMoveFast.duration }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }

                        RowLayout {
                            id: itemRow
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 6
                                rightMargin: 6
                            }
                            spacing: 6

                            // Toggle done button
                            RippleButton {
                                id: checkBtn
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 30
                                implicitHeight: 30
                                buttonRadius: 15
                                colBackground: "transparent"
                                colBackgroundHover: Appearance.colors.colPrimaryContainerHover

                                onClicked: {
                                    if (taskItem.modelData.done) {
                                        Todo.markUnfinished(taskItem.modelData.originalIndex);
                                    } else {
                                        Todo.markDone(taskItem.modelData.originalIndex);
                                    }
                                }

                                contentItem: Item {
                                    anchors.centerIn: parent
                                    implicitWidth: 20
                                    implicitHeight: 20

                                    MaterialSymbol {
                                        anchors.centerIn: parent
                                        text: taskItem.modelData.done ? "check_circle" : "radio_button_unchecked"
                                        fill: taskItem.modelData.done ? 1 : 0
                                        iconSize: 20
                                        color: taskItem.modelData.done ? Appearance.colors.colPrimary : Appearance.colors.colOutline
                                    }
                                }

                                StyledToolTip {
                                    text: taskItem.modelData.done ? Translation.tr("Mark unfinished") : Translation.tr("Mark done")
                                }
                            }

                            // Task description
                            StyledText {
                                id: taskText
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                text: taskItem.modelData.content
                                wrapMode: Text.Wrap
                                font {
                                    pixelSize: Appearance.font.pixelSize.small
                                    strikeout: taskItem.modelData.done
                                }
                                color: taskItem.modelData.done ? Appearance.m3colors.m3outline : Appearance.colors.colOnLayer1
                            }

                            // Delete button
                            RippleButton {
                                id: deleteBtn
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 26
                                implicitHeight: 26
                                buttonRadius: 13
                                colBackground: "transparent"
                                colBackgroundHover: Appearance.colors.colErrorContainer
                                opacity: (!root.isClickthrough && (itemMouseArea.containsMouse || deleteBtn.hovered)) ? 1 : 0.3

                                Behavior on opacity {
                                    NumberAnimation { duration: Appearance.animation.elementMoveFast.duration }
                                }

                                onClicked: {
                                    Todo.deleteItem(taskItem.modelData.originalIndex);
                                }

                                contentItem: Item {
                                    anchors.centerIn: parent
                                    implicitWidth: 16
                                    implicitHeight: 16

                                    MaterialSymbol {
                                        anchors.centerIn: parent
                                        text: "delete_outline"
                                        iconSize: 16
                                        color: deleteBtn.hovered ? Appearance.colors.colError : Appearance.colors.colOutline
                                    }
                                }

                                StyledToolTip {
                                    text: Translation.tr("Delete task")
                                }
                            }
                        }
                    }
                }
            }

            // Empty state placeholder
            Item {
                anchors.centerIn: parent
                visible: root.currentTaskList.length === 0
                implicitWidth: emptyColumn.implicitWidth
                implicitHeight: emptyColumn.implicitHeight

                ColumnLayout {
                    id: emptyColumn
                    anchors.centerIn: parent
                    spacing: 6

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignHCenter
                        iconSize: 42
                        color: Appearance.colors.colOutlineVariant
                        text: tabBar.currentIndex === 0 ? "task_alt" : "checklist"
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colSubtext
                        horizontalAlignment: Text.AlignHCenter
                        text: tabBar.currentIndex === 0 ? 
                            Translation.tr("All caught up!") : 
                            Translation.tr("No completed tasks")
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOutline
                        horizontalAlignment: Text.AlignHCenter
                        text: tabBar.currentIndex === 0 ? 
                            Translation.tr("Add a task above to get started.") : 
                            Translation.tr("Tasks you finish will show here.")
                    }
                }
            }
        }
    }

    function addNewTask() {
        const textVal = todoInput.text.trim();
        if (textVal.length > 0) {
            Todo.addTask(textVal);
            todoInput.text = "";
            tabBar.currentIndex = 0;
        }
    }
}
