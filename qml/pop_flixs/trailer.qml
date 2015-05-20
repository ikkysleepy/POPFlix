import QtQuick 1.1
import com.nokia.meego 1.1
import "VideoPlayer"                // Video Player module
import "UI.js" as UI
import QtMobility.systeminfo 1.1
import "core.js" as Core

/*!
 * @brief playholder for loading movie Trailer
 *
 * version 0.7 11/9/2012 Initial Release
 * version 0.10 11/24/2012 Added Support for HQ video
 * version 0.11 12/23/2012 Redid Trailer to inclue popup and include Question + strLink to Auto Open
 */
Page {
    id:root
    orientationLock: PageOrientation.LockLandscape

    // Page Params
    property int error: 0
    property string videoURL;
    property string movieTitle;
    property string yt_id;
    property bool blocked: false
    property string myError;
    property int retries:0;

    onBlockedChanged: ss.setScreenSaverDelayed(blocked)

    //! Hide the Clock
    Component.onCompleted:{ showClock=false;
    xmlIndicator.running = true;
    }

    signal myVideoError;

    onMyVideoError: {
        queryDialog.open()
    }

    QueryDialog {
              id: queryDialog
              titleText: "Video Error: " + myError
              message: "Open Trailer in Browser?"
              acceptButtonText: "Yes"
              rejectButtonText: "No"
              onAccepted:{
                  Qt.openUrlExternally("http://m.youtube.com/#/watch?v=" + yt_id+"&desktop_uri=%2Fwatch%3Fv%3D" +yt_id)
                  exitVideoTimer.start()
              }
              onRejected: {
                  exitVideoTimer.start()
              }
          }

    //! VisualStyle needed for VideoPlayer Component.
    VisualStyle {
        id: visual
    }

    //! Disable / Enable ScreenSaver TimeOut
    ScreenSaver {
          id: ss

          //! Screensaver disabled by default
           Component.onCompleted:  blocked = true
      }

    //! XML Data
    XmlListModel {
        id:videoXML
        source:"http://popflix.dengineer.com/trailers.php?name=" + movieTitle +"&country="+strCountry + "   &quality="+strVideoQuality
        query: "/trailer/video"

        XmlRole { name: "url"; query: "@url/string()"; }
        XmlRole { name: "error"; query: "@error/string()"; }

        onStatusChanged: {

                if (status === XmlListModel.Ready)
                {
                    //! Stop Indicator
                    loadingContentError.stop()

                    //! Load Video
                    if(videoXML.get(0).error)
                    {

                        if(strSendError === 0)
                        {
                            Core.sendError("movie="+movieTitle+"&quality="+strVideoQuality+"&country="+strCountry+"&error=No Trailer")
                            errorTxt.text = "No Trailer Found!\nDeveloper was notified. =)"
                         }
                        else
                        {
                        errorTxt.text = "No Trailer Found! :("
                        }

                        xmlIndicator.visible = false;
                        errorItem.visible = true;
                        error = 1;
                        showClock = true;
                        blocked = false;
                        videoError.start()

                    }
                    else
                    {
                        //! Set YouTube Video ID & Quality
                        yt_id  = videoXML.get(0).url;

                        if(strLink == 1)
                        {
                        //YouTube.setPlaybackQuality(strVideoQuality)
                        //YouTube.getVideoUrl(yt_id);
                          getVideo.start()

                        }
                        else
                        {
                            Qt.openUrlExternally("http://m.youtube.com/#/watch?v=" + yt_id+"&desktop_uri=%2Fwatch%3Fv%3D" +yt_id)
                            exitVideoTimer.start()
                        }
                    }


                }

                //! Check Internet Errors when Loading
                if(status === XmlListModel.Loading)
                {
                    //! Start loading Timer
                    xmlIndicator.running = true;
                    loadingContentError.start()
                }

                //! If the progress is finished and the result is an error
                //! Show the Error Message
                if (status === XmlListModel.Error && progress === 1)
                {
                    errorTxt = "Error Getting Trailer! :("
                    errorItem.visible = true;
                    error = 1;
                }
        }
    }



    //! Loading Video
    BusyIndicator{
        id: xmlIndicator
        anchors.centerIn: parent

        running: true
        platformStyle: BusyIndicatorStyle { size: "Large" }
        visible: running
    }

    Button{
        text: "Cancel"
        x:260
        y:330
        visible: xmlIndicator.visible
        onClicked: {
            showClock = true;
            blocked = false;
            root.pageStack.pop()
        }
    }


    //! Hide Busy Indicator
    Timer{
        id: hideBusyIndicator
        interval: 2000;
        running: false;
        repeat: false;
        onTriggered: xmlIndicator.running = false;

    }

    //! Timer to End Video
    Timer{
        id: videoError
        interval: 3000;
        running: false;
        repeat: false;
        onTriggered:root.pageStack.pop();
    }

    //! Slow Internet Timer
    Timer {
        id: loadingContentError
        interval: 15000;
        running: false;
        repeat: false;
        onTriggered: {
            //! Error if Slow/No Internet in 15 seconds
            errorTxt.text  = "No Internet/Trouble with Connection"
            error = 1;
        }

    }

    //! Slow Internet Timer
    Timer {
        id: exitVideoTimer
        interval: 4000;
        running: false;
        repeat: false;
        onTriggered: {
            showClock = true;
            blocked = false;
            root.pageStack.pop()
         }

    }


    function getYouTube(yt_id){

            var http = new XMLHttpRequest()
            var url = "http://www.youtube.com/watch?hl=en&amp;gl=US&amp;client=mv-google&amp;v="+yt_id+"&amp;nomobile=1"
            http.open("GET", url);

             // Send the proper header information along with the request
            http.setRequestHeader("Referer",url);
            http.setRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14");
            http.setRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
            http.setRequestHeader("Accept-Language", "en-us;q=0.7,en;q=0.3");
            http.setRequestHeader("Accept-Encoding", "gzip,deflate");
            http.setRequestHeader("Accept-Charset", "windows-1251,utf-8;q=0.7,*;q=0.7");
            http.setRequestHeader("Keep-Alive", "300");
            http.setRequestHeader("Connection", "keep-alive");
            http.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            http.onreadystatechange = function() { // Call a function when the state changes.
                   try{
                    if (http.readyState == 4) {
                         if (http.status == 200) {
                             parseResponse(http.responseText)
                         } else {

                             console.log("error: " + http.status)
                         }
                     }
                   }
                   catch(merror){
                       console.log("no response... " + merror + " : " + http.status)
                   }

                 }
            http.send(null);
    }

    function parseResponse(res) {
     try {

         var regex = /stream_map=(.[^&]*?)(?:\\\\|&)/i;
         var match = regex.exec(res);

         var fmt_url =  urldecode(match[1]);
         var urls = fmt_url.split(",");

         var foundArray = new Array();
         var u;

         for(var i=0; i<urls.length; i++) {
             try{
                 var regex_url = /itag=([0-9]+)/;
                 var tm = regex_url.exec(urls[i])

                 var regex_sig = /sig=(.*?)&/;
                 var si = regex_sig.exec(urls[i]);

                 var regex_um = /url=(.*?)&/;
                 var um = regex_um.exec(urls[i]);

                 if((typeof tm[1] !== 'undefined' && tm[1] !== null) && (typeof si[1] !== 'undefined' && si[1] !== null) && (typeof um[1] !== 'undefined' && um[1] !== null)){
                     u = urldecode(um[1]);
                    foundArray[tm[1]] = u+'&signature='+si[1];
                 }
             }
             catch(error){
                 console.log("error",error)
             }
         }

         console.log(urldecode(foundArray[18]));

         if(strVideoQuality === "Mobile")
           playTrailer(urldecode(foundArray[5]));
         else if(strVideoQuality === "360p")
            playTrailer(urldecode(foundArray[18]));
         else if(strVideoQuality === "480p")
            playTrailer(urldecode(foundArray[36]));
         else
           playTrailer(urldecode(foundArray[18]));

     }
     catch(ex){
         console.log(ex)

        if(retries < 3)
        {getYouTube(yt_id); retries = retries + 1;}
        else
        {
            myError = "Couldn't Get Video Stream"
            queryDialog.open()
        }
    }
    }

    function urldecode(url) {
      return decodeURIComponent(url.replace(/\+/g, ' '));
    }

    Timer {
        id: getVideo
        interval: 500;
        running: false;
        repeat: false;
        onTriggered: {
            console.log("getting Video")
            getYouTube(yt_id);
         }

    }

    function playTrailer(videoUrl){
        hideBusyIndicator.start()

        var component = Qt.createComponent("VideoPlayer/VideoPlayView.qml");

        if (component.status === Component.Ready) {

            //! Go Back and Destroy Page
            //! Show Clock
            //! Allow Sleep
            function exitHandler() {
                player.destroy();
                exitVideoTimer.start()
            }

            var player = component.createObject(root);

            // setVideoData expects parameter to contain video data
            // information properties.
            var model = new Object();
            model.m_contentUrl = videoUrl;
            model.m_title = "";
            model.m_duration = "";
            model.m_author = "";
            model.m_numLikes = "";
            model.m_numDislikes = "";
            model.m_viewCount = "";
            model.m_description = "";
            player.isFullScreen = true;
            player.enableScrubbing = true;
            player.videoExit.connect(exitHandler);
            player.setVideoData(model);
        }
    }

    //! Play YouTube Video
    Connections {
        target: YouTube
        onGotVideoUrl: {
            playTrailer(videoUrl);
        }

        onVideoUrlError: {

            if(strSendError === 0)
            {
                Core.sendError("movie="+movieTitle+"&yt_id="+yt_id+"&quality="+strVideoQuality+"&country="+strCountry+"&error=Error Loading Trailer")
                errorTxt.text = "Error Loading Trailer.\nDeveloper was notified.";
             }
            else
            {
                errorTxt.text = "Error Loading Trailer :(";
            }

            errorItem.visible = true;
            error = 1;
            myError = "Could Not Load Trailer"
            queryDialog.open()
        }
    }

    //! Error Msg
    Item{
        id:errorItem
        visible: false

        Text{
            id: errorTxt
            x: 156
            y: 250
            color: UI.COLOR_BACKGROUND
            font.family: UI.FONT_FAMILY
            font.pointSize: UI.FONT_DEFAULT
        }
    }

}
