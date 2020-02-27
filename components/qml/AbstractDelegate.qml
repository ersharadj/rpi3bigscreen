/*
 *  Copyright 2019 Aditya Mehra <aix.m@outlook.com>
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.11 as Kirigami
import org.kde.mycroft.bigscreen 1.0 as BigScreen

PlasmaComponents.ItemDelegate {
    id: delegate

    readonly property ListView listView: ListView.view
    readonly property bool isCurrent: listView.currentIndex == index && activeFocus && !listView.moving

    z: isCurrent ? 2 : 0

    onClicked: {
        listView.forceActiveFocus()
        listView.currentIndex = index
    }

    leftPadding: Kirigami.Units.largeSpacing*2
    topPadding: Kirigami.Units.largeSpacing*2
    rightPadding: Kirigami.Units.largeSpacing*2
    bottomPadding: Kirigami.Units.largeSpacing*2

    Keys.onReturnPressed: {
        clicked();
    }

    contentItem: Item {}

    background: Item {
        id: background

        Rectangle {
            id: shadowSource
            anchors.fill: frame
            color: "black"
            radius: frame.radius
            visible: false
        }

        FastBlur {
            id: shadowBlur
            anchors {
                fill: frame
            }
            transparentBorder: true
            source: shadowSource
            radius: Kirigami.Units.largeSpacing*2
            cached: true
        }

        Rectangle {
            id: frame
            anchors {
                fill: parent
                //margins: delegate.isCurrent ? -Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
                Behavior on margins {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                leftMargin: delegate.isCurrent ? Kirigami.Units.largeSpacing - innerFrame.anchors.margins : Kirigami.Units.largeSpacing
                rightMargin: delegate.isCurrent ? Kirigami.Units.largeSpacing - innerFrame.anchors.margins : Kirigami.Units.largeSpacing
                topMargin: delegate.isCurrent ? -Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
                bottomMargin: delegate.isCurrent ? -Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            }

            radius: delegate.isCurrent ? 6 : 3
            color: delegate.isCurrent ? delegate.Kirigami.Theme.highlightColor : delegate.Kirigami.Theme.backgroundColor
            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Rectangle {
                id: innerFrame
                anchors {
                    fill: parent
                    margins: units.smallSpacing
                }
                radius: frame.radius/2
                color: delegate.Kirigami.Theme.backgroundColor
            }
            states: [
                State {
                    when: delegate.isCurrent
                    PropertyChanges {
                        target: frame.anchors
                        leftMargin: Kirigami.Units.largeSpacing - innerFrame.anchors.margins
                        rightMargin: Kirigami.Units.largeSpacing - innerFrame.anchors.margins
                        topMargin: -Kirigami.Units.smallSpacing 
                        bottomMargin: -Kirigami.Units.smallSpacing
                    }
                },
                State {
                    when: !delegate.isCurrent
                    PropertyChanges {
                        target: frame.anchors
                        leftMargin: Kirigami.Units.largeSpacing
                        rightMargin: Kirigami.Units.largeSpacing
                        topMargin: Kirigami.Units.largeSpacing
                        bottomMargin: Kirigami.Units.largeSpacing
                    }
                }
            ]
            transitions: Transition {
                ParallelAnimation {
                    NumberAnimation {
                        property: "leftMargin"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "rightMargin"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "topMargin"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        property: "bottomMargin"
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
