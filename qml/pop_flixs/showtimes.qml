import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.location 1.2
import "storage.js" as Storage
import "core.js" as Core
import "UI.js" as UI
import cz.vutbr.fit.pcmlich 1.0

/*!
 * @brief displays showtimes of nearby theaters
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/19/2012 added new pull2update
 */
Page{
    id:root
    width: pageWidth
    height: pageHeight
    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"
    states: [
        State {
            name: "landscape"
            PropertyChanges { target:listView; height: pageHeight - 215}
        },
        State {
            name: "portrait"
            PropertyChanges { target:listView; height: pageHeight - 215}
        }
    ]

    //! Page Params
    property string showtimeURL;
    property string movieTitle;
    property string movieURL;
    property string near;
    property string place;
    property string currentLocation;
    property bool refreshing:false;
    property int loadingSpacer: 0;

    //! Database / XML Params
    property int error: 0
    property bool firstTime: false;
    property bool loaded;
    property string url: showtimeURL + "&near=" +near+ "&country="+strCountry
    property bool databaseLoaded:true;
    property bool metrics: false;

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

            //! Check if Loading for the first time
            if(Storage.lastShowtimesTime(near,movieTitle) == undefined)
            {metrics = true; firstTime = true; }
            else
                metrics = Storage.lastShowtimesTime(near,movieTitle);

            Core.checkXML("showtimes",metrics);

        }
    }

    //! Page Header
    Header{pageTitle:movieTitle}

    //! Change Location Nav
    ChangeLocation{ pageName: "showtimes.qml"}

    //! Main ListView
    ListView {
            id:listView
            x: 0
            y: 110
            model:databaseModel
            width: pageWidth
            height: pageHeight - 252
            clip: true
            smooth: true
            delegate: myDelegate
            header: spacer
            cacheBuffer: 400
            onContentYChanged:{Core.pull2Update();}

            BusyIndicator{
                id: xmlIndicator
                anchors.centerIn: parent
                running: false
                platformStyle: BusyIndicatorStyle { size: "large" }
                visible: running
            }
        }

    //! Pull Box
    Pull2Update{id: pull2update; startY: 110}

    //! Database ListView
    ListModel {
        id: databaseModel
    }

    //! ListView Delegate
    Component{
        id: myDelegate

        Rectangle{
            id:row
            height: Core.adjustedHeight(showtimes)
            width: parent.width
            color:"#00000000"
            state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"
            states: [
                State {
                    name: "landscape"
                    PropertyChanges { target: row; height: Core.adjustedHeight2(showtimes);}
                },
                State {
                    name: "portrait"
                    PropertyChanges { target: row; height: Core.adjustedHeight(showtimes);}
                }
            ]

            Component.onCompleted: {

                if (index == 3)
                {

                    if (animationCount < 3)
                    {
                        animationSharing.start()

                        var item = new Array;

                        //! Set Animation Count Settings
                        item.modified = new Date();
                        item.id = 1
                        item.animationCount = animationCount +1;
                        animationCount = item.animationCount;

                        //! Update Animation Count
                        Storage.updateAnimationCount(item);
                    }

                }
            }

           SequentialAnimation{
                        id:animationSharing
                        PauseAnimation { duration: 900 }
                        PropertyAnimation { target: rowArea; property: "visible"; to: true; duration: 0 }
                        PropertyAnimation { target: shareImage; property: "visible"; to: false; duration: 0 }
                        PropertyAnimation { target: shared; property: "visible"; to: true; duration: 0 }
                        PauseAnimation { duration: 1600 }
                        PropertyAnimation { target: shareShowtimesHelper; property: "visible"; to: true; duration: 200 }
                        NumberAnimation { target: shared; property: "opacity"; to: 1; duration: 200; easing.type: Easing.InOutQuad }
                        PauseAnimation { duration: 3200 }
                        PropertyAnimation { target: shareShowtimesHelper; property: "visible"; to: false; duration: 200 }
                        PropertyAnimation { target: shareImage; property: "visible"; to: true; duration: 200 }
                        PauseAnimation { duration: 4600 }
                        PropertyAnimation { target: rowArea; property: "visible"; to: false; duration: 0 }
                        PropertyAnimation { target: shareImage; property: "visible"; to: false; duration: 0 }
                        PropertyAnimation { target: shared; property: "visible"; to: false; duration: 0 }
          }


            MouseArea{
                id:rowArea
                anchors.fill: parent
                onClicked: {
                    refPage = "showtimes"
                    tabGroup.currentTab = tab2

                    //! Push if theaters loaded, otherwise replace with no transitions
                    if(tab2.depth == 1)
                        tab2.push(Qt.resolvedUrl("theater.qml"),{theaterTitle:name,theaterAddress:address, near:place},true);
                    else
                        tab2.replace(Qt.resolvedUrl("theater.qml"),{theaterTitle:name,theaterAddress:address, near:place},true);
                }

                onPressAndHold: {
                rowArea.visible = false
                shared.visible = true
                }
            }

            Item{
                id: shared
                anchors.fill: parent
                visible: false
                z:1

                Rectangle{
                    id: shareBox
                    anchors.fill:parent
                    color: UI.COLOR_FOREGROUND
                    opacity: 0.85
                }

                ShareHelper {
                  id: shareHelper
                }

                Text{
                    id:shareShowtimesHelper
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    text: "Press & Hold to Share Showtimes"
                    font.bold: true
                    font.family: UI.FONT_FAMILY
                    font.pointSize: UI.FONT_SMALL
                    color: UI.COLOR_BACKGROUND
                    visible:false
                }

                Image{
                    id:shareImage
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 40
                    source: "images/icon-m-toolbar-share-selected.png"

                    Text{
                        id:shareShowtimes
                        x:80
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Share Showtimes"
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_SMALL
                        color: UI.COLOR_BACKGROUND

                        MouseArea{
                            anchors.fill: parent
                            anchors.leftMargin: -50
                            anchors.topMargin: -10
                            anchors.bottomMargin: 10

                            onClicked: {

                                var str = "Showtimes for " + movieTitle + " at " + name;
                                str = str + ":\n\n" + showtimes.replace(/\s\s/g, " | ") +"\n\n";
                                str = str + "Address:\n" + address + "\n";

                                shareHelper.share("POP Flix", movieURL, str);
                                shared.visible = false;  rowArea.visible = true
                            }

                        }

                    }


                }

                Image {
                    id: close
                    source: "images/icon-m-input-methods-close.png"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {shared.visible = false;  rowArea.visible = true}
                    }
                }

            }

        Text{
            text: name
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_LSMALL
            font.bold: true
            x:8
            color:UI.COLOR_BACKGROUND
            height: 15
            elide: Text.ElideRight
            width: pageWidth - 20
        }

        Text{
            id: showtimeList
            width: parent.width -20
            text: showtimes
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SMALL
            x:8
            color: UI.COLOR_SECONDARY_BACKGROUND
            y:35
            wrapMode: Text.WordWrap
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

    //! ListView XML Data
    XmlListModel {
            id:mainListViewXML
            query: "/showtimes/theater"

            XmlRole { name: "name"; query: "@name/string()"; }
            XmlRole { name: "address"; query: "@address/string()"; }
            XmlRole { name: "showtimes"; query: "@showtimes/string()"; }
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
                        //! Drop Showtimes for location
                        Storage.dropShowtimes(near,movieTitle);

                        var i;
                        for(i=0; i< mainListViewXML.count; i++)
                        {
                            var item = new Array;

                            item.name = mainListViewXML.get(i).name
                            item.address = mainListViewXML.get(i).address
                            item.showtimes = mainListViewXML.get(i).showtimes
                            item.near = near
                            item.movieTitle = movieTitle
                            item.modified = new Date();
                            Storage.createShowtimesList(item);
                        }

                        //! Stop Correct Indicator
                        Core.stopIndicator();

                        //! Reload Model
                        databaseModel.clear()
                        Storage.readShowtimes(databaseModel,near,movieTitle)
                        }
                }

                //! Check Internet Errors when Loading
                if(status === XmlListModel.Loading && databaseLoaded == false && source != "")
                {
                    Core.startIndicator();
                    errorText = "Trouble Loading Movie Showtimes"
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
                Core.errorMsg("Local Showtimes Not Cached.\n-Offline")
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
