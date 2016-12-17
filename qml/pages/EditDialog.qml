import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.countdown.settings 1.0
import "storage.js" as ST
import "compute.js" as Compute

Dialog {
    id: editDialog

    property string existedTitle
    property string newTitle
    property int dayid: new Date() / 10000
    property int existedDayid: -1
    property int existedYear: -1
    property int existedMonth: -1
    property int existedDay: -1
    property date existed_date: new Date(existedYear, existedMonth - 1,existedDay)
    property string existedDatetext: ""
    property int favorite

    function get_settings() {
        console.log("get settings")
    }

    Component.onCompleted: {
        get_settings()
    }


    allowedOrientations: Orientation.Portrait | Orientation.LandscapeMask

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id:column
            width: parent.width

            DialogHeader {
                title: existedTitle ? qsTr("Edit") : qsTr("Create New")
                acceptText: existedTitle ? qsTr("Save") : qsTr("Create")
            }

            TextField {
                id: input
                width: parent.width
                focus: existedYear === -1 ? true : false
                placeholderText: qsTr("Enter a new title")
                label: qsTr("Title")
                text: existedTitle ? existedTitle : ""
                EnterKey.enabled: text.length > 0
                EnterKey.text: dateButton.year === -1 && existedYear === -1 ? qsTr("Date") : (existedYear === -1 ? qsTr("Create") : qsTr("Save"))
                EnterKey.onClicked: dateButton.year === -1 && existedYear === -1 ? dateButton.openDateDialog() : accept()
            }

            ValueButton {
                id: dateButton
                property date selectedDate: new Date(year,month,day)
                property int year: -1
                property int month: -1
                property int day: -1
                property string datetext

                function openDateDialog() {
                    var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                    date: existed_date.getFullYear() !== -1 ?
                                              existed_date :
                                              (selectedDate.getFullYear() !== -1 ?
                                                   selectedDate :
                                                   new Date()
                                               ),
                                    allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted
                                 })

                    dialog.accepted.connect(function() {
                        selectedDate = dialog.date
                        year = dialog.year
                        month = dialog.month
                        day = dialog.day
                        datetext = dialog.dateText
                        /*value = date_format_type === Settings.System_locale_short ?
                                    dialog.dateText:
                                    date_text*/
                        value = Compute.get_date_text(year,month,day,datetext)
                    })
                }

                label: qsTr("Date")
                value: existedDatetext ?
                           Compute.get_date_text(existedYear,existedMonth,existedDay,existedDatetext) :
                           qsTr("Select")

                width: parent.width
                onClicked: openDateDialog()
            }

            TextSwitch {
                id: tswitch
                text: qsTr("Display on cover")
                description: qsTr("You can also change this setting by tapping on the item on the first page")
                automaticCheck: false
                checked: favorite === 1
                onClicked:favorite = (favorite === 0 ? 1 : 0)
            }
        }
    }

    canAccept: input.text.length > 0 && (existedYear !== -1 || dateButton.year !== -1) ? true : false

    onAccepted: {
        newTitle = input.text
        itemAdded = true
        if(existedTitle) {
            if(dateButton.year === -1) {
                ST.editDays(existedDayid,newTitle,existedYear,existedMonth,existedDay,existedDatetext,favorite)
            }
            else {
                ST.editDays(existedDayid,newTitle,dateButton.year,dateButton.month,dateButton.day,dateButton.datetext,favorite)
            }
        }
        else {
            ST.createDays(dayid,newTitle,dateButton.datetext,dateButton.year,dateButton.month,dateButton.day,favorite)
        }
        console.log("dateButton.year="+dateButton.year)
        console.log("coverAdd="+coverAdd)
        console.log("favorite="+favorite)
    }

    onRejected: {
        if(coverAdd) {
            coverAdd = false
        }
    }

    Settings {
        id: settings
    }
}
