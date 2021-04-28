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
