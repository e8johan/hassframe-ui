/*
 * hassframe-ui - the user interface of a hass.io photo frame
 * Copyright (C) 2018 Johan Thelin
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

import QtQuick 2.7
import QtQuick.Window 2.0

Window {
    id: root

    width: 800
    height: 480
    title: qsTr("Hello World")

    SlideshowBackground {
        id: slideshow

        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (menuDrawer.isOpen)
                    menuDrawer.hide();
                else
                    menuDrawer.show();
            }
        }

        Item {
            id: overlay

            anchors.fill: parent

            z: 2

            ListView {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 20
                anchors.leftMargin: 20
                anchors.bottom: clockText.top

                enabled: false

                width: 300
                clip: true

                model: icalModel.model

                section.property: "dateString"
                section.delegate: Item {
                    width: parent.width
                    height: 20
                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: section

                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 2

                        color: "white"
                    }
                }
                delegate: Item {
                    width: parent.width
                    height: 16
                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: timeString

                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 50
                        width: parent.width-x

                        text: eventSummary
                        elide: Text.ElideRight

                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            IcalModel {
                id: icalModel
            }

            Column {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.topMargin: 20

                Repeater {
                    model: busStopModel.model
                    delegate: Item {
                        width: 100;
                        height: 20;

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right

                            text: timeString.substring(0, 5)

                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            width: 40

                            height: 16
                            radius: height/2

                            color: "#009ddb"

                            Text {
                                anchors.centerIn: parent

                                text: transportNumber

                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }
            }

            BusStopModel {
                id: busStopModel
            }

            Timer {
                interval: 60000
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: {
                    var url = 'http://192.168.1.202:8123/api/states/sensor.outdoors_temperature'
                    var http = new XMLHttpRequest();
                    http.onreadystatechange = function() {
                        if (http.readyState === 4)
                        {
                            if (http.status === 200) {
                                var json = JSON.parse(http.responseText);
                                temperatureText.text = json.state+"°C"
                            }
                            else
                                console.log("Issue with temperature, " + http.readyState);
                        }
                    };
                    http.open('GET', url, true);
                    http.setRequestHeader('Content-Type', 'application/json');
                    http.setRequestHeader('Authorization', 'Bearer ' + HASS_AUTH_KEY);
                    http.send("");
                }
            }

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    var date = new Date;

                    var hours = date.getHours();
                    var minutes = date.getMinutes();
                    var seconds = date.getSeconds();

                    var year = date.getFullYear();
                    var month = date.getMonth();
                    var day = date.getDate();
                    var dayOfWeek = date.getDay();

                    var dayOfWeekName = "Okänd dag"

                    switch(dayOfWeek)
                    {
                    case 0:
                        dayOfWeekName = "Söndag";
                        break;
                    case 1:
                        dayOfWeekName = "Måndag";
                        break;
                    case 2:
                        dayOfWeekName = "Tisdag";
                        break;
                    case 3:
                        dayOfWeekName = "Onsdag";
                        break;
                    case 4:
                        dayOfWeekName = "Torsdag";
                        break;
                    case 5:
                        dayOfWeekName = "Fredag";
                        break;
                    case 6:
                        dayOfWeekName = "Lördag";
                        break;
                    }

                    clockText.text = ("00" + hours).slice(-2) + ":" + ("00" + minutes).slice(-2) // + ":" + ("00" + seconds).slice(-2);
                    dateText.text = dayOfWeekName + " " + year + "-" + ("00" + (month+1)).slice(-2) + "-" + ("00" + day).slice(-2);
                }
            }

            Text {
                id: clockText

                anchors.left: dateText.left
                anchors.baseline: temperatureText.baseline

                text: "12:34"

                color: "white"
                font.pixelSize: 80
            }

            Text {
                id: dateText

                anchors.left: parent.left
                anchors.top: clockText.bottom
                anchors.leftMargin: 20

                text: "Måndag 2018-10-05"

                color: "white"
                font.pixelSize: 20
            }

            Text {
                id: temperatureText

                anchors.bottom: weatherRow.top
                anchors.right: parent.right
                anchors.bottomMargin: 20
                anchors.rightMargin: 20

                text: "##°C"

                color: "white"
                font.pixelSize: 80
            }

            Row {
                id: weatherRow

                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottomMargin: 20

                spacing: 10
                Repeater {
                    delegate: Column {
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            text: {
                                switch (period) {
                                case 0:
                                    "00 - 06"
                                    break;
                                case 1:
                                    "06 - 12"
                                    break;
                                case 2:
                                    "12 - 18"
                                    break;
                                case 3:
                                default:
                                    "18 - 00"
                                    break;
                                }
                            }
                        }
                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            source: symbolSource
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            text: precipitation + "mm"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                            text: temperature + "°C"
                        }
                    }

                    model: weatherModel.model
                }
            }

            YrWeatherModel {
                id: weatherModel
                place: "Sweden/V%C3%A4stra_G%C3%B6taland/Alings%C3%A5s"
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 5
                anchors.rightMargin: 20
                text: weatherModel.dataSourceNotice
                color: "white"
                font.pixelSize: 12
                font.italic: true
            }
        }
    }

    Rectangle {
        id: menuDrawer

        property bool isOpen: false

        function show()
        {
            showAnimation.start();
            hideTimer.restart();
        }

        function hide()
        {
            hideAnimation.start();
            hideTimer.stop();
        }

        Timer {
            id: hideTimer
            interval: 10000
            repeat: false
            onTriggered: menuDrawer.hide()
        }

        SequentialAnimation {
            id: showAnimation

            PropertyAnimation {
                target: menuDrawer
                property: "y"
                to: root.height - menuDrawer.height
                duration: 300
                easing.type: Easing.OutCubic
            }
            PropertyAction {
                target: menuDrawer
                property: "isOpen"
                value: true
            }
        }

        SequentialAnimation {
            id: hideAnimation

            PropertyAnimation {
                target: menuDrawer
                property: "y"
                to: root.height
                duration: 300
                easing.type: Easing.InCubic
            }
            PropertyAction {
                target: menuDrawer
                property: "isOpen"
                value: false
            }
        }

        x: 0
        y: root.height

        width: root.width
        height: 420

        color: "black"

        MouseArea {
            anchors.fill: parent
        }

        DrawerContents {
            anchors.fill: parent
        }
    }

    Component.onCompleted: {
        if (HASS_DEBUG === "yes")
            root.show();
        else
            root.showFullScreen();
    }

    MouseArea {
        anchors.fill: parent
        enabled: false
        cursorShape: Qt.BlankCursor
    }
}
