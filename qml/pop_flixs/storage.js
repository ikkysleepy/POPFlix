.pragma library

var _db;

//! ----------------------------------------------------
//! Database Tables
//!
//! version 0.7 11/9/2012 Initial Release
//! version 0.10 11/24/2012 Added Video & Error functions
//!
//! ----------------------------------------------------

//! Open the Database
function openDB() {
    _db = openDatabaseSync("POPFlixDB","1.0","POP Flix Database",1000000);
    createGPSTable();
    createSettingsTable();
    checkSettings();
    //updateSettings_patch(); //! version 0.10
    //updateSettings_patch2(); //! version 0.11
    createMoviesTable();
    createTheatersTable();
    createTheaterTable();
    createShowtimesTable();
    createReviewsTable();
}

//! Create GPS Table
function createGPSTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS gps (id INTEGER PRIMARY KEY AUTOINCREMENT, lat INTEGER, lon INTEGER, near TEXT, modified DATE)");
  }
    )
}

//! Create Settings Table
function createSettingsTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS settings (id INTEGER PRIMARY KEY AUTOINCREMENT, animationCount INTEGER, animation INTEGER, country_id INTEGER, language_id INTEGER, quality TEXT, optout INTEGER, link INTEGER,  error INTEGER, modified DATE)");
  }
    )
}

//! Create Movies Table
function createMoviesTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS movies (id INTEGER PRIMARY KEY AUTOINCREMENT, movieId INTEGER, title TEXT,mpaa_rating TEXT,runtime INTEGER,critics_rating TEXT,critics_score INTEGER,audience_rating TEXT,audience_score INTEGER,critics_consensus TEXT,release_dates DATE,synopsis TEXT,reviews TEXT,new_release INTEGER,video TEXT,thumbnail TEXT,profile TEXT,detailed TEXT,type TEXT,abridged_cast_1 TEXT,abridged_cast_1_charactor TEXT,abridged_cast_2 TEXT,abridged_cast_2_charactor TEXT,abridged_cast_3 TEXT,abridged_cast_3_charactor TEXT,abridged_cast_4 TEXT,abridged_cast_4_charactor TEXT,abridged_cast_5 TEXT,abridged_cast_5_charactor TEXT, modified DATE)");
  }
    )
}

//! Create Theaters Table
function createTheatersTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS theaters (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, near TEXT, modified DATE)");
  }
    )
}

//! Create Theater Table
function createTheaterTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS theater (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, showtimes TEXT,  near TEXT, theaterTitle TEXT, modified DATE)");
  }
    )
}


//! Create Showtimes Table
function createShowtimesTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS showtimes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, showtimes TEXT,near TEXT, movieTitle TEXT, modified DATE)");
  }
    )
}


//! Create Reviews Table
function createReviewsTable(){
    _db.transaction(
  function(tx){
      tx.executeSql("CREATE TABLE IF NOT EXISTS reviews (id INTEGER PRIMARY KEY AUTOINCREMENT, movie TEXT, critic TEXT, date DATE, freshness TEXT,publication TEXT, quote TEXT, link TEXT, modified DATE)");
  }
    )
}

//! Check if Settings need patch
function updateSettings_patch2 (){
    _db.readTransaction(
  function(tx){
        try{
            //! Old Settings Table does not have quality field so test for hits
            tx.executeSql("select link from settings limit 1 ");
        }
        catch(e){
            updateSettings_patch_2();
        }


  })

}

//! Check if Settings need patch
function updateSettings_patch(){
    _db.readTransaction(
  function(tx){
        try{
            //! Old Settings Table does not have quality field so test for hits
            tx.executeSql("select error from settings limit 1 ");
        }
        catch(e){
            updateSettings_patch_1();
        }


  })

}

//! Update Patch to update Settings
function updateSettings_patch_2(){
    _db.transaction(
  function(tx){
        //! Rename Settings Table
        //! Create New Settings Table
        //! Copy old Settings Table with new default field values
        //! Delete old Settings Table
        tx.executeSql("ALTER TABLE settings RENAME TO TempOldTable2;");
        createSettingsTable();
        tx.executeSql('INSERT INTO settings (id, animationCount, animation, country_id, language_id, quality, optout, link, error, modified) SELECT id, animationCount, animation, country_id, language_id, quality, 0, 0, error, modified FROM TempOldTable2;')
        dropTable('TempOldTable2');
       })

}

//! Update Patch to update Settings
function updateSettings_patch_1(){
    _db.transaction(
  function(tx){
        //! Rename Settings Table
        //! Create New Settings Table
        //! Copy old Settings Table with new default field values
        //! Delete old Settings Table
        tx.executeSql("ALTER TABLE settings RENAME TO TempOldTable;");
        createSettingsTable();
        tx.executeSql('INSERT INTO settings (id, animationCount, animation, country_id, language_id, quality, cache, error, modified) SELECT id, animationCount, animation, countryid, 0, "360p", 0, 0, modified FROM TempOldTable;');
        dropTable('TempOldTable');
  })

}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Settings Functions
//! ----------------------------------------------------

//! Add Default Settings
function addSettings(){
    var defaultAnimationCount = 0,
     defaultAnimation = 1,
     defaultCountryId= 0,
     defaultLanguageId= 0,
     defaultQuality = "360p",
     defaultCache = 0,
     defaultError = 0,
     defaultModifiedDate = new Date();
    _db.transaction(
  function(tx){
    tx.executeSql("INSERT INTO settings (animationCount, animation, country_id, language_id, quality, cache,error, modified) VALUES(?,?,?,?,?,?,?,?)",[defaultAnimationCount, defaultAnimation, defaultCountryId, defaultLanguageId, defaultQuality, defaultCache,  defaultError, defaultModifiedDate]);
    }
)
}

//! Checks if Settings Table Exist
function checkSettings(){
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT * FROM settings");

      if (rs.rows.length === 0)
      {addSettings();}
  })
}

//! Get Country
//! QML: MainPage.qml
function getCountry()
{
    var data;
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT country_id FROM settings where id=1");

                     if(rs.rows.item(0)  !== undefined){
                        data = rs.rows.item(0).country_id;
                     }
                }
    )
    return data;
}

//! Get Link
//! QML: MainPage.qml
function getLink()
{
    var data;
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT link FROM settings where id=1");

                     if(rs.rows.item(0)  !== undefined){
                        data = rs.rows.item(0).link;
                     }
                }
    )
    return data;
}

//! Get Video Quality
//! QML: MainPage.qml
function getVideoQuality()
{
    var data;
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT quality FROM settings where id=1");

                     if(rs.rows.item(0)  !== undefined){
                        data = rs.rows.item(0).quality;
                     }
                }
    )
    return data;
}

//! Get Send Error
//! QML: MainPage.qml
function getSendError()
{
    var data;
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT error FROM settings where id=1");

                     if(rs.rows.item(0)  !== undefined){
                        data = rs.rows.item(0).error;
                     }
                }
    )
    return data;
}

//! Update Country
//! QML: Settings.qml
function updateCountry(settingsItem)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("UPDATE settings SET country_id = ?, modified = ?  \
                                  WHERE id = ?", [settingsItem.country_id, settingsItem.modified, settingsItem.id]);
                }
    )
}

//! Update Video Quality
//! QML: Settings.qml
function updateVideoQuality(settingsItem)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("UPDATE settings SET quality = ?, modified = ?  \
                                  WHERE id = ?", [settingsItem.quality, settingsItem.modified, settingsItem.id]);
                }
    )
}

//! Update Video Quality
//! QML: Settings.qml
function updateSendError(settingsItem)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("UPDATE settings SET error = ?, modified = ?  \
                                  WHERE id = ?", [settingsItem.error, settingsItem.modified, settingsItem.id]);
                }
    )
}

//! Update Link
//! QML: Settings.qml
function updateLink(settingsItem)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("UPDATE settings SET link = ?, modified = ?  \
                                  WHERE id = ?", [settingsItem.link, settingsItem.modified, settingsItem.id]);
                }
    )
}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Animation and General Functions
//! ----------------------------------------------------

//! Get Animation Count
//! QML: MainPage.qml
function countAnimation()
{
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT animationCount FROM settings where id=1");

if(rs.rows.item(0)  !== undefined){
   data = rs.rows.item(0).animationCount;
}
  }
    )
    return data;
}

//! Update Animation Count
//! QML: showtimes.qml and theater.qml
function updateAnimationCount(settingsItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("UPDATE settings SET animationCount = ?, modified = ?  \
      WHERE id = ?", [settingsItem.animationCount, settingsItem.modified, settingsItem.id]);
  }
    )
}

//! Last GPS Location
//! QML: ChangeLocation.qml
function lastLocation(){
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("select * from gps ORDER BY  Modified DESC limit 1");
      if(rs.rows.item(0)  !== undefined) data = rs.rows.item(0).near;
  }
    )
    return data;
}

//! Create GPS Location
//! QML: ChangeLocation.qml
function createLocation(gpsItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("INSERT INTO gps (lat, lon, near, modified) VALUES(?,?,?,?)",[gpsItem.lat, gpsItem.lon, gpsItem.near, gpsItem.modified]);
                }
    )
}

//! Drop Tabel
function dropTable(table)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DROP TABLE IF EXISTS " + table);
                }
    )
}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Movies
//! ----------------------------------------------------

//! Create MovieList
//! QML: storage.js
function createMovieList(movieItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("INSERT INTO movies (id,movieId,title,mpaa_rating,runtime,critics_rating,critics_score,audience_rating,audience_score,critics_consensus,release_dates,synopsis,reviews,new_release,video,thumbnail,profile,detailed,type,abridged_cast_1,abridged_cast_1_charactor,abridged_cast_2,abridged_cast_2_charactor,abridged_cast_3,abridged_cast_3_charactor,abridged_cast_4,abridged_cast_4_charactor,abridged_cast_5,abridged_cast_5_charactor, modified) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[movieItem.id,movieItem.movieId,movieItem.title,movieItem.mpaa_rating,movieItem.runtime,movieItem.critics_rating,movieItem.critics_score,movieItem.audience_rating,movieItem.audience_score,movieItem.critics_consensus,movieItem.release_dates,movieItem.synopsis,movieItem.reviews,movieItem.new_release,movieItem.video,movieItem.thumbnail,movieItem.profile,movieItem.detailed,movieItem.type,movieItem.abridged_cast_1,movieItem.abridged_cast_1_charactor,movieItem.abridged_cast_2,movieItem.abridged_cast_2_charactor,movieItem.abridged_cast_3,movieItem.abridged_cast_3_charactor,movieItem.abridged_cast_4,movieItem.abridged_cast_4_charactor,movieItem.abridged_cast_5,movieItem.abridged_cast_5_charactor,movieItem.modified]);
  }
    )
}

//! Read movies to Model
//! QML: MainPage.qml
function readMovies(model,movie)
{
   model.clear();

    if(!_db)openDB();
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT * FROM movies WHERE movieId="+movie);
                    for (var i=0; i< rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }

                }
                )
}

//! Read Movie
//! QML: theater.qml
function readMovie(movie)
{
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT * FROM movies WHERE title="+'"'+movie+'"'+" COLLATE NOCASE LIMIT 1");
                 data =  rs.rows.item(0);
                }
                )
    return data;

}

//! Drop Movies (movieId)
//! QML: MainPage.qml
function dropMovies(movie)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DELETE FROM movies WHERE movieId="+movie);
                }
    )
}

//! Drop All Movies
//! QML: Not Used
function dropAllMovies()
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DROP TABLE IF EXISTS movies");
                }
    )
}

//! Last Movie Time
//! QML: MoviePage
function lastMovieTime(movie){
    var data;
    _db.readTransaction(
  function(tx){
        var rs = tx.executeSql("SELECT strftime('%d', modified) as date_modified FROM movies WHERE movieId="+movie+" ORDER BY id desc LIMIT 1");

          // Calculate the difference in milliseconds
          if(rs.rows.item(0)  !== undefined){
          var date1 = new Date().getDate();
          var date2 = rs.rows.item(0).date_modified;
          var difference = Math.abs(date1-date2)

          //! Check if Difference is more than a day
          if(difference >= 1) data = true; else data = false;
      }

  }
    )
    return data;
}

//! Get movie url
//! QML: theater.qml
function movieURL(movie){
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT video FROM movies WHERE title="+'"'+movie+'"'+" LIMIT 1");

      // Calculate the difference in milliseconds
      if(rs.rows.item(0)  !== undefined){

          data = rs.rows.item(0).video
      }

  }
    )
    return data;
}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Theaters
//! ----------------------------------------------------
function createTheatersList(theatersItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("INSERT INTO theaters (name,address,near,modified) VALUES(?,?,?,?)",[theatersItem.name,theatersItem.address,theatersItem.near,theatersItem.modified]);
  }
    )
}

//! Read Theaters to Model
//! QML: theaters.qml
function checkTheaters(near){
    var data;
    _db.readTransaction(
  function(tx){
          var rs = tx.executeSql("SELECT * FROM theaters WHERE near  = '"+near+"' LIMIT 1");
          // Calculate the difference in milliseconds
          if(rs.rows.item(0)  !== undefined){

          // Diff in Minutes
          data = false;
      }

  }
    )
    return data;

}

//! Read Theaters to Model
//! QML: theaters.qml
function readTheaters(model,near)
{
   model.clear();

    if(!_db)openDB();
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT * FROM theaters WHERE near ='"+near+"'");
                    for (var i=0; i< rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }

                }
                )
}

//! Drop Theaters (near)
//! QML: theaters.qml
function dropTheaters(near)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DELETE FROM theaters WHERE near='"+near+"'");
                }
    )
}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Theaters
//! ----------------------------------------------------
function createTheaterList(theaterItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("INSERT INTO theater (name,showtimes,near,theaterTitle,modified) VALUES(?,?,?,?,?)",[theaterItem.name,theaterItem.showtimes,theaterItem.near,theaterItem.theaterTitle,theaterItem.modified]);
  }
    )
}

//! Drop Theater (near, theater)
//! QML: MainPage.qml
function dropTheater(near, theater)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DELETE FROM theater WHERE near='"+near+"' AND theaterTitle='"+theater+"'");
                }
    )
}

//! Last Movie Time
//! QML: theater.qml
function lastTheaterTime(near,theater){
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT strftime('%d', modified) as date_modified FROM theater WHERE near='"+near+"' AND theaterTitle='"+theater+"' ORDER BY id desc LIMIT 1");

      // Calculate the difference in milliseconds
      if(rs.rows.item(0)  !== undefined){
      var date1 = new Date().getDate();
      var date2 = rs.rows.item(0).date_modified;
      var difference = Math.abs(date1-date2)

      //! Check if Difference is more than a day
      if(difference >= 1) data = true; else data = false;
      }

  }
    )
    return data;
}

//! Read Theaters to Model
//! QML: theaters.qml
function readTheater(model,near, theater)
{
   model.clear();

    if(!_db)openDB();
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT * FROM theater WHERE near ='"+near+"' AND theaterTitle='"+theater+"'");
                    for (var i=0; i< rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }

                }
                )
}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Showtimes
//! ----------------------------------------------------
function createShowtimesList(theaterItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("INSERT INTO showtimes (name,address,showtimes,near,movieTitle,modified) VALUES(?,?,?,?,?,?)",[theaterItem.name,theaterItem.address,theaterItem.showtimes,theaterItem.near,theaterItem.movieTitle,theaterItem.modified]);
  }
    )
}

//! Drop Theater (near, theater)
//! QML: MainPage.qml
function dropShowtimes(near, movie)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DELETE FROM showtimes WHERE near="+'"'+near+'"'+" AND movieTitle="+'"'+movie+'"');
                }
    )
}

//! Last Movie Time
//! QML: showtimes.qml
function lastShowtimesTime(near,movie){
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT strftime('%d', modified) as date_modified FROM showtimes WHERE near="+ '"'+near+'"'+" AND movieTitle="+'"'+movie+'"'+" ORDER BY id desc LIMIT 1");

      // Calculate the difference in milliseconds
      if(rs.rows.item(0)  !== undefined){
      var date1 = new Date().getDate();
      var date2 = rs.rows.item(0).date_modified;
      var difference = Math.abs(date1-date2)

      //! Check if Difference is more than a day
      if(difference >= 1) data = true; else data = false
      }

  }
    )
    return data;
}

//! Read Theaters to Model
//! QML: Theaters.qml
function readShowtimes(model,near, movie)
{
   model.clear();

    if(!_db)openDB();
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT * FROM showtimes WHERE near ="+'"'+near+'"'+" AND movieTitle="+'"'+movie+'"');
                    for (var i=0; i< rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }

                }
                )
}
//! ----------------------------------------------------


//! ----------------------------------------------------
//! Reviews
//! ----------------------------------------------------
function createReviewsList(ReviewItem)
{
    _db.transaction(
  function(tx){
      tx.executeSql("INSERT INTO reviews ( movie, critic, date,freshness,publication, quote,link, modified ) VALUES(?,?,?,?,?,?,?,?)",[ ReviewItem.movie, ReviewItem.critic, ReviewItem.date,ReviewItem.freshness,ReviewItem.publication, ReviewItem.quote,ReviewItem.link, ReviewItem.modified]);

       }
    )
}

//! Drop Reviews (movie)
//! QML: Reviews.qml
function dropReviews(movie)
{
    _db.transaction(
                function(tx){
                    tx.executeSql("DELETE FROM reviews WHERE movie='"+movie+"'");
                }
    )
}

//! Last Movie Time
//! QML: reviews.qml
function lastReviewTime(movie, newRelease){
    var data;
    _db.readTransaction(
  function(tx){
      var rs = tx.executeSql("SELECT strftime('%d', modified) as date_modified FROM reviews WHERE movie='"+movie+"' ORDER BY id desc LIMIT 1");

      // Calculate the difference in milliseconds
      if(rs.rows.item(0)  !== undefined){
      var date1 = new Date().getDate();
      var date2 = rs.rows.item(0).date_modified;
      var difference = Math.abs(date1-date2)


          //! Check if Difference is more than a day, and not yet released
          if (newRelease == true)
            {
              if(difference >=1) data = true; else data = false;
            }
          else
              if(difference >=1 & difference <=7) data = true; else data = false;

      }

  }
    )
    return data;
}

//! Read Reviews to Model
//! QML: reviews.qml
function readReviews(model,movie)
{
   model.clear();

    if(!_db)openDB();
    _db.readTransaction(
                function(tx){
                    var rs = tx.executeSql("SELECT * FROM reviews WHERE movie ='"+movie+"'");
                    for (var i=0; i< rs.rows.length; i++) {
                        model.append(rs.rows.item(i))
                    }

                }
                )
}
//! ----------------------------------------------------

