import QtQuick 1.1
import com.nokia.meego 1.0
import "UI.js" as UI

/*!
 * @brief displays about info
 *
 * version 0.7 11/9/2012 Initial Release
 */
Page{
    id:root
    orientationLock: PageOrientation.LockPortrait

    //! Header
    Text {
        id: headerBox
        x: 22
        y: 10
        width: 400
        height: 60
        color: UI.COLOR_BACKGROUND
        text: qsTr("POP Flix")
        font.bold: true
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_LARGE
    }

    //! Version
    Text {
        id: version
        x: 372
        y: 75
        width: 68
        height: 25
        color: UI.COLOR_BACKGROUND
        text: "v 0.12a"
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
    }

    //! Copyright
    Text {
        id: copyright
        x: 22
        y: 75
        width: 348
        height: 25
        color: UI.COLOR_BACKGROUND
        text: "(C) 2012 Jorge Corona"
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
    }

    //! Summary
    Text {
        id: bio
        x: 22
        y: 117
        width: 418
        height: 60
        color: UI.COLOR_BACKGROUND
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
        text: "Convenient on-the-go movie app for movie reviews, Trailers, and showtimes."
        wrapMode: Text.WordWrap
    }

    //! Flixter Text
    Text {
        id: rotten
        x: 22
        y: 190
        width: 418
        height: 120
        color: UI.COLOR_BACKGROUND
        text: "Flixster, Rotten Tomatoes, the Certified Fresh Logo, Fresh Tomato, Rotten Splat and Popcorn Logos are trademarks or registered trademarks of Flixster, Inc. in the United States and other countries."
        wrapMode: Text.WordWrap
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
    }

    //! Noun Project
    Text{
        x:22
        y:350
        width: 418
        height: 120
        color: UI.COLOR_BACKGROUND
        text: "Popcorn designed by andrei antonesc from The Noun Project, and Cinema from The Noun Project."
        wrapMode: Text.WordWrap
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
    }


    //! TMDb
    Text{
        x:22
        y:450
        width: 418
        height: 120
        color: UI.COLOR_BACKGROUND
        text: "This product uses the TMDb API but is not endorsed or certified by TMDb."
        wrapMode: Text.WordWrap
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
    }

    //! Image Bacground
    Image {
        id: cityBackground
        x: 0
        y: 661
        width: 480
        height: 210 ;source: "images/city_bg.png"}

    //! Feedback
    Button {
        id: sendButton
        x: 22
        y: 525
        width: 250
        height: 60
        text: "Send Feedback"
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_DEFAULT
        onClicked: Qt.openUrlExternally("mailto:jorge@dengineer.com?subject=POP Flix Feedback")
    }

    //! Feedback
    Button {
        id: privacyButton
        x: 22
        y: 620
        width: 250
        height: 60
        text: "Privacy Statement"
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_DEFAULT
        onClicked: root.pageStack.push(Qt.resolvedUrl("privacy.qml"))

    }


    //! Close
    Button {
        id: cancelButton
        x: 300
        y: 525
        width: 150
        height: 135
        text: "Close"
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_DEFAULT
        onClicked: root.pageStack.pop()
        platformStyle: ButtonStyle{ inverted: false }
    }

}
