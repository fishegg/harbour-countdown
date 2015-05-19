import QtQuick 2.0
import Sailfish.Silica 1.0
import "storage.js" as ST
import "calc.js" as CALC
import "."

Dialog {
    id: editDialog
    property string existedTitle
    property string newTitle
    property int dayid: new Date() / 10000

    Column {
        anchors.fill: parent
        DialogHeader {
            title: existedTitle ? qsTr("Edit") : qsTr("Create New")
            acceptText: existedTitle ? qsTr("Save") : qsTr("Create")
        }
        TextField {
            id: input
            width: parent.width
            focus: dateButton.year === 0 ? true : false
            placeholderText: qsTr("Enter a new title")
            label: qsTr("title")
            text: existedTitle ? existedTitle : ""
            EnterKey.enabled: text.length > 0
            EnterKey.text: dateButton.year === 0 ? qsTr("Date") : qsTr("Create")
            EnterKey.onClicked: dateButton.year === 0 ? dateButton.openDateDialog() : accept()
        }
        ValueButton {
            id: dateButton
            property date selectedDate
            property int year
            property int month
            property int day

            function openDateDialog() {
                var dialog = pageStack.push("Sailfish.Silica.DatePickerDialog", {
                                date: selectedDate,
                                allowedOrientations: Orientation.Landscape | Orientation.Portrait | Orientation.LandscapeInverted
                             })

                dialog.accepted.connect(function() {
                    value = dialog.dateText
                    selectedDate = dialog.date
                    year = dialog.year
                    month = dialog.month
                    day = dialog.day
                })
            }

            label: qsTr("Date")
            value: qsTr("Select")
            width: parent.width
            onClicked: openDateDialog()
        }

    }

    canAccept: input.text.length > 0 && dateButton.year !== 0 ? true : false

    onAccepted: {
        newTitle = input.text
        ST.createDays(dayid,newTitle,dateButton.year,dateButton.month,dateButton.day)
        console.log(dateButton.year + dateButton.month + dateButton.day)
    }
}
