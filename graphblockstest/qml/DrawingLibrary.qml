import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Item {
    id: drawLib
    property var canvas;
    Item {
        id: drawCircle
        property string displayName: "Rectangle"
        property var compo: Component {
            Item {
                id: rectItem
                property var input: ["posX","posY", "radius", "rectWidth", "rectHeight", "rectZ"]
                property real posX
                property real posY
                property real radius
                property real rectWidth
                property real rectHeight
                property int rectZ
                Component.onCompleted: {
                    theRect.createObject(drawLib.canvas, {});
                }
                Component {
                    id: theRect
                    //property real posX: rectItem.posX
                    //property real posY: rectItem.posY
                    //property real radius: rectItem.radius
                    //property real width: rectItem.rectWidth
                    //property real height: rectItem.rectHeight
                    Rectangle {
                        x: rectItem.posX
                        y: rectItem.posY
                        radius: rectItem.radius
                        width: rectItem.rectWidth
                        height: rectItem.rectHeight
                        color: "blue"
                        z: rectItem.rectZ
                    }
                }
            }
        }
    }
    Item {
        id: calcALot
        property string displayName: "CalcALot"
        property var compo: Component {
            Item {
                id: rectItem
                property var input: ["one","two", "three"]
                property var output: ["four"]
                property real one
                property real two
                property real three
                property string four
                function execute() {
                    // has no bindings, but execute
                    console.log("Calcing a lot");
                    four = new Date().toLocaleTimeString();
                }
            }
        }
    }
}
