/*
 * hassframe-ui - the user interface of a hass.io photo frame
 * Copyright (C) 2018 Johan Thelin
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

import QtQuick 2.0
import QtQuick.XmlListModel 2.0

/*
 * Weather model with data from MET / Yr.
 * Uses the Yr XML weather.
 *
 * Has the following properties:
 *
 *   - place (must be set!), URL encoded location string.
 *   - refreshHour, how many hours between each refresh. Recommended setting to > 1.
 *   - dataPoints, the number of data points (6h periods) expected.
 *   - model, the weather model itself.
 *
 * The model as the following properties:
 *
 *    - period, 0 - 3, time of day (00 - 06, 06 - 12, 12 - 18, 18 - 00)
 *    - temperature, in Centigrades.
 *    - precipitation, mms of precipitation expected.
 *    - symbol, a symbol index according to https://api.met.no/weatherapi/weathericon/1.1/documentation
 *    - symbolUrl, URL to the symbol png.
 *
 */

Item {
    id: root

    property alias model: weatherModel
    property int refreshHour: 1     // How often is the model refreshed (in hours)
    property int dataPoints: 6      // How many data points (max) are expected (in 6h periods)
    property string place           // Place, URL encoded and according to Yr web site, e.g. Sweden/V%C3%A4stra_G%C3%B6taland/Alings%C3%A5s
    readonly property string dataSourceNotice: "Data from MET Norway"

    ListModel {
        id: weatherModel
    }

    Timer {
        interval: 3600000 * root.refreshHour
        running: true
        repeat: true
        onTriggered: {
            _innerModel.reload();
        }
    }

    XmlListModel {
        id: _innerModel

        query: "/weatherdata/forecast/tabular/time"

        source: (place.length === 0)?"":("https://www.yr.no/place/" + root.place + "/forecast.xml")

        XmlRole { name: "period"; query: "string(@period)" }
        XmlRole { name: "symbol"; query: "symbol/string(@number)"; }
        XmlRole { name: "temperature"; query: "temperature/string(@value)"; }
        XmlRole { name: "precipitation"; query: "precipitation/string(@value)"; }

        onStatusChanged: {
            if (status === XmlListModel.Ready)
            {
                for(var i = 0; i< root.dataPoints && i < count; ++i)
                {
                    var symbol = get(i).symbol;
                    var period = parseInt(get(i).period);
                    var is_night = 0;

                    if (period === 3 || period === 0)
                        is_night = 1;

                    weatherModel.set(i, {
                        "period":period,
                        "symbol":symbol,
                        "symbolSource":"https://api.met.no/weatherapi/weathericon/1.1/?symbol=" + symbol + "&is_night=" + is_night + "&content_type=image/png",
                        "temperature":get(i).temperature,
                        "precipitation":get(i).precipitation
                        });
                }
            }
            else if (status === XmlListModel.Error)
            {
                console.warn("Weather error")
                console.warn(errorString());
            }
        }
    }
}
