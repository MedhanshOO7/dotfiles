import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.synchronizer

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    anchors.fill: parent
    property bool aiChatEnabled: Config.options.policies.ai !== 0
    property bool translatorEnabled: Config.options.sidebar.translator.enable
    property bool animeEnabled: Config.options.policies.weeb !== 0
    property bool animeCloset: Config.options.policies.weeb === 2
    property var tabButtonList: [
        ...(root.aiChatEnabled ? [{"icon": "neurology", "name": Translation.tr("Intelligence"), "type": "ai"}] : []),
        ...(root.translatorEnabled ? [{"icon": "translate", "name": Translation.tr("Translator"), "type": "translator"}] : []),
        ...((root.animeEnabled && !root.animeCloset) ? [{"icon": "bookmark_heart", "name": Translation.tr("Anime"), "type": "anime"}] : [])
    ]
    property int tabCount: swipeView.count

    function focusActiveItem() {
        if (swipeView.currentItem) {
            if (swipeView.currentItem.item) {
                swipeView.currentItem.item.forceActiveFocus();
            } else {
                swipeView.currentItem.forceActiveFocus();
            }
        }
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                swipeView.incrementCurrentIndex()
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp) {
                swipeView.decrementCurrentIndex()
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: sidebarPadding

        Toolbar {
            visible: tabButtonList.length > 0
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: swipeView.currentIndex
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: swipeView.implicitWidth
            implicitHeight: swipeView.implicitHeight
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1

            SwipeView { // Content pages
                id: swipeView
                anchors.fill: parent
                spacing: 10
                currentIndex: tabBar.currentIndex
                clip: true

                Repeater {
                    model: root.tabButtonList.length > 0 ? root.tabButtonList : [{"icon": "", "name": "", "type": "placeholder"}]
                    Loader {
                        id: pageLoader
                        required property int index
                        required property var modelData
                        property bool hasBeenActive: index === swipeView.currentIndex

                        active: hasBeenActive || index === swipeView.currentIndex
                        onActiveChanged: {
                            if (active) hasBeenActive = true;
                        }
                        Connections {
                            target: swipeView
                            function onCurrentIndexChanged() {
                                if (pageLoader.index === swipeView.currentIndex) {
                                    pageLoader.hasBeenActive = true;
                                }
                            }
                        }

                        sourceComponent: {
                            if (modelData.type === "ai") return aiChat;
                            if (modelData.type === "translator") return translator;
                            if (modelData.type === "anime") return anime;
                            return placeholder;
                        }
                    }
                }
            }
        }

        Component {
            id: aiChat
            AiChat {}
        }
        Component {
            id: translator
            Translator {}
        }
        Component {
            id: anime
            Anime {}
        }
        Component {
            id: placeholder
            Item {
                StyledText {
                    anchors.centerIn: parent
                    text: root.animeCloset ? Translation.tr("Nothing") : Translation.tr("Enjoy your empty sidebar...")
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}