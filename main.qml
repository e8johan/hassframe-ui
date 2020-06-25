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

    width: 320
    height: 240
    title: qsTr("Hello World")

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Button {
        id: houseButton

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 3
        anchors.topMargin: 3

        iconSource: "images/house.png"

        onClicked: houseControlOverlay.show()
    }

    Button {
        id: calendarButton

        anchors.right: houseButton.right
        anchors.top: houseButton.bottom
        anchors.topMargin: 10

        iconSource: "images/calendar.png"

        onClicked: calendarOverlay.show()
    }

    CalendarOverlay {
        id: calendarOverlay
        z: 2
    }

    HouseControlOverlay {
        id: houseControlOverlay
        z: 2
    }

    Item {
        id: clock

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 17
        anchors.leftMargin: 10

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

            anchors.left: parent.left
            anchors.top: parent.top

            text: "12:34"

            color: "white"
            font.pixelSize: 80
        }

        Text {
            id: dateText

            anchors.top: clockText.bottom
            anchors.horizontalCenter: clockText.horizontalCenter
            anchors.topMargin: -20

            text: "Måndag 2018-10-05"

            color: "white"
            font.pixelSize: 20
        }
    }

    Item {
        id: temperature

        anchors.left: parent.left
        anchors.bottom: weather.bottom

        height: 90
        width: 90

        Text {
            id: temperatureText

            anchors.centerIn: parent

            text: "##°C"

            color: "white"
            font.pixelSize: 20
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
    }

    Item {
        id: weather

        anchors.bottom: parent.bottom
        anchors.right: parent.right

        Row {
            id: weatherRow

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.bottomMargin: 12

            spacing: 0

            Repeater {
                delegate: Column {
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 8
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
                    // TODO shrink margins here
                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: symbolSource
                        scale: 0.7
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "white"
                        font.pixelSize: 8
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
            anchors.bottomMargin: 3
            anchors.rightMargin: 3
            text: weatherModel.dataSourceNotice
            color: "white"
            font.pixelSize: 8
            font.italic: true
        }
    }

    Component.onCompleted: {
        if (HASS_DEBUG === "yes")
            root.show();
        else
            root.showFullScreen();

        backlight.enabled = true;
    }

    Timer {
        id: backlightTimer
        interval: 5000 // 60000*2 // two minutes
        running: true
	repeat: false
        onTriggered: backlight.enabled = false;
    }

    MouseArea {
        anchors.fill: parent
        enabled: true
        cursorShape: Qt.BlankCursor
	propagateComposedEvents: true
	z: 100

	onClicked: {
            backlightTimer.restart();
            if (backlight.enabled)
                mouse.accepted = false;
            else
                mouse.accepted = true;
            backlight.enabled = true;
	}
    }
}
