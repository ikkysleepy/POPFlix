// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtMobility.location 1.2
import GeoHelper 1.0

/*!
 * @brief Reverse GeoCoding
 *
 * version 0.7 11/9/2012 Initial Release
 */
Rectangle {
    visible: false

    Component.onCompleted:  geohelper.findCoordinates(strStreet, strCity, strCountry);

    GeoHelper
    {
        id: geohelper

        onSearchError:
        {
            console.log("MSG: " + error)
        }

        onSearchReply:
        {
            var replyArray = JSON.parse(reply)
            if (replyArray.length > 0)
            {

                for (var i = 0; i < replyArray.length; i++)
                {
                    Qt.openUrlExternally("geo:"+replyArray[i].coordinate.latitude + ","+ replyArray[i].coordinate.longitude)
                }

            }
        }


    }
}
