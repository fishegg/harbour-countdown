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
import "../pages/calc.js" as CALC
import "../pages"

CoverBackground {

    id: cover

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
        }
    }

    Timer {
        id: refreshTimer
        onTriggered: {
            updateDaysbetween()
        }
    }

    function updateDaysbetween() {
        ST.getDays("favorite")
        refreshTimer.interval = CALC.nextZeroPoint()
        refreshTimer.start()
    }

    Component.onCompleted: {
        updateDaysbetween()
    }

    onStatusChanged: {
        if( status === Cover.Activating ) {
            console.log("add="+itemAdded+"delete="+itemDeleted)
            if(itemAdded) {
                updateDaysbetween()
                itemAdded = false
            }else if(itemDeleted) {
                refreshdelay.start()
                itemDeleted = false
            }else {
                updateDaysbetween()
            }
            console.log("start and interval="+refreshTimer.interval)
        }else if( status === Cover.Deactivating ) {
            refreshTimer.stop()
            console.log("stop")
        }
    }

    Label {
        id: label
        anchors.centerIn: parent
    }

    ListView {
        id: listview
        anchors {
            fill: cover
            topMargin: Theme.paddingMedium
        }
        clip: true
        model: listModel
        delegate: ListView {
            id:listview2
            height: label2.height + label3.height + Theme.paddingSmall / 10

            function refreshdays(year,month,day) {
                console.log(year+"."+month+"."+day)
                var days = CALC.daysBetween(year,month,day)
                return days
            }
            property int daysbetween: refreshdays(year,month,day)


            Label {
                id: label1
                x: Theme.paddingMedium
                text: daysbetween < 0 ? -daysbetween : (daysbetween===0 ? qsTr("0") : (daysbetween===1 ? qsTr("1") : daysbetween))
                font.pixelSize: Theme.fontSizeExtraLarge
                color: daysbetween >= 0 ? Theme.highlightColor : Theme.secondaryColor
            }
            Label {
                id: label2
                text: daysbetween < -1 ? qsTr("days ago") : (daysbetween === -1 ? qsTr("day ago") : (daysbetween===0 || daysbetween===1 ? qsTr("day later") : qsTr("days later")))
                font.pixelSize: Theme.fontSizeTiny
                anchors {
                    left: label1.right
                    bottom: label1.bottom
                    bottomMargin: Theme.paddingSmall * 5/4
                }
                color: daysbetween >= 0 ? Theme.highlightColor : Theme.secondaryColor
            }
            Label {
                id: label3
                text: name
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignRight
                truncationMode: TruncationMode.Fade
                width: cover.width - label1.width - 2 * Theme.paddingMedium - Theme.paddingSmall / 2
                anchors {
                    left: label1.right
                    leftMargin: Theme.paddingSmall / 2
                    bottom: label2.top
                    bottomMargin: -Theme.paddingSmall
                }
            }
        }
    }

    OpacityRampEffect {
        sourceItem: listview
        direction: OpacityRamp.TopToBottom
        slope: 3.8
        offset: 0.69
        enabled: listModel.count > 4
    }

    FirstPage {id: firstpage}

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: {
                coverAdd = true
                console.log(coverAdd)
                mainapp.activate()
                firstpage.createNew()
            }
        }
    }
}


