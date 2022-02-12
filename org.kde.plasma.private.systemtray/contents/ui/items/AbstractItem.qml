/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>
    SPDX-FileCopyrightText: 2020 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
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

    PulseAnimation {
        targetItem: iconContainer
        running: (abstractItem.status === PlasmaCore.Types.NeedsAttentionStatus ||
            abstractItem.status === PlasmaCore.Types.RequiresAttentionStatus ) &&
            PlasmaCore.Units.longDuration > 0
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
            duration: PlasmaCore.Units.shortDuration
            easing.type: Easing.InQuad
        }

        ScaleAnimator {
            target: iconContainer
            from: 0.5
            to: 1
            duration: PlasmaCore.Units.shortDuration
            easing.type: Easing.OutQuad
        }
    }

    Loader {
        anchors.centerIn: abstractItem
        active: !abstractItem.inHiddenLayout
                && !labelVisible
                && itemId.length > 0
                && plasmoid.configuration.hasBackgroundLayer
        sourceComponent: Rectangle{
            width: root.itemSize + Math.min(4, plasmoid.configuration.iconsSpacing)
            height: width
            radius: width * plasmoid.configuration.reversedBackgroundRadius/100
            color: root.backgroundColor
            opacity: plasmoid.configuration.reversedBackgroundOpacity/100
        }
    }

    MouseArea {
        propagateComposedEvents: true
        // This needs to be above applets when it's in the grid hidden area
        // so that it can receive hover events while the mouse is over an applet,
        // but below them on regular systray, so collapsing works
        z: inHiddenLayout ? 1 : 0
        anchors.fill: abstractItem
        hoverEnabled: true
        drag.filterChildren: true
        // Necessary to make the whole delegate area forward all mouse events
        acceptedButtons: Qt.AllButtons
        // Using onPositionChanged instead of onEntered because changing the
        // index in a scrollable view also changes the view position.
        // onEntered will change the index while the items are scrolling,
        // making it harder to scroll.
        onPositionChanged: if (inHiddenLayout) {
            root.hiddenLayout.currentIndex = index
        }
        onClicked: abstractItem.clicked(mouse)
        onPressed: {
            if (inHiddenLayout) {
                root.hiddenLayout.currentIndex = index
            }
            abstractItem.hideImmediately()
            abstractItem.pressed(mouse)
            if (mouse.button === Qt.RightButton) {
                abstractItem.contextMenu(mouse);
            }
        }
        onPressAndHold: if (mouse.button === Qt.LeftButton) {
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
            readonly property int size: abstractItem.inVisibleLayout ? root.itemSize : PlasmaCore.Units.iconSizes.medium

            Layout.alignment: Qt.Bottom | Qt.AlignHCenter
            Layout.fillHeight: abstractItem.inHiddenLayout ? true : false
            implicitWidth: root.vertical && abstractItem.inVisibleLayout ? abstractItem.width : size
            implicitHeight: !root.vertical && abstractItem.inVisibleLayout ? abstractItem.height : size
            Layout.topMargin: abstractItem.inHiddenLayout ? Math.round(PlasmaCore.Units.smallSpacing * 1.5): 0
            opacity: !colorizerLoader.active
        }

        PlasmaComponents3.Label {
            id: label

            Layout.fillWidth: true
            Layout.fillHeight: abstractItem.inHiddenLayout ? true : false
            Layout.leftMargin: abstractItem.inHiddenLayout ? PlasmaCore.Units.smallSpacing : 0
            Layout.rightMargin: abstractItem.inHiddenLayout ? PlasmaCore.Units.smallSpacing : 0
            Layout.bottomMargin: abstractItem.inHiddenLayout ? PlasmaCore.Units.smallSpacing : 0

            visible: abstractItem.inHiddenLayout

            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 3

            opacity: visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: PlasmaCore.Units.longDuration
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
                   || root.hasReversedColors)
        z:1000

        sourceComponent: ColorOverlay {
            anchors.fill: parent
            source: iconContainer
            color: root.textColor
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

