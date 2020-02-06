import QtQuick 2.0

Item {
    id: root

    width: 64
    height: 64

    property string entity
    property int interval: 30000
    property string imagePrefix: "light_"

    property string _state: "off"

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: "images/"+ imagePrefix + _state + ".png"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (_state == "on")
                _setState("off");
            else
                _setState("on");
        }
    }

    Timer {
        interval: root.interval
        repeat: true
        triggeredOnStart: true

        running: interval != 0

        onTriggered: _pollState()
    }

    function _setState(newState)
    {
        var service = entity.split(".")[0] + "/turn_" + newState

        var url = 'http://192.168.1.202:8123/api/services/' + service
        var params = '{"entity_id": "' + entity + '"}'
        var http = new XMLHttpRequest();

        http.open('POST', url, true);
        http.setRequestHeader('Content-Type', 'application/json');
        http.setRequestHeader('Authorization', 'Bearer ' + HASS_AUTH_KEY);
        http.send(params);

        _state = newState
    }

    function _pollState()
    {
        var url = 'http://192.168.1.202:8123/api/states/' + root.entity
        var http = new XMLHttpRequest();
        http.onreadystatechange = function() {
            _updateState(http);
        };
        http.open('GET', url, true);
        http.setRequestHeader('Content-Type', 'application/json');
        http.setRequestHeader('Authorization', 'Bearer ' + HASS_AUTH_KEY);
        http.send();
    }

    function _updateState(http)
    {
        if (http.readyState === 4)
        {
            if (http.status === 200) {
                var json = JSON.parse(http.responseText);
                _state = json.state
            }
            else
                console.log("Issue with hass element " + root.entity + " " + http.status);
        }
    }
}
