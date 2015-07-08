import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import "qrc:/theme/";

Item {
    id: root
    property var options
    onXChanged: reinit()
    onYChanged: reinit()
    onVisibleChanged: reinit()
    height: lv.height
    Rectangle {
        z:800
        anchors.fill: parent
        border.width: 1
        border.color: ColorTheme.contextMenuBorder
        gradient: Gradient {
            GradientStop { position: 0.0; color: ColorTheme.contextMenu1}
            GradientStop { position: 1.0; color: ColorTheme.contextMenu2}
        }
    }
    function reinit() {
        if(visible) {
            lv.forceActiveFocus();
        }
        lv.model.clear();
        for( var i in options) {
            if(options.hasOwnProperty(i)) {
                lv.model.append(options[i]);
            }
        }
    }
    ListView {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: model.count * 20
        id: lv
        z:900
        clip: true
        model: ListModel {}
        delegate: Text {
            text: name
            color: lv.currentIndex===index?"grey":"black"
        }
    }
}
