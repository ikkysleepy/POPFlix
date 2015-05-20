/**
 * Copyright (c) 2012 Nokia Corporation.
 */

import QtQuick 1.1
import "util.js" as Util

Item {
    id: videoInformationView

    property string videoTitle: ""
    property int numLikes: 0
    property int numDislikes: 0
    property int viewCount: 0

    // Prepends forward zeros to a text (e.g. 41 -> 0041)
    function __prependToLength(text, len, fill) {
        text = text.toString();
        fill = fill.toString();
        var diff = len - text.length;

        for (var index = 0; index < diff; index++) {
            text = fill.concat(text);
        }

        return text;
    }

    anchors.margins: visual.informationViewMargins

    // Bundle each text label & image as a pair.
    Item {
        id: views

        height: childrenRect.height
        width: childrenRect.width
        anchors {
            top: parent.top
            topMargin: visual.inPortrait ? visual.margins * 10 : 0
            horizontalCenter: parent.horizontalCenter
        }

        VideoInfoTextLabel {
            id: viewCount
            // The forward zeros aren't prepended at the time being.
            //text: videoInformationView.__prependToLength(videoInformationView.viewCount, 4, 0)
            text: videoInformationView.viewCount
            font.pixelSize: visual.ultraLargeFontSize
        }

        VideoInfoTextLabel {
            anchors {
                top: viewCount.bottom
                horizontalCenter: visual.inPortrait ? viewCount.horizontalCenter : undefined
                left: visual.inPortrait ? undefined : viewCount.left
            }
            text: qsTr("views")
        }
    }

    Loader {
        id: likesAndDislikesLoader

        width: parent.width
        anchors {
            top: views.bottom
            topMargin: visual.margins * 2
            horizontalCenter: visual.inPortrait ? parent.horizontalCenter : undefined
            left: visual.inPortrait ? undefined : views.left
        }

        sourceComponent: visual.inPortrait ? likesAndDislikes : likesAndDislikesLS
    }

    Component {
        id: likesAndDislikes

        // Item bundling the likes & dislikes amounts + strings together.
        Item {
            // Two Text elements on top of each other,
            // amount of likes + "likes" string.
            VideoInfoTextLabel {
                id: likesCount

                anchors.left: parent.left
                font.pixelSize: visual.extraLargeFontSize
                // The forward zeros aren't prepended at the time being.
                //text: videoInformationView.__prependToLength(videoInformationView.numLikes, 4, 0)
                text: videoInformationView.numLikes
            }
            VideoInfoTextLabel {
                id: likesLabel

                anchors {
                    top: likesCount.bottom
                    horizontalCenter: likesCount.horizontalCenter
                }
                text: qsTr("likes")
            }

            // Two Text elements on top of each other,
            // amount of dislikes + "dislikes" string.
            VideoInfoTextLabel {
                id: dislikesCount

                anchors {
                    right: parent.right
                    rightMargin: visual.margins
                }
                font.pixelSize: visual.extraLargeFontSize
                // The forward zeros aren't prepended at the time being.
                //text: videoInformationView.__prependToLength(videoInformationView.numDislikes, 4, 0)
                text: videoInformationView.numDislikes
            }
            VideoInfoTextLabel {
                id: dislikesLabel

                anchors {
                    horizontalCenter: dislikesCount.horizontalCenter
                    top: dislikesCount.bottom
                }
                text: qsTr("dislikes")
            }
        }
    }

    Component {
        id: likesAndDislikesLS

        // Item bundling the likes & dislikes amounts + strings together.
        Item {
            // Two Text elements on top of each other,
            // amount of likes + "likes" string.
            VideoInfoTextLabel {
                id: likesCount

                //anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                font.pixelSize: visual.extraLargeFontSize
                // The forward zeros aren't prepended at the time being.
                //text: videoInformationView.__prependToLength(videoInformationView.numLikes, 4, 0)
                text: videoInformationView.numLikes
            }
            VideoInfoTextLabel {
                id: likesLabel

                anchors {
                    top: likesCount.bottom
                    //horizontalCenter: likesCount.horizontalCenter
                    left: likesCount.left
                }
                text: qsTr("likes")
            }

            // Two Text elements on top of each other,
            // amount of dislikes + "dislikes" string.
            VideoInfoTextLabel {
                id: dislikesCount

                anchors {
                    //horizontalCenter: parent.horizontalCenter
                    left: parent.left
                    top: likesLabel.bottom
                    topMargin: visual.margins
                }
                font.pixelSize: visual.extraLargeFontSize
                // The forward zeros aren't prepended at the time being.
                //text: videoInformationView.__prependToLength(videoInformationView.numDislikes, 4, 0)
                text: videoInformationView.numDislikes
            }
            VideoInfoTextLabel {
                id: dislikesLabel

                anchors {
                    //horizontalCenter: dislikesCount.horizontalCenter
                    left: dislikesCount.left
                    top: dislikesCount.bottom
                }
                text: qsTr("dislikes")
            }
        }
    }
}
