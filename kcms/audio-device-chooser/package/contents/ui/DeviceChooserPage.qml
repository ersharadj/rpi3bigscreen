import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3 as Controls
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.private.volume 0.1
import org.kde.mycroft.bigscreen 1.0 as BigScreen

import "delegates" as Delegates
import "views" as Views

FocusScope {
    id: mainFlick
    anchors.top: parent.top
    anchors.topMargin: Kirigami.Units.largeSpacing

    SourceModel {
        id: paSourceModel
    }

    SinkModel {
        id: paSinkModel
    }

    ColumnLayout {
        id: contentLayout
        width: parent.width - settingsView.width
        property Item currentSection
        y: currentSection ? -currentSection.y : 0
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.largeSpacing
        Behavior on y {
            NumberAnimation {
                duration: Kirigami.Units.longDuration * 2
                easing.type: Easing.InOutQuad
            }
        }
        height: parent.height

        BigScreen.TileView {
            id: sinkView
            model: paSinkModel
            focus: true
            title: i18n("Playback Devices")
            currentIndex: 0
            onActiveFocusChanged: { 
                if(activeFocus){ 
                    contentLayout.currentSection = sinkView
                    settingsView.model = sinkView.model
                    settingsView.positionViewAtIndex(currentIndex, ListView.Center);
                    //settingsView.currentIndex = sinkView.currentIndex
                    settingsView.checkPlayBack = true
                    settingsView.typeDevice = "sink"
                }
            }
            delegate: Delegates.AudioDelegate {
                isPlayback: true
                type: "sink"
            }
            navigationDown: sourceView.visible ? sourceView : kcmcloseButton
            
            onCurrentItemChanged: {
                settingsView.currentIndex = sinkView.currentIndex
                settingsView.positionViewAtIndex(sinkView.currentIndex, ListView.Center);
            }
        }

        BigScreen.TileView {
            id: sourceView
            model: paSourceModel
            title: i18n("Recording Devices")
            currentIndex: 0
            focus: false
            visible: sourceView.view.count > 0 ? 1 : 0 
            onActiveFocusChanged: {
                if(activeFocus){
                    contentLayout.currentSection = sourceView
                    settingsView.model = sourceView.model
                    settingsView.positionViewAtIndex(currentIndex, ListView.Center);
                    settingsView.checkPlayBack = false
                    settingsView.typeDevice = "source"
                }
            }
            delegate: Delegates.AudioDelegate {
                isPlayback: false
                type: "source"
            }
            navigationUp: sinkView
            navigationDown: kcmcloseButton
            
            onCurrentItemChanged: {
                    settingsView.currentIndex = sourceView.currentIndex
                    settingsView.positionViewAtIndex(currentIndex, ListView.Center);
            }
        }

        Component.onCompleted: {
            sinkView.forceActiveFocus();
        }

        Connections {
            target: root
            onActivateDeviceView: {
                sinkView.forceActiveFocus();
            }
        }
    }
    
    Kirigami.Separator {
        id: viewSept
        anchors.right: settingsView.left
        anchors.top: settingsView.top
        anchors.bottom: settingsView.bottom
        width: 1
    }
    
    ListView {
        id: settingsView
        anchors.top: parent.top
        anchors.topMargin: -Kirigami.Units.largeSpacing
        anchors.right: parent.right
        anchors.rightMargin: -Kirigami.Units.largeSpacing
        height: parent.height + Kirigami.Units.smallSpacing
        width: parent.width / 3.5
        layoutDirection: Qt.LeftToRight
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem;
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        spacing: Kirigami.Units.largeSpacing
        clip: true
        interactive: false
        implicitHeight: settingsView.implicitHeight
        currentIndex: 0
        property bool checkPlayBack
        property string typeDevice
        delegate: SettingsItem {
                isPlayback: settingsView.checkPlayBack
                type: settingsView.typeDevice
        }
    }
}
