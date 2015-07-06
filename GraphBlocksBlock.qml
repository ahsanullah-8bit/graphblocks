import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "qrc:/theme/";

Item {
    id: root
    //width: 160
    height: Math.max(20, Math.max((inner?inner.height?inner.height:0:0) + theLayout.height + 10, Math.max(inputHeight, outputHeight )))
    z: 100
    property real slotWidth: 10
    property var inner: []
    property string displayName
    property string className
    property real inputWidth: 0
    property real outputWidth: 0
    property real inputHeight: 10
    property real outputHeight: 10
    property real middleWidth: Math.max(middleWidthText.width + 10, inner?inner.width?inner.width:0:0) + 10
    width: Math.max(50, inputWidth + outputWidth + middleWidth + rootRect.anchors.leftMargin + rootRect.anchors.rightMargin)
    property int uniqueId
    default property alias parentForInner: parentForInnerElem
    property var slotsIn
    property var slotsOut
    property var connections
    property bool editable: true
    property bool isInputBlock: false
    property bool isOutputBlock: false
    function getSlot(propName, isInput) {
        if(isInput) {
            return slotsIn[propName];
        } else {
            return slotsOut[propName];
        }
    }
    Component.onCompleted: {
        slotsIn = {}; //Note: this must be executed before Repeater expands
        slotsOut = {};
        connections = [];
    }
    Component.onDestruction: {
        connections.forEach(function(con) {
            con.destroy();
        });
    }
    Keys.onPressed: {
        if (event.key === Qt.Key_Delete) {
            if(root.editable) {
                destroy();
                event.accepted = true;
            }
        }
    }

    Rectangle {
        id: rootRect
        anchors.rightMargin: root.slotWidth
        anchors.leftMargin:root.slotWidth
        anchors.fill: parent
        radius: ColorTheme.blockRadius
        border.color: root.focus?ColorTheme.blockBorderColorHighlight:(root.isInputBlock||root.isOutputBlock)?ColorTheme.inputOutputBlockBorderColor:ColorTheme.blockBorderColor
        border.width: 1 //+ 2*root.focus
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.isOutputBlock?ColorTheme.outputBlockColor1:root.isInputBlock?ColorTheme.inputBlockColor1:ColorTheme.blockColor1}//Qt.rgba(1.0,1.0,1.0,1.0) }
            GradientStop { position: 1.0; color: root.isOutputBlock?ColorTheme.outputBlockColor2:root.isInputBlock?ColorTheme.inputBlockColor2:ColorTheme.blockColor2}//Qt.rgba(0.9,0.9,0.95,1.0) }
        }
        Drag.dragType: Drag.Internal
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: root
            drag.minimumX: 0
            drag.maximumX: root.parent.width-root.width
            drag.minimumY: 0
            drag.maximumY: root.parent.height-root.height
            onDoubleClicked: if(inner.dialog) inner.dialog.visible = true;
            onClicked: root.forceActiveFocus();
            property bool activeDrop: drag.active
            onActiveDropChanged: forceActiveFocus()
        }
        Text {
            id: middleWidthText
            opacity: 0.0
            text: textFieldBlockDisplayName.text
            font.bold: true
        }

        ColumnLayout {
            property real myHeight: 0
            id: theLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            anchors.leftMargin: Math.max( 3, root.inputWidth - 5)
            anchors.rightMargin: root.outputWidth
            TextField {
                id:textFieldBlockDisplayName
                enabled: root.editable
                font.bold: true
                text: root.displayName
                style: TextFieldStyle {
                    textColor: (root.isInputBlock||root.isOutputBlock)?ColorTheme.inputOutputBlockTextColor:ColorTheme.blockTextColor
                    renderType: Text.QtRendering
                    background: Rectangle {
                        radius: 2
                        implicitWidth: middleWidthText.width + 10
                        implicitHeight: 24
                        border.color: "#333"
                        border.width: 1
                        opacity: Math.min(textFieldBlockDisplayName.hovered * 0.2 + textFieldBlockDisplayName.focus, 1.0)
                    }
                }
                onEditingFinished: root.displayName = text;
            }
//            onChildrenChanged: {
//                var h = 0;
//                for(var chi=0; chi < theLayout.children.length ; ++chi) {
//                    h += theLayout.children[chi].height;
//                }
//                myHeight = h;
//            }

            Text {
                id: classNameText
                visible: typeof root.inner != "object"
                color: "red"
                text: "Class:\n" + root.className
                font.capitalization: Font.SmallCaps
                font.pointSize: 8
            }
        }
        Item {
            id: parentForInnerElem
            anchors.top: theLayout.bottom
            anchors.left: parent.left
            anchors.leftMargin: Math.max( 3, root.inputWidth - 5)
        }
    }

    Item {
        z: 200
        id: toolTip
        property alias text: ttt.text
        property real totalHeight: toolTipBg.height + toolTipBg.anchors.topMargin + toolTipBg.anchors.bottomMargin
        Text {
            id: ttt
            color: ColorTheme.toolTipTextColor
            z: 200
        }
        Rectangle {
            id: toolTipBg
            anchors.fill: ttt
            anchors.margins: -5
            color: ColorTheme.toolTipBackgroundColor
            z: 199
            visible: ttt.text.length !== 0
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: rootRect.anchors.leftMargin
        Repeater {
            model: inner.input
            Rectangle {
                id: inSlot
                z: 10
                property bool isInput: true
                property bool isOutput: false
                property string propName: inner.input[index]
                property var block: inner
                property var blockOuter: root
                property alias lazyConnectTimer: theLazyConnectTimer
                height: 20
                color: "black"
                Layout.fillWidth: true
                Component.onCompleted: {
                    slotsIn[inner.input[index]] = inSlot;
                }
                Timer {
                    id: theLazyConnectTimer
                    repeat: false
                    property var lastConnect: -99999
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        toolTip.text = inSlot.propName;
                        toolTip.visible = true;
                    }
                    onExited: {
                        toolTip.visible = false;
                    }
                    acceptedButtons: "NoButton"
                    onMouseXChanged: repositionToolTip()
                    onMouseYChanged: repositionToolTip()
                    function repositionToolTip() {
                        var xy = mapToItem(toolTip.parent, mouseX, mouseY);
                        toolTip.x = xy.x;
                        toolTip.y = xy.y - toolTip.totalHeight - 10;
                    }
                }
            }
            onItemAdded: {
                root.inputHeight += 20 + 5;
            }
        }
    }
//    ColumnLayout {
//        anchors.left: rootRect.left
//        anchors.leftMargin: 2
//        anchors.top: rootRect.top
//        anchors.bottom: rootRect.bottom
//        width: root.inputWidth + 5
//        Repeater {
//            model: inner.input
//            Text {
//                anchors.leftMargin: 5
//                height: 20
//                color: "black"
//                Layout.fillWidth: true
//                text: inner.input[index]
//            }
//            onItemAdded: {
//                root.inputWidth = Math.max( 20, Math.max( root.inputWidth, item.implicitWidth));
//            }
//        }
//    }
    ColumnLayout {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: rootRect.anchors.rightMargin
        Repeater {
            model: inner.output
            Rectangle {
                id: outSlot
                z: 10
                property bool isInput: false
                property bool isOutput: true
                property string propName: inner.output[index]
                property var block: inner
                property var blockOuter: root
                height: 20
                color: "black"
                Layout.fillWidth: true
                Component.onCompleted: {
                    slotsOut[inner.output[index]] = outSlot;
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: "NoButton"
                    onEntered: {
                        toolTip.text = outSlot.propName;
                        toolTip.visible = true;
                    }
                    onExited: {
                        toolTip.visible = false;
                    }
                    onMouseXChanged: repositionToolTip()
                    onMouseYChanged: repositionToolTip()
                    function repositionToolTip() {
                        var xy = mapToItem(toolTip.parent, mouseX, mouseY);
                        toolTip.x = xy.x;
                        toolTip.y = xy.y - toolTip.totalHeight -  10;
                    }
                }
            }
            onItemAdded: {
                root.outputHeight += 20 + 5;
            }
        }
    }
//    ColumnLayout {
//        anchors.right: rootRect.right
//        anchors.rightMargin: 2
//        anchors.top: rootRect.top
//        anchors.bottom: rootRect.bottom
//        width: root.outputWidth
//        Repeater {
//            model: inner.output
//            Text {
//                anchors.leftMargin: 5
//                height: 20
//                color: "black"
//                Layout.fillWidth: true
//                text: inner.output[index]
//            }
//            onItemAdded: {
//                root.outputWidth = Math.max( 20, Math.max( root.outputWidth, item.implicitWidth));
//            }
//        }
//    }
}

