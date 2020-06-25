import QtQuick 2.0

Item {
    id: root

    anchors.centerIn: parent

    width: 320
    height: 240

    visible: false

    function show() {
        root.visible = true
    }

    function hide() {
        root.visible = false
    }

    Rectangle {
        anchors.fill: parent

        opacity: 0.7
        color: "black"
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
    }

    Button {
        anchors.right: root.right
        anchors.bottom: root.bottom
        anchors.rightMargin: 3
        anchors.bottomMargin: 3

        z: 2

        onClicked: {
            if (houseMap.state == "zoomedout")
                root.hide();
            else
                houseMap.state = "zoomedout"
        }
    }

    Image {
        id: houseMap

        source: "images/house-map.png"

        x: 10
        y: 20

        sourceSize.width: 300
        sourceSize.height: 220

        MouseArea {
            x: 0
            y: 0
            width: 100
            height: 220

            onClicked: houseMap.state = "livingroom"
        }

        MouseArea {
            x: 100
            y: 0
            width: 100
            height: 220

            onClicked: houseMap.state = "disco"
        }

        MouseArea {
            x: 200
            y: 0
            width: 100
            height: 120

            onClicked: houseMap.state = "bedroom"
        }

        state: "zoomedout"

        states: [
            State {
                name: "zoomedout"
                PropertyChanges { target: houseMap; x: 10; y: 20; sourceSize.width: 300; sourceSize.height: 220; }
            },
            State {
                name: "bedroom"
                PropertyChanges { target: houseMap; x: -250; y: 20; sourceSize.width: 600; sourceSize.height: 440; }
            },
            State {
                name: "livingroom"
                PropertyChanges { target: houseMap; x: 50; y: 20; sourceSize.width: 600; sourceSize.height: 440; }
            },
            State {
                name: "disco"
                PropertyChanges { target: houseMap; x: -100; y: -100; sourceSize.width: 600; sourceSize.height: 440; }
            }
        ]
    }
}
