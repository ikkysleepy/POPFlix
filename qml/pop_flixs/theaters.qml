import QtQuick 1.1
import com.nokia.meego 1.0
import "storage.js" as Storage
import "UI.js" as UI
import "core.js" as Core

/*!
 * @brief displays nearby theaters
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/19/2012 added new pull2update
 */
Page{
    id:root
    width: pageWidth
    height: pageHeight

    //! Page Params
    property int error: 0
    property bool loaded;
    property string near;
    property string place;
    property bool refreshing:false;
    property int loadingSpacer: 0;


    property string url: "http://popflix.dengineer.com/theaters.php?near="+near+"&country="+strCountry
    property bool firstTime: false;
    property bool databaseLoaded:false;
    property bool metrics: false;
    property string currentLocation;

    //! Bug: Click Too Fast
    property int loadedTheaterPage:0;

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }

    //! Check if Current Location Changed
    onStatusChanged: {
        if(status === PageStatus.Activating)
        {
            var xnear = Storage.lastLocation();

            if(near !== xnear)
            {
                place = xnear
                near = xnear
            }

            //! Check if Loaded in past hour
            if(Storage.checkTheaters(near) == undefined)
                {metrics = true;firstTime = true; }
            else
                metrics = Storage.checkTheaters(near)

            Core.checkXML("theaters",metrics);

            //! Reset Loader Bug (Only One Click)
            loadedTheaterPage =0;
        }
    }

    //! Page Header
    Header{pageTitle:"Nearby Theaters"}

    //! Change Location Nav
    ChangeLocation{}

    //! Pull Box
    Pull2Update{id: pull2update; startY:110}

    //! Main ListView
    ListView {
            id:listView
            x: 0
            y: 110
            model:databaseModel
            width: pageWidth
            height: pageHeight - 215
            clip: true
            smooth: true
            header: spacer
            spacing: 5
            delegate: myDelegate
            onContentYChanged:{Core.pull2Update();}

            BusyIndicator{
                id: xmlIndicator
                anchors.centerIn: parent
                running: false
                platformStyle: BusyIndicatorStyle { size: "large" }
                visible: running
            }
        }

    //! Database ListView
    ListModel {
        id: databaseModel
    }

    //! ListView Delegate
    Component{
        id:myDelegate

        Rectangle{
            height: 90
            width: parent.width
            color:"#00000000"

            MouseArea{
                anchors.fill: parent

                onClicked: {
                    if(loadedTheaterPage == 0){
                        root.pageStack.push(Qt.resolvedUrl("theater.qml"),{theaterTitle:name.replace(/'/g, "&#39;") ,theaterAddress:address, near:place});
                        loadedTheaterPage =1;

                        //! Stop loading
                        if(refreshing == true) Core.stopIndicator();
                    }
                }
            }

            Component.onCompleted: {

            var theaterAddressParts = address.split(',');
            address_line1.text = theaterAddressParts[0];

            // Fix for ellide address
            if(theaterAddressParts[2] != undefined)
            {
                if(theaterAddressParts[3] != undefined)
                    address_line2.text = theaterAddressParts[1].replace(/^\s+/,"") + "," + theaterAddressParts[2] + ", " + theaterAddressParts[3] ;
                else
                    address_line2.text = theaterAddressParts[1].replace(/^\s+/,"") + "," + theaterAddressParts[2] ;
            }
            else
                if(theaterAddressParts[1] != undefined) address_line2.text = theaterAddressParts[1].replace(/^\s+/,"");
        }

            Text{
            text: name
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_DEFAULT
            font.bold: true
            x:8
            color:UI.COLOR_BACKGROUND
            elide: Text.ElideRight
            width: pageWidth - 70
        }

            Text{
            id:address_line1
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_XSMALL
            x:8
            color:UI.COLOR_SECONDARY_BACKGROUND
            y:30
            elide: Text.ElideRight
            width: pageWidth - 150
        }

            Text{
            id:address_line2
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_XSMALL
            x:8
            color:UI.COLOR_SECONDARY_BACKGROUND
            y:56
            elide: Text.ElideRight
            width: pageWidth - 150
        }

            Image{
            y:30
            anchors.right: parent.right
            anchors.rightMargin: 20
            source:"images/link.png"
            opacity: 0.5
        }

        }
    }

    //! Header Spacer
    Component{
        id:spacer

        Rectangle{
            id:space
            height: 20 + loadingSpacer
            color: "#00000000"
            width: pageWidth
        }

    }

    //! ListView Scroller
    ScrollDecorator {
        id: scrolldecorator
        flickableItem: listView
    }

    //! listView XML Data
    XmlListModel {
        id:mainListViewXML
        query: "/theaters/theater"

        XmlRole { name: "name"; query: "@name/string()"; }
        XmlRole { name: "address"; query: "@address/string()"; }
        XmlRole { name: "error"; query: "@error/string()"; }

        onStatusChanged: {
            if (status === XmlListModel.Ready && databaseLoaded == false && source != "")
             {

                if(mainListViewXML.get(0).error)
                {
                    //! Show Error Msg
                    Core.errorMsg(mainListViewXML.get(0).error)
                }
                else
                {
                    //! Drop Theaters for location
                    Storage.dropTheaters(near);

                    var i;
                    for(i=0; i< mainListViewXML.count; i++)
                    {
                        var item = new Array;

                        item.name = mainListViewXML.get(i).name
                        item.address = mainListViewXML.get(i).address
                        item.near = near
                        item.modified = new Date()
                        Storage.createTheatersList(item)
                    }

                    //! Stop Correct Indicator
                    Core.stopIndicator()

                    //! Reload Model
                    databaseModel.clear()
                    Storage.readTheaters(databaseModel,near)
                }
            }


            //! Check Internet Errors when Loading
            if(status === XmlListModel.Loading && databaseLoaded == false && source != "")
            {
                //! Start Correct Indicator
                Core.startIndicator()
                errorText = "Trouble Loading Theaters"
            }

            //! If the progress is finished and the result is an error
            //! Show the Error Message
            if (status === XmlListModel.Error && progress === 1 && databaseLoaded == false)
            {
                errorItem.visible = true;
                error = 1;
            }

        }
    }

    //! Updating  Box
    Updating{id: updating; startY:110; }

    //! Updating Timer
    Timer {
        id: updatingTimer
        interval: 20000;
        running: false;
        repeat: false;
        onTriggered: {
           Core.pull2UpdateReset();
          }
    }

    //! XML Loading
    PropertyAnimation { id: loadingXML; target: listView; property: "contentY"; to: -52; duration: 200 }

    //! XML Data Timer
    Timer {
        id: refresh
        interval: 10;
        running: false;
        repeat: false;
        onTriggered: {
            if(firstTime == true & offline == true){
                Core.errorMsg("Local Theaters Not Cached.\n-Offline Msg")
            }

            if (offline == false && refreshing == false){
            databaseLoaded = false;
            mainListViewXML.source = url
            mainListViewXML.reload();
            }
        }
    }

    //! Slow Internet Timer
    Timer {
        id: loadingContentError
        interval: 15000;
        running: false;
        repeat: false;
        onTriggered: {
            //! Error if Slow/No Internet in 15 seconds
            errorTxt.text  = errorText
            error = 1;
            errorItem.visible = true
            xmlIndicator.visible = false
        }
    }

    //! Slow Internet Timer Bubble
    Timer {
        id: loadingContentErrorBubble
        interval: 15000;
        running: false;
        repeat: false;
        onTriggered: {
            //! Error if Slow/No Internet in 15 seconds
            banner.text = errorText
            banner.open()
        }
    }

    //! Error Msg
    Item{
        id:errorItem
        visible: false
        width: pageWidth
        height: pageHeight

        Text{
            id: errorTxt
            anchors.centerIn: parent
            width: (screen.currentOrientation == Screen.Portrait) ? 300: 700
            height: (screen.currentOrientation == Screen.Portrait) ? 300: 150
            wrapMode: Text.WordWrap
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_LARGE
            color: UI.COLOR_BACKGROUND
        }
    }

    //! Error Msg Bubble
    InfoBanner{id: banner}

}
