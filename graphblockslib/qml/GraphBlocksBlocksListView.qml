import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "qrc:/qml/theme/";

ListView {
    id:root
    property var blocksModel

    model: blocksModel
    delegate: Text {
        id: elem
        text: displayName
        property string currentClassName
        renderType: Text.NativeRendering
        property Component myCompo: compo
        property bool dragActive: dragArea.drag.active
        property real dragStartX
        property real dragStartY
        onDragActiveChanged: {
            forceActiveFocus();
            if (dragActive) {
                dragStartX = x;
                dragStartY = y;
                var cn = className?className:displayName;
                currentClassName = cn;
                Drag.start();
            } else {
                Drag.drop();
                x = dragStartX;
                y = dragStartY;
            }
        }
        Drag.dragType: Drag.Internal
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
        }
    }
    z: 100
}
