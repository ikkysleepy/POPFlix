.pragma library

//! ----------------------------------------------------
//! UI Fonts & Colors
//!
//! version 0.7 11/9/2012 Initial Release
//!
//! ----------------------------------------------------

//! Font Familes
var FONT_FAMILY = "Menlo";

var live = false;

if (live == true )
{
    var FONT_XLARGE  = 47.693,
     FONT_LARGE   = 41.279,
     FONT_SLARGE  = 30.00,
     FONT_SDEFAULT = 27.00,
     FONT_LDEFAULT  = 23.888,
     FONT_DEFAULT = 20.00,
     FONT_LSMALL  = 19.167,
     FONT_SMALL   = 16.589,
     FONT_XSMALL  = 15.973,
     FONT_XXSMALL = 13.324,
     FONT_XXXSMALL = 12.520;

    var imagePath = "/home/user/popflix/cache/"

}
else{
    //! Font Sizes
    var FONT_XLARGE  = 47.693/3,
     FONT_LARGE   = 41.279/3,
     FONT_SLARGE  = 30.00/3,
     FONT_SDEFAULT = 27.00/3,
     FONT_LDEFAULT  = 23.888/3,
     FONT_DEFAULT = 20.00/3,
     FONT_LSMALL  = 19.167/3,
     FONT_SMALL   = 16.589/3,
     FONT_XSMALL  = 15.973/3,
     FONT_XXSMALL = 13.324/3,
     FONT_XXXSMALL = 12.520/3;

      var imagePath = "/Users/jorge/cache/";

}

//! Colors
var COLOR_FOREGROUND = "#000000", // Black
    COLOR_SECONDARY_FOREGROUND = "#505050", // Pull Color
    COLOR_MAIN_BACKGROUND = "#313131", // Grey One, Header
    COLOR_BACKGROUND = "#ffffff", // White
    COLOR_SECONDARY_BACKGROUND = "#bfbfbf", // Light Text
    COLOR_BORDER = "#414141",  // Grey Two, Header
    COLOR_SECONDARY_BORDER = "#e6e6e6";
