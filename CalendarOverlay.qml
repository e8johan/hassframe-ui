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
        onClicked: hide()
    }

    ListView {
        anchors.fill: parent
        anchors.margins: 10

        enabled: false

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
}
