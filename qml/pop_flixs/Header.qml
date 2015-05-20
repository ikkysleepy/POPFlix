import QtQuick 1.1
import "UI.js" as UI

/*!
 * @brief Header code
 *
 * version 0.7 11/9/2012 Initial Release
 */
Rectangle{
    id:header
    width: pageWidth
    height:55
    color:UI.COLOR_BORDER
    border.width:2
    border.color: UI.COLOR_MAIN_BACKGROUND

    property string pageTitle;

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
    text: pageTitle
    z:20

}

}
