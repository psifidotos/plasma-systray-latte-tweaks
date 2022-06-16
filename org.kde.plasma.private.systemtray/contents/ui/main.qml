/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.draganddrop 2.0 as DnD
import org.kde.kirigami 2.5 as Kirigami // For Settings.tabletMode

import "items"

MouseArea {
    id: root

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    Layout.minimumWidth: vertical ? PlasmaCore.Units.iconSizes.small : mainLayout.implicitWidth + PlasmaCore.Units.smallSpacing
    Layout.minimumHeight: vertical ? mainLayout.implicitHeight + PlasmaCore.Units.smallSpacing : PlasmaCore.Units.iconSizes.small

    LayoutMirroring.enabled: !vertical && Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    readonly property alias systemTrayState: systemTrayState
    readonly property alias itemSize: tasksGrid.itemSize
    readonly property alias visibleLayout: tasksGrid

    readonly property bool oneRowOrColumn: tasksGrid.rowsOrColumns == 1

    property Item expandedRepresentation: null //set by the Dialog
    property Item hiddenLayout: null //set by the Dialog
    property Item containmentVisualParent: null //set but parent applet

    readonly property bool hasReversedColors: plasmoid.configuration.hasBackgroundLayer && plasmoid.configuration.hasReversedColors

    readonly property int constraintHints: plasmoid.configuration.canFillThickness ? PlasmaCore.Types.CanFillArea : PlasmaCore.Types.NoHint

    readonly property color backgroundColor: {
        if (inLatteCustomPalette) {
            return root.hasReversedColors? latteBridge.palette.textColor : latteBridge.palette.backgroundColor;
        } else {
            return root.hasReversedColors? theme.textColor : theme.backgroundColor;
        }
    }

    readonly property color textColor: {
        if (inLatteCustomPalette) {
            return root.hasReversedColors ? latteBridge.palette.backgroundColor : latteBridge.palette.textColor;
        } else {
            return root.hasReversedColors ? theme.backgroundColor : "transparent";
        }
    }

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
        location: Plasmoid.location
        parent: root

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

            if (!Plasmoid.nativeInterface.isSystemTrayApplet(plasmoidId)) {
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

            if (Plasmoid.configuration.extraItems.indexOf(plasmoidId) < 0) {
                var extraItems = Plasmoid.configuration.extraItems;
                extraItems.push(plasmoidId);
                Plasmoid.configuration.extraItems = extraItems;
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

            // Automatically use autoSize setting when in tablet mode, if it's
            // not already being used
            readonly property bool autoSize: Plasmoid.configuration.scaleIconsToFit || Kirigami.Settings.tabletMode

            readonly property int gridThickness: root.vertical ? root.width : root.height
            // Should change to 2 rows/columns on a 56px panel (in standard DPI)
            readonly property int rowsOrColumns: autoSize ? 1 : Math.max(1, Math.min(count, Math.floor(gridThickness / (smallIconSize + PlasmaCore.Units.smallSpacing))))

            readonly property int thicknessLines: {
                if (autoSize) {
                    return 1;
                }

                return Math.min(plasmoid.configuration.maxLines, Math.max(1, Math.floor(gridThickness / smallIconSize)));
            }
            readonly property int lengthLines: Math.ceil(count / thicknessLines)

            model: PlasmaCore.SortFilterModel {
                sourceModel: Plasmoid.nativeInterface.systemTrayModel
                filterRole: "effectiveStatus"
                filterCallback: function(source_row, value) {
                    return value === PlasmaCore.Types.ActiveStatus
                }
            }

            delegate: ItemLoader {
                id: delegate
                // We need to recalculate the stacking order of the z values due to how keyboard navigation works
                // the tab order depends exclusively from this, so we redo it as the position in the list
                // ensuring tab navigation focuses the expected items
                Component.onCompleted: {
                    let item = tasksGrid.itemAtIndex(index - 1);
                    if (item) {
                        Plasmoid.nativeInterface.stackItemBefore(delegate, item)
                    } else {
                        item = tasksGrid.itemAtIndex(index + 1);
                    }
                    if (item) {
                        Plasmoid.nativeInterface.stackItemAfter(delegate, item)
                    }
                }
            }

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
            Layout.alignment: vertical ? Qt.AlignVCenter : Qt.AlignHCenter
            iconSize: tasksGrid.itemSize
            implicitWidth: tasksGrid.cellWidth
            implicitHeight: tasksGrid.cellHeight
            visible: root.hiddenLayout && root.hiddenLayout.itemCount > 0
        }
    }

    //Main popup
    Loader {
        id: dialog
        active: true
        source: root.inLatte ? "dialogs/LatteCoreDialog.qml" : "dialogs/PlasmaCoreDialog.qml"
    }
}
