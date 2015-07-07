import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import "qrc:/theme/";

//TODO
Rectangle {
    id: root
    property ListModel optionsModel: ListModel {}

    signal createLink(var block)
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
            lv.forceActiveFocus();
        }
    }
    ListView {
        anchors.fill: parent
        clip: true
        Layout.fillWidth: true
        Layout.fillHeight: true
        id: lv
        model: optionsModel
        delegate: Text {
            text: displayName
            color: lv.currentIndex===index?"grey":"black"
        }
    }
}

