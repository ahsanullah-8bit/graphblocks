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
        //property var dynamicSlotNameToBlockUniqueIdAndInnerSlotName
        property var dynamicSlotNameToInnerSlot

        property var inputMap
        property var outputMap
        property var outputToChangedMethod
        Component.onCompleted: {
            if(typeof(inputMap) == "undefined") {
                inputMap = {};
            }
            if(typeof(outputMap) == "undefined") {
                outputMap = {};
            }
            if(typeof(outputToChangedMethod) == "undefined") {
                outputToChangedMethod = {};
            }
        }
    }

    function makeSafeName(name) {
        return name.replace(/[^\w]/gi, '_');
    }
    function removeBlockInput( propname ) {
        delete priv.inputMap[propname];
        var index1 = input.indexOf( propname );
        if (index1 > -1) {
            input.splice(index1, 1);
        }
        parent.outerBlock.redoLayout();
    }
    function removeBlockOutput( propname ) {
        delete priv.outputMap[propname];
        var index1 = output.indexOf( propname );
        if (index1 > -1) {
            output.splice(index1, 1);
        }
        parent.outerBlock.redoLayout();
    }

    function addBlockOutput( innerSlot ) {
        var pn = makeSafeName( innerSlot.blockOuter.displayName + innerSlot.propName );
        if(priv.outputMap.hasOwnProperty( pn )) {
            return false;
        }
        priv.outputMap[ pn ] = innerSlot;
        if(-1 == output.indexOf( pn )) {
            console.log(" puso");
            console.log(" pushou " + pn + " is " + innerSlot.blockOuter.displayName + "." + innerSlot.propName);
            output.push( pn );
        }
        parent.outerBlock.redoLayout();
    }

    function addBlockInput( innerSlot ) {
        var pn = makeSafeName( innerSlot.blockOuter.displayName + innerSlot.propName );
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
        //var pn = makeSafeName( innerSlot.block.displayName + innerSlot.propName );
        if(!priv.inputMap.hasOwnProperty( pn )) {
            console.log(" 22222");
            console.log("dynamic block input connection error for " + pn);
            return null;
        }
        return priv.inputMap[ pn ]
    }

    function getBlockOutput( pn ) {
        //var pn = makeSafeName( innerSlot.block.displayName + innerSlot.propName );
        if(!priv.outputMap.hasOwnProperty( pn )) {
            console.log(" wwwww");
            console.log("dynamic block output connection error for " + pn);
            return null;
        }
        return priv.outputMap[ pn ]
    }

    function setBlockInput( propname, value ) {
        console.log("got222 " );
        console.log("got " + propname + " to " + value );
        if(priv.inputMap[propname] !== value) {
            priv.inputMap[propname] = value;
        }
        //TODO
    }
    function setBlockOutput( propname, value ) {
        if(priv.outputMap[propname] !== value) {
            priv.outputMap[propname] = value;
            if(priv.outputToChangedMethod[propname] === "undefined") {
                priv.outputToChangedMethod[propname]( value );
            }
        }
    }
    function connectToChangedSignal(propname, fn) {
        var oldfn = priv.outputToChangedMethod[propname];
        if( typeof(oldfn) === "function") {
            priv.outputToChangedMethod[propname] = function( value ) { fn( value ); oldfn( value ); };
        } else {
            priv.outputToChangedMethod[propname] = fn;
        }
    }
}

