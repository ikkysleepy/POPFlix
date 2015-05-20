import QtQuick 1.1
import com.nokia.meego 1.0
import QtMobility.systeminfo 1.1
import "storage.js" as Storage
import "core.js" as Core
import "UI.js" as UI

/*!
 * @brief Landing Page with CHROME
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/19/2012 moved functions to core.js
 * version 0.10 11/24/2012 Added Support for HD video
 *
 */
Page {
    id:root
    width: pageWidth
    height: pageHeight

    //! Global Error Params
    property int error: 0
    property string errorText;

    //! Page Params
    property int pageStackTab1:1;
    property int pageStackTab2:1;
    property string refPage;
    property string animationCount;

    //! Check Database on Load of Page
    Component.onCompleted: {
        console.log(appCache)

        //! Check Databses
        Storage.openDB();

        //! Select Country
        strCountry = selectCountry.model.get(Storage.getCountry()).country;
        strOldCountry = strCountry

        //! Set Video Quality & Send Error
        strVideoQuality = Storage.getVideoQuality();
        strSendError = Storage.getSendError();

        //! Get Link Value
        strLink = Storage.getLink();

        //! Animation Count
        animationCount = Storage.countAnimation();

    }

    //! Network Activity
    NetworkInfo {
        id: internet
        monitorNameChanges: true
        monitorSignalStrengthChanges: true
    }

    //! Select Country
    BoxSelectionDialogCountry{id:selectCountry}

    //! Gradient Background
    GradientBackground{}

    //! Page Nav
    Rectangle{
        id:header
        width: pageWidth
        height: 70

        TabButton{
            id:menuTab
            x:0
            y: 0
            width: 70
            height: 70

            Image{
                id: menuIcon
                x:15
                y:10
                rotation: 180
                source: "images/icon-m-toolbar-view-menu-white-selected.png"
            }

            onClicked: Core.checkTabIcon()

        }

        TabButton{
            id:moviesTab
            x: 70
            y: 0
            width: (screen.currentOrientation == Screen.Portrait) ? 185:330
            height: 70
            checked: true
            tab: tab1

            Item{
                x: (screen.currentOrientation == Screen.Portrait) ? 0:100

                Text {
                    x:60
                    y:20
                    id: movies
                    color: UI.COLOR_BACKGROUND
                    text: "Movies"
                    font.family: UI.FONT_FAMILY
                    font.bold: true
                    font.pointSize: UI.FONT_DEFAULT
                }

                Image {
                    id: moviesIcon
                    x:10
                    y:15
                    width: 40
                    height: 40
                    source: "images/movies.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }
            }
        }

        TabButton{
            id:theatersTab
            x: (screen.currentOrientation == Screen.Portrait) ? 235:400
            y: 0
            tab: tab2
            width: (screen.currentOrientation == Screen.Portrait) ? 185:400
            height: 70

            Item{
                x: (screen.currentOrientation == Screen.Portrait) ? 0:120

                Text {
                    x:60
                    y:20
                    id: movies2
                    color: UI.COLOR_BACKGROUND
                    text: "Theaters"
                    font.family: UI.FONT_FAMILY
                    font.bold: true
                    font.pointSize: UI.FONT_DEFAULT
                }

                Image {
                    id: moviesIcon2
                    x:10
                    y:15
                    width: 40
                    height: 40
                    source: "images/theaters.svg"
                    sourceSize.width: 40
                    sourceSize.height: 40
                }
           }
        }

        TabButton{
            id:checkinTab
            x: (screen.currentOrientation == Screen.Portrait) ? 420:795
            y: 0
            width: 60
            height: 70

            Image {
                id: geolocate
                x:0
                y:10
                width: 50
                height: 50
                source: "images/geolocate.png"
                sourceSize.width: 50
                sourceSize.height: 50
                visible: false
            }

        }

    }

    //! Tab Pages
    TabGroup {
        id: tabGroup
        anchors.top: header.bottom
        currentTab: tab1

        PageStack {
            id: tab1

            Component.onCompleted: {
                tab1.push(Qt.resolvedUrl("MoviePage.qml"))
            }

            onCurrentPageChanged: Core.checkTab()
        }

        PageStack {
            id: tab2

            Component.onCompleted: {
                tab2.push(Qt.resolvedUrl("theaters.qml"))
            }

            onCurrentPageChanged: Core.checkTab()

        }

        onCurrentTabChanged: Core.checkTab();

       }

 }
