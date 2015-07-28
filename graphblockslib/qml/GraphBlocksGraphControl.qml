import QtQuick 2.0
import QtQuick.Controls 1.3
import "qrc:/qml/theme/";

Item {
    id: root
    z: -100

    property bool isEditingSuperblock: false

    property var input
    property var output

    property var sourceElement: root

    property var ioBlocks

    property var classMap
    property alias blocksModel: quickAccessMenu.blocksModel
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
        id: blockInpCompo
        Item {
            property var output: ["outp"]
            property var outp
        }
    }
    Component {
        id: blockOutpCompo
        Item {
            property var input: ["inp"]
            property var inp
        }
    }
    property real nextInY: 100
    property real nextOutY: 100
    function createInputBlock(displayName, setupInner) {
        var newBlock = createSpecialBlock(blockInpCompo, {x: 100, y: nextInY, displayName: displayName, className: "in_"+displayName, editable: false, isInputBlock: true}, setupInner);
        nextInY += 50;
        ioBlocks[displayName] = newBlock; // ioBlocks is used to identify block when file is loaded (in/out blocks persist!)
    }
    function createOutputBlock(displayName, setupInner) {
        var newBlock = createSpecialBlock(blockOutpCompo, {x: 400, y: nextOutY, displayName: displayName, className: "out_"+displayName, editable: false, isOutputBlock: true}, setupInner);
        nextOutY += 50;
        ioBlocks[displayName] = newBlock;
    }
    function createDynamicBlock(displayName, xp, yp, displayName ) {
        var newBlock = createSpecialBlock(blockOutpCompo, {x: xp, y: yp, displayName: displayName}, {});
        return newBlock.inner;
    }

    function createSpecialBlock(blockCompo, proto, setupInner) {
        var newBlock = root.blockComponent.createObject(parentForBlocks, proto);
        newBlock.uniqueId += nextUniqueId;
        newBlock.contextMenu = globalContextMenu;
        nextUniqueId++;
        var newBlockInner = blockCompo.createObject(newBlock.parentForInner, {});
        setupInner(newBlockInner);
        newBlock.inner = newBlockInner;
        if(typeof(newBlockInner.initialize) === "function") {
            newBlockInner.initialize();
        }
        return newBlock;
    }

    function blockIoChanged( block ) {
        if( !isEditingSuperblock ) {
            return;
        }
        var so;
        var si;
        if( block.isInputBlock ) {
            for(so in block.slotsOut) {
                sourceElement.removeBlockOutput( block.slotsOut[so] );
            }
            for(si in block.slotsIn) {
                sourceElement.addBlockInput( block.slotsIn[si] );
            }
        } else if( block.isOutputBlock ) {
            for(si in block.slotsIn) {
                sourceElement.removeBlockInput( block.slotsIn[si] );
            }
            for(so in block.slotsOut) {
                sourceElement.addBlockOutput( block.slotsOut[so] );
            }
        } else {
            for(si in block.slotsIn) {
                sourceElement.removeBlockInput( block.slotsIn[si] );
            }
            for(so in block.slotsOut) {
                sourceElement.removeBlockOutput( block.slotsOut[so] );
            }
        }
    }
    function loadGraph(obj, offset) {
        var startUniqueId = nextUniqueId;
        var blocks = obj.blocks;
        var connections = obj.connections;
        var savedUniqueIdToBlock = [];
        for(var i= 0 ; i < blocks.length ; ++i) {
            var serBlock = blocks[i];
            if(!isEditingSuperblock && ( serBlock.blockProto.isInputBlock || serBlock.blockProto.isOutputBlock ) ) {
                var ioBlock = ioBlocks[serBlock.blockProto.displayName];
                savedUniqueIdToBlock[serBlock.blockProto.uniqueId] = ioBlock;
                ioBlock.x = serBlock.blockProto.x;
                ioBlock.y = serBlock.blockProto.y;
                continue;
            }

            var newBlock = root.blockComponent.createObject(parentForBlocks, serBlock.blockProto);
            newBlock.uniqueId += startUniqueId;
            newBlock.contextMenu = globalContextMenu;
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
                if(typeof(newBlockInner.initialize) === "function") {
                    newBlockInner.initialize();
                }
                blockIoChanged( newBlock );
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
        for(var inputs in root.input) {
            var dni = root.input[inputs].charAt(0).toUpperCase() + root.input[inputs].slice(1);
            createInputBlock(dni, function(innerBlock) {
                var propName = root.input[inputs];
                var disconnectLogicalFn = fullScreenMouseArea.createLogicalConnection( innerBlock, "outp", root.sourceElement, propName );
                // never disconnected, ioblock persist!
            });
        }
        for(var outputs in root.output) {
            var dno = root.output[outputs].charAt(0).toUpperCase() + root.output[outputs].slice(1);
            createOutputBlock(dno, function(innerBlock) {
                var propName = root.output[outputs];
                var disconnectLogicalFn = fullScreenMouseArea.createLogicalConnection( root.sourceElement , propName, innerBlock, "inp" );
                // never disconnected, ioblock persist!
            });
        }
    }

    Button {
        x: 10
        y: 10
        z:901
        id: breadcrumb
        visible: isEditingSuperblock
        text: "Back"
        onClicked: {
            root.visible = false;
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
                newBlock.contextMenu = globalContextMenu;
                var blockItem = root.classMap[className];
                var blockCompo = blockItem.compo;
                var newBlockInner = blockCompo.createObject(newBlock.parentForInner, {});
                newBlock.inner = newBlockInner;
                if(typeof(newBlockInner.initialize) === "function") {
                    newBlockInner.initialize();
                }
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
                        globalContextMenu.visible = false;
                        mouseXLastClick = mouse.x;
                        mouseYLastClick = mouse.y;
                    } else {
                        globalContextMenu.visible = false;
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
                    //TODO: use this for input output blocks. save input output correctly
                }
                Component {
                    id: lazyTimerComponent
                    Timer {
                        repeat: false
                    }
                }
                Item {
                    //TODO: connection deletion -> timer deletion!
                    id: lazyConnectionTimers
                }
                //TODO: Hopefully never called due to "lazyProps"-objects containing lazyTimers
                property var lazyTimers
                function getOrCreateLazyTimer(e1, e2, e3, e4) {
                    var a, b, c, d
                    if( !lazyTimers ) { lazyTimers = {}; }
                    if( lazyTimers.contains( e1 ) )  {
                        a = lazyTimers[ e1 ];
                    } else {
                        a = {};
                        lazyTimers[ e1 ] = a;
                    }
                    if( a.contains( e2 ) )  {
                        b = a[ e2 ];
                    } else {
                        b = {};
                        a[ e2 ] = b;
                    }
                    if( b.contains( e3 ) )  {
                        c = b[ e3 ];
                    } else {
                        c = {};
                        b[ e3 ] = c;
                    }
                    if( c.contains( e4 ) )  {
                        d = c[ e4 ];
                    } else {
                        d = lazyTimerComponent.createObject( lazyConnectionTimers );
                        c[ e4 ] = d;
                    }
                    return d;
                }

                // returns, wether a function only connection could be established
                // (caller can decide, to destroy old value connections in the case)
                function shouldRemoveOldConnections(typeIn, typeOut) {
                    return typeIn !== "function" || typeOut !== "function";
                }

                function canConnect(typeIn, typeOut) {
                    // call function on value change is usually not allowed
                    if(typeIn === "function" && typeOut !== "function") return false;
                    //set value on to functioncall is impossible
                    if(typeIn !== "function" && typeOut === "function") return false;
                    return true;
                }

                function createLogicalConnection(inpElem, inpPropertyName, outpElem, outpPropertyName, initialBind, lazyProps, inpDyn, outpDyn) {
                    var typeIn = typeof inpElem[inpPropertyName];
                    var typeOut = typeof outpElem[outpPropertyName];
                    var fn;
                    var theSignal;
                    var disconnectLazyFn;
                    //Note: superblock + functions/event/fire not implemented yet
                    if( inpDyn && outpDyn ) {
                        fn = function( val ) { inpElem.setBlockInput(inpPropertyName, val); };
                    } else if( inpDyn && !outpDyn ) {
                        fn = function() { inpElem.setBlockInput(inpPropertyName, outpElem[outpPropertyName]); };
                    } else if( !inpDyn && outpDyn ) {
                        fn = function( val ) { inpElem[inpPropertyName] = val };
                    } else if(typeIn == "function" && typeOut == "function") {
                        fn = inpElem[ inpPropertyName ];
                        theSignal = outpElem[outpPropertyName];
                    } else {
                        fn = function() { inpElem[inpPropertyName] = outpElem[outpPropertyName]; };
                    }
                    //if the Signal is not special for functions or dynamic Output, use the most common case (change event) ...
                    if( !outpDyn && !theSignal ) {
                        var chSigNam = outpPropertyName.charAt(0).toUpperCase();
                        chSigNam += outpPropertyName.substring(1);
                        theSignal = outpElem["on"+chSigNam+"Changed"];
                    }
                    if(lazyProps && lazyProps.lazyConnect && (lazyProps.lazyInputProps?lazyProps.lazyInputProps.indexOf(inpPropertyName) !== -1:true)) {
                        var lazyConnectTimer = lazyProps.lazyConnectTimer?lazyProps.lazyConnectTimer:getOrCreateLazyTimer(inpElem, inpPropertyName, outpElem, outpPropertyName);
                        lazyConnectTimer.onTriggered.connect( fn );
                        var lazyFn = fn;
                        disconnectLazyFn = function() { lazyConnectTimer.onTriggered.disconnect( lazyFn ) };
                        fn = function() {
                            var lazyInterval = lazyProps.lazyInterval?lazyProps.lazyInterval:1000;
                            var onlyIfNoChange = lazyProps.onlyResting; //only set value, if x sec no change occured
                            if( lazyConnectTimer.running) {
                                if( onlyIfNoChange ) {
                                    lazyConnectTimer.restart();
                                }
                            } else {
                                lazyConnectTimer.interval = lazyInterval;
                                lazyConnectTimer.start();
                            }
                        }
                    }
                    if( theSignal ) {
                        theSignal.connect( fn );
                    } else if( outpDyn ) {
                        outpElem.connectToChangedSignal( fn );
                    } else {
                        console.log( "Error, signal not available." );
                    }
                    //initial set value
                    if( initialBind ) {
                        fn();
                    }
                    //// construct destruction method, that must be called to unconnect
                    var disconnectLogical = function() {
                        if( outpElem && theSignal ) {
                            theSignal.disconnect( fn );
                        }
                        if( disconnectLazyFn ) { disconnectLazyFn(); }
                    };
                    return disconnectLogical;
                }

                function createConnection(slot1, slot2) {
                    // input: value is input of a channel. value is set by connection. goes out of connection.
                    // output: value is output of channel. value is received/read by connection.
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

                    if(!connections[inp]) {
                        connections[inp] = {};
                    }
                    if(connections[inp][outp]) {
                        return;
                    }
                    if(!canConnect(typeIn, typeOut)) return;

                    if( shouldRemoveOldConnections(typeIn, typeOut) ) {
                        //forbid multiple inputs? yes!
                        Object.keys(connections[inp]).forEach(function(s2prop) {
                            // can have deleted connections
                            if(connections[inp].hasOwnProperty(s2prop)) {
                                if( connections[inp][s2prop] ) {
                                    connections[inp][s2prop].destroy(); // will trigger removal of logical connection
                                }
                            }
                        });
                        connections[inp] = {};
                    }
                    console.log("fetching inp " + (inp.block.isDynamic?inp.propName:"nonon"));
                    console.log("fetching oup " + (outp.block.isDynamic?outp.propName:"nono"));
                    var inpSrc = inp.block.isDynamic?inp.block.getBlockInput(inp.propName):inp;
                    var outpSrc = outp.block.isDynamic?outp.block.getBlockOutput(outp.propName):outp;

                    //TODO: remove is dynamic, loops of superblocks... recursive?!
                    var disconnectLogicalFn = createLogicalConnection(inpSrc.block, inpSrc.propName, outpSrc.block, outpSrc.propName, !outpSrc.block.noInitialBind, inpSrc.block, inpSrc.block.isDynamic, outpSrc.block.isDynamic);

                    var newConnection;
                    var disconnectFn = function() {
                        disconnectLogicalFn();
                        if(slot1 && slot2) {
                            delete connections[inp][outp];
                        } else {
                            if( fullScreenMouseArea ) {
                                Object.keys(connections).forEach(function(inp) {
                                    Object.keys(connections[inp]).forEach(function(outp) {
                                        // can have deleted connections
                                        if(connections[inp].hasOwnProperty(outp)) {
                                            if(connections[inp][outp] === newConnection) {
                                                delete connections[inp][outp];
                                            }
                                        }
                                    })
                                });
                            }
                        }
                        if(slot1) {
                            var index1 = slot1.blockOuter.connections.indexOf( newConnection );
                            if (index1 > -1) {
                                slot1.blockOuter.connections.splice(index1, 1);
                            }
                        }
                        if(slot2) {
                            var index2 = slot2.blockOuter.connections.indexOf( newConnection );
                            if (index2 > -1) {
                                slot2.blockOuter.connections.splice(index2, 1);
                            }
                        }
                    }

                    newConnection = root.connectionComponent.createObject(parentForConnections, {slot1: slot1, slot2: slot2, /*slotFunc: fn, startSignal: theSignal,*/ contextMenu: globalContextMenu, disconnectionMethod: disconnectFn });
                    connections[inp][outp] = newConnection;
                    slot1.blockOuter.connections.push(newConnection);
                    slot2.blockOuter.connections.push(newConnection);
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Space) {
                        mouseXLastClick = mouseX;
                        mouseYLastClick = mouseY;
                        quickAccessMenu.visible = true;
                        globalContextMenu.visible = false;
                    }
                }
            }
            GraphBlocksConnection {
                z: 1
                id: previewConnection
                visible: fullScreenMouseArea.dragStartSlot != null
            }
            QuickAccessMenu {
                id: quickAccessMenu
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
                settings: root
                id: globalContextMenu
                x: fullScreenMouseArea.mouseXLastClick
                y: fullScreenMouseArea.mouseYLastClick
                z: 900
                width: 200
                //height: 200
                visible: false
//                options: [
//                    { name: "nothing",
//                        action: function() {
//                            console.log("activated");
//                        }
//                    }
//                ]
            }
        }
    }
}

