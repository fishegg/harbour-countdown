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
    property int date_format_type
    property int seperator_type
    property string date_text
    property string seperator

    function get_settings() {
        date_format_type = settings.get_date_format()
        seperator_type = settings.get_seperator_type()
        set_seperator()
        console.log("get settings")
    }

    function set_seperator() {
        switch(seperator_type) {
        case Settings.Period: seperator = "."
            break
        case Settings.Slash: seperator = "/"
            break
        case Settings.Hhyphen: seperator = "-"
            break
        default: seperator = "."
        }
    }

    function get_date_text(year,month,day) {
        var text
        switch(date_format_type) {
        case Settings.System_locale: text = Compute.get_date(year,month,day)
            console.log("type"+date_format_type+"date_text"+date_text)
            return text
        case Settings.YYYYMMDD: text = year + seperator + month + seperator + day
            console.log("date_text"+date_text)
            return text
        case Settings.DDMMYYYY: text = day + seperator + month + seperator + year
            console.log("date_text"+date_text)
            return text
        case Settings.MMDDYYYY: text = month + seperator + day + seperator + year
            console.log("date_text"+date_text)
            return text
        }
    }

    Component.onCompleted: {
        get_settings()
        if(existedDatetext && date_format_type === Settings.System_locale_short) {
            dateButton.value = existedDatetext
            console.log("if")
        }
        else if(existedDatetext) {
            date_text = get_date_text(existedYear,existedMonth,existedDay)
            dateButton.value = date_text
            console.log("else if")
        }
        else {
            dateButton.value = qsTr("Select")
            console.log("else")
        }
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
                        get_date_text(year,month,day)
                        console.log("date_text"+date_text)
                        datetext = dialog.dateText
                        value = date_format_type === Settings.System_locale_short ?
                                    dialog.dateText:
                                    date_text
                    })
                }

                label: qsTr("Date")
                //value: existedDatetext ? existedDatetext : qsTr("Select")

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
