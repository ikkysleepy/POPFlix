//! ----------------------------------------------------
//! Core Functions
//!
//! version 0.7 11/9/2012 Initial Release
//! version 0.10 11/24/2012 Added Video & Error functions
//!
//! ----------------------------------------------------

//! screenFlip
//! Flips Resolution
//!
//! QML: All
function screenFlip() {
    if (screen.currentOrientation == Screen.Portrait)
    { pageWidth = 480; pageHeight = 854; }
    else
    { pageWidth = 854; pageHeight = 480; }
}

//! pull2Update(footer)
//! Pull 2 Update on Page
//! Optional footer for MoviePage.qml
//!
//! QML: All
function pull2Update(footer) {

    //! Start when pulling down slightly
    var start,max;

    if (screen.currentOrientation == Screen.Portrait) {
         start = -28;
         max = 120;
    }
    else
    {
        start = -28;
        max = 60;
    }

    //! Reset firstTime
    firstTime = false;

    //! Show Pull2Refresh
    if (listView.contentY <start && loaded == true && listView.flicking == false)
    {
        pull2update.visible = true;

        if(listView.contentY <- max && listView.flicking == false && offline == false)
        { if(footer) listView.footer = footerNull; refresh.start();}
    }
    else
    {

        pull2update.visible = false;

    }
}

//! saveMovies
//! Save Movie Info
//!
//! QML: MoviePage.qml
function saveMovies(){

    var defined;
    if(mainListViewXML.get(0) != undefined)
        defined = true;

    //! Save to Database
    if(defined)
    {
        //! Drop Movies for ID
        Storage.dropMovies(movieId);

        var i;
        for(i=0; i< mainListViewXML.count; i++)
        {

        //! Record Location
        var item = new Array,
            localid;

        //! Configure Primary Key
        if(movieId == 1)
            localid = 20 +i;
        else if (movieId == 4)
            localid = 36 +i
        else
            localid = i

        item.id = localid
        item.movieId = movieId
        item.title = mainListViewXML.get(i).title
        item.mpaa_rating = mainListViewXML.get(i).mpaa_rating
        item.runtime = mainListViewXML.get(i).runtime
        item.critics_rating = mainListViewXML.get(i).critics_rating
        item.critics_score = mainListViewXML.get(i).critics_score
        item.audience_rating = mainListViewXML.get(i).audience_rating
        item.audience_score = mainListViewXML.get(i).audience_score
        item.critics_consensus = mainListViewXML.get(i).critics_consensus
        item.release_dates = mainListViewXML.get(i).release_dates
        item.synopsis = mainListViewXML.get(i).synopsis
        item.reviews = mainListViewXML.get(i).reviews
        item.new_release = mainListViewXML.get(i).new_release
        item.video = mainListViewXML.get(i).video
        item.thumbnail = mainListViewXML.get(i).thumbnail
        item.profile = mainListViewXML.get(i).profile
        item.detailed = mainListViewXML.get(i).detailed
        item.type = mainListViewXML.get(i).type
        item.abridged_cast_1 = mainListViewXML.get(i).abridged_cast_1
        item.abridged_cast_1_charactor = mainListViewXML.get(i).abridged_cast_1_charactor
        item.abridged_cast_2 = mainListViewXML.get(i).abridged_cast_2
        item.abridged_cast_2_charactor = mainListViewXML.get(i).abridged_cast_2_charactor
        item.abridged_cast_3 = mainListViewXML.get(i).abridged_cast_3
        item.abridged_cast_3_charactor = mainListViewXML.get(i).abridged_cast_3_charactor
        item.abridged_cast_4 = mainListViewXML.get(i).abridged_cast_4
        item.abridged_cast_4_charactor = mainListViewXML.get(i).abridged_cast_4_charactor
        item.abridged_cast_5 = mainListViewXML.get(i).abridged_cast_5
        item.abridged_cast_5_charactor = mainListViewXML.get(i).abridged_cast_5_charactor
        item.modified = new Date();
        Storage.createMovieList(item);

        }
    }

}

//! checkXML
//! Determines to load db or get data from online
//!
//! QML: All
function checkXML(page,metrics){

    //! No Internet
    if (internet.networkStatus !== "Connected" && internet.networkStatus !== "Home Network")
    {
        // Only if live
        metrics = false;
    }

    //! Check if metrics was met
    if(metrics == true)
    {

     if(page === "main")
     {listView.footer = footerNull; }

     refresh.start();
    }


     if(page === "main")
      {  Storage.readMovies(databaseModel,movieId);
         listView.footer = footer;
     }
     else if (page === "theaters")
     {
         Storage.readTheaters(databaseModel,near)
     }
     else if (page === "theater")
     {
         Storage.readTheater(databaseModel,near,theaterTitle)
     }
     else if (page === "showtimes")
     {
         Storage.readShowtimes(databaseModel,near,movieTitle)
     }
     else if (page === "reviews")
     {
         Storage.readReviews(databaseModel,movieTitle)
     }

     databaseLoaded = true;
     loaded = true;
}

//! errorMsg
//! Error Message
//!
//! QML: All
function errorMsg(msg){

    //! Stop Indicator
    if(firstTime == true)
    {   xmlIndicator.running = false;

        //! Enable Pull2update
        loaded = true;

        //! Stop loading Timer
        loadingContentError.stop()

          //! Show Error
            errorTxt.text  = msg
            error = 1;
            errorItem.visible = true

    }
    else
       {
        //! Pull 2 Update Reset
        listView.contentY = 0
        loadingXML.stop()
        pull2update.pullTxt = "Pull to Update"

        //! Stop loading Timer
        loadingContentErrorBubble.stop()

        //! Show Error
        banner.text = msg
        banner.open()
    }

    return true;
}

//! stopIndicator
//! Stops Busy Indicators
//!
//! QML: All
function stopIndicator()
{

    //! Reset if Error
    errorItem.visible = false;

    //! Stop Indicator
    if(firstTime == true)
    {   xmlIndicator.running = false;

        //! Enable Pull2update
        loaded = true;

        //! Stop loading Timer
        loadingContentError.stop()


    }
    else
       {
        //! Pull 2 Update Reset
        listView.contentY = 0
        updating.visible = false;
        refreshing = false;
        loadingSpacer = 0;
        updatingTimer.stop();
        loadingXML.stop()


        //! Stop loading Timer
        loadingContentErrorBubble.stop()
    }


}

//! pull2Update
//! Resets Pull2Update
//!
//! QML: All
function pull2UpdateReset(){
    //! Pull 2 Update Reset
    listView.contentY = 0
    updating.visible = false;
    refreshing = false;
    loadingSpacer = 0;
}

//! startIndicator
//! Stops Busy Indicators
//!
//! QML: All
function startIndicator(tab)
{
    //! Reset if Error
     errorItem.visible = false;

    //! Stop loading Timer
    loadingContentError.stop()

    //! Start Indicator
    if(firstTime == true)
    {   xmlIndicator.running = true;

        //! Disable Pull2update
        loaded = false;

        //! Start Error Timeout
         loadingContentError.start()

    }
    else
    {
        //! Pull 2 Update Txt
        updating.visible = true;
        refreshing = true;
        loadingSpacer = 52;
        updatingTimer.start()
        loadingXML.start()


        //! Start Error Timeout
        loadingContentErrorBubble.start()
    }

}

//! getFileName(url)
//! Gets the FileName from URL
//!
//! QML: MoviePage.qml and MovieDetails.qml
function getFileName(url) {

//this removes the anchor at the end, if there is one
url = url.substring(0, (url.indexOf("#") == -1) ? url.length : url.indexOf("#"));
//this removes the query after the file name, if there is one
url = url.substring(0, (url.indexOf("?") == -1) ? url.length : url.indexOf("?"));
//this removes everything before the last slash in the path
url = url.substring(url.lastIndexOf("/") + 1, url.length);
//return
return url;
}

//! dayName(date)
//! Returns the day name
//!
//! QML: MoviePage.qml and MovieDetails.qml
function dayName(date)
{

    var myDate=date;
    myDate=myDate.split("-");
    var newDate=myDate[1]+"/"+myDate[0]+"/"+myDate[2];
    var d = new Date(newDate).getDay();

    var weekday=new Array(7);
    weekday[0]="Sunday";
    weekday[1]="Monday";
    weekday[2]="Tuesday";
    weekday[3]="Wednesday";
    weekday[4]="Thursday";
    weekday[5]="Friday";
    weekday[6]="Saturday";

    var day = weekday[d];

    return day;
}

//! longDate(date)
//! Returns a long Date
//!
//! QML: MoviePage.qml and MovieDetails.qml
function longDate(date)
{

    var myDate=date;
    myDate=myDate.split("-");
    var newDate=myDate[1]+"/"+myDate[0]+"/"+myDate[2];
    var d = new Date(newDate).getDay();
    var m = new Date(newDate).getMonth();

    var month_names_short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var month = month_names_short[m];

    var weekday=new Array(7);
    weekday[0]="Sunday";
    weekday[1]="Monday";
    weekday[2]="Tuesday";
    weekday[3]="Wednesday";
    weekday[4]="Thursday";
    weekday[5]="Friday";
    weekday[6]="Saturday";

    var day = weekday[d];

    return day + ", " + month + ". " + myDate[0] + ", " + myDate[2];
}

//! checkTab
//! Shows the menu or back button
//!
//! QML: All
function checkTab(){

    if (tabGroup.currentTab == tab1)
    {

        if (tab1.depth >= 2)
           { menuIcon.source = "images/link.png"
            pageStackTab1 = 2
           }
        else
        {
            menuIcon.source = "images/icon-m-toolbar-view-menu-white-selected.png"
            pageStackTab1 = 1

        }
    }
    else
    {
        if (tab2.depth >= 2)
           { menuIcon.source = "images/link.png"
            pageStackTab2 = 2
           }
        else
        {
            menuIcon.source = "images/icon-m-toolbar-view-menu-white-selected.png"
            pageStackTab2 = 1

        }
    }

}

//! checkTabIcon
//! Actions for menu or back button
//!
//! QML: All
function checkTabIcon(){

    if (tabGroup.currentTab == tab1)
    {
        if (pageStackTab1 == 1)
            menu()
        else
        {

            //! Go Back
            tab1.pop()

        }
    }
    else
    {
        if (pageStackTab2 == 1)
            menu()
        else
           {

            if(refPage === "showtimes")
            {
              tabGroup.currentTab = tab1
              tab2.pop()
              refPage = ""
            }
            else
                tab2.pop()

        }
    }

}

//! menu
//! Shows Menu
//!
//! QML: MainPage.qml
function menu(){

    if(myMenu.status == DialogStatus.Closed)
        myMenu.open()
    else
        myMenu.close()
}

//! realMinutes(minutes)
//! Returns human friendly time in hours
//!
//! QML: MoviePage.qml and theater.qml
function realMinutes(minutes){
    var realmin = minutes % 60,
        hours = Math.floor(minutes / 60),
        tmp;

    if (hours >= 1)
    {
        tmp = hours + "hr.";

        if (realmin === 0 )
            return ", " + hours + " hr."
        else
            return ", " + hours + " hr. " + realmin + " min."

    }
    else
       {
        if (minutes)
            return ", " + minutes + " min."
        else
            return "";
    }

}

//! movieDay(date)
//! Returns weekday
//!
//! QML: MoviePage.qml
function movieDay(date)
{

    var myDate=date;
    myDate=myDate.split("-");
    var newDate=myDate[1]+"/"+myDate[0]+"/"+myDate[2];
    var d = new Date(newDate).getDay();

    var weekday=new Array(7);
    weekday[0]="Sunday";
    weekday[1]="Monday";
    weekday[2]="Tuesday";
    weekday[3]="Wednesday";
    weekday[4]="Thursday";
    weekday[5]="Friday";
    weekday[6]="Saturday";

    var day = weekday[d];

    return day;
}

//! movieDateDetail(date)
//! Returns the movie month
//!
//! QML: MoviePage.qml
function movieDateDetail(date)
{

    var myDate=date;
    myDate=myDate.split("-");
    var newDate=myDate[1]+"/"+myDate[0]+"/"+myDate[2];
    var m = new Date(newDate).getMonth();

    var month_names_short = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var month = month_names_short[m];

    return month + ". " + myDate[0];
}

//! switchList(id)
//! Switches movie list
//!
//! QML: MoviePage.qml
function switchList(id){
    errorItem.visible = false

    showingNav = false;
    hideNavPanel.start()

    if(movieId !== id){
    switch(id)
    {
    case 1:
        movieList.pageTitle = "New Release"
      break;
    case 4:
        movieList.pageTitle = "Coming Soon"
      break;
    default:
        movieList.pageTitle = "In Theaters"
    }


    movieId = id

    if(Storage.lastMovieTime(movieId) == undefined)
        metrics = true;
    else
        metrics = Storage.lastMovieTime(movieId);

    Core.checkXML("main",metrics)
    }

    //! Stop Loading
    stopIndicator();
}

//! adjustedHeight(date)
//! Adjustes Showtime Height (Portrait)
//!
//! QML: theater.qml & showtimes.qml
function adjustedHeight(showtimes)
{

    if (showtimes.length > 52)
    {


        var sFix;

        //! Fix for extra wording
        if(showtimes.indexOf("in") != -1)
            sFix = 90;
        else
            sFix = 110

        if (showtimes.length > sFix)
           {
            if (showtimes.length > (sFix+50))
               {
                return 47 + Math.ceil(showtimes.length/53)*29
               }
            else
             return 134;
           }
           else
            return 104;
    }
    else
        return 76;

}

//! adjustedHeight2(date)
//! Adjustes Showtime Height (Landscape)
//!
//! QML: theater.qml & showtimes.qml
function adjustedHeight2(showtimes)
{

    if (showtimes.length > 90)
     {
         if (showtimes.length > 180)
             return 134;
         else
             return 104;
     }
    else
        return 76;

}

//! updateVideoQuality(value)
//! Updates Video Quality
//!
//! QML: Settings.qml
function updateVideoQuality(value) {
    var item = new Array;

     //! Update Video Quality
     item.modified = new Date();
     item.id = 1
     item.quality = value;
     Storage.updateVideoQuality(item);
     strVideoQuality = value;
}

//! updateSendError(value)
//! Updates Send Error Value
//!
//! QML: Settings.qml
function updateSendError(value) {
    var item = new Array;

     //! Update SentError
     item.modified = new Date();
     item.id = 1
     item.error = value;
     Storage.updateSendError(item);
     strSendError = value;
}

//! updateLink(value)
//! Updates Link Value
//!
//! QML: Settings.qml
function updateLink(value) {
    var item = new Array;

     //! Update Link
     item.modified = new Date();
     item.id = 1
     item.link = value;
     Storage.updateLink(item);
     strLink = value;
}

//! sendError(vars)
//! Sends Error Msg
//!
//! QML: Settings.qml
function sendError(vars){
    var http = new XMLHttpRequest()
      var url = "http://popflix.dengineer.com/error.php";
      var params = vars;
      http.open("POST", url, true);

      // Send the proper header information along with the request
      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.setRequestHeader("Content-length", params.length);
      http.setRequestHeader("Connection", "close");
      http.send(params);

      http.onreadystatechange = function() { // Call a function when the state changes.
                  if (http.readyState == 4) {
                      if (http.status == 200) {
                          console.log("ok")
                      } else {
                          console.log("error: " + http.status)
                      }
                  }
              }


}
