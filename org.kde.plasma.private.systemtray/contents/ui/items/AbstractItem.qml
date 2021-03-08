/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *   Copyright 2020 Konrad Materka <materka@gmail.com>
 *   Copyright 2020 Nate Graham <nate@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

import QtGraphicalEffects 1.0

PlasmaCore.ToolTipArea {
    id: abstractItem

    height: inVisibleLayout ? visibleLayout.cellHeight : hiddenTasks.cellHeight
    width: inVisibleLayout ? visibleLayout.cellWidth : hiddenTasks.cellWidth

    property var model: itemModel

    property string itemId
    property alias text: label.text
    property alias iconContainer: iconContainer
    property bool labelVisible: inHiddenLayout && !root.activeApplet
    property int /*PlasmaCore.Types.ItemStatus*/ status: model.status || PlasmaCore.Types.UnknownStatus
    property int /*PlasmaCore.Types.ItemStatus*/ effectiveStatus: model.effectiveStatus || PlasmaCore.Types.UnknownStatus
    readonly property bool inHiddenLayout: effectiveStatus === PlasmaCore.Types.PassiveStatus
    readonly property bool inVisibleLayout: effectiveStatus === PlasmaCore.Types.ActiveStatus

    signal clicked(var mouse)
    signal pressed(var mouse)
    signal wheel(var wheel)
    signal contextMenu(var mouse)

    /* subclasses need to assign to this tooltip properties
    mainText:
    subText:
    */

    location: {
        if (inHiddenLayout) {
            if (LayoutMirroring.enabled && plasmoid.location !== PlasmaCore.Types.RightEdge) {
                return PlasmaCore.Types.LeftEdge;
            } else if (plasmoid.location !== PlasmaCore.Types.LeftEdge) {
                return PlasmaCore.Types.RightEdge;
            }
        }

        return plasmoid.location;
    }


//BEGIN CONNECTIONS

    onContainsMouseChanged: {
        if (inHiddenLayout && containsMouse) {
            root.hiddenLayout.currentIndex = index
        }
    }

//END CONNECTIONS

    PulseAnimation {
        targetItem: iconContainer
        running: (abstractItem.status === PlasmaCore.Types.NeedsAttentionStatus ||
                  abstractItem.status === PlasmaCore.Types.RequiresAttentionStatus ) &&
                 units.longDuration > 0
    }

    function activated() {
        activatedAnimation.start()
    }

    SequentialAnimation {
        id: activatedAnimation
        loops: 1

        ScaleAnimator {
            target: iconContainer
            from: 1
            to: 0.5
            duration: units.shortDuration
            easing.type: Easing.InQuad
        }

        ScaleAnimator {
            target: iconContainer
            from: 0.5
            to: 1
            duration: units.shortDuration
            easing.type: Easing.OutQuad
        }
    }

    Loader {
        anchors.centerIn: abstractItem
        active: !abstractItem.inHiddenLayout
                && !labelVisible
                && itemId.length > 0
                && plasmoid.configuration.hasReversedColors
        sourceComponent: Rectangle{
            width: root.itemSize + Math.min(4, plasmoid.configuration.iconsSpacing)
            height: width
            radius: 2
            color: root.inLatte ? latteBridge.palette.textColor : theme.textColor
        }
    }

    MouseArea {
        anchors.fill: abstractItem
        hoverEnabled: true
        drag.filterChildren: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: abstractItem.clicked(mouse)
        onPressed: {
            abstractItem.hideToolTip()
            abstractItem.pressed(mouse)
        }
        onPressAndHold: {
            abstractItem.contextMenu(mouse)
        }
        onWheel: {
            abstractItem.wheel(wheel);
            //Don't accept the event in order to make the scrolling by mouse wheel working
            //for the parent scrollview this icon is in.
            wheel.accepted = false;
        }
    }

    ColumnLayout {
        id: itemColumn
        anchors.fill: abstractItem
        spacing: 0

        Item {
            id: iconContainer
            property alias container: abstractItem
            property alias inVisibleLayout: abstractItem.inVisibleLayout
            readonly property int size: abstractItem.inVisibleLayout ? root.itemSize : units.iconSizes.medium

            Layout.alignment: Qt.Bottom | Qt.AlignHCenter
            Layout.fillHeight: abstractItem.inHiddenLayout ? true : false
            implicitWidth: root.vertical && abstractItem.inVisibleLayout ? abstractItem.width : size
            implicitHeight: !root.vertical && abstractItem.inVisibleLayout ? abstractItem.height : size
            Layout.topMargin: abstractItem.inHiddenLayout ? units.smallSpacing : 0

            opacity: !colorizerLoader.active
        }

        PlasmaComponents3.Label {
            id: label

            Layout.fillWidth: true
            Layout.fillHeight: abstractItem.inHiddenLayout ? true : false
            Layout.leftMargin: abstractItem.inHiddenLayout ? units.smallSpacing : 0
            Layout.rightMargin: abstractItem.inHiddenLayout ? units.smallSpacing : 0
            Layout.bottomMargin: abstractItem.inHiddenLayout ? units.smallSpacing : 0

            visible: abstractItem.inHiddenLayout

            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 3

            opacity: visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    //!Latte Coloring Approach with Colorizer and BrightnessContrast for hovering effect
    Loader {
        id: colorizerLoader
        anchors.centerIn: itemColumn
        width: iconContainer.width
        height: iconContainer.height

        active: !abstractItem.inHiddenLayout
                && !labelVisible
                && itemId.length > 0
                && (plasmoid.configuration.blockedAutoColorItems.indexOf(itemId) < 0)
                && ((root.inLatte && root.inLatteCustomPalette)
                    || plasmoid.configuration.hasReversedColors)


        z:1000

        sourceComponent: ColorOverlay {
            anchors.fill: parent
            source: iconContainer
            color: {
                if (root.inLatte) {
                    return plasmoid.configuration.hasReversedColors ? latteBridge.palette.backgroundColor : latteBridge.palette.textColor
                }

                return plasmoid.configuration.hasReversedColors ? theme.backgroundColor : "transparent"
            }
        }
    }

    Loader {
        id: hoveredColorizerLoader
        anchors.centerIn: itemColumn
        width: iconContainer.width
        height: iconContainer.height

        active: colorizerLoader.active
        z:1001

        sourceComponent: BrightnessContrast {
            anchors.fill: parent
            source: colorizerLoader.item
            brightness: 0.2
            contrast: 0.1

            opacity: abstractItem.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }
}

