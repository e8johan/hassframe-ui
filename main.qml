import QtQuick 2.11
import QtQuick.Window 2.11
import Qt.labs.folderlistmodel 2.2

Window {
    id: root

    visible: true
    width: 800
    height: 480
    title: qsTr("Hello World")

    Item {
        id: slideshow

        anchors.fill: parent

        function switchImage()
        {
            if (imageA.opacity === 0)
            {
                showImageAAnimation.start();
            }
            else
            {
                showImageBAnimation.start();
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (menuDrawer.isOpen)
                    menuDrawer.hide();
                else
                    menuDrawer.show();
            }
        }

        Timer {
            interval: 20000
            repeat: true
            running: true
            onTriggered: slideshow.switchImage()
        }

        SequentialAnimation {
            id: showImageAAnimation

            PropertyAction { target: imageA; property: "opacity"; value: 0 }
            PropertyAction { target: imageA; property: "z"; value: 1 }
            PropertyAction { target: imageB; property: "z"; value: 0 }
            PropertyAnimation { target: imageA; property: "opacity"; from: 0; to: 1; duration: 1000; }
            PropertyAction { target: imageB; property: "opacity"; value: 0 }
            ScriptAction { script: { imageB.source = imagesModel.getNext(); } }
        }

        SequentialAnimation {
            id: showImageBAnimation

            PropertyAction { target: imageB; property: "opacity"; value: 0 }
            PropertyAction { target: imageB; property: "z"; value: 1 }
            PropertyAction { target: imageA; property: "z"; value: 0 }
            PropertyAnimation { target: imageB; property: "opacity"; from: 0; to: 1; duration: 1000; }
            PropertyAction { target: imageA; property: "opacity"; value: 0 }
            ScriptAction { script: { imageA.source = imagesModel.getNext(); } }
        }

        FolderListModel {
            id: imagesModel

            property int _index: 0

            function getNext()
            {
                var nextIndex = imagesModel._index + 1;
                if (imagesModel.count === 0) {
                    console.warn("No images found!");

                    if (nextIndex === 1)
                    {
                        imagesModel._index = 1;
                        return "images/erik.jpg";
                    }
                    else
                    {
                        imagesModel._index = 0;
                        return "images/lisa.jpg";
                    }
                }
                else if (nextIndex >= imagesModel.count)
                    nextIndex = 0;

                imagesModel._index = nextIndex;
                return imagesModel.get(nextIndex, "fileURL");
            }

            nameFilters: [ "IMG_*.jpg" ]
            folder: "file:///home/pi/Pictures"
        }

        Image {
            id: imageA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            source: "images/erik.jpg"

            opacity: 0
        }

        Image {
            id: imageB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            source: "images/lisa.jpg"
        }

        Item { // Overlay
            anchors.fill: parent

            z: 2

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    // Update clock and date and stuff here

                }
            }

            Text {
                id: clockText

                anchors.left: dateText.left
                anchors.bottom: dateText.top

                text: "16:55"

                color: "white"
                font.pixelSize: 100
            }

            Text {
                id: dateText

                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 40
                anchors.bottomMargin: 40

                text: "Måndag 2018-10-05"

                color: "white"
                font.pixelSize: 30
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

        Grid {
            anchors.fill: parent
            columns: 4
            spacing: 40
            topPadding: 40
            leftPadding: 40
            rightPadding: 40
            bottomPadding: 40

            Repeater {
                model: 8
                delegate:
                Rectangle {
                    color: "white"

                    width: height
                    height: 150
                    MouseArea {
                        anchors.fill: parent
                        onClicked: hideTimer.restart();
                    }
                }
            }
        }
    }
}
