import QtQuick 1.1
import com.nokia.meego 1.0

/*!
 * @brief Dropdown Country List
 *
 * version 0.7 11/9/2012 Initial Release
 */
SelectionDialog {
    id: root
    titleText: "Country List"
    anchors.fill: parent
    opacity: 0.5
    model:   ListModel {
        ListElement { name:"USA"; country:"US"}
        ListElement { name:"Australia"; country:"AU"}
        ListElement { name: 'France'; country: 'FR'}
        ListElement { name:"United Kingdom"; country:"UK"}
    }
}
