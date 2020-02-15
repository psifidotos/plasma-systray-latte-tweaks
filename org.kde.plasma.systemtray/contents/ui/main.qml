/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    Layout.minimumWidth: internalSystray ? internalSystray.Layout.minimumWidth : 0
    Layout.minimumHeight: internalSystray ? internalSystray.Layout.minimumHeight : 0
    Layout.preferredHeight: Layout.minimumHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.status: internalSystray ? internalSystray.status : PlasmaCore.Types.UnknownStatus

    Plasmoid.onExpandedChanged: {
        if (internalSystray && !plasmoid.expanded) {
            internalSystray.expanded = false;
        }
    }
    Connections {
        target: internalSystray
        onExpandedChanged: plasmoid.expanded = internalSystray.expanded
    }

    property Item internalSystray

    //! Latte Connection
    property QtObject latteBridge: null
    readonly property bool inLatte: latteBridge !== null

    onLatteBridgeChanged: checkAndUpdateInternalLatteBridge();
    onInternalSystrayChanged: checkAndUpdateInternalLatteBridge();
    //!

    Component.onCompleted: {
        root.internalSystray = plasmoid.nativeInterface.internalSystray;

        if (root.internalSystray == null) {
            return;
        }
        root.internalSystray.parent = root;
        root.internalSystray.anchors.fill = root;
    }

    Connections {
        target: plasmoid.nativeInterface
        onInternalSystrayChanged: {
            root.internalSystray = plasmoid.nativeInterface.internalSystray;
            root.internalSystray.parent = root;
            root.internalSystray.anchors.fill = root;

            checkAndUpdateInternalLatteBridge();
        }
    }

    function checkAndUpdateInternalLatteBridge() {
        if (!latteBridge) {
            return;
        }

        var level0 = internalSystray.children;

        for(var i=0; i<level0.length; ++i){
            if (level0[i].hasOwnProperty("latteBridge")) {
                level0[i].latteBridge = root.latteBridge;
                break;
            }

            var level1 = level0[i].children;
            for(var j=0; j<level1.length; ++j){
                if (level1[j].hasOwnProperty("latteBridge")) {
                    level1[j].latteBridge = root.latteBridge;
                    break;
                }
            }
        }
    }
}

