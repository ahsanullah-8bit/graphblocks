import QtQuick 2.0
import QtQuick.Controls 1.3
import "qrc:/qml/theme/";
import Clipboard 1.0
import Library 1.0

//TODO: on deletion, all connections must be destroyed seperatly so they are disconnected. also blocks?
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
    function findAllConnectionsBetweenBlocks( blocks ) {
        var ret = [];
        var connections = parentForConnections.children;
        for(var l= 0 ; l < connections.length ; ++l) {
            var connection = connections[l];
            if(   -1 !== blocks.indexOf( connection.slot1.blockOuter )
               && -1 !== blocks.indexOf( connection.slot2.blockOuter )) {
                ret.push( connection );
            }
        }
        return ret;
    }
    function serializeBlocksAndConnections( blocks, recenter ) {
        serializeBlocks( blocks, findAllConnectionsBetweenBlocks( blocks ), recenter );
    }

    function saveBlockToLibrary( block ) {
        var serBlocks = serializeBlocks([block], [], true);
        if( Library.addGraphToLib("", block.displayName, JSON.stringify( serBlocks ) ) ) {
            var todo = {displayName: block.displayName, graph: serBlocks};
            importBlockToLib( todo );
        }
    }

    function serializeBlocks( blocks, connections, recenter ) {
        var objToSerialize = {blocks:[], connections:[]};

        var loadedOffsetX = 0, loadedOffsetY = 0;
        if(recenter) {
            var loadedOffsetXmin = 999999, loadedOffsetYmin = 999999;
            for(var i= 0 ; i < blocks.length ; ++i) {
                var block = blocks[i];
                loadedOffsetX = Math.max(loadedOffsetX, block.x + block.width);
                loadedOffsetY = Math.max(loadedOffsetY, block.y + block.height);
                loadedOffsetXmin = Math.min(loadedOffsetXmin, block.x);
                loadedOffsetYmin = Math.min(loadedOffsetYmin, block.y);
            }
            loadedOffsetX = (loadedOffsetX + loadedOffsetXmin) * 0.5;
            loadedOffsetY = (loadedOffsetY + loadedOffsetYmin) * 0.5;
        }

        for(var i= 0 ; i < blocks.length ; ++i) {
            var block = blocks[i];
            var serializedInner = block.inner.serialize?block.inner.serialize():{/*maybeTodo*/};
            var serializedBlock = {
                blockProto: {
                    x:block.x - loadedOffsetX,
                    y:block.y - loadedOffsetY,
                    displayName: block.displayName,
                    className: block.className?block.className:block.displayName,
                    uniqueId: block.uniqueId,
                    isInputBlock: block.isInputBlock,
                    isOutputBlock: block.isOutputBlock},
                innerProto: serializedInner};
            objToSerialize.blocks.push( serializedBlock );
        }
        if( connections ) {
            for(var l= 0 ; l < connections.length ; ++l) {
                var connection = connections[l];
                var serializedConnection = {
                    s1: connection.slot1.blockOuter.uniqueId,
                    pn1: connection.slot1.propName,
                    s1Inp: connection.slot1.isInput,
                    s2: connection.slot2.blockOuter.uniqueId,
                    pn2: connection.slot2.propName};
                objToSerialize.connections.push( serializedConnection );
            }
        }
        return objToSerialize;
    }
    function saveGraph() {
        return serializeBlocks( parentForBlocks.children, parentForConnections.children );
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
    function loadGraph(obj, offsetx, offsety, ignoreIo, recenter) {
        if( offsetx === undefined ) offsetx = 0;
        if( offsety === undefined ) offsety = 0;
        var startUniqueId = nextUniqueId;
        var blocks = obj.blocks;
        var connections = obj.connections;
        var savedUniqueIdToBlock = [];
        var ignoredBlocks = [];

        var xmax = 0, ymax = 0;
        var xmin = 999999, ymin = 999999;
        for(var i= 0 ; i < blocks.length ; ++i) {
            var block = blocks[i];
            xmax = Math.max(xmax, block.blockProto.x + 90);
            ymax = Math.max(ymax, block.blockProto.y + 50);
            xmin = Math.min(xmin, block.blockProto.x);
            ymin = Math.min(ymin, block.blockProto.y);
        }

        if(recenter) {
            var xcorr = (xmin + xmax) * 0.5;
            var ycorr = (ymin + ymax) * 0.5;
            offsetx -= xcorr;
            offsety -= ycorr;
            xmin -= xcorr;
            ymin -= ycorr;
            xmax -= xcorr;
            ymax -= ycorr;
        }
        if(offsetx - xmin < 0) {
            offsetx = xmin;
        }
        if(offsety - ymin < 0) {
            offsety = ymin;
        }

        for(var i= 0 ; i < blocks.length ; ++i) {
            var serBlock = blocks[i];
            if(!isEditingSuperblock && ( serBlock.blockProto.isInputBlock || serBlock.blockProto.isOutputBlock ) ) {
                if(ignoreIo) {
                    ignoredBlocks.push( serBlock.blockProto.uniqueId );
                    continue;
                }
                var ioBlock = ioBlocks[serBlock.blockProto.displayName];
                savedUniqueIdToBlock[serBlock.blockProto.uniqueId] = ioBlock;
                ioBlock.x = serBlock.blockProto.x + offsetx;
                ioBlock.y = serBlock.blockProto.y + offsety;
                continue;
            }
            serBlock.blockProto.x += offsetx;
            serBlock.blockProto.y += offsety;

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
            if( -1 !== ignoredBlocks.indexOf(connection.s1) || -1 !== ignoredBlocks.indexOf(connection.s2) ) {
                continue;
            }
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
                property alias blockContext: root
                id: parentForBlocks
                anchors.fill: parent
                z:100
            }
            Item {
                property alias connectionContext: root
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
                    if( drop.source.myCompo || drop.source.myGraph) {
                        var xy = parentForBlocks.mapFromItem(drop.source.parent, drop.source.x+drop.source.width*0.5, drop.source.y+drop.source.height*0.5);
                        //var xy = parentForBlocks.mapFromItem(fullScreenMouseArea, fullScreenMouseArea.mouseX, fullScreenMouseArea.mouseY);
                        zoomer.createBlock(drop.source, xy.x, xy.y);
                    } else {
                        drop.accepted = false;
                    }
                }
            }
            //blockinfo has either a component or graph member to instantiate a new block/graph
            //currentClassName: dragDrop, className: fromModel, myGraph: fromDragDrop: Textdelegate, graph: from Model directly: QWuickAccesssMenu
            function createBlock(blockInfo, x, y) {
                if( (blockInfo.graph || blockInfo.myGraph) && !(blockInfo.isClass || blockInfo.myIsClass) ) {
                    //console.log("mygr: " + blockInfo.displayName + " gr: " + blockInfo.graph + " js: " + JSON.stringify( blockInfo ));
                    root.loadGraph( blockInfo.myGraph?blockInfo.myGraph:blockInfo.graph, x, y, true, true);
                    return;
                }
                var className = blockInfo.currentClassName?blockInfo.currentClassName:blockInfo.className;
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
                // may be needed for completly graphicless graphs
                property var lazyTimers
                function getOrCreateLazyTimer(e1, e2, e3, e4) {
                    var a, b, c, d
                    if( !lazyTimers ) { lazyTimers = {}; }
                    if( lazyTimers.hasOwnProperty( e1 ) )  {
                        a = lazyTimers[ e1 ];
                    } else {
                        a = {};
                        lazyTimers[ e1 ] = a;
                    }
                    if( a.hasOwnProperty( e2 ) )  {
                        b = a[ e2 ];
                    } else {
                        b = {};
                        a[ e2 ] = b;
                    }
                    if( b.hasOwnProperty( e3 ) )  {
                        c = b[ e3 ];
                    } else {
                        c = {};
                        b[ e3 ] = c;
                    }
                    if( c.hasOwnProperty( e4 ) )  {
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

                function createLogicalConnection(inpElem, inpPropertyName, outpElem, outpPropertyName, initialBind, lazyProps) {
                    var typeIn = typeof inpElem[inpPropertyName];
                    var typeOut = typeof outpElem[outpPropertyName];
                    var fn;
                    var theSignal;
                    var disconnectLazyFn;
                    if(typeIn == "function" && typeOut == "function") {
                        fn = inpElem[ inpPropertyName ];
                        theSignal = outpElem[outpPropertyName];
                    } else {
                        fn = function() {
                            //TODO: typesafety
                            if( typeof( inpElem[inpPropertyName] ) === "number" && typeof( outpElem[outpPropertyName] ) === "undefined" ) {
                                outpElem[outpPropertyName] = 0;
                            }
                            inpElem[inpPropertyName] = outpElem[outpPropertyName];
                        };
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
                    theSignal.connect( fn );
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
                    var inpSrc = inp.block.isDynamic?inp.block.getBlockInput(inp.propName):inp;
                    var outpSrc = outp.block.isDynamic?outp.block.getBlockOutput(outp.propName):outp;

                    //TODO: remove is dynamic, loops of superblocks... recursive?!
                    var disconnectLogicalFn = createLogicalConnection(inpSrc.block, inpSrc.propName, outpSrc.block, outpSrc.propName, !outpSrc.block.noInitialBind, inpSrc.block);

                    var newConnection;
                    var disconnectFn = function() {
                        disconnectLogicalFn();
                        if(slot1 && slot2) {
                            //var con = connections[inp][outp];
                            //if( con ) {
                                delete connections[inp][outp];
                            //}
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
                    } else if(event.key === Qt.Key_V && (event.modifiers & Qt.ControlModifier) ) {
                        var cbdata = Clipboard.text;
                        if( cbdata === "") return;
                        var blocks = JSON.parse( cbdata );
                        root.loadGraph( blocks, mouseX, mouseY);
                    }
                }
            }
            Item {
                property alias connectionContext: root
                GraphBlocksConnection {
                    z: 1
                    id: previewConnection
                    visible: fullScreenMouseArea.dragStartSlot != null
                }
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
                    zoomer.createBlock(block, x, y);
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

