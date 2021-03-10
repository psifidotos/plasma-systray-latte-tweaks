/***************************************************************************
 *   Copyright 2013 Sebastian Kügler <sebas@kde.org>                       *
 *   Copyright 2015 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU Library General Public License as       *
 *   published by the Free Software Foundation; either version 2 of the    *
 *   License, or (at your option) any later version.                       *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                  *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import QtGraphicalEffects 1.0

PlasmaCore.ToolTipArea {
    id: tooltip

    property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical
    subText: systemTrayState.expanded ? i18n("Close popup") : i18n("Show hidden icons")

    readonly property int length: units.iconSizes.smallMedium + plasmoid.configuration.iconsSpacing

    Loader {
        anchors.centerIn: tooltip
        active: plasmoid.configuration.hasBackgroundLayer
        sourceComponent: Rectangle{
            width: root.itemSize + Math.min(4, plasmoid.configuration.iconsSpacing)
            height: width
            radius: width * plasmoid.configuration.reversedBackgroundRadius/100
            color: root.backgroundColor
            opacity: plasmoid.configuration.reversedBackgroundOpacity/100
        }
    }

    MouseArea {
        id: arrowMouseArea
        anchors.fill: parent
        onClicked: systemTrayState.expanded = !systemTrayState.expanded

        readonly property int arrowAnimationDuration: units.shortDuration

        PlasmaCore.Svg {
            id: arrowSvg
            imagePath: "widgets/arrows"
        }

        PlasmaCore.SvgItem {
            id: arrow
            anchors.centerIn: parent

            width: units.iconSizes.smallMedium
            height: width
            rotation: systemTrayState.expanded ? 180 : 0
            svg: arrowSvg

            elementId: {
                if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                    return "down-arrow";
                } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                    return "right-arrow";
                } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                    return "left-arrow";
                } else {
                    return "up-arrow";
                }
            }

            Behavior on rotation {
                RotationAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }



            states: [
                ///horizontal
                State {
                    name: "horizontal"
                    when: !vertical

                    AnchorChanges {
                        target: arrow
                        anchors{ right: parent.right; verticalCenter:parent.verticalCenter; bottom: undefined; horizontalCenter: undefined}
                    }
                },
                State {
                    name: "vertical"
                    when: vertical

                    AnchorChanges {
                        target: arrow
                        anchors{ right: undefined; verticalCenter:undefined; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                    }
                }
            ]
        }
    }

    //!Latte Coloring Approach with Colorizer and BrightnessContrast for hovering effect
    Loader {
        id: colorizerLoader
        anchors.fill: parent
        active: (root.inLatte && root.inLatteCustomPalette)
                || root.hasReversedColors
        z:1000

        sourceComponent: ColorOverlay {
            anchors.fill: parent
            source: arrowMouseArea
            color: root.textColor
        }
    }

    Loader {
        id: hoveredColorizerLoader
        anchors.fill: parent
        active: colorizerLoader.active
        z:1001

        sourceComponent: BrightnessContrast {
            anchors.fill: parent
            source: colorizerLoader.item
            brightness: 0.2
            contrast: 0.1

            opacity: arrowMouseArea.containsMouse ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }


}
