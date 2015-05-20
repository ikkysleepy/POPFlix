import QtQuick 1.1
import "UI.js" as UI

/*!
 * @brief Bubble Error
 *
 * version 0.7 11/9/2012 Initial Release
 */
Item {
    id: root
    x: 60
    y:60
    opacity: 0;

    property alias text: text.text

    function open() {
        fadeIn.start();
        openBox.start();
        }

    Rectangle {
        id: box
        width: pageWidth-100
        height: 100
        color: UI.COLOR_FOREGROUND
        opacity: 0.75
        border.width: 3
        border.color: UI.COLOR_BACKGROUND
        radius: 10

    }

    Text{
        id:text
        x: 20
        y: 20

        text: ""
        wrapMode: Text.WordWrap
        width:  box.width-20
        height: 100
        font.pointSize: UI.FONT_DEFAULT
        color: UI.COLOR_BACKGROUND
    }

    SequentialAnimation {
             id: fadeOut
             running: false
             PropertyAnimation { target: root; properties: "opacity"; to: "0"; duration: 1000}
         }

    SequentialAnimation {
             id: fadeIn
             running: false
             PropertyAnimation { target: root; properties: "opacity"; to: "1"; duration: 1000}
             PauseAnimation { duration: 3000 }

         }

    Timer {
        id: openBox
        interval: 4000;
        running: false;
        repeat: false;
        onTriggered: {
            fadeOut.start();
        }
    }
}
