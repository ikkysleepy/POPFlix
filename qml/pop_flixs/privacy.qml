import QtQuick 1.1
import com.nokia.meego 1.0
import "UI.js" as UI
import "core.js" as Core

/*!
 * @brief Settings (Privacy Statement)
 *
 * version 0.11 12/23/2012 Initial Release
 */
Page{
    id:root
    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }

    //! Graident Background
    GradientBackground{}

    //! Page Header
    Rectangle{
        id:header
        width: pageWidth
        height: 50
        color: "#000000000"

        Rectangle {
            id: borderline
            x: 0
            y: 42
            width: pageWidth
            height: 2
            color: UI.COLOR_BACKGROUND
            radius: 0
            anchors.top: header.bottom
            anchors.topMargin: 0
        }

        Rectangle{
            y:0
            width: pageWidth
            color: "#00000000"

            Text{
                id:movieList
                x: 8
                y: 0
                font.family: UI.FONT_FAMILY
                font.pointSize: UI.FONT_SLARGE
                font.bold: true
                color:"white"
                text: qsTr("Private Statement")
            }
        }
    }

    Flickable {
        id:main
        y:50
        width: pageWidth;
        height: pageHeight -150;
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        clip: true
        contentWidth: pageWidth;
        contentHeight: pageHeight +50;


        Text{
            id:policy
            y:55
            x:22
            width: pageWidth-30
            wrapMode: Text.WordWrap
            color: UI.COLOR_BACKGROUND
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_XSMALL
            text:"Data\nOur systems log information like your mobile operating system and Location (if you give us permission to do so). We do not collect personally identifiable information about you. In other words, we do not collect information such as your name, address, phone number or email address.\n\nLocation\nIn serving you nearby theater locations, we may use or store your precise geographic location, if you give us permission to do so. We do not use or share this data for any other purpose. Many devices will indicate through an icon when location services are operating.\n\nSecurity\nInformation we collect may be stored or processed on computers located in any country where we do business.\n\nAds and Sharing Data\nThere are no ads and we do not share information with others."
        }

    }

    //! Back Button Nav
    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back";
            onClicked: root.pageStack.pop()
        }
    }

}
