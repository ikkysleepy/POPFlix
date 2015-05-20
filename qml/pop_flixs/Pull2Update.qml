import QtQuick 1.1
import com.nokia.meego 1.0
import "UI.js" as UI

/*!
 * @brief PUll 2 Update Code
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.9 11/9/2012 Added Updating.qml
 */
Rectangle{
    id:pull2Rrefresh

    property int startY:0;
    property string pullTxt:"Pull to Update"

    y:startY
    width: pageWidth
    visible: false
    color:UI.COLOR_SECONDARY_FOREGROUND
    height: -listView.contentY
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

}
