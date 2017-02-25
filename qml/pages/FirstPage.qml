/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import harbour.countdown.settings 1.0
import "storage.js" as ST
import "compute.js" as Compute


Page {
    id: page
    allowedOrientations: Orientation.Portrait | Orientation.LandscapeMask

    //property var currentDay:Qt.formatDateTime(wallClock.time, "dd")
    property int current_date: Compute.get_day()

    /*function update_settings() {
        //date_text = Compute.get_date_text(year,month,day,datetext)
    }*/

    function createNew() {
        var createdialog = pageStack.push(Qt.resolvedUrl("EditDialog.qml"))
        if(!coverAdd) {
            createdialog.accepted.connect(function() {
                ST.getDays("all")
                console.log("getDays")
            })
        }
    }

    function set() {
        var settingsdialog = pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"))
        settingsdialog.accepted.connect(function() {
            //update_settings()
            ST.getDays("all")
        }
        )
    }

    function editItem(dayid,name,year,month,day,datetext,favorite) {
        var createdialog = pageStack.push(Qt.resolvedUrl("EditDialog.qml"),
                                          {
                                              existedDayid: dayid,
                                              existedYear: year,
                                              existedMonth: month,
                                              existedDay: day,
                                              existedTitle: name,
                                              existedDatetext: datetext,
                                              favorite: favorite
                                          })
        createdialog.accepted.connect(function() {
            ST.getDays("all")
        })
    }

    function updateDaysbetween() {
        ST.getDays("all")
        refreshtimer.interval = Compute.nextZeroPoint()
        refreshtimer.start()
    }

    onStatusChanged: {
        if(status === PageStatus.Activating) {
            if(coverAdd) {
                ST.getDays("all")
                coverAdd = false
            }
        }
    }

    Timer {
        id: refreshtimer
        onTriggered: {
            updateDaysbetween()
        }
    }

    Timer {
        id: longtimer
        interval: 90000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            console.log("long timer triggered")
            if(Compute.nextZeroPoint() < interval) {
                stop()
                shorttimer.start()
                console.log("shorttimer start")
            }
            else if(Compute.is_next_day(current_date)) {
                ST.getDays("all")
                current_date = Compute.get_day()
            }
        }
    }

    Timer {
        id: shorttimer
        interval: 1000
        repeat: true
        onTriggered: {
            console.log("short timer triggered")
            if(Compute.is_next_day(current_date)) {
                ST.getDays("all")
                stop()
                longtimer.start()
                current_date = Compute.get_day()
                console.log("longtimer start")
            }
        }
    }

    /*onCurrentDayChanged: {
        //listItem.daysbetween = listItem.refreshdays(year,month,day)
        ST.getDays("all")
        console.log("Day changed getDays")
        console.log(Compute.get_time())
    }*/

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: listview
        anchors.fill: parent
        property int current_index: currentIndex

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: set()
            }
            MenuItem {
                text: qsTr("Create New")
                onClicked: createNew()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Create New")
                onClicked: createNew()
            }
        }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.

        header: PageHeader {
            title: qsTr("Important Days")
        }

        Component.onCompleted: {
            ST.initialize()
            ST.getDays("all")
            //positionViewAtIndex(current_index, ListView.Beginning)
//            refreshTimer.start()
//            console.log(CALC.nextZeroPoint())
        }

        ListModel {
            id: listModel
        }
        model: listModel
        clip: true

        ViewPlaceholder {
            enabled: listModel.count === 0
            text: qsTr("No items")
        }

        delegate: ListItem {
            id: listItem
            menu: contextMenuComponent
            contentHeight: countdowntotext.height + nametext.height + datetexttext.height
            property int daysbetween: refreshdays(year,month,day)
            property var date_text: Compute.get_date_text(year,month,day,datetext)

            function adjust() {
                if(nametext.contentWidth > nametext.width) {
                    var ratio = nametext.contentWidth / nametext.width
                    console.log("ratio=" + ratio)
                    if(ratio < 2) {
                        nametext.font.pixelSize = Theme.fontSizeLarge / ratio
                        nametext.maximumLineCount = 1
                    }
                    else {
                        nametext.font.pixelSize = Theme.fontSizeLarge / 2
                        nametext.elide = Text.ElideRight
                        nametext.wrapMode = Text.WordWrap
                        nametext.maximumLineCount = 2
                    }
                }
                /*if(datetexttext.contentWidth > datetexttext.width) {
                    var ratio1 = datetexttext.contentWidth / datetexttext.width
                    console.log("ratio1=" + ratio1)
                    if(ratio1 < 2) {
                        datetexttext.font.pixelSize = Theme.fontSizeLarge / ratio1
                        datetexttext.maximumLineCount = 1
                    }
                    else {
                        datetexttext.font.pixelSize = Theme.fontSizeLarge / 2
                        datetexttext.elide = Text.ElideRight
                        datetexttext.wrapMode = Text.WordWrap
                        datetexttext.maximumLineCount = 2
                    }
                }*/
            }

            Component.onCompleted: {
                adjust()
            }

            onClicked: {
                var tmp = (favorite === 0) ? 1 : 0
                var flag = ST.editDays(dayid,name,year,month,day,datetext,tmp)
                console.log("flag="+flag)
                if(flag){
                    //staricon.visible = tmp === 1
                    listModel.set(index,{"favorite":tmp})
                }
                //adjust()
            }

            ListView.onRemove: RemoveAnimation {
                target: listItem
                duration: 250
            }

            function refreshdays(year,month,day) {
                var days = Compute.daysBetween(year,month,day)
                return days
            }

            function remove(dayid) {
                remorseAction ( qsTr( "Deleting" ) , function() {
                    listModel.remove(index);
                    ST.deleteDays(dayid);
                } , 3000 )
            }

            Rectangle {
                z: -1
                height: parent.height
                width: parent.width
                opacity: index%2 === 0 ? 0.08 : 0
            }

            Label {
                id: countdowntotext
                x: Theme.paddingMedium
                text: daysbetween > 1 ? qsTr( "Countdown to" ) : ""
                color: Theme.highlightColor
            }

            Label {
                id: nametext
                x: Theme.paddingMedium
                anchors.top: countdowntotext.bottom
                width: page.width - daystext1.width - daystext2.width - 3 * x
                text: name
                //truncationMode: TruncationMode.Fade
                elide: Text.ElideNone
                font.pixelSize: Theme.fontSizeLarge
                wrapMode: Text.NoWrap
                //maximumLineCount: truncated ? 2 : 1
                color: listItem.highlighted ?
                           Theme.highlightColor :
                           (daysbetween >= 0 ? Theme.highlightColor : Theme.primaryColor)
            }

            Label {
                id: datetexttext
                x: Theme.paddingMedium
                anchors.top: nametext.bottom
                width: staricon.visible ?
                           parent.width - 2 * x - staricon.width - daystext1.width - daystext2.width :
                           parent.width - 2 * x - daystext1.width - daystext2.width
                //text: year + seperator + month + seperator + day
                text: date_text
                truncationMode: TruncationMode.Fade
                //elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.secondaryColor
            }

            Image {
                id: staricon
                visible: favorite === 1
                anchors {
                    left: datetexttext.right
                    verticalCenter: datetexttext.verticalCenter
                }
                source: "image://theme/icon-s-favorite"
            }

            Label {
                id: daystext1
                anchors.left: nametext.right
                anchors.bottom: datetexttext.bottom
                text: daysbetween > 1 ? daysbetween : (daysbetween === 0 ? qsTr("today") : (daysbetween ===1 ? qsTr("tmr") : -daysbetween) )
                font.pixelSize: daysbetween < 0 || daysbetween > 1 ? Theme.fontSizeHuge * 1.5 : Theme.fontSizeHuge
                color: listItem.highlighted ?
                           Theme.highlightColor :
                           (daysbetween >= 0 ? Theme.highlightColor : Theme.primaryColor)
            }

            Label {
                id: daystext2
                anchors.left: daystext1.right
                anchors.bottom: nametext.bottom
                anchors.bottomMargin: -15
                text: daysbetween > 1 ? qsTr("days") : (daysbetween === 0 || daysbetween === 1 ? "" : (daysbetween === -1 ? qsTr("day ago") : qsTr("days ago")))
                font.pixelSize: Theme.fontSizeMedium
                color: listItem.highlighted ?
                           Theme.highlightColor :
                           (daysbetween >= 0 ? Theme.highlightColor : Theme.primaryColor)
            }

            Component {
                id: contextMenuComponent
                ContextMenu {
                    id: itemmenu
                    MenuItem {
                        text: qsTr("Edit")
                        onClicked: editItem(dayid,name,year,month,day,datetext,favorite)
                    }
                    MenuItem {
                        text: qsTr("Delete")
                        onClicked: {
                            itemDeleted = true
                            remove(dayid)
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }

    Settings {
        id: settings
    }

}


