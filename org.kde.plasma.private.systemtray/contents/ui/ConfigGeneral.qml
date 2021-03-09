

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

    property alias cfg_hasReversedColors: reversedColorsChk.checked
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

        QtControls.CheckBox {
            id: reversedColorsChk
            text: i18n("Reversed color palette for items")
            Kirigami.FormData.label: i18n("Colors:")
        }

        QQC2.Slider {
            id: reversedBackgroundRadiusSlider
            enabled: cfg_hasReversedColors
            from: 0
            to: 100
            Kirigami.FormData.label: i18n("Background radius:")
        }
        QQC2.Slider {
            id: reversedBackgroundOpacitySlider
            enabled: cfg_hasReversedColors
            from: 0
            to: 100
            Kirigami.FormData.label: i18n("Background opacity:")
        }

        QQC2.Label {
            text: " "
        }

        QtControls.CheckBox {
            id: internalHighlightChk
            text: i18n("Internal highlight for main popup window is enabled")
            Kirigami.FormData.label: i18n("Highlight:")
        }
    }
}
