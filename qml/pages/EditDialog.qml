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
    property int existedDayid
    property int existedYear
    property int existedMonth
    property int existedDay
    property string existedDatetext
    property int favorite

    allowedOrientations: Orientation.Portrait | Orientation.LandscapeMask

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
            label: qsTr("Title")
            text: existedTitle ? existedTitle : ""
            EnterKey.enabled: text.length > 0
            EnterKey.text: dateButton.year === 0 && existedYear === 0 ? qsTr("Date") : (existedYear === 0 ? qsTr("Create") : qsTr("Save"))
            EnterKey.onClicked: dateButton.year === 0 && existedYear === 0 ? dateButton.openDateDialog() : accept()
        }
        ValueButton {
            id: dateButton
            property date selectedDate
            property int year
            property int month
            property int day
            property string datetext

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
                    datetext = dialog.dateText
                })
            }

            label: qsTr("Date")
            value: existedDatetext ? existedDatetext : qsTr("Select")
            width: parent.width
            onClicked: openDateDialog()
        }

        TextSwitch {
            id: tswitch
            text: qsTr("Show on cover")
            automaticCheck: false
            checked: favorite === 1
            onClicked:favorite = favorite === 0?1:0
        }
    }


    canAccept: input.text.length > 0 && (existedYear !== 0 || dateButton.year !== 0) ? true : false

    onAccepted: {
        newTitle = input.text
        itemAdded = true
        if(existedTitle) {
            if(dateButton.year === 0) {
                ST.editDays(existedDayid,newTitle,existedYear,existedMonth,existedDay,existedDatetext,favorite)
            }else {
                ST.editDays(existedDayid,newTitle,dateButton.year,dateButton.month,dateButton.day,dateButton.datetext,favorite)
            }
        }else{
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
}
