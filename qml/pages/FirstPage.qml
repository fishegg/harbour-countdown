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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "storage.js" as ST
import "calc.js" as CALC

Page {
    id: page

    property var currentDay:Qt.formatDateTime(wallClock.time, "dd")
    onCurrentDayChanged: {
        console.log(currentDay)
        ST.getDays("all")
    }

    allowedOrientations: Orientation.Portrait | Orientation.LandscapeMask

    property var currentDay:Qt.formatDateTime(wallClock.time, "dd")


    onCurrentDayChanged: {
        //listItem.daysbetween = listItem.refreshdays(year,month,day)
        ST.getDays("all")
        console.log("Day changed getDays")
    }

    function createNew() {
        var createdialog = pageStack.push(Qt.resolvedUrl("EditDialog.qml"))
        if(!coverAdd) {
            createdialog.accepted.connect(function() {
                ST.getDays("all")
                signalcenter.added();
                console.log("getDays")
            })
        }
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

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaListView {
        id: listview
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
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
            contentHeight: text1.height + text2.height + text3.height
            property int daysbetween: listItem.refreshdays(year,month,day)

            onClicked: {
                var tmp = favorite === 0 ? 1 : 0
                var flag = ST.editDays(dayid,name,year,month,day,datetext,tmp)
                console.log("flag="+flag)
                if(flag){
                    listModel.set(index,{"favorite":tmp})
                }
            }

            ListView.onRemove: RemoveAnimation {
                target: listItem
                duration: 250
            }

            function refreshdays(year,month,day) {
                var days = CALC.daysBetween(year,month,day)
                return days
            }

            function remove(dayid) {
                remorseAction ( qsTr( "Deleting" ) , function() {
                    listModel.remove(index);
                    ST.deleteDays(dayid);
                } , 3000 )
            }

            /*Timer {
                id: refreshtimer
                interval: 90000
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: {
                    daysbetween = listItem.refreshdays(year,month,day)
                    //console.log("refresh done")
                }
            }*/

            Rectangle {
                z: -1
                height: parent.height
                width: parent.width
                opacity: index%2 === 0 ? 0.08 : 0
            }

            Label {
                id: text1
                x:Theme.paddingMedium
                text: daysbetween > 1 ? qsTr( "Countdown to" ) : ""
                color: Theme.secondaryColor
            }
            Label {
                id: text2
                x: Theme.paddingMedium
                anchors.top: text1.bottom
                width: page.width - text4.width - text5.width - 2 * x
                text: name
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
            }
            Label {
                id: text3
                x: Theme.paddingMedium
                anchors.top: text2.bottom
                text: year + "." + month + "." + day
                color: Theme.secondaryColor
            }
            Image {
                id: tick
                visible: favorite === 1
                anchors {
                    left: text3.right
                    verticalCenter: text3.verticalCenter
                }
                source: "image://theme/icon-s-favorite"
            }
            Label {
                id: text4
                anchors.left: text2.right
                anchors.bottom: text3.bottom
                text: daysbetween > 1 ? daysbetween : (daysbetween === 0 ? qsTr("today") : (daysbetween ===1 ? qsTr("tmr") : -daysbetween) )
                font.pixelSize: daysbetween < 0 || daysbetween > 1 ? Theme.fontSizeHuge * 1.5 : Theme.fontSizeHuge
                color: daysbetween >=0 ? Theme.highlightColor : Theme.secondaryColor
            }
            Label {
                id: text5
                anchors.left: text4.right
                anchors.bottom: text2.bottom
                anchors.bottomMargin: -15
                text: daysbetween > 1 ? qsTr("days") : (daysbetween === 0 || daysbetween === 1 ? "" : (daysbetween === -1 ? qsTr("day ago") : qsTr("days ago")))
                font.pixelSize: Theme.fontSizeMedium
                color: daysbetween >=0 ? Theme.secondaryHighlightColor : Theme.secondaryColor
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
}


