/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import org.kde.plasma.configuration 2.0
import QtQuick.Controls 2.3 as QtControls
import QtQuick.Layouts 1.1

import org.kde.kconfig 1.0 // for KAuthorized
import org.kde.plasma.private.shell 2.0 as ShellPrivate // for WallpaperPlugin
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
    id: root

    property int formAlignment: wallpaperComboBox.Kirigami.ScenePosition.x - root.Kirigami.ScenePosition.x + (units.largeSpacing/2)
    property string currentWallpaper: ""
    signal configurationChanged

//BEGIN functions
    function saveConfig() {
        if (main.currentItem.saveConfig) {
            main.currentItem.saveConfig()
        }
        for (var key in configDialog.wallpaperConfiguration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                configDialog.wallpaperConfiguration[key] = main.currentItem["cfg_"+key]
            }
        }
        configDialog.currentWallpaper = root.currentWallpaper;
        configDialog.applyWallpaper()
    }
//END functions

    Component.onCompleted: {
        for (var i = 0; i < configDialog.wallpaperConfigModel.count; ++i) {
            var data = configDialog.wallpaperConfigModel.get(i);
            if (configDialog.currentWallpaper == data.pluginName) {
                wallpaperComboBox.currentIndex = i
                wallpaperComboBox.activated(i);
                break;
            }
        }
    }

    Kirigami.InlineMessage {
        visible: plasmoid.immutable || animating
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "Layout cannot be changed while widgets are locked")
        showCloseButton: true
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing
        Layout.rightMargin: Kirigami.Units.smallSpacing
    }

    Kirigami.FormLayout {
        Layout.fillWidth: true
        RowLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18nd("plasma_shell_org.kde.plasma.desktop", "Wallpaper Type:")
            QtControls.ComboBox {
                id: wallpaperComboBox
                Layout.preferredWidth: Math.max(implicitWidth, pluginComboBox.implicitWidth)
                model: configDialog.wallpaperConfigModel
                width: theme.mSize(theme.defaultFont).width * 24
                textRole: "name"
                onActivated: {
                    var model = configDialog.wallpaperConfigModel.get(currentIndex)
                    root.currentWallpaper = model.pluginName
                    configDialog.currentWallpaper = model.pluginName
                    main.sourceFile = model.source
                    root.configurationChanged()
                }
            }
            /* //need mobile friendly ghns
            QtControls.Button {
                icon.name: "get-hot-new-stuff"
                text: i18nd("plasma_shell_org.kde.plasma.desktop", "Get New Plugins...")
                visible: KAuthorized.authorize("ghns")
                onClicked: wallpaperPlugin.getNewWallpaperPlugin(this)
                Layout.preferredHeight: wallpaperComboBox.height

                ShellPrivate.WallpaperPlugin {
                    id: wallpaperPlugin
                }
            }*/
        }
    }

    Item {
        id: emptyConfig
    }

    QtControls.StackView {
        id: main

        Layout.fillHeight: true;
        Layout.fillWidth: true;

        // Bug 360862: if wallpaper has no config, sourceFile will be ""
        // so we wouldn't load emptyConfig and break all over the place
        // hence set it to some random value initially
        property string sourceFile: "tbd"
        onSourceFileChanged: {
            if (sourceFile) {
                var props = {}

                var wallpaperConfig = configDialog.wallpaperConfiguration
                for (var key in wallpaperConfig) {
                    props["cfg_" + key] = wallpaperConfig[key]
                }

                var newItem = replace(Qt.resolvedUrl(sourceFile), props)

                for (var key in wallpaperConfig) {
                    var changedSignal = newItem["cfg_" + key + "Changed"]
                    if (changedSignal) {
                        changedSignal.connect(root.configurationChanged)
                    }
                }
            } else {
                replace(emptyConfig)
            }
        }
    }
}
