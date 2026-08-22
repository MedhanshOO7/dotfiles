pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root

    configEntryName: "todo"
    needsColText: false

    implicitWidth: 340
    implicitHeight: 380

    readonly property var allTasks: Todo.list.map((item, i) => Object.assign({}, item, {originalIndex: i}))
    readonly property var unfinishedTasks: allTasks.filter(item => !item.done)
    readonly property var doneTasks: allTasks.filter(item => item.done)
    readonly property int totalCount: allTasks.length
    readonly property int unfinishedCount: unfinishedTasks.length
    readonly property int doneCount: doneTasks.length
    readonly property real progress: totalCount > 0 ? (doneCount / totalCount) : 0
    readonly property var currentTaskList: tabBar.currentIndex === 0 ? unfinishedTasks : doneTasks

    property int currentTab: 0

    // Static lightweight container (Near zero GPU/CPU cost)
    Rectangle {
        id: widgetBackground
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: ColorUtils.transparentize(Appearance.colors.colLayer0, 0.15)
        border.width: 1
        border.color: Appearance.colors.colLayer0Border

        ColumnLayout {
            id: contentColumn
            anchors {
                fill: parent
                margins: 10
            }
            spacing: 6

            // Header Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                MaterialSymbol {
                    text: "checklist"
                    iconSize: 20
                    color: Appearance.colors.colPrimary
                    Layout.alignment: Qt.AlignVCenter
                }

                StyledText {
                    text: Translation.tr("To-do")
                    font {
                        family: Appearance.font.family.title
                        pixelSize: Appearance.font.pixelSize.normal
                        weight: Font.DemiBold
                    }
                    color: Appearance.colors.colOnLayer0
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                }

                // Simple count badge
                Rectangle {
                    radius: Appearance.rounding.full
                    color: Appearance.colors.colSecondaryContainer
                    implicitHeight: 22
                    implicitWidth: badgeRow.implicitWidth + 12

                    RowLayout {
                        id: badgeRow
                        anchors.centerIn: parent
                        spacing: 4

                        StyledText {
                            text: `${root.unfinishedCount} ${Translation.tr("pending")}`
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSecondaryContainer
                        }
                    }
                }
            }

            // Tab Bar
            SecondaryTabBar {
                id: tabBar
                Layout.fillWidth: true
                currentIndex: root.currentTab
                onCurrentIndexChanged: {
                    root.currentTab = tabBar.currentIndex;
                }

                SecondaryTabButton {
                    buttonIcon: "checklist"
                    buttonText: Translation.tr("Active (%1)").arg(root.unfinishedCount)
                }

                SecondaryTabButton {
                    buttonIcon: "check_circle"
                    buttonText: Translation.tr("Done (%1)").arg(root.doneCount)
                }
            }

            // Static Progress Indicator (Zero GPU animation overhead)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
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

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 2
                        color: Appearance.colors.colSecondaryContainer

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: parent.width * root.progress
                            radius: 2
                            color: Appearance.colors.colPrimary
                        }
                    }
                }

                RippleButton {
                    id: clearDoneBtn
                    visible: root.doneCount > 0 && tabBar.currentIndex === 1
                    implicitHeight: 24
                    implicitWidth: 24
                    buttonRadius: 12
                    colBackground: "transparent"
                    colBackgroundHover: Appearance.colors.colErrorContainer

                    onClicked: {
                        Todo.clearCompleted();
                    }

                    contentItem: Item {
                        anchors.centerIn: parent
                        implicitWidth: 16
                        implicitHeight: 16
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: "delete_sweep"
                            iconSize: 16
                            color: clearDoneBtn.hovered ? Appearance.colors.colError : Appearance.colors.colOutline
                        }
                    }

                    StyledToolTip {
                        text: Translation.tr("Clear completed")
                    }
                }
            }

            // Quick Add Input Box
            Rectangle {
                id: inputCard
                Layout.fillWidth: true
                implicitHeight: 38
                radius: Appearance.rounding.small
                color: Appearance.colors.colLayer1
                border.width: 1
                border.color: todoInput.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 4
                    spacing: 4

                    MaterialSymbol {
                        text: "add_task"
                        iconSize: 16
                        color: Appearance.colors.colOutline
                        Layout.alignment: Qt.AlignVCenter
                    }

                    TextField {
                        id: todoInput
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        placeholderText: Translation.tr("Add task... (Enter)")
                        placeholderTextColor: Appearance.colors.colSubtext
                        color: Appearance.colors.colOnLayer0
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
                        implicitWidth: 26
                        implicitHeight: 26
                        buttonRadius: 13
                        colBackground: Appearance.colors.colPrimaryContainer
                        colBackgroundHover: Appearance.colors.colPrimaryContainerHover
                        enabled: todoInput.text.trim().length > 0
                        opacity: enabled ? 1 : 0.4

                        onClicked: root.addNewTask()

                        contentItem: Item {
                            anchors.centerIn: parent
                            implicitWidth: 16
                            implicitHeight: 16
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "add"
                                iconSize: 16
                                color: Appearance.colors.colOnPrimaryContainer
                            }
                        }
                    }
                }
            }

            // Task List
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                StyledListView {
                    id: taskListView
                    anchors.fill: parent
                    spacing: 4
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
                            implicitHeight: itemRow.implicitHeight + 8
                            radius: Appearance.rounding.small
                            color: itemMouseArea.containsMouse ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1Base
                            border.width: 1
                            border.color: itemMouseArea.containsMouse ? Appearance.colors.colOutlineVariant : Appearance.colors.colLayer0Border

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
                                    implicitWidth: 26
                                    implicitHeight: 26
                                    buttonRadius: 13
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
                                        implicitWidth: 16
                                        implicitHeight: 16

                                        MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: taskItem.modelData.done ? "check_circle" : "radio_button_unchecked"
                                            fill: taskItem.modelData.done ? 1 : 0
                                            iconSize: 16
                                            color: taskItem.modelData.done ? Appearance.colors.colPrimary : Appearance.colors.colOutline
                                        }
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
                                    color: taskItem.modelData.done ? Appearance.m3colors.m3outline : Appearance.colors.colOnLayer0
                                }

                                // Delete button
                                RippleButton {
                                    id: deleteBtn
                                    Layout.alignment: Qt.AlignVCenter
                                    implicitWidth: 22
                                    implicitHeight: 22
                                    buttonRadius: 11
                                    colBackground: "transparent"
                                    colBackgroundHover: Appearance.colors.colErrorContainer
                                    opacity: (itemMouseArea.containsMouse || deleteBtn.hovered) ? 1 : 0.2

                                    onClicked: {
                                        Todo.deleteItem(taskItem.modelData.originalIndex);
                                    }

                                    contentItem: Item {
                                        anchors.centerIn: parent
                                        implicitWidth: 14
                                        implicitHeight: 14

                                        MaterialSymbol {
                                            anchors.centerIn: parent
                                            text: "delete_outline"
                                            iconSize: 14
                                            color: deleteBtn.hovered ? Appearance.colors.colError : Appearance.colors.colOutline
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Item {
                    anchors.centerIn: parent
                    visible: root.currentTaskList.length === 0
                    implicitWidth: emptyColumn.implicitWidth
                    implicitHeight: emptyColumn.implicitHeight

                    ColumnLayout {
                        id: emptyColumn
                        anchors.centerIn: parent
                        spacing: 4

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            iconSize: 32
                            color: Appearance.colors.colOutlineVariant
                            text: tabBar.currentIndex === 0 ? "task_alt" : "checklist"
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colSubtext
                            horizontalAlignment: Text.AlignHCenter
                            text: tabBar.currentIndex === 0 ? 
                                Translation.tr("All caught up!") : 
                                Translation.tr("No completed tasks")
                        }
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
