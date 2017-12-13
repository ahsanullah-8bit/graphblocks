import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import FileIO 1.0
import Library 1.0
import Clipboard 1.0

ApplicationWindow {
    title: qsTr("GraphBlocks")
    id: root
    property alias control: graphBlockControl
    property bool isEditingSuperblock: false

    property var superblockToControl

    Component.onCompleted: {
        superblockToControl = {};
        var ser = Library.loadLibs();
        var libs = JSON.parse( ser );
        for(var lib in libs) {
            graphBlockControl.importLibrary(libs[lib].name, libs[lib].entries);
        }
    }
    //// TODO: make private ////
    function createSuperblockControl( superblock ) {
        var superblockcontrol = superBlockControlCompo.createObject(controlParent, { input: superblock.input, output: superblock.output, sourceElement: superblock, classMap: root.control.classMap });
        if( superblock.json ) {
            superblockcontrol.loadGraph( superblock.json );
        }
        superblockToControl[ superblock ] = superblockcontrol;
    }
    function removeSuperblockControl( superblock ) {
        delete superblockToControl[ superblock ];
    }

    function serializeSuperblock( superblock ) {
        return superblockToControl[ superblock ].saveGraph();
    }
    function showSuperBlockControl( superblock ) {
        if(superblockToControl[ superblock ]) {
            superblockToControl[ superblock ].visible = true;
        } else {
            console.log("superblock had not been initialized");
            createSuperBlockControl( superblock );
        }
    }
    ////////

    function importLibrary(name, lib) {
        graphBlockControl.importLibrary(name, lib)
    }

    function loadGraph(json, x, y) {
        controlParent.children = "";
        superblockToControl = {};
        graphBlockControl.loadGraph( json, x, y );
    }
    function loadGraphAsSuperblock(json, x, y) {
        graphBlockControl.loadGraphAsSuperblock( json, {x:x, y:y} );
    }
    function saveGraph() {
        var json = graphBlockControl.saveGraph();
        return json;
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
                text: qsTr("C&lear")
                onTriggered: graphBlockControl.clear()
            }
            MenuItem {
                text: qsTr("E&xit")
                onTriggered: Qt.quit();
            }
        }
        Menu {
            title: qsTr("&Edit")
            MenuItem {
                text: qsTr("&Copy")
                onTriggered: console.log("not yet implemented. use crtl+c.");
            }
            MenuItem {
                text: qsTr("&Paste")
                onTriggered: {
                    var cbdata = Clipboard.text;
                    if( cbdata === "") return;
                    var blocks = JSON.parse( cbdata );
                    control.loadGraph( blocks, control.viewPositionX, control.viewPositionY);
                }
            }
            MenuSeparator { }
            MenuItem {
                id: manualModeItem
                text: qsTr("&Manual Mode")
                checkable: true
                checked: control.manualMode
                onCheckedChanged: {
                    control.manualMode = checked;
                    manualModeCheckBox.checked = checked;
                }
            }
            MenuItem {
                id: executeItem
                text: qsTr("E&xecute")
                enabled: control.manualMode
                onTriggered: control.execute();
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
            graphBlockControl.loadGraph( JSON.parse( ser ), 0, 0 );
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
            controlManager: root
        }
    }

    RowLayout {
        anchors.fill: parent

        GraphBlocksBlocksListView {
            id: graphBlockView
            Layout.fillHeight: true
            width: 100
            blocksModel: graphBlockControl.blocksModel
            Component.onCompleted: {
                graphBlockControl.importLibrary("basic", basicLib);
                graphBlockControl.importLibrary("internal", internalLib)
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                Button {
                    text: "Execute"
                    onClicked: executeItem.trigger();
                    enabled: executeItem.enabled
                }
                CheckBox {
                    id: manualModeCheckBox
                    text: "Manual Mode"
                    checked: control.manualMode
                    onCheckedChanged: {
                        control.manualMode = checked;
                        manualModeItem.checked = checked;
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                GraphBlocksGraphControl {
                    id: graphBlockControl
                    anchors.fill: parent
                    isEditingSuperblock: root.isEditingSuperblock
                }
                Item {
                    id: controlParent
                    anchors.fill: parent
                }
            }
        }
    }
    Component {
        id: superBlockControlCompo
        GraphBlocksGraphControl {
            anchors.fill: parent
            blocksModel: graphBlockControl.blocksModel //TODO: if this does not work, give via prototype
            isEditingSuperblock: true
            visible: false
        }
    }
}
