import QtQuick 2.7
import Qt.labs.folderlistmodel 2.2

Item {
    id: slideshowRoot

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

    Timer {
        interval: 20000
        repeat: true
        running: true
        onTriggered: slideshowRoot.switchImage()
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

        nameFilters: [ "*.jpg" ]
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
}
