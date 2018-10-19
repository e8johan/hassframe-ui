import QtQuick 2.0

Item {
    property alias model: busModel
    property var stops: []

    ListModel {
        id: busModel
    }

    ListModel {
        id: _internalModel
    }

    function _updateBusModel(http)
    {
        if (http.readyState === 4)
        {
            if (http.status === 200) {
                var json = JSON.parse(http.responseText);
                var departureList = json.Departure;

                // Determine which bus numbers appear in the results
                var busNumbers = [];
                for (var i=0; i<departureList.length; ++i)
                    if (busNumbers.indexOf(departureList[i].transportNumber) === -1)
                        busNumbers.push(departureList[i].transportNumber);

                // Remove the relevant busses from the intermediate model
                for (var i=0; i<_internalModel.count; ++i) {
                    if (busNumbers.indexOf(_internalModel.get(i).transportNumber) > -1) {
                        _internalModel.remove(i);
                        i=-1; // The for-loop will ++i
                    }
                }

                // Re-insert the busses into the intermediate model
                for (var i=0; i<departureList.length; ++i) {
                    var j=0;
                    while(j<_internalModel.count && _internalModel.get(j).date<Date.parse(departureList[i].date + " " + departureList[i].time))
                        ++j;

                    while(j<_internalModel.count && _internalModel.get(j).date === Date.parse(departureList[i].date + " " + departureList[i].time) && _internalModel.get(j).transportNumber < departureList[i].transportNumber)
                        ++j;

                    _internalModel.insert(j, { "transportNumber": departureList[i].transportNumber,
                                               "date": Date.parse(departureList[i].date + " " + departureList[i].time),
                                               "timeString": departureList[i].time,
                                               "dateString": departureList[i].date } );
                }

                // Update the final model with the top items
                for (var i=0; i<5 && i< _internalModel.count; ++i)
                    busModel.set(i, _internalModel.get(i));
            }
            else
                console.log("Issue with bus model, " + http.readyState);
        }
    }

    Timer {
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // curl --data 'key=DEPARTURE_KEY' --data 'format=json' --data 'maxJourneys=5' --data 'passlist=0' --data 'direction=740000018' --data 'id=740061017' -G https://api.resrobot.se/v2/departureBoard

            var url1 = 'https://api.resrobot.se/v2/departureBoard?' +
                    'format=json&maxJourneys=5&passlist=0&direction=740000018&id=740061017&key=' + DEPARTURE_KEY
            var url2 = 'https://api.resrobot.se/v2/departureBoard?' +
                    'format=json&maxJourneys=5&passlist=0&direction=740000018&id=740060956&key=' + DEPARTURE_KEY

            var http;
            http = new XMLHttpRequest();
            http.onreadystatechange = function() {
                _updateBusModel(http);
            };
            http.open('GET', url1, true);
            http.send('');

            var http2 = new XMLHttpRequest();
            http2.onreadystatechange = function() {
                _updateBusModel(http2);
            };
            http2.open('GET', url2, true);
            http2.send('');

//            var url = 'http://192.168.1.202:8123/api/services/' + service
//            var params = '{"entity_id": "' + entity + '"}'
//            var http = new XMLHttpRequest();

//            http.open('POST', url, true);
//            http.setRequestHeader('Content-Type', 'application/json');
//            http.send(params);
        }
    }
}
