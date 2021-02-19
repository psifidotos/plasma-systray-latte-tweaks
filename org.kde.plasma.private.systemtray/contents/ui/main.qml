/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2020 Konrad Materka <materka@gmail.com>
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

import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.draganddrop 2.0 as DnD
import org.kde.kirigami 2.5 as Kirigami

import "items"

MouseArea {
    id: root

    readonly property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    Layout.minimumWidth: vertical ? PlasmaCore.Units.iconSizes.small : mainLayout.implicitWidth + PlasmaCore.Units.smallSpacing
    Layout.minimumHeight: vertical ? mainLayout.implicitHeight + PlasmaCore.Units.smallSpacing : PlasmaCore.Units.iconSizes.small

    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    readonly property alias systemTrayState: systemTrayState
    readonly property alias itemSize: tasksGrid.itemSize
    readonly property alias visibleLayout: tasksGrid
    readonly property alias hiddenLayout: expandedRepresentation.hiddenLayout

    //! Latte Connection
    property QtObject latteBridge: null
    readonly property bool inLatte: latteBridge !== null
    readonly property bool inLatteCustomPalette: inLatte && latteBridge.palette && latteBridge.applyPalette
    readonly property bool internalMainHighlightEnabled: plasmoid.configuration.internalMainHighlightEnabled

    onLatteBridgeChanged: {
        if (latteBridge) {
            latteBridge.actions.setProperty(plasmoid.id, "latteSideColoringEnabled", false);
            cItemHighlight.informLatteIndicator();
        }
    }

    onInternalMainHighlightEnabledChanged: cItemHighlight.informLatteIndicator()
    //!

    onWheel: {
        // Don't propagate unhandled wheel events
        wheel.accepted = true;
    }

    SystemTrayState {
        id: systemTrayState
    }

    //being there forces the items to fully load, and they will be reparented in the popup one by one, this item is *never* visible
    Item {
        id: preloadedStorage
        visible: false
    }

    CurrentItemHighLight {
        id: cItemHighlight
        location: plasmoid.location

        function informLatteIndicator() {
            if (!inLatte) {
                return;
            }

            if (root.internalMainHighlightEnabled || parent !== root) {
                latteBridge.actions.setProperty(plasmoid.id, "activeIndicatorEnabled", false);
            } else if (parent) {
                latteBridge.actions.setProperty(plasmoid.id, "activeIndicatorEnabled", true);
            }
        }

        onParentChanged: cItemHighlight.informLatteIndicator()

        Connections {
            target: root
            onInLatteChanged: cItemHighlight.informLatteIndicator()
        }
    }

    DnD.DropArea {
        anchors.fill: parent

        preventStealing: true;

        /** Extracts the name of the system tray applet in the drag data if present
         * otherwise returns null*/
        function systemTrayAppletName(event) {
            if (event.mimeData.formats.indexOf("text/x-plasmoidservicename") < 0) {
                return null;
            }
            var plasmoidId = event.mimeData.getDataAsByteArray("text/x-plasmoidservicename");

            if (!plasmoid.nativeInterface.isSystemTrayApplet(plasmoidId)) {
                return null;
            }
            return plasmoidId;
        }

        onDragEnter: {
            if (!systemTrayAppletName(event)) {
                event.ignore();
            }
        }

        onDrop: {
            var plasmoidId = systemTrayAppletName(event);
            if (!plasmoidId) {
                event.ignore();
                return;
            }

            if (plasmoid.configuration.extraItems.indexOf(plasmoidId) < 0) {
                var extraItems = plasmoid.configuration.extraItems;
                extraItems.push(plasmoidId);
                plasmoid.configuration.extraItems = extraItems;
            }
        }
    }

    //Main Layout
    GridLayout {
        id: mainLayout
        rowSpacing: 0
        columnSpacing: 0
        anchors.fill: parent
        flow: vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

        GridView {
            id: tasksGrid
            Layout.alignment: Qt.AlignCenter
            interactive: false //disable features we don't need
            flow: vertical ? GridView.LeftToRight : GridView.TopToBottom

            implicitWidth: !root.vertical ? cellWidth * lengthLines : cellWidth * thicknessLines
            implicitHeight: !root.vertical ? cellHeight * thicknessLines : cellHeight * lengthLines

            cellWidth: !root.vertical && !autoSize ? smallSizeCellLength : autoSizeCellThickness + (!root.vertical ? plasmoid.configuration.iconsSpacing : 0)
            cellHeight: root.vertical && !autoSize ? smallSizeCellLength : autoSizeCellThickness + (root.vertical ? plasmoid.configuration.iconsSpacing : 0)

            // Used only by AbstractItem, but it's easiest to keep it here since it
            // uses dimensions from this item to calculate the final value
            readonly property int itemSize: autoSize ? PlasmaCore.Units.roundToIconSize(Math.min(Math.min(root.width / thicknessLines, root.height / thicknessLines), PlasmaCore.Units.iconSizes.enormous)) :
                                                       smallIconSize

            readonly property int smallSizeCellLength: smallIconSize + plasmoid.configuration.iconsSpacing
            readonly property int autoSizeCellThickness: (gridThickness / thicknessLines)

            // The icon size to display when not using the auto-scaling setting
            readonly property int smallIconSize: PlasmaCore.Units.iconSizes.smallMedium
            readonly property bool autoSize: plasmoid.configuration.scaleIconsToFit

            readonly property int gridThickness: root.vertical ? root.width : root.height
            // Should change to 2 rows/columns on a 56px panel (in standard DPI)
            readonly property int thicknessLines: autoSize ? 1 : Math.max(1, Math.floor(gridThickness / (smallIconSize + plasmoid.configuration.iconsSpacing)))
            readonly property int lengthLines: Math.ceil(count / thicknessLines)

            model: PlasmaCore.SortFilterModel {
                sourceModel: plasmoid.nativeInterface.systemTrayModel
                filterRole: "effectiveStatus"
                filterCallback: function(source_row, value) {
                    return value === PlasmaCore.Types.ActiveStatus
                }
            }

            delegate: ItemLoader {}

            add: Transition {
                enabled: itemSize > 0

                NumberAnimation {
                    property: "scale"
                    from: 0
                    to: 1
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.longDuration
                }
            }

            displaced: Transition {
                //ensure scale value returns to 1.0
                //https://doc.qt.io/qt-5/qml-qtquick-viewtransition.html#handling-interrupted-animations
                NumberAnimation {
                    property: "scale"
                    to: 1
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.longDuration
                }
            }

            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    easing.type: Easing.InOutQuad
                    duration: PlasmaCore.Units.longDuration
                }
            }
        }

        ExpanderArrow {
            id: expander
            Layout.fillWidth: vertical
            Layout.fillHeight: !vertical
            visible: root.hiddenLayout.itemCount > 0
        }
    }

    //Main popup
    PlasmaCore.Dialog {
        id: dialog
        visualParent: root
        flags: Qt.WindowStaysOnTopHint
        location: plasmoid.location
        hideOnWindowDeactivate: !plasmoid.configuration.pin
        visible: systemTrayState.expanded

        onVisibleChanged: {
            systemTrayState.expanded = visible
        }
        mainItem: ExpandedRepresentation {
            id: expandedRepresentation

            Keys.onEscapePressed: {
                systemTrayState.expanded = false
            }

            LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
            LayoutMirroring.childrenInherit: true
        }
    }
}
