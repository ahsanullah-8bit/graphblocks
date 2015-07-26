import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import FileIO 1.0

ApplicationWindow {
    title: qsTr("GraphBlocksTest")
    width: 640
    height: 480
    visible: true
    id: drawingArea
    MouseArea {
        id:ma
        anchors.fill: parent
        hoverEnabled: true
    }
    ColumnLayout {
        Button {
            text: "[]--[]"
            GraphBlocksWindow {
                id: gbw
                control.input: ["mouseCoordX", "mouseCoordY"]
                control.output: ["ballX", "ballY"]
                control.sourceElement: gbw
                property real ballX
                property real ballY
                property real mouseCoordX: ma.mouseX
                property real mouseCoordY: ma.mouseY
                visible: false
                width: 800
                height: 500
                Component.onCompleted: {
                    gbw.importLibrary("Draw", drawLib);
                }
                DrawingLibrary {
                    id: drawLib
                    canvas: drawingArea
                }
            }
            onClicked: gbw.visible = !gbw.visible
        }
    }
    Rectangle {
        id: ball
        x: gbw.ballX
        y: gbw.ballY
        radius: 5
        width: 10
        height: 10
        color: "red"
    }
}
