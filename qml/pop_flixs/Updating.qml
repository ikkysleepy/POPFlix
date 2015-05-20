// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.0
import "UI.js" as UI

/*!
 * @brief Updating Code
 *
 * version 0.9 11/19/2012 Initial Release
 */
Rectangle{
    id:pull2Rrefresh

    property int startY:0;
    property string pullTxt:"Updating..."

    y:startY
    width: pageWidth
    visible: false
    color:UI.COLOR_SECONDARY_FOREGROUND
    height: 52
    z:0

    Text{
        y:15
        x: pull2Rrefresh.width/2 -70
        text:pullTxt
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_XSMALL
        color:UI.COLOR_BACKGROUND
        visible: pull2Rrefresh.visible
    }


    BusyIndicator{
        id: xmlIndicatorSmall
        y:15
        x:20
        running: true
        platformStyle: BusyIndicatorStyle { size: "small" }
        visible:running
    }


}
