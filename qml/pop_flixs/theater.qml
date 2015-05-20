// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.systeminfo 1.1
import cz.vutbr.fit.pcmlich 1.0
import "storage.js" as Storage
import "core.js" as Core
import "UI.js" as UI

/*!
 * @brief displays theater address and showtimes
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/19/2012  moved functions to core.js + added new pull2update
 */
Page{
    id:root
    width: pageWidth
    height: pageHeight

    //! Page Params
    property string theaterTitle;
    property string theaterAddress;
    property string near;
    property bool refreshing:false;
    property int loadingSpacer: 0;

    //! Database / XML Params
    property int error: 0
    property bool firstTime: false;
    property bool loaded;
    property string url: "http://popflix.dengineer.com/theater.php?near="+near+"&theater=" +theaterTitle + "&country="+strCountry
    property bool databaseLoaded:false;
    property bool metrics: false;

    //! Directions
    property string strStreet;
    property string strCity;
    property variant json;

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }

    //! Update Location
    Component.onCompleted: {

        //! Check if Loaded in past hour
        if(Storage.lastTheaterTime(near,theaterTitle) == undefined)
            {metrics = true;firstTime = true; }
        else
            metrics = Storage.lastTheaterTime(near,theaterTitle);

        Core.checkXML("theater",metrics)

        var theaterAddressParts = theaterAddress.split(',');
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

    //! Page Header
    Header{pageTitle:theaterTitle.replace(/&#39;/,"'")}

    //! Directions
    Rectangle{
        color: UI.COLOR_MAIN_BACKGROUND
        x:0
        y:55
        height:65
        width: pageWidth

        Image {
            id: directions
            x: 8
            y: 8
            width: 48
            height: 48
            source: "images/icon-m-ovi-service-maps.png"

            MouseArea{
                anchors.fill: parent
                onClicked: {

                    var partsOfStr = theaterAddress.split(','),
                        strCountry = selectCountry.model.get(Storage.getCountry()).name;

                     strStreet = partsOfStr[0];
                     strCity = partsOfStr[1];

                    getDirectioins.source = "Directions.qml"
                }
            }
        }

        Loader{
        id:getDirectioins
        }

        //! Select Country
        BoxSelectionDialogCountry{id:selectCountry}

        Text{
            id:address_line1
            horizontalAlignment: Text.AlignLeft;
            x:74
            y:4
            elide: Text.ElideRight
            width: pageWidth - 100
            height: 20
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SMALL
            color: UI.COLOR_BACKGROUND
            opacity: 0.75
        }

        Text{
            id:address_line2
            horizontalAlignment: Text.AlignLeft;
            x:74
            y:28
            elide: Text.ElideRight
            width: pageWidth - 90
            height: 20
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SMALL
            color: UI.COLOR_BACKGROUND
            opacity: 0.75
        }

    }

    //! Pull Box
    Pull2Update{id: pull2update; startY:120}

    //! Main ListView
    ListView {
            id:listView
            x: 0
            y: 120
            model:databaseModel
            width:pageWidth
            height: pageHeight - 215
            clip: true
            smooth: true
            header: spacer
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

                onPressAndHold: {
                rowArea.visible = false
                shared.visible = true
                }

                onClicked: {

                    var myModel;

                    if(Storage.readMovie(name) !== undefined)
                    {
                        myModel = Storage.readMovie(name);

                        var tempCast;

                        if (myModel.abridged_cast_1)
                            tempCast = myModel.abridged_cast_1

                        if (myModel.abridged_cast_1 && myModel.abridged_cast_2)
                            tempCast = tempCast + ", " + myModel.abridged_cast_2

                        if (myModel.abridged_cast_2 && myModel.abridged_cast_3)
                            tempCast = tempCast + ", " + myModel.abridged_cast_3

                        if (myModel.abridged_cast_3 && myModel.abridged_cast_4)
                            tempCast = tempCast + ", " + myModel.abridged_cast_4

                        if (myModel.abridged_cast_4 && myModel.abridged_cast_5)
                            tempCast = tempCast + ", " + myModel.abridged_cast_5

                        if(!tempCast) tempCast = "No Major Stars"


                        //! Get Movie Length
                        var movieLength = myModel.mpaa_rating +  Core.realMinutes(myModel.runtime);


                        //! Push if theaters loaded, otherwise replace with no transitions
                        if(tab1.depth == 1)
                        {

                            //! Select Tab1
                            tabGroup.currentTab = tab1
                            tab1.push(Qt.resolvedUrl("MovieDetails.qml"),
                                            {
                                            movieTitle: myModel.title,
                                            movieURL: myModel.detailed,
                                            movieNew: myModel.new_release,
                                            movieReleaseDate:myModel.release_dates,
                                            movieRuntime:movieLength,
                                            movieCriticsScore:myModel.critics_score,
                                            movieCriticsRating:myModel.critics_rating,
                                            movieAudienceScore:myModel.audience_score,
                                            movieReview: myModel.reviews,
                                            movieCriticsConsensus: myModel.critics_consensus,
                                            movieAudienceRating:myModel.audience_rating,
                                            movieSynopsis:myModel.synopsis,
                                            movieTrailer:myModel.video,
                                            movieCasts:tempCast
                                            },true)
                        }

                        else
                        {

                            //! Pop to first page
                            tab1.pop(tab1.find(function(page) {
                                                             return page.uid == 1;
                                                         }));
                            //! Store to Var
                            json  =         {
                                movieTitle: myModel.title,
                                movieURL: myModel.detailed,
                                movieNew: myModel.new_release,
                                movieReleaseDate:myModel.release_dates,
                                movieRuntime:movieLength,
                                movieCriticsScore:myModel.critics_score,
                                movieCriticsRating:myModel.critics_rating,
                                movieAudienceScore:myModel.audience_score,
                                movieReview: myModel.reviews,
                                movieCriticsConsensus: myModel.critics_consensus,
                                movieAudienceRating:myModel.audience_rating,
                                movieSynopsis:myModel.synopsis,
                                movieTrailer:myModel.video,
                                movieCasts:tempCast
                                };

                            delay.start()

                        }
                    }
                    else{

                        //! Show Error
                        banner.text = "Movie not found in local database..."
                        banner.open()

                    }

                }

                Timer {
                        id: delay
                      interval: 250;
                      running: false;
                      repeat: false
                      onTriggered: {
                          //! Select Tab1
                          tabGroup.currentTab = tab1
                          tab1.push(Qt.resolvedUrl("MovieDetails.qml"),json,true);
                      }

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

                                var str = "Showtimes for " + name + " at " + theaterTitle;
                                str = str + ":\n\n" + showtimes.replace(/\s\s/g, " | ") +"\n\n";
                                str = str + "Address:\n" + theaterAddress + "\n";

                                var movieURL;

                                if(Storage.movieURL(name) !== undefined)
                                    movieURL  = Storage.movieURL(name)
                                else
                                    movieURL  = "http://www.rottentomatoes.com/m/"

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
                        onClicked: {shared.visible = false;  rowArea.visible = true;
                        }
                    }
                }

            }

            Text{
                text: name
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_DEFAULT
                font.bold: true
                x:8
                color:UI.COLOR_BACKGROUND
                elide: Text.ElideRight
                width: pageWidth - 20
            }

            Text{
                width: parent.width-20
                text: showtimes
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_SMALL
                wrapMode: Text.WordWrap
                x:8
                color:UI.COLOR_SECONDARY_BACKGROUND
                y:30

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
        query: "/movies/movie"

        XmlRole { name: "name"; query: "@name/string()"; }
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
                    //! Drop Theaters for location
                    Storage.dropTheater(near,theaterTitle);

                    var i;
                    for(i=0; i< mainListViewXML.count; i++)
                    {
                        var item = new Array;

                        item.name = mainListViewXML.get(i).name
                        item.showtimes = mainListViewXML.get(i).showtimes
                        item.near = near
                        item.theaterTitle = theaterTitle
                        item.modified = new Date();
                        Storage.createTheaterList(item);
                    }

                    //! Stop Correct Indicator
                    Core.stopIndicator()

                    //! Reload Model
                    databaseModel.clear()
                    Storage.readTheater(databaseModel,near,theaterTitle)
                }
            }

            //! Check Internet Errors when Loading
            if(status === XmlListModel.Loading && databaseLoaded == false && source != "")
            {
                //! Start Correct Indicator
                Core.startIndicator()
                errorText = "Trouble Loading Theater Showtimes"
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
    Updating{id: updating; startY:120; }

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
                Core.errorMsg("Local Theater Not Cached.\n-Offline")
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
