import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "qrc:/qml/theme/";
// input of superblock starts outside and goes inside directly to an inputblock.
// output of superblock starts at outputblock and goes outside to a normal block.
// Connection is always established from outside, slot-setup is done from inside.
// When IoBlock are created, their slots are published here.
// inputblock: input-slots become inputslots of superblock.
// outputblock: output-slots become outputslots of superblock.
// when input-connection is established: logical link goes directly to inner inputblock.
// when output-connection is established: logical link goes from outputblock to normal block.
// When ioblock is made private, outside connection is lost/destroyed.

Item {
    id: root
    property var input: []
    property var output: []
    property bool isDynamic: true

    Item {
        id: priv

        property var inputMap
        property var outputMap
        Component.onCompleted: {
            if(typeof(inputMap) == "undefined") {
                inputMap = {};
            }
            if(typeof(outputMap) == "undefined") {
                outputMap = {};
            }
        }
    }

    function makeSafeName( innerSlot ) {
        var name = innerSlot.blockOuter.displayName + innerSlot.blockOuter.uniqueId + innerSlot.propName;
        return name.replace(/[^\w]/gi, '_');
    }

    function removeBlockInput( innerSlot ) {
        console.log("poooodoodod");
        var pn = makeSafeName( innerSlot );
        console.log("search " + pn);
        for(var ii in priv.inputMap) {
            console.log("k: " + ii + " was " + priv.inputMap[ii].propName);
        }

        if(!priv.inputMap.hasOwnProperty( pn )) {
            return;
            //console.log("error while removing input");
        }
        console.log("sdsdsd");
        for( var conIdx in innerSlot.blockOuter.connections ) {
            console.log("schlop connection for slot" + innerSlot.propName);
            var con = innerSlot.blockOuter.connections[conIdx];
            console.log("neq connection for slot -> " + con.slot1.propName + " 2: " + con.slot2.propName);
            //TODO: they are not equal anymore becuase repeater reread them!
            //TODO: write own repeater
            if(con.slot1 === innerSlot || con.slot2 === innerSlot) {
                console.log("destroyed connection for slot");
                con.destroy();
            }
        }
        delete priv.inputMap[ pn ];
        var index1 = input.indexOf( pn );
        if (index1 > -1) {
            input.splice(index1, 1);
        }
        parent.outerBlock.redoLayout();
    }

    function removeBlockOutput( innerSlot ) {
        console.log("sdssweettttttt");
        var pn = makeSafeName( innerSlot );
        if(!priv.outputMap.hasOwnProperty( pn )) {
            return;
            //console.log("error while removing output");
        }
        console.log("sdseeee");
        for( var conIdx in innerSlot.blockOuter.connections ) {
            console.log("schlop2 connection for slot");
            var con = innerSlot.blockOuter.connections[conIdx];
            console.log("neqrrr connection for slot");
            if(con.slot1 == innerSlot || con.slot2 == innerSlot) {
                console.log("destroyed connection for slot");
                con.destroy();
            }
        }
        delete priv.outputMap[ pn ];
        var index1 = output.indexOf( pn );
        if (index1 > -1) {
            output.splice(index1, 1);
        }
        parent.outerBlock.redoLayout();
    }

    function addBlockOutput( innerSlot ) {
        var pn = makeSafeName( innerSlot );
        if(priv.outputMap.hasOwnProperty( pn )) {
            return false;
        }
        priv.outputMap[ pn ] = innerSlot;
        if(-1 == output.indexOf( pn )) {
            output.push( pn );
        }
        parent.outerBlock.redoLayout();
    }

    function addBlockInput( innerSlot ) {
        var pn = makeSafeName( innerSlot );
        if(priv.inputMap.hasOwnProperty( pn )) {
            return false;
        }
        priv.inputMap[ pn ] = innerSlot;
        if(-1 == input.indexOf( pn )) {
            console.log(" piso");
            console.log(" pushin " + pn + " is " + innerSlot.blockOuter.displayName + "." + innerSlot.propName);
            input.push( pn );
        }
        parent.outerBlock.redoLayout();
    }

    function getBlockInput( pn ) {
        if(!priv.inputMap.hasOwnProperty( pn )) {
            console.log("dynamic block input connection error for " + pn);
            return null;
        }
        return priv.inputMap[ pn ]
    }

    function getBlockOutput( pn ) {
        if(!priv.outputMap.hasOwnProperty( pn )) {
            console.log("dynamic block output connection error for " + pn);
            return null;
        }
        return priv.outputMap[ pn ]
    }
}

