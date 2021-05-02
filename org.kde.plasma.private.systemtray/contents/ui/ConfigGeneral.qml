

/***************************************************************************
 *   Copyright (C) 2020 Konrad Materka <materka@gmail.com>                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/
import QtQuick 2.14
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Controls 2.14 as QQC2
import QtQuick.Layouts 1.13

import org.kde.plasma.core 2.1 as PlasmaCore

import org.kde.kirigami 2.13 as Kirigami

ColumnLayout {
    id: generalPage
    property bool cfg_scaleIconsToFit

    property alias cfg_canFillThickness: canFillThicknessChk.checked
    property alias cfg_hasBackgroundLayer: hasBackgroundLayerChk.checked
    property alias cfg_hasReversedColors: reversedColorsChk.checked
    property alias cfg_maxLines: maxLinesSpn.value
    property alias cfg_reversedBackgroundRadius: reversedBackgroundRadiusSlider.value
    property alias cfg_reversedBackgroundOpacity: reversedBackgroundOpacitySlider.value
    property alias cfg_iconsSpacing: iconsSpacing.value
    property alias cfg_internalMainHighlightEnabled: internalHighlightChk.checked


    Kirigami.FormLayout {
        Layout.fillHeight: true

        QQC2.RadioButton {
            Kirigami.FormData.label: i18nc("The arrangement of system tray icons in the Panel", "Panel icon size:")
            text: i18n("Small")
            checked: cfg_scaleIconsToFit == false
            onToggled: cfg_scaleIconsToFit = !checked
        }
        QQC2.RadioButton {
            id: automaticRadioButton
            text: plasmoid.formFactor === PlasmaCore.Types.Horizontal ? i18n("Scale with Panel height")
                                                                      : i18n("Scale with Panel width")
            checked: cfg_scaleIconsToFit == true
            onToggled: cfg_scaleIconsToFit = checked
        }

        QQC2.Label {
            text: " "
        }

        QtControls.SpinBox{
            id: iconsSpacing
            minimumValue: 0
            maximumValue: 36 //in pixels

            suffix: i18nc("pixels","px.")

            Kirigami.FormData.label: i18n("Spacing:")
        }

        QQC2.Label {
            text: " "
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Maximum:")
            enabled: !cfg_scaleIconsToFit

            QtControls.SpinBox{
                id: maxLinesSpn
                minimumValue: 1
                maximumValue: 5
            }

            QtControls.Label {
                text: maxLinesSpn.value<=1 ? i18nc("one line", "line is used to distribute applets") : i18nc("multiple lines","lines are used to distribute applets")
            }
        }


        QQC2.Label {
            text: " "
        }

        QtControls.CheckBox {
            id: hasBackgroundLayerChk
            text: i18n("Add a background layer to items")
            Kirigami.FormData.label: i18n("Background:")
        }

        QtControls.CheckBox {
            id: reversedColorsChk
            enabled: cfg_hasBackgroundLayer
            text: i18n("Reversed color palette for items")
        }

        RowLayout {
            QQC2.Slider {
                id: reversedBackgroundRadiusSlider
                enabled: cfg_hasBackgroundLayer
                from: 0
                to: 50
            }
            QQC2.Label {
                text: Math.round(cfg_reversedBackgroundRadius) + "% radius"
                enabled: reversedBackgroundRadiusSlider.enabled
            }
        }

        RowLayout {
            QQC2.Slider {
                id: reversedBackgroundOpacitySlider
                enabled: cfg_hasBackgroundLayer
                from: 0
                to: 100
            }
            QQC2.Label {
                text: Math.round(cfg_reversedBackgroundOpacity) + "% opacity"
                enabled: reversedBackgroundOpacitySlider.enabled
            }
        }

        QQC2.Label {
            text: " "
        }

        QtControls.CheckBox {
            id: canFillThicknessChk
            text: i18n("Fill all panel thickness with no margins")
            Kirigami.FormData.label: i18n("Behavior:")
        }

        QtControls.CheckBox {
            id: internalHighlightChk
            text: i18n("Internal highlight for main popup window is enabled")
        }
    }
}
