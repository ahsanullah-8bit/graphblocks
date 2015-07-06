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
                property var input: ["mouseCoordX"]
                property var output: ["myValue"]
                property real myValue
                property real mouseCoordX: ma.mouseX
                visible: false
                width: 500
                height: 500
            }
            onClicked: gbw.visible = !gbw.visible
        }
    }
}
