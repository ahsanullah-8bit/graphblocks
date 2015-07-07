import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import "qrc:/theme/";

Rectangle {
    id: root
    property string filterFieldName
    property alias blocksModel: lv.model
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
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.bottomMargin: 2
        TextField {
            Layout.fillWidth: true
            id: ff
            placeholderText: "filter..."

        }
        ListView {
            clip: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            id: lv
            delegate: Text {
                text: displayName
                color: "black"
                visible: {
                    var re = new RegExp(ff.text);
                    return displayName.match(re);
                }
            }
        }
    }
}

