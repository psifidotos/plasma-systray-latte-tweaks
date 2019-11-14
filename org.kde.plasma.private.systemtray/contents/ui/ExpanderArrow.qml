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
    implicitWidth: !vertical ? length : units.iconSizes.smallMedium
    implicitHeight: vertical ? legnth : units.iconSizes.smallMedium
    visible: root.hiddenLayout.children.length > 0

    subText: root.expanded ? i18n("Close popup") : i18n("Show hidden icons")

    readonly property int length: units.iconSizes.smallMedium + plasmoid.configuration.iconsSpacing

    MouseArea {
        id: arrowMouseArea
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded

        readonly property int arrowAnimationDuration: units.shortDuration * 7

        PlasmaCore.Svg {
            id: arrowSvg
            imagePath: "widgets/arrows"
        }

        PlasmaCore.SvgItem {
            id: arrow

            width: units.iconSizes.smallMedium
            height: width

            transformOrigin: horizontal ? Item.Right : Item.Bottom

            rotation: root.expanded ? 180 : 0
            Behavior on rotation {
                RotationAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }
           // opacity: root.expanded ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: arrowMouseArea.arrowAnimationDuration
                }
            }

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
        active: root.inLatte
        z:1000

        sourceComponent: ColorOverlay {
            anchors.fill: parent
            source: arrowMouseArea
            color: root.inLatte ? latteBridge.palette.textColor : "transparent"
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
