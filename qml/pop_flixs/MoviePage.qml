import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.systeminfo 1.1
import "storage.js" as Storage
import "core.js" as Core
import "UI.js" as UI

/*!
 * @brief Movie List with Poster & Showtime Button
 *
 * version 0.8 11/9/2012 Initial Release
 * version 0.9 11/19/2012 moved functions to core.js
 * version 0.11 12/8/2012 added appCache
 *
 */
Page {
    id:root
    width: pageWidth
    height: pageHeight
    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"
    states: [
        State {
            name: "landscape"
            PropertyChanges { target: listView; height: pageHeight - 155}
        },
        State {
            name: "portrait"
        }
    ]

    //! Page Params
    property int error: 0
    property int movieId:3;
    property bool firstTime: false;
    property bool loaded;
    property int loadingSpacer: 0;

    property bool databaseLoaded:false;
    property string url: "http://popflix.dengineer.com/showtimes.php?list=" + movieId + "&country="+strCountry
    property bool metrics: false;
    property bool showingNav: false;
    property int uid:1;
    property bool refreshing:false;


    //! Bug: Click Too Fast
    property int loadedMoviePage:0;
    property int loadedShowtimesPage:0;

    //! Check Database on Load of Page
    Component.onCompleted: {

        //! Check if Loaded in past hour
        if(Storage.lastMovieTime(movieId) == undefined)
            {metrics = true;firstTime = true; }
        else
            metrics = Storage.lastMovieTime(movieId)

        Core.checkXML("main",metrics);
    }

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }

    //! Check if Country Updated
    onStatusChanged: {
        if(status === PageStatus.Activating) {

            if (strCountry !== strOldCountry)
            {
                metrics = true;
                Core.checkXML("main",metrics);
            }

            //! No Ref Page
            refPage = ""

            //! Reset Loader Bug (Only One Click)
            loadedMoviePage = 0;
            loadedShowtimesPage = 0;

        }
    }

    //! Database ListView
    ListModel {
        id: databaseModel
    }

    //! Page Header
    Header{
        id:movieList
        pageTitle:qsTr("In Theaters")

        Button{
           y:6
           anchors.right: parent.right
           anchors.rightMargin: 8
           text:"sort"
           width: 100
           height:44
           onClicked: {

               if(showingNav == false)
                   {showingNav = true; showNavPanel.start()}
               else
                  {showingNav = false; hideNavPanel.start()}
           }

        }
   }

    //! Main ListView
    ListView {
        id: listView
        x: 0
        y: 55
        width: pageWidth
        height: pageHeight - 155
        snapMode: ListView.SnapToItem
        cacheBuffer: 400
        smooth: true
        clip: true
        spacing: 10
        model: databaseModel
        delegate: myDelegate
        header: spacer
        section.property: "type"
        section.criteria: ViewSection.FullString
        section.delegate: sectionHeading
        onContentYChanged:{Core.pull2Update(true);}

        BusyIndicator{
            id: xmlIndicator
            anchors.centerIn: parent
            running: false
            platformStyle: BusyIndicatorStyle { size: "large" }
            visible:running
        }
    }

    //! Pull Box
    Pull2Update{id: pull2update; startY:55; }

    //! ListView Delegate
    Component{
        id:myDelegate

        Rectangle{
                height: 180
                width:pageWidth
                color:"#00000000"

                property int reset: 0;

                //! Load Movie Page Timer
                Timer{
                    id: loadMoviePage
                    interval: 10;
                    running: false;
                    repeat: false;
                    onTriggered: {

                        //! Don't Show Movie Page if showing showtimes
                        if(loadedShowtimesPage == 1) loadedMoviePage =1;

                        //! Only Continue if Page not Loaded
                        if(loadedMoviePage === 0)
                        {
                            //! Loading Page
                            loadedMoviePage = 1;

                           var tempCast;

                           if (abridged_cast_1)
                               tempCast = abridged_cast_1

                           if (abridged_cast_1 && abridged_cast_2)
                               tempCast = tempCast + ", " + abridged_cast_2

                           if (abridged_cast_2 && abridged_cast_3)
                               tempCast = tempCast + ", " + abridged_cast_3

                           if (abridged_cast_3 && abridged_cast_4)
                               tempCast = tempCast + ", " + abridged_cast_4

                           if (abridged_cast_4 && abridged_cast_5)
                               tempCast = tempCast + ", " + abridged_cast_5

                           if(!tempCast) tempCast = "No Major Stars"

                            root.pageStack.push(Qt.resolvedUrl("MovieDetails.qml"),
                                                {
                                                movieTitle: title,
                                                movieURL: detailed,
                                                movieNew: new_release,
                                                movieReleaseDate:release_dates,
                                                movieRuntime:movieLength.text,
                                                movieCriticsScore:critics_score,
                                                movieCriticsRating:critics_rating,
                                                movieAudienceScore:audience_score,
                                                movieReview: reviews,
                                                movieCriticsConsensus: critics_consensus,
                                                movieAudienceRating:audience_rating,
                                                movieSynopsis:synopsis,
                                                movieTrailer:video,
                                                movieCasts:tempCast
                                                })
                           //! Stop loading
                           if(refreshing == true) Core.stopIndicator();

                            }
                    }

                }

                //! Load Movie
                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        loadMoviePage.start()
                       }
                }

                Component.onCompleted: {
                   //! Configure Movie Details
                   movieLength.text = mpaa_rating +  Core.realMinutes(runtime);

                    // Hide Showtimes button?
                    if(new_release == 1)
                        {showtimesButton.visible = false; calendarButton.visible = true;

                        movieRuntimeDate.text = Core.movieDay(release_dates)
                        movieRuntimeDateDetails.text = Core.movieDateDetail(release_dates)

                    }
                    else
                        calendarButton.visible = false;

                    // Show rottentomatoes score?
                    if(critics_score >0)
                    {
                        rottentomatoes.source = "images/"+critics_rating+".svg"
                        rottentomatoesScore.text = critics_score + "%"
                    }

                }

                //! Poster Animation
                SequentialAnimation {
                         id: animatePoster
                         running: false
                         NumberAnimation { target: poster; property: "opacity"; to: 1; easing.type: Easing.OutCirc; duration: 2000}
                 }

                //! Poster
                Rectangle{
                    id:posterHolder
                    x:10
                    y:0
                    width: 117
                    height: 180
                    color:"#00000000"

                    Image{
                    id:posterPlaceHolder
                    source: "images/palomitas.svg"
                    anchors.centerIn: parent
                }

                    Image{
                    id:poster
                    width: 117
                    height: 180
                    opacity: 0

                    //! Local Poster Location
                    property int errorCount: 0
                    property string posterLoc:appCache + "/cache/" + Core.getFileName(profile);

                    Component.onCompleted: {
                        //! Check if Local Poster File Exist
                        if(imageSaver.exist(posterLoc) === 1)
                        {
                            errorCount = 0;
                            source = posterLoc;
                        }
                        else
                           {
                            errorCount = 1;
                            if (offline == false) source = profile
                        }
                    }

                    onStatusChanged: {

                        // Image Loaded
                        if (status  === Image.Ready)
                        {
                            //! Stop Poster Busy Indicator
                            posterIndicator.running = false;

                            if(errorCount == 1  || reset == 1)
                            {
                            // Fade-In Animation
                            animatePoster.start()

                            // Save image
                            imageSaver.save(poster, posterLoc);

                            // Reset Image source to local, if saved correctly
                            if(imageSaver.exist(posterLoc) === 1)
                                poster.source = posterLoc
                            else
                            {
                              poster.source = profile
                            }

                            }
                            else
                            {
                                poster.opacity =1;
                            }
                        }

                        //! Loading Indicator
                        if(status === Image.Loading)
                        {
                           posterIndicator.running = true
                        }

                    }


                    MouseArea{
                        anchors.fill: parent

                        onClicked: { loadMoviePage.start();}

                        onPressAndHold: {

                            if (offline == false){
                                reset = 1;
                                poster.source = profile
                            }

                        }
                    }
                }

                    BusyIndicator{
                    id: posterIndicator
                    anchors.centerIn: parent
                    running: false
                    visible: running
                }

                }

                //! Title & Casts
                Item{
                     x: 138
                     y:0

                    Text {
                        id:movieTitle
                        text:title
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_DEFAULT
                        font.bold: true
                        color: UI.COLOR_BACKGROUND
                        elide: Text.ElideRight
                        width: pageWidth - 140
                    }

                    Text {
                        id:casts
                        y:80
                        text: abridged_cast_2  ? abridged_cast_1 + ", " +abridged_cast_2: abridged_cast_1
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_XSMALL
                        color: UI.COLOR_SECONDARY_BACKGROUND
                        elide: Text.ElideRight
                        width: pageWidth - 140
                    }

                }

                //! Load Showtimes Page Timer
                Timer{
                    id: loadShowtimes
                    interval: 10;
                    running: false;
                    repeat: false;
                    onTriggered: {

                        //! Don't Show Showtimes if showing Movie Page
                        if(loadedMoviePage == 1)  loadedShowtimesPage =1;

                        //! Only Continue if Page not Loaded
                        if(loadedShowtimesPage === 0)
                        {
                           //! Loading Page
                           loadedShowtimesPage = 1;
                           tab1.push(Qt.resolvedUrl("showtimes.qml"),{movieTitle:title,movieURL:video,showtimeURL:"http://popflix.dengineer.com/showtime.php?movie="+title});

                            //! Stop Loading
                            if(refreshing == true) Core.stopIndicator();
                       }
                    }
                }

                //! Showtimes Button
                Item{
                     id: showtimesButton
                     x: pageWidth-165
                     y: 135
                     width: 155
                     height: 40

                     MouseArea{
                         anchors.fill: parent

                         onClicked: {
                             loadShowtimes.start()
                          }
                     }

                     Image{
                         id:showtimes
                         width:40
                         height: 40
                         source:"images/showtimes.svg"

                         Text{
                             y:9
                             x:38
                             text: "Showtimes"
                             font.family: UI.FONT_FAMILY
                             font.pointSize: UI.FONT_XSMALL
                             color: UI.COLOR_BACKGROUND
                         }

                     }
                }

                //! Calendar Button
                Item{
                     id: calendarButton
                     x: pageWidth-160;
                     y: 130

                     Text{
                             id:movieRuntimeDate
                             y:0
                             x:38
                             font.family: UI.FONT_FAMILY
                             font.pointSize: UI.FONT_XSMALL
                             font.bold: true
                             color: UI.COLOR_BACKGROUND
                         }

                     Text{
                             id:movieRuntimeDateDetails
                             y:27
                             x:38
                             font.family: UI.FONT_FAMILY
                             font.pointSize: UI.FONT_XXSMALL
                             color: UI.COLOR_SECONDARY_BACKGROUND
                         }

                }

                //! MPAA Rating
                Item{
                  x: 125
                  y: 140

                  Text {
                        id:movieLength
                        x:15
                        y:4
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_XXSMALL
                        color: UI.COLOR_SECONDARY_BACKGROUND
                    }

                }

                //! Ratings
                Item{
                    x:135
                    y:40

                    Image{
                        id:rottentomatoes
                        x:100
                        height: 30
                        width: 30
                    }

                    Text {
                        id:rottentomatoesScore
                        x:134
                        y:5
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_XSMALL
                        color: UI.COLOR_BACKGROUND
                    }

                    Image{
                        id:popcorn
                        source: "images/Popcorn.svg"
                        height: 30
                        width: 30
                    }

                    Text {
                        x:34
                        y:5
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_XSMALL
                        color: UI.COLOR_BACKGROUND
                        text: audience_score + "%"
                    }

                }

            }
    }

    //! Header Spacer
    Component{
        id:spacer

        Rectangle{
            id:space
            height: movieId != 3? (20 + loadingSpacer):(0 + loadingSpacer)
            color: "#00000000"
            width: pageWidth
        }

    }

    //! ListView section header
    Component {
        id: sectionHeading

        Rectangle {
            width: listView.width
            height: 50
            color: "#00000000"

            Text {
                x:8
                y:5
                text: section
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_LDEFAULT
                font.bold: true
                color:UI.COLOR_BACKGROUND
            }
        }
    }

    //! ListView Null Footer
    Component{
        id:footerNull
        Item{}
    }

    //! ListView Footer
    Component{
        id:footer

        Rectangle{
            height:100

            Text{
                x:8
                y:10
                text: "Rating by Rotten Tomatoes"
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_XXXSMALL
                color: UI.COLOR_BACKGROUND
            }

            Image{
                x:8
                y:30
                id:fresh
                source: "images/Fresh.svg"
                height: 30
                width: 30
            }

            Image{
                x:8
                y:60
                id:rotten
                source: "images/Rotten.svg"
                height: 30
                width: 30
            }

            Text{
                x:45
                y:35
                text: "Fresh (60% or more critics raded the movie positively)"
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_XXXSMALL
                color: UI.COLOR_BACKGROUND
            }

            Text{
                x:45
                y:60
                text: "Rotten (59% or fewer critics raded the movie positively)"
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_XXXSMALL
                color: UI.COLOR_BACKGROUND
            }

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
        query: "/showtimes/movie"

        XmlRole { name: "title"; query: "@title/string()"; }
        XmlRole { name: "mpaa_rating"; query: "@mpaa_rating/string()"; }
        XmlRole { name: "runtime"; query: "@runtime/string()"; }
        XmlRole { name: "critics_rating"; query: "@critics_rating/string()"; }
        XmlRole { name: "critics_score"; query: "@critics_score/string()"; }
        XmlRole { name: "audience_rating"; query: "@audience_rating/string()"; }
        XmlRole { name: "audience_score"; query: "@audience_score/string()"; }
        XmlRole { name: "release_dates"; query: "@release_dates/string()"; }
        XmlRole { name: "synopsis"; query: "@synopsis/string()"; }
        XmlRole { name: "reviews"; query: "@reviews/string()"; }
        XmlRole { name: "critics_consensus"; query: "@critics_consensus/string()"; }
        XmlRole { name: "new_release"; query: "@new/string()"; }
        XmlRole { name: "video"; query: "@video/string()"; }
        XmlRole { name: "thumbnail"; query: "@thumbnail/string()"; }
        XmlRole { name: "profile"; query: "@profile/string()"; }
        XmlRole { name: "detailed"; query: "@detailed/string()"; }
        XmlRole { name: "type"; query: "@type/string()"; }
        XmlRole { name: "abridged_cast_1"; query: "@abridged_cast_1/string()"; }
        XmlRole { name: "abridged_cast_1_charactor"; query: "@abridged_cast_1_charactor/string()"; }
        XmlRole { name: "abridged_cast_2"; query: "@abridged_cast_2/string()"; }
        XmlRole { name: "abridged_cast_2_charactor"; query: "@abridged_cast_2_charactor/string()"; }
        XmlRole { name: "abridged_cast_3"; query: "@abridged_cast_3/string()"; }
        XmlRole { name: "abridged_cast_3_charactor"; query: "@abridged_cast_3_charactor/string()"; }
        XmlRole { name: "abridged_cast_4"; query: "@abridged_cast_4/string()"; }
        XmlRole { name: "abridged_cast_4_charactor"; query: "@abridged_cast_4_charactor/string()"; }
        XmlRole { name: "abridged_cast_5"; query: "@abridged_cast_5/string()"; }
        XmlRole { name: "abridged_cast_5_charactor"; query: "@abridged_cast_5_charactor/string()"; }
        XmlRole { name: "error_msg"; query: "@error_msg/string()" }

        onStatusChanged: {

                // Everything is AOK!
                if (status === XmlListModel.Ready && databaseLoaded == false && source != "")
                {
                    if(mainListViewXML.get(0).error)
                    {
                        //! Show Error Msg
                        Core.error(mainListViewXML.get(0).error)
                    }
                    else
                    {
                    //! Save Movie List
                    Core.saveMovies();

                    //! Stop Correct Indicator
                    Core.stopIndicator()

                    //! Reload Model
                    databaseModel.clear()
                    Storage.readMovies(databaseModel,movieId);
                    listView.footer = footer;
                    }
                }

                //! Check Internet Errors when Loading
                if(status === XmlListModel.Loading && databaseLoaded == false && source != "")
                {
                    //! Start Correct Indicator
                    Core.startIndicator()
                    errorText = "Trouble Loading Movies"
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

    //! XML Loading
    PropertyAnimation { id: loadingXML; target: listView; property: "contentY"; to: -52; duration: 0 }

    //! XML Reloader Timer
    Timer {
        id: refresh
        interval: 10;
        running: false;
        repeat: false;
        onTriggered: {
            if(firstTime == true & offline == true){
                Core.errorMsg("Movie List Not Cached.\n-Offline")
            }

            if (offline == false && refreshing == false){
            databaseLoaded = false;
            mainListViewXML.source = url;
            mainListViewXML.reload();
            }
        }
    }

    //! Updating  Box
    Updating{id: updating; startY:55; }

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

    //! Show Sort Nav Panel
    SequentialAnimation{
        id:showNavPanel
        PropertyAnimation { target: hiddenArea; property: "visible"; to: true; duration: 0 }
        PropertyAnimation { target: sortNav; property: "visible"; to: true; duration: 0 }
        NumberAnimation { target: sortNav; property: "opacity"; to: 1; duration: 200; easing.type: Easing.InOutQuad }
    }

    //! Hide Sort Nav Panel
    SequentialAnimation{
        id:hideNavPanel
        NumberAnimation { target: sortNav; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InOutQuad }
        PropertyAnimation { target: sortNav; property: "visible"; to: false; duration: 0 }
        PropertyAnimation { target: hiddenArea; property: "visible"; to: false; duration: 0 }
    }

    //! Sort Nav Panel
    MouseArea{
        id:hiddenArea
        x:0
        y:70
        width: pageWidth
        height: pageHeight -70
        visible: false

        onClicked: hideNavPanel.start()
    }

    //! Sort Nav
    Rectangle {
        id: sortNav
        anchors.right:parent.right
        y: 55
        width: 241
        height: 210
        color: UI.COLOR_BORDER
        visible:false
        opacity: 0

        Rectangle {
            id: rectangle2
            x: 16
            y: 15
            width: 209
            height: 50
            color: movieId == 1 ? UI.COLOR_BORDER:UI.COLOR_BACKGROUND
            radius: 4
            border.width:1
            border.color: UI.COLOR_BACKGROUND

            Text {
                id: text1
                x: 10
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("New Release")
                color:  movieId == 1 ? UI.COLOR_BACKGROUND:UI.COLOR_MAIN_BACKGROUND
                font.pointSize: UI.FONT_SMALL
                font.bold: true
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    Core.switchList(1)
                }
            }
        }

        Rectangle {
            id: rectangle3
            x: 16
            y: 145
            width: 209
            height: 50
            color: movieId == 4 ? UI.COLOR_BORDER:UI.COLOR_BACKGROUND
            radius: 4
            border.width:1
            border.color: UI.COLOR_BACKGROUND

            Text {
                id: text3
                x: 10
                anchors.verticalCenter: parent.verticalCenter
                color: movieId == 4 ? UI.COLOR_BACKGROUND:UI.COLOR_MAIN_BACKGROUND
                text: qsTr("Coming Soon")
                font.pointSize: UI.FONT_SMALL
                font.bold: true
            }

            MouseArea{
                anchors.fill: parent
                onClicked: {
                    Core.switchList(4)
                }
            }
        }

        Rectangle {
            id: rectangle4
            x: 16
            y: 80
            width: 209
            height: 50
            color: movieId == 3 ? UI.COLOR_BORDER:UI.COLOR_BACKGROUND
            radius: 3
            border.width:1
            border.color: UI.COLOR_BACKGROUND

            Text {
                id: text2
                x: 10
                anchors.verticalCenter: parent.verticalCenter
                color:   movieId == 3 ? UI.COLOR_BACKGROUND:UI.COLOR_MAIN_BACKGROUND
                text: qsTr("In Theaters")
                font.pointSize: UI.FONT_SMALL
                font.bold: true
            }


            MouseArea{
                anchors.fill: parent
                onClicked: {
                    Core.switchList(3)
                }
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
