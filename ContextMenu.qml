import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import "qrc:/theme/";

Rectangle {
    id: root
    property string filterFieldName
    property ListModel blocksModel <-todo: single model!

    property ListModel filteredModel: ListModel {}
    property alias selection: lv.currentItem
    property var classMap
    border.width: 1
    border.color: ColorTheme.contextMenuBorder
    gradient: Gradient {
        GradientStop { position: 0.0; color: ColorTheme.contextMenu1}
        GradientStop { position: 1.0; color: ColorTheme.contextMenu2}
    }
    onXChanged: reinit()
    onYChanged: reinit()
    onVisibleChanged: reinit()
    function reinit() {
        if(visible) {
            ff.text = "";
            ff.forceActiveFocus();
        }
        filteredModel.clear();
        for(var i; i<root.blocksModel.count ; ++i) {
            filteredModel.append(blocksModel.get(i));
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: 2
        TextField {
            Layout.fillWidth: true
            id: ff
            placeholderText: "filter..."
            onTextChanged: {
                filteredModel.clear();
                var re = new RegExp(ff.text);
                for(var i; i<blocksModel.count ; ++i) {
                    var block = blocksModel.get(i);
                    if(block.displayName.match(re)) {
                        filteredModel.append(block);
                    }
                }
            }
        }
        ListView {
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            id: lv
            model: filteredModel
            delegate: Text {
                text: displayName
                color: "black"
//                visible: {
//                    var re = new RegExp(ff.text);
//                    return displayName.match(re);
//                }
            }
        }
    }
}

