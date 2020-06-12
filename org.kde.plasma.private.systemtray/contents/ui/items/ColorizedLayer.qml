/*
 *   Copyright 2019 Michail Vourlakos <mvourlakos@kde.org>
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

import QtGraphicalEffects 1.0

ColorOverlay {
    color: root.inLatte ? latteBridge.palette.textColor : "transparent"

    property bool isHovered: false

    BrightnessContrast {
        anchors.fill: parent
        source: parent

        brightness: 0.2
        contrast: 0.1

        opacity: isHovered ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
}
