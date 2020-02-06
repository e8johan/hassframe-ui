import QtQuick 2.7

Item {

    Image {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 40
        anchors.leftMargin: 100

        source: "images/house-map.png"

        /* Downstairs */
        HassButton {
            x: -5; y: 125
            entity: "switch.fonsterlampor_vardagsrum"
        }
        HassButton {
            x: 90; y: 20
            entity: "switch.tomtestaden"
        }
        HassButton {
            x: 35; y: 260
            entity: "switch.rislampan"
        }
        HassButton {
            x: 350; y: 230
            entity: "switch.vitrinskap"
        }
        /* Outdoors */
        HassButton {
            x: -80; y: 20
            entity: "switch.ljusslingan"
        }
        /* Upstairs */
        HassButton {
            x: 145.5; y: 220
            entity: "switch.discolampan"
        }
        HassButton {
            x: 520; y: 10
            entity: "switch.fonsterlampan_sovrum"
        }
        HassButton {
            x: 520; y: 70
            entity: "switch.ac_sovrum"
            imagePrefix: "snow_"
        }
        HassButton {
            x: 520; y: 220
            entity: "light.sunrise"
        }
        /* Garage */
        HassButton {
            x: 600; y: 40
            entity: "switch.garage_heating"
            imagePrefix: "heat_"
        }
    }
}
