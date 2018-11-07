import QtQuick 2.0

Item {
    id: root

    property alias model: _innerModel

    ListModel {
        id: _innerModel
    }

    function _dateString(d)
    {
        var year = d.getYear() + 1900;
        var month = d.getMonth();
        var day = d.getDate();

        return year + "-" + ("00" + (month+1)).slice(-2) + "-" + ("00" + day).slice(-2);
    }

    function _insertNewEvent(_eventDate, _eventTime, _eventSummary)
    {
        var firstDate = Date.now() - 1*1000*24*60*60; // Drop everything older than yesterday
        var lastDate = Date.now() + 7*1000*24*60*60;  // Drop everything further into the future than a week

        // Drop contents older or newer than the window
        if (!(_eventDate > firstDate && _eventDate < lastDate))
            return;

        var i = 0;
        while (i < _innerModel.count && _innerModel.get(i).eventDate < _eventDate)
            ++i;

        var d = new Date(_eventDate);

        if (_eventTime.length > 0) {
            var utcD = new Date();
            utcD.setUTCHours(_eventTime.substr(0,2));
            utcD.setUTCMinutes(_eventTime.substr(3, 2));
            _eventTime = ("00"+utcD.getHours()).substr(-2) + ":" + ("00"+utcD.getMinutes()).substr(-2)
        }
        _innerModel.insert(i, { eventDate: _eventDate, dateString: _dateString(d), timeString: _eventTime, eventSummary: _eventSummary });
    }

    function _updateModel(http)
    {
        if (http.readyState === 4)
        {
            if (http.status === 200) {
                _innerModel.clear();

                var lines = http.responseText.match(/[^\r\n]+/g);

                var inEvent = false;
                var eventSummary, eventStart, eventEnd, eventTime;

                for (var i=0; i<lines.length; ++i)
                {
                    var line = lines[i];

                    if (!inEvent)
                    {
                        if (line.indexOf("BEGIN:VEVENT") === 0)
                        {
                            inEvent = true;

                            // clear data
                            eventStart = "";
                            eventEnd = "";
                            eventTime = "";
                            eventSummary = "";
                        }
                    }
                    else
                    {
                        if (line.indexOf("END:VEVENT") === 0)
                        {
                            inEvent = false;

                            // create event lines in model
                            if (eventStart === eventEnd)
                                _insertNewEvent(eventStart, eventTime, eventSummary)
                            else
                            {
                                // multi-day events are duplicated per day
                                var d = new Date(eventStart);
                                while (eventStart <= eventEnd) {
                                    _insertNewEvent(eventStart, "", eventSummary);
                                    eventStart += 1000*24*60*60; // milliseconds per day
                                    d = new Date(eventStart);
                                }
                            }
                        }
                        else if (line.indexOf("DTSTART") === 0)
                        {
                            line = line.substr(8);
                            if (line.indexOf("VALUE=DATE:") === 0)
                            {
                                line = line.substr(11);
                            }
                            if (line.indexOf("T") === 8)
                            {
                                eventTime = line.substr(9, 2) + ":" + line.substr(11, 2);
                                line = line.substr(0, 8);
                            }
                            eventStart = Date.parse(line.substr(0,4) + "-" + line.substr(4, 2) + "-" + line.substr(6, 2));
                        }
                        else if (line.indexOf("DTEND") === 0)
                        {
                            line = line.substr(6);
                            if (line.indexOf("VALUE=DATE:") === 0)
                            {
                                line = line.substr(11);
                            }
                            if (line.indexOf("T") === 8)
                            {
                                line = line.substr(0, 8);
                            }
                            eventEnd = Date.parse(line.substr(0,4) + "-" + line.substr(4, 2) + "-" + line.substr(6, 2));
                        }
                        else if (line.indexOf("SUMMARY") === 0)
                        {
                            eventSummary = line.substr(8);
                        }
                    }
                }
            }
            else
                console.log("Issue with ical model, " + http.readyState);
        }
    }

    Timer {
        interval: 3600000 // 1h
        repeat: true
        triggeredOnStart: true
        running: true

        onTriggered: {
            var http;
            http = new XMLHttpRequest();
            http.onreadystatechange = function() {
                _updateModel(http);
            };
            http.open('GET', ICAL_URL, true);
            http.send('');
        }
    }
}
