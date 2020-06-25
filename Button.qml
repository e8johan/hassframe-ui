import QtQuick 2.0

Item {
    property alias iconSource: icon.source
    signal clicked

    width: 60
    height: 60

    Image {
        anchors.centerIn: parent
        source: "images/buttonbg.png"
    }

    Image {
        id: icon
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
