import QtQuick 2.0
import "qrc:/qml/theme/";

Canvas {
    id:canvas
    property var slot1
    property var slot2
    property var lineStart: slot1 ? parent.mapFromItem(slot1, slot1.width*0.5, slot1.height*0.5) : {}
    property var lineEnd: slot2 ? parent.mapFromItem(slot2, slot2.width*0.5, slot2.height*0.5) : {}
    property var disconnectionMethod
    property var slotFunc
    property var startSignal
    property var contextMenu
    property real clickThickness: 8 // resizes the element when it is perfectly horizontal/vertical
    property real clickThicknessDiagonal: 10 // used for diagonal lines (can be bigger)
    Item {
        id: priv
        property var points: []
    }
    //Todo: support "points" so graphs do not look so messy
//    function addPoint(var p) {
//        priv.points.push(p);
//        var newX = Math.min(lineStart.x, lineEnd.x);
//        x = Math.min
//    }

    x: Math.min(lineStart.x, lineEnd.x)-clickThickness;
    y: Math.min(lineStart.y, lineEnd.y)-clickThickness;
    z: 1
    width: Math.abs(lineEnd.x-lineStart.x)+clickThickness*2;
    height: Math.abs(lineEnd.y-lineStart.y)+clickThickness*2;
    onXChanged: requestPaint()
    onYChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    property var _oldSlot1
    property var _oldSlot2
    onSlot1Changed: setupBinding1()
    onSlot2Changed: setupBinding2()
    Component.onDestruction: {
        disconnectionMethod();

        if(slot1) {
            slot1.parent.parent.onXChanged.disconnect(redoStart);
            slot1.parent.parent.onYChanged.disconnect(redoStart);
            slot1.parent.parent.onWidthChanged.disconnect(redoStart);
            slot1.parent.parent.onHeightChanged.disconnect(redoStart);
        }
        if(slot2) {
            slot2.parent.parent.onXChanged.disconnect(redoEnd);
            slot2.parent.parent.onYChanged.disconnect(redoEnd);
            slot2.parent.parent.onWidthChanged.disconnect(redoStart);
            slot2.parent.parent.onHeightChanged.disconnect(redoStart);
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Delete) {
            destroy(0); //why delayed?
            event.accepted = true;
        }
    }

    function setupBinding1() {
        if(_oldSlot1) {
            _oldSlot1.parent.parent.onXChanged.disconnect(redoStart);
            _oldSlot1.parent.parent.onYChanged.disconnect(redoStart);
            _oldSlot1.parent.parent.onWidthChanged.disconnect(redoStart);
            _oldSlot1.parent.parent.onHeightChanged.disconnect(redoStart);
        }
        if(slot1) {
            slot1.parent.parent.onXChanged.connect(redoStart);
            slot1.parent.parent.onYChanged.connect(redoStart);
            slot1.parent.parent.onWidthChanged.connect(redoStart);
            slot1.parent.parent.onHeightChanged.connect(redoStart);
            _oldSlot1 = slot1;
        }
    }
    function setupBinding2() {
        if(_oldSlot2) {
            _oldSlot2.parent.parent.onXChanged.disconnect(redoEnd);
            _oldSlot2.parent.parent.onYChanged.disconnect(redoEnd);
            _oldSlot2.parent.parent.onWidthChanged.disconnect(redoEnd);
            _oldSlot2.parent.parent.onHeightChanged.disconnect(redoEnd);
        }
        if(slot2) {
            slot2.parent.parent.onXChanged.connect(redoEnd);
            slot2.parent.parent.onYChanged.connect(redoEnd);
            slot2.parent.parent.onWidthChanged.connect(redoEnd);
            slot2.parent.parent.onHeightChanged.connect(redoEnd);
            _oldSlot2 = slot2;
        }
    }

    function redoStart() {
        canvas.lineStart = getLineStart();
        requestPaint();
    }
    function redoEnd() {
        canvas.lineEnd = getLineEnd();
        requestPaint();
    }

    function getLineStart() {
        return slot1 ? parent.mapFromItem(slot1, slot1.width*0.5, slot1.height*0.5) : lineStart;
    }
    function getLineEnd() {
        return slot2 ? parent.mapFromItem(slot2, slot2.width*0.5, slot2.height*0.5) : lineEnd;
    }

    Component.onCompleted: {
        setupBinding1();
        setupBinding2();
    }
    onFocusChanged: requestPaint()

    onPaint: {
        var ctx = canvas.getContext('2d');
        ctx.clearRect(clickThickness, clickThickness, width-clickThickness*2, height-clickThickness*2);
        if( focus ) {
            ctx.strokeStyle = ColorTheme.connectionColorHighlight;// 'rgba(255,0,0,255)';
        } else {
            ctx.strokeStyle = ColorTheme.connectionColor;// 'rgba(255,255,0,255)';
        }
        //ctx.lineWidth = clickThickness;
        ctx.beginPath();
        ctx.moveTo(lineStart.x - x, lineStart.y - y);
        ctx.lineTo(lineEnd.x - x, lineEnd.y - y);
        ctx.closePath();
        ctx.stroke();
    }
    MouseArea {
        z: 700
        id: conMa
        anchors.fill: parent
        property bool isOver
        propagateComposedEvents: true
        function isOverCon(x, y) {
            var sx = lineStart.x - canvas.x;
            var sy = lineStart.y - canvas.y;
            var ex = lineEnd.x - canvas.x - sx;
            var ey = lineEnd.y - canvas.y - sy;
            var mx = x - sx;
            var my = y - sy;
            var len = Math.sqrt(ex*ex + ey*ey);
            var nx = ex/len;
            var ny = ey/len;
            var dot = nx*mx + ny*my;
            var ox = nx*dot - mx;
            var oy = ny*dot - my;
            var d = Math.sqrt(ox*ox + oy*oy);
            return d < clickThicknessDiagonal;
        }
        onClicked: {
            if(!conMa.isOverCon(mouse.x, mouse.y)) {
                mouse.accepted = false;
                return;
            }
            if (mouse.button === Qt.LeftButton) {
                parent.forceActiveFocus();
                mouse.accepted = true;
            }
            else if (mouse.button === Qt.RightButton) {
                var ctxPos = mapToItem(contextMenu.parent, mouse.x, mouse.y);
                contextMenu.showOptions( canvas, contextMenuOptions, ctxPos.x, ctxPos.y );
                mouse.accepted = true;
            }
        }
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        property var contextMenuOptions: [
            {
                name: "Create Shortcut",
                action: function( data ) { console.log("create shcut");}
            },
            {
                name: "Add Point",
                action: function( data ) { console.log("point added");}
            },
            {
                name: "Remove",
                action: function( data ) { console.log("connection removed");}
            }
        ]
    }
}
