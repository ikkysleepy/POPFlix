// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import QtMobility.location 1.2
import QtMobility.systeminfo 1.1
import QReverseGeocode 1.0
import com.nokia.meego 1.0
import "storage.js" as Storage
import "core.js" as Core
import "UI.js" as UI

/*!
 * @brief Change Location code
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/19/2012 Added  elide to location
 */
Rectangle {
    z:100

    property string pageName: "theaters.qml"

    //! Stop retrieving position information when component is to be destroyed, only if needed
    Component.onDestruction: {  if (positionSource.active == true) positionSource.stop();}

    //! Update Location
    Component.onCompleted: {

        if(Storage.lastLocation())
        {
            //! Set Saved Location
            near = Storage.lastLocation();
            place = near;
            currentLocation = near

            if(pageName === "theaters.qml")
            {
                //! Check if Loaded
                if(Storage.checkTheaters(near) == undefined)
                    {metrics = true;firstTime = true; }
                else
                    metrics = Storage.checkTheaters(near)

                Core.checkXML("theaters",metrics);
            }
            else
            {

            //! Check if Loading for the first time
            if(Storage.lastShowtimesTime(near,movieTitle) == undefined)
            {metrics = true; firstTime = true; }
            else
                metrics = Storage.lastShowtimesTime(near,movieTitle);

            Core.checkXML("showtimes",metrics);
            }

        }
        else
        {
            //! Find Location
            locateIndicator.running = true;
            place = "Finding Location...";
            positionSource.start()
            gpsTimer.start()
        }

    }

    //! Header
    Rectangle{
        id:header

        width: pageWidth
        y:55
        height:55
        color: UI.COLOR_MAIN_BACKGROUND

        Button{
            y:6
            anchors.right: parent.right
            anchors.rightMargin: 8
            text:"change"
            width: 110
            height:44
            onClicked: {
                showChangeLocation.start()
            }

        }

        Text{
            id:placeHolder;
            horizontalAlignment: Text.AlignLeft;
            x:8;
            y:13
            width: (screen.currentOrientation == Screen.Portrait) ? 280: 760
            height: 20
            text: place
            elide: Text.ElideRight
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_LSMALL
            color: UI.COLOR_BACKGROUND

            BusyIndicator{
                id: locateIndicator
                x: 215
                y: 3
                running: false
                platformStyle: BusyIndicatorStyle { size: "small" }
                visible: locateIndicator.running
            }


        }

    }

    //! GPS Source
    PositionSource {
        id: positionSource
        active: false

        onPositionChanged: {
            reverseGeocoder.latitude  = positionSource.position.coordinate.latitude
            reverseGeocoder.longitude = positionSource.position.coordinate.longitude
            reverseGeocoder.process();
        }
    }

    //! Rerverse Geocode
    QReverseGeocode {
        id:reverseGeocoder
        onReverseGeocodeFinished:{
            //! Record Location
            var item = new Array;
            item.lat = latitude;
            item.lon = longitude;
            item.near = reverseGeocoder.city +", " +reverseGeocoder.state + " " + reverseGeocoder.postCode
            item.modified = new Date();
            Storage.createLocation(item);

            //! Update Location
            place = item.near;
            near = item.near

            //! Stop GPS
            positionSource.stop()
            gpsTimer.stop()
            gpsTimerLong.stop();

            //! Turn of Indicator
            locateIndicator.running = false;

            if(pageName === "theaters.qml")
            {
            //! Check if Loaded in past hour
            if(Storage.checkTheaters(near) == undefined)
                {metrics = true;firstTime = true; }
            else
                metrics = Storage.checkTheaters(near)

            Core.checkXML("theaters",metrics);
            }
            else
            {

            //! Check if Loading for the first time
            if(Storage.lastShowtimesTime(near,movieTitle) == undefined)
            {metrics = true; firstTime = true; }
            else
                metrics = Storage.lastShowtimesTime(near,movieTitle);

            Core.checkXML("showtimes",metrics);
            }
        }
    }

    //! Show Form
    SequentialAnimation{
        id:showChangeLocation
        PropertyAnimation { target: hiddenArea; property: "visible"; to: true; duration: 0 }
        PropertyAnimation { target: changeLocation; property: "visible"; to: true; duration: 0 }
        NumberAnimation { target: changeLocation; property: "opacity"; to: 1; duration: 200; easing.type: Easing.InOutQuad }
    }

    //! Hide Form
    SequentialAnimation{
        id:hideChangeLocation
        NumberAnimation { target: changeLocation; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InOutQuad }
        PropertyAnimation { target: changeLocation; property: "visible"; to: false; duration: 0 }
        PropertyAnimation { target: hiddenArea; property: "visible"; to: false; duration: 0 }
    }

    //! Hidden Area
    MouseArea{
        id:hiddenArea
        x:0
        y:155
        width: pageWidth
        height: pageHeight -155
        visible: false

        onClicked: hideChangeLocation.start()
    }

    //! Nav
    Rectangle {
        id: changeLocation
        x: 0
        y: (screen.currentOrientation == Screen.Portrait) ?55:0
        width: pageWidth
        height: 135
        color: UI.COLOR_BORDER
        visible:false
        opacity: 1

        MouseArea
        {
            anchors.fill: parent

        }

        TextField {
            id: manualLocation
            x: 8
            y: 10
            width: (screen.currentOrientation == Screen.Portrait) ? 390:760
            height: 50
            placeholderText: "Postal Code or City/State"


        }

        Button{

            anchors.right: manualLocation.right
            anchors.rightMargin: -75

            y:10
            width:70
            height:50

            Image{
                y:2
                x:16
                source: "images/ic_menu_mylocation.png"
                width:40
                height:40

            }

            onClicked: {
                hideChangeLocation.start()
                locateIndicator.running = true;
                currentLocation = place
                place = "Finding Location...";
                positionSource.start();
                gpsTimer.start()
            }
        }

        Button {
            id: rectangle3
            x: 8
            y: 73
            width: 120
            height: 50
            text:"Cancel"
            platformStyle: ButtonStyle{ inverted: false }
            onClicked: {
                manualLocation.text = "";
                hideChangeLocation.start()}
        }

        Button {
            id: rectangle4
            x: 140
            y: 73
            width:  (screen.currentOrientation == Screen.Portrait) ? 333: 703
            height: 50
            text: "Change Location"
            onClicked: {

                //! Record Location
                if(manualLocation.text !== "")
                {
                    var item = new Array, addres;
                        item.lat = "";
                        item.lon = "";
                        item.near = manualLocation.text
                        item.modified = new Date();
                        Storage.createLocation(item);
                        place = manualLocation.text
                        near = item.near


                    if(pageName === "theaters.qml")
                    {
                        //! Check if Loaded in past hour
                        if(Storage.checkTheaters(near) == undefined)
                            {metrics = true;firstTime = true; }
                        else
                            metrics = Storage.checkTheaters(near)

                    Core.checkXML("theaters",metrics);
                     }
                    else
                    {

                    //! Check if Loading for the first time
                    if(Storage.lastShowtimesTime(near,movieTitle) == undefined)
                    {metrics = true; firstTime = true; }
                    else
                        metrics = Storage.lastShowtimesTime(near,movieTitle);

                    Core.checkXML("showtimes",metrics);
                    }
                    manualLocation.text = "";
                    hideChangeLocation.start()
                }
            }

        }

    }

    //! GPS Timer
    Timer {
        id: gpsTimer
        interval: 1000;
        running: false;
        repeat: false;
        onTriggered: {

            if(positionSource.positioningMethod == PositionSource.NoPositioningMethod)
            {
                //! No GPS
                place = "Please Turn GPS On!"
                locateIndicator.running = false;
                positionSource.stop();
                gpsTimer.stop()
                gpsTimerLong.stop()
                gpsResetText.start()
            }
            else
              {  gpsTimerLong.start();}
        }

    }

    //! GPS Long Timer
    Timer {
        id: gpsTimerLong
        interval: 15000;
        running: false;
        repeat: false;
        onTriggered: {

            //! Laggy GPS
            place = "Problems with GPS..."
            locateIndicator.running = false;
            positionSource.stop()
            gpsResetText.start()
        }
   }

    //! GPS Reset Location
    Timer{
        id: gpsResetText
        interval: 10000;
        running: false
        repeat: false;
        onTriggered: {place = currentLocation}
    }

}

