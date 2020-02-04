import QtQuick 2.7

Grid {
    columns: 4
    spacing: 40
    topPadding: 40
    leftPadding: 40
    rightPadding: 40
    bottomPadding: 40

    Repeater {
        delegate:
        Rectangle {
            width: height
            height: 150

            color: type === "disabled"?"#333333":"white"

            Image {
                anchors.centerIn: parent
                visible: type != "disabled"
                source: (type != "disabled")?("images/" + name + ".png"):""
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    hideTimer.restart();

                    if (type === "request") {
                        var url = 'http://192.168.1.202:8123/api/services/' + service
                        var params = '{"entity_id": "' + entity + '"}'
                        var http = new XMLHttpRequest();

                        http.open('POST', url, true);
                        http.setRequestHeader('Content-Type', 'application/json');
                        http.setRequestHeader('Authorization', 'Bearer ' + HASS_AUTH_KEY);
                        http.send(params);
                    }
                    else if (type === "action")
                    {
                        action();
                    }
                }
            }
        }

        model: ListModel {
            ListElement {
                name: "fonsterlampa-on"
                type: "request"
                entity: "switch.fonsterlampor_vardagsrum"
                service: "switch/turn_on"
            }

            ListElement {
                name: "rislampa-on"
                type: "request"
                entity: "switch.rislampan"
                service: "switch/turn_on"
            }

            ListElement {
                name: "disco-on"
                type: "request"
                entity: "switch.discolampan"
                service: "switch/turn_on"
            }

            ListElement {
                name: "toggle-overlay"
                type: "action"
                action: function() { overlay.visible = !overlay.visible; }
            }

            ListElement {
                name: "fonsterlampa-off"
                type: "request"
                entity: "switch.fonsterlampor_vardagsrum"
                service: "switch/turn_off"
            }

            ListElement {
                name: "rislampa-off"
                type: "request"
                entity: "switch.rislampan"
                service: "switch/turn_off"
            }

            ListElement {
                name: "disco-off"
                type: "request"
                entity: "switch.discolampan"
                service: "switch/turn_off"
            }

            ListElement {
                type: "disabled"
            }
        }
    }
}
