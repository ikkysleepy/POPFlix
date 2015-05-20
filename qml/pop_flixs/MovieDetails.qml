import Qt 4.7
import QtQuick 1.1
import com.nokia.meego 1.0
import "UI.js" as UI
import "core.js" as Core

/*!
 * @brief Movie Details (Poster + Play & Showtimes button + Read More button
 *
 * version 0.8 11/9/2012 Initial Release
 * version 0.9 11/19/2012 Larger Read Reviews Button
 * version 0.11 12/8/2012 added appCache
 *
 */
Page{
    id:root
    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"
    states: [
        State {
            name: "landscape"
            PropertyChanges { target: movieReviews; y:282 + movieCast.paintedHeight + 35;}
            PropertyChanges { target: criticConsensus; width:443;}
            PropertyChanges { target: movieCastTitle; y:282}
            PropertyChanges { target: movieSynopsisTitle; x:488; y:8;}
            PropertyChanges { target: synopsis; width:330}
            PropertyChanges { target: movieCast; font.pointSize: UI.FONT_XXSMALL}
            PropertyChanges { target: main; contentHeight:  (pageHeight + criticConsensus.paintedHeight +100) > (pageHeight-280 + synopsis.paintedHeight) ? (pageHeight + criticConsensus.paintedHeight +140):(pageHeight-280 + synopsis.paintedHeight +10) }

        },
        State {
            name: "portrait"
            PropertyChanges { target: movieCastTitle; y:290}
            PropertyChanges { target: movieSynopsisTitle; x:8; y:380;}
            PropertyChanges { target: synopsis; width:440}
            PropertyChanges { target: movieCast; font.pointSize: UI.FONT_XSMALL}
            PropertyChanges { target: main; contentHeight: pageHeight-270 + synopsis.paintedHeight + (70 + criticConsensus.paintedHeight + 45)}
        }
    ]

    //! Page Params
    property int reset: 0;
    property string movieTitle;
    property string movieCriticsScore;
    property string movieCriticsRating;
    property string movieAudienceScore;
    property string movieAudienceRating;
    property string movieURL;
    property string movieRuntime;
    property string movieReleaseDate;
    property string movieCasts;
    property string movieSynopsis;
    property string movieTrailer;
    property string movieNew;
    property string movieReview;
    property string movieCriticsConsensus;
    property int uid:2;

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }

    //! Check if Ref Page
    onStatusChanged: {
        if(status === PageStatus.Activating) {

            //! No Ref Page
            refPage = ""
        }
    }

    //! Page Header
    Rectangle{
        color:"#00000000"

        Rectangle{
            y:0
            width: pageWidth
            height:55
            color:UI.COLOR_BORDER
            border.width:2
            border.color: UI.COLOR_MAIN_BACKGROUND

        }

        //! Movie Title
        Text{
            id:movieList
            x: 8
            y: 5
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_SDEFAULT
            font.bold: true
            color:UI.COLOR_BACKGROUND
            elide: Text.ElideRight
            width: pageWidth - 20
            height: 41
            text: movieTitle
            z:20

        }
     }

    //! Main Flickable Page
    Flickable {
        id:main
        y:57
        width: pageWidth;
        height: pageHeight;
        flickableDirection: Flickable.VerticalFlick
        clip: true
        contentWidth: pageWidth;
        contentHeight: pageHeight-270 + synopsis.paintedHeight + (70 + criticConsensus.paintedHeight + 30)

        //! Popcorn Rating
        Image {
                id: moviePocorn
                x: 224
                y: 18
                width: 60
                height: 60
                source: "images/Popcorn_large.png"
                sourceSize.width: 60
                sourceSize.height: 60

                //! Percent
                Text {
                    id: popcornRatingPercent
                    x: 0
                    width: 60
                    height: 30
                    color: UI.COLOR_BACKGROUND
                    text: movieAudienceScore + "%"
                    anchors.top: moviePocorn.bottom
                    horizontalAlignment: Text.AlignHCenter
                    font.family: UI.FONT_FAMILY
                    font.pointSize: UI.FONT_SMALL
                }

                //! Critic Reviews
                MouseArea{
                    width: 60
                    height: 72
                    anchors.bottomMargin: -10
                    anchors.fill: parent
                    onClicked: {
                       root.pageStack.push(Qt.resolvedUrl("Reviews.qml"),{reviewLink:movieReview, movieTitle:movieTitle, movieCriticsScore:movieCriticsScore,movieCriticsRating:movieCriticsRating,movieAudienceScore:movieAudienceScore, movieAudienceRating:movieAudienceRating, movieNew:movieNew});
                    }

                }
            }

        //! Rotten Rating
        Image {
            id: movieRotten
            x: 354
            y: 18
            width: 60
            height: 60
            anchors.topMargin: 32
            anchors.top: movieTitle.bottom
            source: movieCriticsRating === "" ? "": "images/"+movieCriticsRating+"_large.svg"
            sourceSize.width: 60
            sourceSize.height: 60

            //! Percent
            Text {
                id: criticsRatingPercent
                x: 0
                width: 60
                height: 30
                color: UI.COLOR_BACKGROUND
                text: movieCriticsScore <0 ? "": movieCriticsScore + "%"
                anchors.top: movieRotten.bottom
                horizontalAlignment: Text.AlignHCenter
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_SMALL
            }

            //! Critic Reviews
            MouseArea{
                visible:movieCriticsRating === "" ? false:true
                anchors.fill: parent
                anchors.bottomMargin: -10
                onClicked: {
                   root.pageStack.push(Qt.resolvedUrl("Reviews.qml"),{reviewLink:movieReview, movieTitle:movieTitle, movieCriticsScore:movieCriticsScore,movieCriticsRating:movieCriticsRating,movieAudienceScore:movieAudienceScore, movieAudienceRating:movieAudienceRating, movieNew:movieNew});
                }
            }
        }

        //! Release Date
        Text {
            id: movieRelease
            x: 233
            y: 105
            width: 245
            height: 30
            color: UI.COLOR_SECONDARY_BACKGROUND
            text: Core.longDate(movieReleaseDate)
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            font.family: UI.FONT_FAMILY
            font.bold: false
            font.pointSize: UI.FONT_XXSMALL
        }

        //! Runtime
        Text {
            id: movieMpaa
            x: 233
            y: 130
            width: 245
            height: 30
            color: UI.COLOR_SECONDARY_BACKGROUND
            text: movieRuntime
            verticalAlignment: Text.AlignBottom
            horizontalAlignment: Text.AlignLeft
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_XXSMALL
            wrapMode: Text.WordWrap
            font.bold: false
        }

        //! Poster Animation
        SequentialAnimation {
                 id: movieAnimatePoster
                 running: false
                 NumberAnimation { target: moviePosterHolder; property: "opacity"; to: 1; easing.type: Easing.OutCirc; duration: 2000}
        }

        //! Movie Poster
        Rectangle{
            id: moviePoster
            x: 8
            y: 18
            width: 180
            height: 267
            color:"#00000000"

            //! Place Holder Image
            Image{
                id:posterPlaceHolder
                source: "images/palomitas.svg"
                anchors.centerIn: parent
            }

            //! Load Local/Internet Poster
            Image{
                id:moviePosterHolder
                width: 180
                height: 267
                opacity: 0

                //! Local Poster Location
                property int errorCount: 0
                property string posterLoc:appCache + "/cache/" + Core.getFileName(movieURL);

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
                        if (offline == false) source = movieURL
                    }
                }

                onStatusChanged: {
                    // Image Loaded
                    if (status  === Image.Ready)
                    {
                        //! Stop Poster Busy Indicator
                        moviePosterIndicator.running = false;

                        //! Show if error or on Reset (Press & Hold)
                        if(errorCount == 1 || reset == 1 )
                        {
                            // Fade-In Animation
                            movieAnimatePoster.start()

                            // Save image
                            imageSaver.save(moviePosterHolder, posterLoc);

                            // Reset Image source to local, if saved correctly
                            if(imageSaver.exist(posterLoc) === 1)
                                moviePosterHolder.source = posterLoc;
                            else
                            {
                              moviePosterHolder.source = movieURL
                            }

                        }
                        else
                        {
                            moviePosterHolder.opacity =1;
                        }
                    }

                    //! Loading Indicator
                    if(status === Image.Loading)
                    {
                       moviePosterIndicator.running = true
                    }

                }

                //! Hold to Refresh, if online
                MouseArea{
                    anchors.fill: parent

                    onPressAndHold: {
                        if (offline == false){
                            reset = 1;
                            moviePosterHolder.source = movieURL
                        }

                    }
                }
            }

            //! Poster Busy Indicator
            BusyIndicator{
                id: moviePosterIndicator
                anchors.centerIn: parent
                running: false
                visible: running
            }
        }

        //! Showtimes Button
        Button {
            id: showtimeButton
            x: 207
            y: 235
            width: 245
            height: 50
            visible: movieNew == 1 ? false:true

            Text {
                id: showtimeTxt
                x: 80
                y: 12
                width: 102
                height: 26
                color: UI.COLOR_BACKGROUND
                text: "Showtimes"
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_XSMALL
                wrapMode: Text.WordWrap
                font.bold: false
            }

            Image {
                id: image2
                x: 30
                y: 4
                width: 40
                height: 40
                source: "images/showtimes.svg"
                sourceSize.width: 40
                sourceSize.height: 40
            }

            onClicked:tab1.push(Qt.resolvedUrl("showtimes.qml"),{movieTitle:movieTitle,movieURL:movieTrailer, showtimeURL:"http://popflix.dengineer.com/showtime.php?movie="+movieTitle});

        }

        //! Play Trailer Button
        Button {
            id: playTrailer
            x: 207
            y: 170
            width: 245
            height: 50

            Text {
                id: playTrailerTxt
                x: 80
                y: 12
                width: 110
                height: 26
                color: UI.COLOR_BACKGROUND
                text: "Play Trailer"
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_XSMALL
                wrapMode: Text.WordWrap
                font.bold: false
            }

            Image {
                id: image1
                x: 30
                y: 4
                width: 40
                height: 40
                sourceSize.height: 40
                sourceSize.width: 40
                source: "images/play.svg"
            }

            onClicked: if (offline == false){appWindow.pageStack.push(Qt.resolvedUrl("trailer.qml"), {videoURL:movieTrailer, movieTitle:movieTitle});}

        }

        //! Movie Casts
        Text {
            id: movieCastTitle
            x: 8
            y: 240
            width: 298
            height: 24
            color: UI.COLOR_BACKGROUND
            text: "Cast"
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_LSMALL
            wrapMode: Text.WordWrap
            font.bold: true

            Text {
                id: movieCast
                x: 0
                y: 26
                width: 443
                height: 48
                color: UI.COLOR_SECONDARY_BACKGROUND
                text: movieCasts
                maximumLineCount:2
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                font.family: UI.FONT_FAMILY
                font.bold: true
                font.pointSize: UI.FONT_XSMALL

            }
        }

        //! Synopsis
        Text {
            id: movieSynopsisTitle
            x: 8
            y: 330
            width: 300
            height: 24
            color: UI.COLOR_BACKGROUND
            text: "Synopsis"
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_LSMALL
            wrapMode: Text.WordWrap
            font.bold: true

            Text {
                id: synopsis
                y: 30
                width: pageWidth-16
                color: UI.COLOR_SECONDARY_BACKGROUND
                text: movieSynopsis === "" ? "None":movieSynopsis.replace(/&quot;/g, "\"")
                wrapMode: TextEdit.Wrap
                font.family: UI.FONT_FAMILY
                font.bold: true
                font.pointSize: UI.FONT_XSMALL
            }
        }

        //! Critic Consesus
        Text {
            id: movieReviews
            x: 8
            y: 390 + synopsis.paintedHeight + 35
            width: 480
            height: 24
            color: UI.COLOR_BACKGROUND
            text: "Critics Consensus"
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_LSMALL
            wrapMode: Text.WordWrap
            font.bold: true

            Text {
                id: criticConsensus
                y: 30
                width: pageWidth-16
                color: UI.COLOR_SECONDARY_BACKGROUND
                text: movieCriticsConsensus == "" ? "None": '"' + movieCriticsConsensus.replace(/&quot;/g, "\"") + '"'
                wrapMode: TextEdit.Wrap
                font.bold: true
                font.pointSize: UI.FONT_XSMALL
            }

            Button{
                x:285
                y: criticConsensus.paintedHeight + 40
                platformStyle: ButtonStyle{ inverted: false }
                height:45
                width:175
                anchors.right: parent.right
                anchors.rightMargin: 20
                onClicked: {
                    root.pageStack.push(Qt.resolvedUrl("Reviews.qml"),{reviewLink:movieReview, movieTitle:movieTitle, movieCriticsScore:movieCriticsScore,movieCriticsRating:movieCriticsRating,movieAudienceScore:movieAudienceScore, movieAudienceRating:movieAudienceRating,movieNew:movieNew});
                }

                Text{   anchors.centerIn: parent
                        text:"Read Reviews";
                        font.family: UI.FONT_FAMILY
                        font.pointSize: UI.FONT_SMALL}

            }
        }
    }

}
