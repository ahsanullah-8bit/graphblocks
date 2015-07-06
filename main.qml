import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import FileIO 1.0

ApplicationWindow {
    title: qsTr("GraphBlocks")
    width: 640
    height: 480
    visible: true

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: qsTr("&Open")
                onTriggered: openFileDialog.open()
            }
            MenuItem {
                text: qsTr("&Save")
                onTriggered: saveFileDialog.open()
            }
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
    }
    FileDialog {
        id: saveFileDialog
        title: "Speichern"
        selectExisting: false
        selectFolder: false
        selectMultiple: false
        onAccepted: {
            var ser = graphBlockControl.saveGraph();
            saveFile.source = saveFileDialog.fileUrl;
            saveFile.write(JSON.stringify( ser ));
        }
        onRejected: {
        }
    }
    FileIO {
        id: saveFile
        onError: console.log(msg)
    }
    FileDialog {
        id: openFileDialog
        title: "Öffnen"
        selectExisting: true
        selectFolder: false
        selectMultiple: false
        onAccepted: {
            openFile.source = openFileDialog.fileUrl;
            loadTimer.start();
        }
        onRejected: {
        }
    }
    Timer {
        id:loadTimer
        interval: 1
        onTriggered: {
            // use timer for clear to run in the correct thread. Destroy did not work in a fileDialog's signal.
            var ser = openFile.read();
            //console.log( "file: " + ser );
            graphBlockControl.clear();
            graphBlockControl.loadGraph( JSON.parse( ser ), graphBlockView.classMap, {x:0, y:0} );
        }
    }
    FileIO {
        id: openFile
        onError: console.log(msg)
    }
    RowLayout {
        anchors.fill: parent
        GraphBlocksBlocksListView {
            id: graphBlockView
            Layout.fillHeight: true
            width: 100
        }
        GraphBlocksGraphControl {
            id: graphBlockControl
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
