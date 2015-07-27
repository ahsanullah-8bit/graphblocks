import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import FileIO 1.0

ApplicationWindow {
    title: qsTr("GraphBlocks")
    id: root
    property alias control: graphBlockControl

    ListModel {
        id: theBlocksModel
    }

    function importLibrary(name, lib) {
        if(typeof graphBlockControl.classMap === "undefined") {
            graphBlockControl.classMap = {};
        }
        var blocks = lib.children;
        for(var i=0 ; i < blocks.length ; ++i) {
            var cn = blocks[i].className?blocks[i].className:blocks[i].displayName;
            graphBlockControl.classMap[cn] = blocks[i];
            theBlocksModel.append(blocks[i]);
        }
    }

    function loadGraph(json, x, y) {
        graphBlockControl.loadGraph( json, {x:x, y:y} );
    }
    function loadGraphAsSuperblock(json, x, y) {
        graphBlockControl.loadGraphAsSuperblock( json, {x:x, y:y} );
    }
    function saveGraph(json, x, y) {
        return graphBlockControl.saveGraph();
    }
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
            graphBlockControl.loadGraph( JSON.parse( ser ), {x:0, y:0} );
        }
    }
    FileIO {
        id: openFile
        onError: console.log(msg)
    }
    GraphBlocksBasicLibrary {
        id: basicLib
    }
    Item {
        id: internalLib
        GraphBlocksSuperBlock {

        }
    }

    RowLayout {
        anchors.fill: parent

        GraphBlocksBlocksListView {
            id: graphBlockView
            Layout.fillHeight: true
            width: 100
            blocksModel: theBlocksModel
            Component.onCompleted: {
                importLibrary("basic", basicLib);
                importLibrary("internal", internalLib)
            }
        }
        GraphBlocksGraphControl {
            id: graphBlockControl
            Layout.fillHeight: true
            Layout.fillWidth: true
            blocksModel: theBlocksModel
        }
    }
}
