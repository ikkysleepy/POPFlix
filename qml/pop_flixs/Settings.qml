import QtQuick 1.1
import com.nokia.meego 1.0
import "UI.js" as UI
import "storage.js" as Storage
import "core.js" as Core

/*!
 * @brief Settings (Change Country)
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.10 11/24/2012 Added HQ video options + Send Error
 * version 0.11 12/8/2012 added Clear Cache button
 *
 */
Page{
    id:root
    state: (screen.currentOrientation == Screen.Portrait) ? "portrait" : "landscape"

    //! Flip pageHeight / pageWidth
    onStateChanged: {
        Core.screenFlip();
    }


    Component.onCompleted: {

        //! Update Send Error
        if (strSendError === 1 ) mySwitch.checked=false;

        //! Update Link
        if (strLink === 1 ) myLink.checked=false;

        var size = imageSaver.dir_size(appCache+"/cache/"),
        humanSize = size / (1024*1024);

        clearCache.text = "Clear Cache (" + humanSize.toFixed(2) + " MB )";

    }

    //! Graident Background
    GradientBackground{}

    //! Main Flickable Page
    Flickable {
        id:main
        y:57
        width: pageWidth;
        height: pageHeight;
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        clip: true
        contentWidth: pageWidth;
        contentHeight: 600;

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
                text: qsTr("Settings")
            }
        }

    }

    //! Country Label
    Text {
        id: countryLabel
        x: 19
        y: 95
        width: 172
        height: 25
        text: qsTr("Country")
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_LDEFAULT
        color: UI.COLOR_BACKGROUND
    }

    //! Country button
    Button{
        id: countryButton
        x:150
        y:85
        width: 100; height: 50
         text: strCountry
         checkable: true

         MouseArea{
             anchors.fill: parent
             onClicked: selectionDialog.open();
         }
    }

    //! Country Dialog
    BoxSelectionDialogCountry{
        id: selectionDialog

        onAccepted :{
            strOldCountry = strCountry;
            var country = selectionDialog.model.get(selectedIndex).country,
                   item = new Array;

            //! Update Button Text
            countryButton.text = country;

            //! Update Country
            item.modified = new Date();
            item.id = 1
            item.country_id = selectedIndex;
            strCountry = country;
            Storage.updateCountry(item);
        }
    }


    //! Video Quality
    Text {
        x: 19
        y: 170
        width: 172
        height: 25
        text: qsTr("Video Quality")
        font.family: UI.FONT_FAMILY
        font.pointSize: UI.FONT_LDEFAULT
        color: UI.COLOR_BACKGROUND
    }

    ButtonRow {
        id: amount
        y:220
        x:19
        width: pageWidth-40

        Button {
            id: smallButton
            text: "Mobile"
            checked: strVideoQuality === "Mobile" ? true:false

            onClicked: {
                Core.updateVideoQuality("Mobile")
            }

        }


        Button {
            id: mediumButton
            text: "360p"
            checked: strVideoQuality === "360p" ? true:false

            onClicked: {
                Core.updateVideoQuality("360p")
            }
        }

        Button {
            id: largeButton
            text: "480p"
            checked: strVideoQuality === "480p" ? true:false

            onClicked: {
                Core.updateVideoQuality("480p")
            }

        }

    }

    CheckBox{
        id: mySwitch
        x: pageWidth -65
        y: 300
        checked: true

        onClicked:{
            if(strSendError == 0 && checked == false)
                Core.updateSendError(1);
            else
                Core.updateSendError(0);
        }

   }

   //! Send Errors
   Text {
       x: 19
       y: 305
       width: pageWidth - 80
       height: 60
       text: qsTr("Automatically Send Movie Trailer Errors?")
       font.family: UI.FONT_FAMILY
       font.pointSize: UI.FONT_SMALL
       color: UI.COLOR_BACKGROUND
   }


   CheckBox{
       id: myLink
       x: pageWidth -65
       y: 380
       checked: true
       onClicked:{
           if(strLink == 0 && checked == false)
               Core.updateLink(1);
           else
               Core.updateLink(0);
       }

  }

  //! Open YouTube Link
  Text {
      x: 19
      y: 385
      width: pageWidth - 80
      height: 60
      text: qsTr("Automatically Open Trailer In Browser?")
      font.family: UI.FONT_FAMILY
      font.pointSize: UI.FONT_SMALL
      color: UI.COLOR_BACKGROUND
  }





   Button{
       id:clearCache
       x:19
       y:450
       text: "Clear Cache"
       height: 60
       width: pageWidth -30
       onClicked: {imageSaver.removeDir(appCache);
           text = "Clear Cache";
       }

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
