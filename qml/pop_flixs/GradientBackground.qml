// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

/*!
 * @brief Page Gradient
 *
 * version 0.7 11/9/2012 Initial Release
 */
Rectangle {
    width: pageWidth;
    height: pageHeight

   gradient: Gradient {
        GradientStop { position: 0.0; color: "#000000" }
        GradientStop { position: 0.25; color: "#050506" }
        GradientStop { position: 0.40; color: "#0d0d0d" }
        GradientStop { position: 0.55; color: "#161616" }
        GradientStop { position: 0.70; color: "#1f2020" }
        GradientStop { position: 0.85; color: "#272728" }
        GradientStop { position: 1.0; color: "#2b2c2b" }

    }
}
