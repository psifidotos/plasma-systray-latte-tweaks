import QtQuick 2.5

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

import ".."

//Main popup
PlasmaCore.Dialog {
    id: dialog
    visualParent: root
    flags: Qt.WindowStaysOnTopHint
    location: plasmoid.location
    hideOnWindowDeactivate: !plasmoid.configuration.pin
    visible: systemTrayState.expanded
    backgroundHints: (plasmoid.containmentDisplayHints & PlasmaCore.Types.DesktopFullyCovered) ? PlasmaCore.Dialog.SolidBackground : PlasmaCore.Dialog.StandardBackground

    onVisibleChanged: {
        systemTrayState.expanded = visible
    }
    mainItem: ExpandedRepresentation {
        id: expandedRepresentation

        Keys.onEscapePressed: {
            systemTrayState.expanded = false
        }

        // Draws a line between the applet dialog and the panel
        PlasmaCore.SvgItem {
            // Only draw for popups of panel applets, not desktop applets
            visible: [PlasmaCore.Types.TopEdge, PlasmaCore.Types.LeftEdge, PlasmaCore.Types.RightEdge, PlasmaCore.Types.BottomEdge]
                .includes(plasmoid.location)
            anchors {
                top: plasmoid.location == PlasmaCore.Types.BottomEdge ? undefined : parent.top
                left: plasmoid.location == PlasmaCore.Types.RightEdge ? undefined : parent.left
                right: plasmoid.location == PlasmaCore.Types.LeftEdge ? undefined : parent.right
                bottom: plasmoid.location == PlasmaCore.Types.TopEdge ? undefined : parent.bottom
                topMargin: plasmoid.location == PlasmaCore.Types.BottomEdge ? undefined : -dialog.margins.top
                leftMargin: plasmoid.location == PlasmaCore.Types.RightEdge ? undefined : -dialog.margins.left
                rightMargin: plasmoid.location == PlasmaCore.Types.LeftEdge ? undefined : -dialog.margins.right
                bottomMargin: plasmoid.location == PlasmaCore.Types.TopEdge ? undefined : -dialog.margins.bottom
            }
            height: (plasmoid.location == PlasmaCore.Types.TopEdge || plasmoid.location == PlasmaCore.Types.BottomEdge) ? 1 : undefined
            width: (plasmoid.location == PlasmaCore.Types.LeftEdge || plasmoid.location == PlasmaCore.Types.RightEdge) ? 1 : undefined
            z: 999 /* Draw the line on top of the applet */
            elementId: (plasmoid.location == PlasmaCore.Types.TopEdge || plasmoid.location == PlasmaCore.Types.BottomEdge) ? "horizontal-line" : "vertical-line"
            svg: PlasmaCore.Svg {
                imagePath: "widgets/line"
            }
        }

        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        Binding {
            target: root
            property: "expandedRepresentation"
            value: expandedRepresentation
        }

        Binding {
            target: root
            property: "hiddenLayout"
            value: expandedRepresentation.hiddenLayout
        }
    }
}
