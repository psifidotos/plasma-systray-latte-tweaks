/*
    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

//SystemTray is a Containment. To have it presented as a widget in Plasma we need thin wrapping applet
Item {
    id: root
    Layout.minimumWidth: internalSystray ? internalSystray.Layout.minimumWidth : 0
    Layout.minimumHeight: internalSystray ? internalSystray.Layout.minimumHeight : 0
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.status: internalSystray ? internalSystray.status : PlasmaCore.Types.UnknownStatus

    Plasmoid.constraintHints: internalSystrayMainItem ? internalSystrayMainItem.constraintHints : PlasmaCore.Types.NoHint

    //synchronize state between SystemTray and wrapping Applet
    Plasmoid.onExpandedChanged: {
        if (internalSystray) {
            internalSystray.expanded = Plasmoid.expanded
        }
    }

    Connections {
        target: internalSystray
        function onExpandedChanged() {
            Plasmoid.expanded = internalSystray.expanded
        }
    }

    property Item internalSystray: null
    property Item internalSystrayMainItem: null

    //! Latte Connection
    property QtObject latteBridge: null
    readonly property bool inLatte: latteBridge !== null
    readonly property Item containmentVisualParent: root.parent && root.parent.parent ? root.parent.parent.parent : null

    onLatteBridgeChanged: checkAndUpdateInternalLatteBridge();
    onInternalSystrayChanged: checkAndUpdateInternalLatteBridge();

    Binding {
        target: internalSystrayMainItem
        property: "containmentVisualParent"
        value: root.containmentVisualParent
    }

    //!

    Component.onCompleted: {
        root.internalSystray = Plasmoid.nativeInterface.internalSystray;

        if (root.internalSystray == null) {
            return;
        }
        root.internalSystray.parent = root;
        root.internalSystray.anchors.fill = root;
    }

    Connections {
        target: Plasmoid.nativeInterface
        function onInternalSystrayChanged() {
            root.internalSystray = Plasmoid.nativeInterface.internalSystray;
            root.internalSystray.parent = root;
            root.internalSystray.anchors.fill = root;

            checkAndUpdateInternalLatteBridge();
        }
    }

    function checkAndUpdateInternalLatteBridge() {
        if (!latteBridge || !internalSystray) {
            return;
        }

        var level0 = internalSystray.children;

        for(var i=0; i<level0.length; ++i){
            if (level0[i].hasOwnProperty("latteBridge")) {
                internalSystrayMainItem = level0[i];
                level0[i].latteBridge = root.latteBridge;
                break;
            }

            var level1 = level0[i].children;
            for(var j=0; j<level1.length; ++j){
                if (level1[j].hasOwnProperty("latteBridge")) {
                    internalSystrayMainItem = level1[j];
                    level1[j].latteBridge = root.latteBridge;
                    break;
                }
            }
        }
    }
}

