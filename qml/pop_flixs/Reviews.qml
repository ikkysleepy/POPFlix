// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.systeminfo 1.1
import "storage.js" as Storage
import "core.js" as Core
import "UI.js" as UI

/*!
 * @brief Reviews of Movie
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/19/2012 added new pull2update
*/
Page{
    id:root

    //! Page Params
    property string reviewLink;
    property string movieTitle;
    property string movieNew;
    property string movieCriticsScore;
    property string movieCriticsRating;
    property string movieAudienceScore;
    property string movieAudienceRating;
    property bool refreshing:false;
    property int loadingSpacer: 0;

    //! Database / XML Params
    property int error: 0
    property bool firstTime: false;
    property bool loaded;
    property string url: "http://popflix.dengineer.com/reviews.php?review="+reviewLink+"&country=" +strCountry
    property bool databaseLoaded:false;
    property bool metrics: false;

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }

    //! Check if Current Location Changed
    onStatusChanged: {
        if(status === PageStatus.Activating)
        {

            //! Check if Loaded in past hour
            if(Storage.lastReviewTime(movieTitle,movieNew) == undefined)
                {metrics = true;firstTime = true; }
            else
                metrics = Storage.lastReviewTime(movieTitle,movieNew)

            Core.checkXML("reviews",metrics);

        }
    }

    //! Page Header
    Header{pageTitle:movieTitle}

    //! Critic Header
    Rectangle{
         color: UI.COLOR_MAIN_BACKGROUND
         x:0
         y:55
         height:65
         width: pageWidth

        Text {
            x: 8
            y:2
            width: 150
            color: UI.COLOR_BACKGROUND
            text: "Critic"
            wrapMode: Text.WordWrap
            font.family: UI.FONT_FAMILY
            font.bold: true
            font.pointSize: UI.FONT_SDEFAULT
        }

        Text {
            x: 8
            y:35
            width: 150
            color: UI.COLOR_BACKGROUND
            text: "Reviews"
            wrapMode: Text.WordWrap
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SMALL
        }

        //! Select Country
        BoxSelectionDialogCountry{id:selectCountry}

        Image {
                id: moviePocorn
                y: 0
                width: 60
                height: 60
                source: "images/Popcorn_large.png"
                sourceSize.width: 60
                sourceSize.height: 60
                anchors.right: parent.right
                anchors.rightMargin: 280

                Text {
                    id: popcornRatingPercent
                    x: 62
                    y: 15
                    width: 60
                    height: 30
                    color: UI.COLOR_BACKGROUND
                    text: movieAudienceScore + "%"
                    horizontalAlignment: Text.AlignHCenter
                    font.family: UI.FONT_FAMILY
                    font.pointSize: UI.FONT_SMALL
            }
            }

        Image {
            id: movieRotten
            y: 0
            width: 60
            height: 60
            anchors.right: parent.right
            anchors.rightMargin: 100
            source: movieCriticsRating === "" ? "": "images/"+movieCriticsRating+"_large.svg"
            sourceSize.width: 60
            sourceSize.height: 60

            Text {
                id: criticsRatingPercent
                x: 52
                y: 15
                width: 60
                height: 30
                color: UI.COLOR_BACKGROUND
                text: movieCriticsScore <0 ? "": movieCriticsScore + "%"
                horizontalAlignment: Text.AlignHCenter
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_SMALL
        }
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
            width: parent.width
            color:"#00000000"
            height: 70 + quoteTxt.paintedHeight


        Text{
            id:criticTxt
            text: critic
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_DEFAULT
            font.bold: true
            x:8
            color:UI.COLOR_BACKGROUND
            elide: Text.ElideRight
            width: pageWidth - 20

            Image{
                y:10
                anchors.right: parent.right
                source: "images/link.png"
                opacity: 0.5

                MouseArea{
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally(link)
                }
            }
        }

        Image{
            x: criticTxt.paintedWidth +20
            source: freshness ? "images/"+freshness+".svg":""
            height: 30
            width: 30
        }

        Text{
            id: publicationTxt
            text: publication + " - " + Core.longDate(date)
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SMALL
            y:30
            x:8
            color:UI.COLOR_BACKGROUND
            elide: Text.ElideRight
            width: pageWidth - 60
        }



        Text{
            id:quoteTxt
            width: parent.width -20
            text: quote.replace(/&quot;/g, "\"")
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SMALL
            wrapMode: Text.WordWrap
            x:8
            color:UI.COLOR_BACKGROUND
            y:60
            opacity: 0.75

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
        query: "/reviews/review"

        XmlRole { name: "critic"; query: "@critic/string()"; }
        XmlRole { name: "date"; query: "@date/string()"; }
        XmlRole { name: "freshness"; query: "@freshness/string()"; }
        XmlRole { name: "publication"; query: "@publication/string()"; }
        XmlRole { name: "quote"; query: "@quote/string()"; }
        XmlRole { name: "link"; query: "@link/string()"; }
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
                    Storage.dropReviews(movieTitle);

                    var i;
                    for(i=0; i< mainListViewXML.count; i++)
                    {
                        var item = new Array;

                        item.movie = movieTitle
                        item.critic = mainListViewXML.get(i).critic
                        item.date = mainListViewXML.get(i).date
                        item.critic = mainListViewXML.get(i).critic
                        item.publication = mainListViewXML.get(i).publication
                        item.freshness = mainListViewXML.get(i).freshness
                        item.quote = mainListViewXML.get(i).quote
                        item.link = mainListViewXML.get(i).link
                        item.modified = new Date()
                        Storage.createReviewsList(item)
                    }

                    //! Stop Correct Indicator
                    Core.stopIndicator()

                    //! Reload Model
                    databaseModel.clear()
                    Storage.readReviews(databaseModel,movieTitle)
               }
            }

            //! Check Internet Errors when Loading
            if(status === XmlListModel.Loading && databaseLoaded == false && source != "")
            {
                //! Start Correct Indicator
                Core.startIndicator()
                errorText = "Trouble Loading Reviews"
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
                Core.errorMsg("Movie Reviews Not Cached.\n-Offline")
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
