import QtQuick 2.5

import org.kde.plasma.core 2.1 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

import org.kde.latte.core 0.2 as LatteCore

import ".."

//Main popup
LatteCore.Dialog {
    id: dialog
    visualParent: root && root.containmentVisualParent ? root.containmentVisualParent : root
    flags: Qt.WindowStaysOnTopHint
    location: PlasmaCore.Types.Floating
    edge: plasmoid.location
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

