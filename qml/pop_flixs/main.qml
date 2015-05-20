import QtQuick 1.1
import com.nokia.meego 1.0

/*!
 * @brief Main QML
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.10 11/24/2012 Added Support for HD video
 */
PageStackWindow {
    id: appWindow
    property int pageWidth:480;
    property int pageHeight:854;
    property bool showClock: true;
    property string strCountry;
    property string strOldCountry;
    property string strVideoQuality;
    property int strSendError;
    property int strLink;
    property bool offline:false;

    showStatusBar: showClock
    initialPage: mainPage

    MainPage {
        id: mainPage
    }

    Menu {
        id: myMenu
        visualParent: pageStack

        MenuLayout {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                  pageStack.push(Qt.resolvedUrl("About.qml"))
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                  pageStack.push(Qt.resolvedUrl("Settings.qml"))
                }
            }
            MenuItem {
                text: qsTr("Go Offline")
                onClicked: {
                    if(offline == true)
                    {offline = false; text =  qsTr("Go Offline");}
                    else
                    {offline = true; text = qsTr("Go Online");}
                }
            }
            MenuItem {
                text: qsTr("Exit")
                onClicked: Qt.quit()
            }

        }
    }


    Component.onCompleted: {
    theme.inverted = true
    }


}
