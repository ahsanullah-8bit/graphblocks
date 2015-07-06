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
    MouseArea {
        id:ma
        anchors.fill: parent
        hoverEnabled: true
    }
    ColumnLayout {
        anchors.fill: parent
        Button {
            text: gbw.myValue
            GraphBlocksWindow {
                id: gbw
                control.input: ["mouseCoordX", "mouseCoordY", "mouseCoordXRand"]
                control.output: ["myValue", "ballX", "ballY"]
                control.sourceElement: gbw
                property real myValue
                property real ballX
                property real ballY
                property real mouseCoordX: ma.mouseX
                property real mouseCoordY: ma.mouseY
                property real mouseCoordXRand: ma.mouseX + 100
                visible: false
                width: 800
                height: 500
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
        color: "green"
    }
}
