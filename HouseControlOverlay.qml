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

        iconSource: "images/back.png"

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

        HassButton {
            x:13
            y:13
            entity: "switch.fonsterlampor_vardagsrum"
        }

        HassButton {
            x:13
            y:98
            entity: "switch.rislampan"
        }

        HassButton {
            x:104
            y:80
            entity: "switch.discolampan"
        }

        HassButton {
            x:236
            y:10
            entity: "switch.fonsterlampan_sovrum"
        }

        HassButton {
            x:236
            y:86
            entity: "switch.ac_sovrum"
            imagePrefix: "snow_"
        }
    }
}
