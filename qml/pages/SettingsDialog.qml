import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.countdown.settings 1.0
import "compute.js" as Compute

Dialog {
    id: settingsDialog

    //allowedOrientations: Orientation.Portrait | Orientation.LandscapeMask

    property int date_format: settings.get_date_format()
    property int seperator_type: settings.get_seperator_type()
    property var date: Compute.get_date()
    property var year: Compute.get_year()
    property var month: Compute.get_month()
    property var day: Compute.get_day()

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id:column
            width: parent.width

            DialogHeader {
                title: qsTr("Settings")
                acceptText: qsTr("Save")
            }

            ComboBox {
                id: seperatorcombobox
                width: parent.width
                label: qsTr("Date seperator")
                currentIndex: seperator_type

                menu: ContextMenu {
                    MenuItem {
                        text: "."
                        onClicked: {
                            seperator_type = Settings.Period
                        }
                    }
                    MenuItem {
                        text: "/"
                        onClicked: {
                            seperator_type = Settings.Slash
                        }
                    }
                    MenuItem {
                        text: "-"
                        onClicked: {
                            seperator_type = Settings.Hhyphen
                        }
                    }
                }
            }

            ComboBox {
                id: dateformatcombobox
                width: parent.width
                label: qsTr("Date format")
                currentIndex: date_format

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Provided by Date Picker Dialog")
                        onClicked: {
                            date_format = Settings.System_locale_short
                        }
                    }
                    MenuItem {
                        text: date
                        onClicked: {
                            date_format = Settings.System_locale
                        }
                    }
                    MenuItem {
                        text: year + seperatorcombobox.value + month + seperatorcombobox.value + day
                        onClicked: {
                            date_format = Settings.YYYYMMDD
                        }
                    }
                    MenuItem {
                        text: day + seperatorcombobox.value + month + seperatorcombobox.value + year
                        onClicked: {
                            date_format = Settings.DDMMYYYY
                        }
                    }
                    MenuItem {
                        text: month + seperatorcombobox.value + day + seperatorcombobox.value + year
                        onClicked: {
                            date_format = Settings.MMDDYYYY
                        }
                    }
                }
            }

            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                }
                text: year + seperatorcombobox.value + month + seperatorcombobox.value + day
            }
        }
    }

    Settings {
        id: settings
    }

    onAccepted: {
        settings.set_seperator_type(seperator_type)
        settings.set_date_format(date_format)
    }

    /*onRejected: {
        if(coverAdd) {
            coverAdd = false
        }
    }*/
}
