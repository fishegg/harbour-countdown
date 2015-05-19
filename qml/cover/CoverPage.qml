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
import "../pages/refreshinterval.js" as RE
import "../pages"

CoverBackground {

    id: cover

    ListModel {id: listModel}

    CoverPlaceholder {
                text: qsTr("No items")
                visible: listModel.count === 0
            }

    Timer {
        id: refreshdelay
        interval: 3000
        onTriggered: ST.getDays("all")
    }

    Timer {
        id: refreshTimer
        property int firstinterval: RE.nextZeroPoint()
        interval: firstinterval
        onTriggered: {
            ST.getDays("all")
        }
    }

    Component.onCompleted: {
        ST.getDays("all")
        refreshTimer.start()
        refreshTimer.start()
    }

    onStatusChanged: {
        if( status === Cover.Activating ) {
            ST.getDays("all")
            refreshdelay.start()
            refreshTimer.restart()
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
            height: label2.height + label3.height + Theme.paddingSmall / 10
            property int daysbetween: refreshdays(year,month,day)
            function refreshdays(year,month,day) {
                var days = CALC.daysBetween(year,month,day)
                return days
            }

            Label {
                id: label1
                x: Theme.paddingMedium
                text: daysbetween < 0 ? -daysbetween : (daysbetween===0 ? qsTr("0") : (daysbetween===1 ? qsTr("1") : daysbetween))
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor
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
                color: Theme.highlightColor
            }
            Label {
                id: label3
                text: name
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                width: parent.width - label1.width - 2 * Theme.paddingMedium
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

/*    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: createNew()
        }
    }*/
}


