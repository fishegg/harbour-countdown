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
import "../pages/storage.js" as ST
import "../pages/compute.js" as Compute
import "../pages"

CoverBackground {

    id: cover

    property int border_index

    ListModel {id: listModel}

    CoverPlaceholder {
        id: coverplaceholder
        text: qsTr("No items")
        icon.source: "../images/harbour-countdown-new.png"
        visible: listModel.count === 0
    }

    Timer {
        id: refreshdelay
        interval: 3000
        onTriggered: {
            updateDaysbetween()
            if(listview.current_page > listview.max_page) {
                listview.current_page = listview.max_page
            }
        }
    }

    Timer {
        id: refreshtimer
        onTriggered: {
            updateDaysbetween()
        }
    }

    function updateDaysbetween() {
        ST.getDays("favorite")
        refreshtimer.interval = Compute.nextZeroPoint()
        refreshtimer.start()
        console.log("cover refresh timer start interval="+refreshtimer.interval)
    }

    Component.onCompleted: {
        updateDaysbetween()
    }

    onStatusChanged: {
        if(status === Cover.Activating) {
            console.log("add="+itemAdded+"delete=" + itemDeleted)
            if(itemAdded) {
                updateDaysbetween()
                if(listview.current_page > listview.max_page) {
                    listview.current_page = listview.max_page
                }
                itemAdded = false
            }
            else if(itemDeleted) {
                refreshdelay.start()
                itemDeleted = false
            }
            else {
                updateDaysbetween()
                if(listview.current_page > listview.max_page) {
                    listview.current_page = listview.max_page
                }
            }
        }
        else if(status === Cover.Deactivating) {
            refreshtimer.stop()
            console.log("cover refresh timer stop")
        }
    }

    /*Label {
        id: label
        anchors.centerIn: parent
    }*/

    Item {
        id: listviewitem
        anchors {
            fill: parent
            topMargin: Theme.paddingMedium
            bottomMargin: Theme.paddingLarge + Theme.paddingLarge + Theme.paddingLarge
        }

        ListView {
            id: listview

            property int current_page: 1
            property int max_page: (listModel.count + 3) / 4
            property int visible_item_count: 4
            property int max_index: listModel.count - 1

            anchors {
                fill: parent
                //topMargin: Theme.paddingMedium
                //bottomMargin: Theme.paddingLarge + Theme.paddingLarge + Theme.paddingLarge
            }

            clip: true
            //height: parent.height / 5 * 4 - Theme.paddingMedium
            model: listModel
            delegate: ListView {
                id:listview2

                height: daystexttext.height + nametext.height + Theme.paddingSmall / 10
                /*visible: ((index >= current_page * 5 - 5) && (index <= current_page * 5 - 1)) ?
                             true :
                             false*/

                property int daysbetween: refreshdays(year,month,day)

                function adjust() {
                    if(nametext.contentWidth > nametext.width) {
                        var ratio = nametext.contentWidth / nametext.width
                        //console.log("ratio=" + ratio)
                        if(ratio < 2) {
                            nametext.font.pixelSize = Theme.fontSizeSmall / ratio
                            nametext.maximumLineCount = 1
                        }
                        else {
                            nametext.font.pixelSize = Theme.fontSizeSmall / 2
                            nametext.elide = Text.ElideRight
                            nametext.wrapMode = Text.WordWrap
                            nametext.maximumLineCount = 2
                        }
                    }
                }

                function refreshdays(year,month,day) {
                    //console.log(year+"."+month+"."+day)
                    var days = Compute.daysBetween(year,month,day)
                    return days
                }

                Component.onCompleted: {
                    adjust()
                    //listview.current_page = 1
                    //listview.max_page = (listModel.count + 4) / 5
                    //console.log("count=" + listModel.count + "max page=" + listview.max_page)
                }

                Label {
                    id: daystext
                    x: Theme.paddingMedium
                    text: daysbetween < 0 ? -daysbetween : (daysbetween===0 ? qsTr("0") : (daysbetween===1 ? qsTr("1") : daysbetween))
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: daysbetween >= 0 ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: daystexttext
                    text: daysbetween < -1 ? qsTr("days ago") : (daysbetween === -1 ? qsTr("day ago") : (daysbetween===0 || daysbetween===1 ? qsTr("day later") : qsTr("days later")))
                    font.pixelSize: Theme.fontSizeTiny
                    anchors {
                        left: daystext.right
                        bottom: daystext.bottom
                        bottomMargin: Theme.paddingSmall * 5/4
                    }
                    color: daysbetween >= 0 ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: nametext
                    text: name
                    font.pixelSize: Theme.fontSizeSmall
                    //horizontalAlignment: Text.AlignRight
                    //truncationMode: TruncationMode.Fade
                    height: 36
                    width: cover.width - daystext.width - 2 * Theme.paddingMedium - Theme.paddingSmall / 2
                    anchors {
                        left: daystext.right
                        leftMargin: Theme.paddingSmall / 2
                        bottom: daystexttext.top
                        bottomMargin: -Theme.paddingSmall
                    }
                    color: daysbetween >= 0 ? Theme.highlightColor : Theme.primaryColor
                }
            }
        }
    }

    /*OpacityRampEffect {
        id: topramp
        sourceItem: listviewitem
        direction: OpacityRamp.BottomToTop
        slope: 2
        offset: 0.5
        //enabled: listModel.count > 4
        enabled: listview.current_page > 1
    }

    OpacityRampEffect {
        id: bottomramp
        sourceItem: listviewitem
        direction: OpacityRamp.TopToBottom
        slope: 2
        offset: 0.5
        //enabled: listModel.count > 4
        enabled: listview.current_page < listview.max_page
    }*/

    Label {
        id: pagelabel
        anchors {
            top: listviewitem.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: listviewitem.horizontalCenter
        }
        font.pixelSize: Theme.fontSizeTiny
        text: listview.current_page + "/" + listview.max_page
    }

    //FirstPage {id: firstpage}

    CoverActionList {
        id: coverAction

        /*CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                coverAdd = true
                console.log(coverAdd)
                mainapp.activate()
                firstpage.createNew()
            }
        }*/

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                //console.log("previous")
                if(listview.current_page === 1) {
                    listview.current_page = listview.max_page
                    //console.log("max index"+max_index)
                    border_index = listview.max_index
                    listview.positionViewAtIndex(border_index,ListView.End)
                }
                else if(listview.current_page === 2) {
                    listview.current_page = listview.current_page - 1
                    border_index = 0
                    listview.positionViewAtIndex(border_index,ListView.Beginning)
                }
                else {
                    listview.current_page = listview.current_page - 1
                    border_index = listview.max_index - (listview.max_page - listview.current_page) * 4
                    listview.positionViewAtIndex(border_index,ListView.End)
                }
                //console.log("topramp=" + topramp.enabled + "bottomramp=" + bottomramp.enabled)
                console.log("listview height=" + listview.height + "border height=" + listviewitem.height)
                //console.log("current page=" + listview.current_page)
                //console.log("positionViewAtIndex=" + border_index)
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                //console.log("next")
                if(listview.current_page < listview.max_page) {
                    listview.current_page = listview.current_page + 1
                    //border_index = listview.current_page * 4 - 4
                    border_index = listview.current_page * 4 - 4
                    listview.positionViewAtIndex(border_index,ListView.Beginning)
                }
                else {
                    listview.current_page = 1
                    border_index = 0
                    listview.positionViewAtIndex(border_index,ListView.Beginning)
                }
                //console.log("topramp=" + topramp.enabled + "bottomramp=" + bottomramp.enabled)
                console.log("listview height=" + listview.height + "border height=" + listviewitem.height)
                //console.log("current page=" + listview.current_page)
                //console.log("positionViewAtIndex=" + border_index)
            }
        }
    }
}


