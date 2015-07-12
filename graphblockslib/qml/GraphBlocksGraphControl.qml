import QtQuick 2.0
import "qrc:/qml/theme/";

Item {
    id: root
    z: -100

    property var input
    property var output

    property var sourceElement: root

    property var ioBlocks

    property var classMap
    property alias blocksModel: ctxMenu.blocksModel
    //property ListModel blocksModel: ListModel { }

    property Component blockComponent: Qt.createComponent("GraphBlocksBlock.qml")
    property Component connectionComponent: Qt.createComponent("GraphBlocksConnection.qml")
    property int nextUniqueId: 0
    function clear() {
        for(var l= 0 ; l < parentForConnections.children.length ; ++l) {
            parentForConnections.children[l].destroy();
        }
        for(var i= 0 ; i < parentForBlocks.children.length ; ++i) {
            if(!parentForBlocks.children[i].isInputBlock && !parentForBlocks.children[i].isOutputBlock) {
                parentForBlocks.children[i].destroy();
            }
        }
    }
    function saveGraph() {
        var objToSerialize = {blocks:[], connections:[]};
        for(var i= 0 ; i < parentForBlocks.children.length ; ++i) {
            var block = parentForBlocks.children[i];
            var serializedInner = block.inner.serialize?block.inner.serialize():{/*maybeTodo*/};
            var serializedBlock = {
                blockProto: {
                    x:block.x,
                    y:block.y,
                    displayName: block.displayName,
                    className: block.className?block.className:block.displayName,
                    uniqueId: block.uniqueId,
                    isInputBlock: block.isInputBlock,
                    isOutputBlock: block.isOutputBlock},
                innerProto: serializedInner};
            objToSerialize.blocks.push( serializedBlock );
        }
        for(var l= 0 ; l < parentForConnections.children.length ; ++l) {
            var connection = parentForConnections.children[l];
            var serializedConnection = {
                s1: connection.slot1.blockOuter.uniqueId,
                pn1: connection.slot1.propName,
                s1Inp: connection.slot1.isInput,
                s2: connection.slot2.blockOuter.uniqueId,
                pn2: connection.slot2.propName};
            objToSerialize.connections.push( serializedConnection );
        }
        //console.log(JSON.stringify( objToSerialize ));
        return objToSerialize;
    }
    Component {
        id: dynamicBlockInpCompo
        Item {
            property var output: ["outp"]
            property var outp
        }
    }
    Component {
        id: dynamicBlockOutpCompo
        Item {
            property var input: ["inp"]
            property var inp
        }
    }
    property real nextInY: 100
    property real nextOutY: 100
    function createDynamicInputBlock(displayName, setupInner) {
        createDynamicBlock(dynamicBlockInpCompo, {x: 100, y: nextInY, displayName: "in_"+displayName, editable: false, isInputBlock: true}, setupInner);
        nextInY += 50;
    }
    function createDynamicOutputBlock(displayName, setupInner) {
        createDynamicBlock(dynamicBlockOutpCompo, {x: 400, y: nextOutY, displayName: "out_"+displayName, editable: false, isOutputBlock: true}, setupInner);
        nextOutY += 50;
    }
    function createDynamicBlock(dynamicBlockCompo, proto, setupInner) {
        var newBlock = root.blockComponent.createObject(parentForBlocks, proto);
        newBlock.uniqueId += nextUniqueId;
        nextUniqueId++;
        var newBlockInner = dynamicBlockCompo.createObject(newBlock.parentForInner, {});
        setupInner(newBlockInner);
        newBlock.inner = newBlockInner;
        ioBlocks[newBlock.displayName] = newBlock;
    }

    function loadGraph(obj, offset) {
        var startUniqueId = nextUniqueId;
        var blocks = obj.blocks;
        var connections = obj.connections;
        var savedUniqueIdToBlock = [];
        for(var i= 0 ; i < blocks.length ; ++i) {
            var serBlock = blocks[i];
            if(serBlock.blockProto.isInputBlock || serBlock.blockProto.isOutputBlock) {
                var ioBlock = ioBlocks[serBlock.blockProto.displayName];
                savedUniqueIdToBlock[serBlock.blockProto.uniqueId] = ioBlock;
                ioBlock.x = serBlock.blockProto.x;
                ioBlock.y = serBlock.blockProto.y;
                continue;
            }

            var newBlock = root.blockComponent.createObject(parentForBlocks, serBlock.blockProto);
            newBlock.uniqueId += startUniqueId;
            nextUniqueId = Math.max(nextUniqueId, newBlock.uniqueId);
            var compo = root.classMap[blocks[i].blockProto.className];
            if(!compo) {
                console.log("ERROR: graph could not be loaded due to unknown block type: \"" + blocks[i].blockProto.className + "\"");
                newBlock.inner = "ERROR";
                console.log("loaded blocktypes:");
                for(var nam in root.classMap) {
                    console.log(nam);
                }
            } else {
                var newBlockInner = compo.compo.createObject(newBlock.parentForInner, serBlock.innerProto);
                newBlock.inner = newBlockInner;
            }
            savedUniqueIdToBlock[serBlock.blockProto.uniqueId] = newBlock;
        }
        nextUniqueId++;
        for(var l= 0 ; l < connections.length ; ++l) {
            var connection = connections[l];
            var b1 = savedUniqueIdToBlock[connection.s1];
            var b2 = savedUniqueIdToBlock[connection.s2];
            var s1 = b1.getSlot(connection.pn1, connection.s1Inp);
            var s2 = b2.getSlot(connection.pn2, !connection.s1Inp);
            fullScreenMouseArea.createConnection(s1, s2);
        }
    }
    function loadGraphAsSuperblock(obj, offset) {

    }
    Component.onCompleted: {
        if( blockComponent.status != Component.Ready )
        {
            if( blockComponent.status == Component.Error )
                console.debug("Error: "+ blockComponent.errorString() );
        }
        if( connectionComponent.status != Component.Ready )
        {
            if( connectionComponent.status == Component.Error )
                console.debug("Error: "+ connectionComponent.errorString() );
        }
        root.ioBlocks = {};
        //root.classMap = {};
        for(var inputs in root.input) {
            createDynamicInputBlock(root.input[inputs], function(innerBlock) {
                var propName = root.input[inputs];
                var chSigNam = propName.charAt(0).toUpperCase();
                chSigNam += propName.substring(1);
                var theSignal = root.sourceElement["on"+chSigNam+"Changed"];
                theSignal.connect(function() { innerBlock.outp = root.sourceElement[propName];});
            });
        }
        for(var outputs in root.output) {
            createDynamicOutputBlock(root.output[outputs], function(innerBlock) {
                var myOut = outputs;
                innerBlock.onInpChanged.connect(function() {
                    root.sourceElement[root.output[myOut]] = innerBlock.inp;
                });
            });
        }
    }

    Flickable {
        id:flickable
        anchors.fill: parent
        contentHeight: zoomer.width*zoomer.myScale
        contentWidth: zoomer.height*zoomer.myScale
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickDeceleration: 99999.0
        rebound: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 0
            }
        }
        z:2
        Item {
            width: 5000
            height: 5000
            id: zoomer
            property alias myScale: zoomer.scale
            transformOrigin: Item.TopLeft
            Item {
                id: parentForBlocks
                anchors.fill: parent
                z:100
            }
            Item {
                id: parentForConnections
                property alias connectionsOwner: fullScreenMouseArea
                anchors.fill: parent
                z:5
            }
            Rectangle {
                anchors.fill: parent
                color: ColorTheme.backgroundColor
            }

            DropArea {
                id: dropArea
                anchors.fill: parent

                onDropped: {
                    if(! drop.source.myCompo) {
                        drop.accepted = false;
                        return;
                    }
//                    var xy = parentForBlocks.mapFromItem(drop.source.parent, drop.source.x, drop.source.y);
//                    var newBlock = root.blockComponent.createObject(parentForBlocks, {x: xy.x, y: xy.y, uniqueId:root.nextUniqueId});
//                    root.nextUniqueId++;
//                    var newBlockInner = drop.source.myCompo.createObject(newBlock.parentForInner, {});
//                    newBlock.inner = newBlockInner;
//                    newBlock.displayName = drop.source.text;
//                    newBlock.className = drop.source.currentClassName;
                    var xy = parentForBlocks.mapFromItem(drop.source.parent, drop.source.x, drop.source.y);
                    zoomer.createBlock(drop.source.currentClassName, xy.x, xy.y);
                }
            }
            function createBlock(className, x, y) {
                var newBlock = root.blockComponent.createObject(parentForBlocks, {x: x, y: y, uniqueId:root.nextUniqueId});
                root.nextUniqueId++;
                var blockItem = root.classMap[className];
                var blockCompo = blockItem.compo;
                var newBlockInner = blockCompo.createObject(newBlock.parentForInner, {});
                newBlock.inner = newBlockInner;
                newBlock.displayName = blockItem.displayName;
                newBlock.className = blockItem.className?blockItem.className:blockItem.displayName;
            }

            MouseArea {
                z:7
                id: fullScreenMouseArea
                preventStealing: true
                property var dragStartSlot: null
                property var connections
                property real mouseXLastClick
                property real mouseYLastClick
                Component.onCompleted: connections = {}
                anchors.fill: parent
                function getSlotAtMouse() {
                    var block = parentForBlocks.childAt(mouseX, mouseY);
                    if( block ) {
                        var mx = mouseX - block.x;
                        var my = mouseY - block.y;
                        var layout = block.childAt(mx, my);
                        if( layout ) {
                            mx -= layout.x;
                            my -= layout.y;
                            var slot = layout.childAt(mx, my);
                            if(slot && (slot.isInput || slot.isOutput)) {
                                return slot;
                            }
                        }
                    }
                    return null;
                }
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                propagateComposedEvents: true

                onClicked: {
                    mouse.accepted = false;
                }
                onMouseXChanged: {
                    previewConnection.lineEnd = {x:mouseX, y:mouseY};
                    previewConnection.requestPaint();
                }
                onMouseYChanged:{
                    previewConnection.lineEnd = {x:mouseX, y:mouseY};
                    previewConnection.requestPaint();
                }
                onWheel: {
                    if(!focus) {
                        return;
                    }

                    var oldScale = zoomer.myScale
                    var maxZoom = Math.max(flickable.width/zoomer.width, flickable.height/zoomer.height);
                    zoomer.myScale = Math.max(Math.min(zoomer.myScale + wheel.angleDelta.y*0.0005, 1.0), maxZoom);
                    flickable.contentX += mouseX*(zoomer.myScale-oldScale);
                    flickable.contentY += mouseY*(zoomer.myScale-oldScale);
                    flickable.returnToBounds();
                }
                onPressed: {
                    var slot = getSlotAtMouse();
                    if( slot ) {
                        forceActiveFocus();
                        dragStartSlot = slot;
                        var xy = fullScreenMouseArea.mapFromItem(slot, slot.width*0.5, slot.height*0.5);
                        previewConnection.lineStart = xy;
                    }
                    else if (mouse.button === Qt.RightButton)
                    {
                        mouseXLastClick = mouse.x;
                        mouseYLastClick = mouse.y;
                        //ctxMenu2.visible = true;
                        ctxMenu.visible = false;
                    } else {
                        ctxMenu2.visible = false;
                        forceActiveFocus();
                        mouse.accepted = false;
                    }
                }
                onReleased: {
                    //forceActiveFocus();
                    var slot = getSlotAtMouse();
                    if( slot && dragStartSlot) {
                        createConnection(dragStartSlot, slot);
                    }
                    dragStartSlot = null;
                }
                function createConnectionWithoutGraphic(inpSource, inpName, outSource, outpName) {
                    //TODO: use this for input output blocks. svae input output correctly
                }

                function createConnection(slot1, slot2) {
                    //can connect?
                    if(typeof slot1 === "undefined" || typeof slot2 === "undefined") {
                        return;
                    }
                    if(typeof slot1.parent === "undefined" || typeof slot2.parent === "undefined") {
                        return;
                    }
                    if(slot1.parent.parent === slot2.parent.parent) {
                        return;
                    }
                    if(!(slot1.isInput && slot2.isOutput || slot1.isOutput && slot2.isInput)) {
                        return;
                    }
                    var inp = slot1.isInput?slot1:slot2;
                    var outp = slot1.isOutput?slot1:slot2;
                    var typeIn = typeof inp.block[inp.propName];
                    var typeOut = typeof outp.block[outp.propName];
                    if(typeIn == "function" && typeOut !== "function" || typeIn !== "function" && typeOut == "function") {
                        return;
                    }
                    if(!connections[inp]) {
                        connections[inp] = {};
                    }
                    if(connections[inp][outp]) {
                        return;
                    }

                    if(typeIn == "function" && typeOut == "function") {
                        outp.block[outp.propName].connect(inp.block[inp.propName]);
                        // no initial call
                        //inp.block[inp.propName]();
                    } else {
                        //forbid multiple inputs?
                        Object.keys(connections[inp]).forEach(function(s2prop) {
                            // can have deleted connections
                            if(connections[inp].hasOwnProperty(s2prop)) {
                                if( connections[inp][s2prop] ) {
                                    connections[inp][s2prop].destroy();
                                }
                            }
                        });
                        connections[inp] = {};

                        var chSigNam = outp.propName.charAt(0).toUpperCase();
                        chSigNam += outp.propName.substring(1);
                        var theSignal = outp.block["on"+chSigNam+"Changed"];
                        // can occasionally cause an error when an event is fired while the signaltarget-block is deleted.
                        // no check is added here for performance
                        //Todo: other lazy behaviour: wait before sending first signal!
                        var fn;
                        if(inp.block.lazyConnect && (inp.block.lazyInputProps?inp.block.lazyInputProps.indexOf(inp.propName) !== -1:true)) {
                            fn = function() {
                                if( inp.lazyConnectTimer.running ) {
                                    return;
                                }
                                var timediff = Date.now() - inp.lazyConnectTimer.lastConnect;
                                var lazyInterval = inp.block.lazyInterval?inp.block.lazyInterval:1000;
                                if(timediff >= lazyInterval) {
                                    inp.block[inp.propName] = outp.block[outp.propName];
                                    inp.lazyConnectTimer.lastConnect = Date.now();
                                } else {
                                    inp.lazyConnectTimer.interval = lazyInterval - timediff;
                                    inp.lazyConnectTimer.start();
                                    inp.lazyConnectTimer.lastConnect -= 100; // ensure update will make it thru check next time
                                }
                            }
                            inp.lazyConnectTimer.onTriggered.connect(fn);
                        } else {
                            fn = function() { inp.block[inp.propName] = outp.block[outp.propName]; }
                        }
                        theSignal.connect( fn );
                        //initial set value
                        if(!outp.block.noInitialBind) {
                            fn();
                        }
                    }
                    var newConnection = root.connectionComponent.createObject(parentForConnections, {slot1: slot1, slot2: slot2, slotFunc: fn, startSignal: theSignal});
                    connections[inp][outp] = newConnection;
                    slot1.blockOuter.connections.push(newConnection);
                    slot2.blockOuter.connections.push(newConnection);
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Space) {
                        mouseXLastClick = mouseX;
                        mouseYLastClick = mouseY;
                        ctxMenu.visible = true;
                        ctxMenu2.visible = false;
                    }
                }
            }
            GraphBlocksConnection {
                z: 1
                id: previewConnection
                visible: fullScreenMouseArea.dragStartSlot != null
            }
            ContextMenu {
                id: ctxMenu
                x: fullScreenMouseArea.mouseXLastClick
                y: fullScreenMouseArea.mouseYLastClick
                z: 900
                width: 200
                height: 200
                visible: false
                //blocksModel: root.blocksModel
                onCreateBlock: {
                    zoomer.createBlock(block.className?block.className:block.displayName, x, y);
                    visible = false;
                }
            }
            RightClickMenu {
                id: ctxMenu2
                x: fullScreenMouseArea.mouseXLastClick
                y: fullScreenMouseArea.mouseYLastClick
                z: 900
                width: 200
                //height: 200
                visible: false
                options: [
                    { name: "nothing",
                        action: function() {
                            console.log("activated");
                        }
                    }
                ]
            }
        }
    }
}

