import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

ListView {
    id:root
    property var classMap
    Component.onCompleted: {
        root.classMap = {};
        var blocks = allTheBlockTemplates.children;
        for(var i=0 ; i < blocks.length ; ++i) {
            var cn = blocks[i].className?blocks[i].className:blocks[i].displayName;
            root.classMap[cn] = blocks[i];
            blocksModel.append(blocks[i]);
        }
    }

    ListModel {
        id: blocksModel
    }
    Item {
        id:allTheBlockTemplates
        Item {
            id: blockReal
            property string displayName: "Real"
            property string className: "real"
            property var compo: Component {
                TextField {
                    id: blockRealText
                    property var output: ["val"]
                    property var input: ["src"]
                    property alias val: blockRealText.src
                    property real src
                    property bool srcUpdate: false
                    validator: DoubleValidator {}
                    text: "0.0"
                    activeFocusOnPress: true
                    onTextChanged: {
                        if( srcUpdate ) return;
                        if(text == "") {
                            val = 0.0;
                        } else {
                            val = text;
                        }
                    }
                    onSrcChanged: {
                        srcUpdate = true;
                        text = src.toFixed(4);
                        srcUpdate = false;
                    }
                    function serialize() {
                        return {src: blockRealText.src};
                    }
                    style: TextFieldStyle {
                        textColor: "black"
                        background: Rectangle {
                            radius: 2
                            implicitWidth: 60
                            implicitHeight: 24
                            border.color: "#333"
                            border.width: 1
                        }
                    }
                    height: 40
                }
            }
        }
        Item {
            id: blockBool
            property string displayName: "Boolean"
            property var compo: Component {
                CheckBox {
                    id:boolBlockCb
                    property var output: ["checked"]
                    property var input: ["src"]
                    property bool src
                    checked: false
                    property bool srcUpdate: false
                    onSrcChanged: {
                        srcUpdate = true;
                        checked = src;
                        srcUpdate = false;
                    }
                    function serialize() {
                        return {checked: boolBlockCb.checked};
                    }
                    height: 30
                }
            }
        }
        Item {
            id: blockAdd
            property string displayName: "Add"
            property var compo: Component {
                Item {
                    property var input: ["op1", "op2"]
                    property var output: ["result"]
                    property real op1
                    property real op2
                    property real result: op1 + op2
                }
            }
        }
        Item {
            id: blockAlert
            property string displayName: "Alert"
            property var compo: Component {
                Text {
                    property var input: ["observed"]
                    property real observed
                    text: observed.toFixed(2)
                    height: 30
                }
            }
        }
        Item {
            id: blockChangingVal
            property string displayName: "SinusValue"
            property var compo: Component {
                Text {
                    property var output: ["result"]
                    property real result
                    SequentialAnimation on result {
                        running: true
                        loops: Animation.Infinite
                        PropertyAnimation { to: 1 }
                        PropertyAnimation { to: 0 }
                    }
                    text: result.toFixed(4)
                    height: 30
                }
            }
        }
        Item {
            id: valueSetBlock
            property string displayName: "Set Value"
            property string className: "SetValue"
            property var compo: Component {
                Item {
                    property var input: ["inp", "acti"]
                    property var output: ["outp"]
                    property var inp: 0.0
                    property var outp: 0.0
                    property var acti: function(){ outp = inp; }
                }
            }
        }
        Item {
            id: timerBlock
            property string displayName: "Timer"
            property var compo: Component {
                Timer {
                    property var input: ["interval", "running", "repeat"]
                    property var output: ["onTriggered"]
                    interval: 200
                    running: true
                    repeat: true
                }
            }
        }
        Item {
            id: ifBlockVal
            property string displayName: "IfVal"
            property var compo: Component {
                Item {
                    property var input: ["inp","condition"]
                    property var output: ["outp"]
                    property var inp
                    property var outp: inp
                    property bool condition: false
                    onInpChanged: trig()
                    onConditionChanged: trig()
                    function trig() {
                        if(condition) {
                            outp = inp;
                        }
                    }
                }
            }
        }
        Item {
            id: ifBlockSig
            property string displayName: "IfSig"
            property var compo: Component {
                Item {
                    property var input: ["inp","condition"]
                    property var output: ["outp"]
                    function inp() {
                        if(condition) {
                            outp();
                        }
                    }
                    signal outp();
                    property bool condition
                    onConditionChanged: inp()
                }
            }
        }
    }
    model: blocksModel
    delegate: Text {
        id:elem
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
