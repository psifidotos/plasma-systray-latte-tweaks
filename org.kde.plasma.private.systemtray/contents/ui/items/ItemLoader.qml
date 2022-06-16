/*
    SPDX-FileCopyrightText: 2020 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.0

Loader {
    id: itemLoader

    z: x
    property var itemModel: model
    onActiveFocusChanged: {
        if (activeFocus && item) {
            item.forceActiveFocus();
        }
    }

    source: {
        if (model.itemType === "Plasmoid" && model.hasApplet) {
            return "PlasmoidItem.qml"
        } else if (model.itemType === "StatusNotifier") {
            return "StatusNotifierItem.qml"
        }
        console.warn("SystemTray ItemLoader: Invalid state, cannot determine source!")
        return ""
    }
}
