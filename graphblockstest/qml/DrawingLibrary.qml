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
                property var input: ["posX","posY", "radius", "width", "height"]
                property real posX
                property real posY
                property real radius
                property real width
                property real height
                Component.onCompleted: {
                    theRect.createObject(drawLib.canvas, {});
                }
                Component {
                    id: theRect
                    property real posX: rectItem.posX
                    property real posY: rectItem.posY
                    property real radius: rectItem.radius
                    property real width: rectItem.width
                    property real height: rectItem.height
                    Rectangle {
                        x: theRect.posX
                        y: theRect.posY
                        radius: theRect.radius
                        width: theRect.width
                        height: theRect.height
                        color: "blue"
                    }
                }
            }
        }
    }
}
