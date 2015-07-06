import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import "qrc:/theme/";

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
                    height: 24
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
            property string displayName: "Add Real"
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
            id: blockLazyPassThrough
            property string displayName: "Lazy Pass"
            property var compo: Component {
                TextField {
                    id: textField
                    property bool lazyConnect: true
                    property real lazyInterval: 5000
                    property var lazyInputProps: ["inp"]
                    property var input: ["inp", "lazyInterval"]
                    property var output: ["outp"]
                    property var inp
                    property var outp: inp
                    height: 24
                    text: "5000"
                    onLazyIntervalChanged: text = lazyInterval;
                    onEditingFinished: lazyInterval = parseInt(text)
                    style: TextFieldStyle {
                        textColor: "black"
                        background: Rectangle {
                            radius: 2
                            implicitWidth: Math.max(20, inviText.width + 10)
                            implicitHeight: 24
                            border.color: "#333"
                            border.width: 1
                        }
                    }
                    Text {
                        id: inviText
                        visible: false
                        text: textField.text
                    }
                    function serialize() {
                        return {lazyInterval: textField.lazyInterval}
                    }
                }
            }
        }
        Item {
            id: blockAddGeneric
            property string displayName: "Add"
            property var compo: Component {
                Item {
                    property var input: ["op1", "op2"]
                    property var output: ["result"]
                    property var op1
                    property var op2
                    property var result: op1 + op2
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
            id: blockFire
            property string displayName: "Fire"
            property var compo: Component {
                Button {
                    property var input: ["fire"]
                    property var output: ["onFire"]
                    signal onFire()
                    text: "Fire"
                    function fire() { onFire(); }
                    onClicked: {
                        fire();
                    }
                }
            }
        }

        Item {
            id: blockString
            property string displayName: "String"
            property var compo: Component {
                TextField {
                    id: textField
                    property var input: ["text"]
                    property var output: ["text"]
                    height: 24
                    //width: Math.max(20, inviText.width + 10)
                    style: TextFieldStyle {
                        textColor: "black"
                        background: Rectangle {
                            radius: 2
                            implicitWidth: Math.max(20, inviText.width + 10)
                            implicitHeight: 24
                            border.color: "#333"
                            border.width: 1
                        }
                    }
                    Text {
                        id: inviText
                        visible: false
                        text: textField.text
                    }
                    function serialize() {
                        return {text: text}
                    }
                }
            }
        }

        Item {
            id: blockMessageBox
            property string displayName: "MessageBox"
            property var compo: Component {
                Item {
                    id: blockDialog
                    //Dialog must be wrapped, because it with and height is not meant to be used by block!
                    property var input: ["title", "text", "show"]
                    property var output: ["accepted", "discard", "dialogVisible"]
                    property alias text: dialogText.text
                    signal accepted()
                    signal discard()
                    property alias title: dialog.title
                    property alias dialogVisible: dialog.visible

                    property var clicks: []

                    function show() {
                        var secondsAgo = Date.now() - 15000;
                        var clicksSecondsAgo = 0;
                        for(var then in blockDialog.clicks) {
                            clicksSecondsAgo += blockDialog.clicks[then] > secondsAgo;
                        }
                        if(clicksSecondsAgo > 5) {
                            console.log("wait for dialog to open again");
                            return;
                        }
                        dialog.visible = true;
                    }
                    Text {
                        id: titleText
                        x: 0
                        y: 0
                        text: blockDialog.title
                        color: ColorTheme.blockTextColor
                    }
                    width: titleText.width
                    height: titleText.height
                    Dialog {
                        id: dialog
                        height: 30
                        standardButtons: StandardButton.Ok | StandardButton.Cancel
                        onAccepted: {
                            blockDialog.clicks.push(Date.now());
                            dialog.visible = false;
                            blockDialog.accepted();
                        }
                        onDiscard: {
                            blockDialog.clicks.push(Date.now());
                            dialog.visible = false;
                            blockDialog.discard();
                        }
                        ColumnLayout {
                            anchors.fill: parent
                            Text {
                                id:dialogText
                                text: "text"
                            }
                        }
                    }
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
                        PropertyAnimation { from: 0; to: 1; easing.type: Easing.SineCurve }
                        PropertyAnimation { from: 1; to: 0; easing.type: Easing.SineCurve }
                    }
                    text: result.toFixed(4)
                    height: 20
                    width: 50
                    color: ColorTheme.blockTextColor
                }
            }
        }
        Item {
            id: blockNow
            property string displayName: "Now"
            property string className: "NowTime"
            property var compo: Component {
                Text {
                    property var output: ["now"]
                    property real now

                    text: now
                    height: 20
                    width: 110
                    color: ColorTheme.blockTextColor
                    Timer {
                        running: true
                        interval: 10
                        repeat: true
                        onTriggered: now = Date.now();
                    }
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
                    property bool noInitialBind: true
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
