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
        function removeBlockSlot( innerSlot, slotMap, slotArray, isInput ) {
            var pn = makeSafeName( innerSlot );

            if(!slotMap.hasOwnProperty( pn )) {
                return;
                //console.log("error while removing input");
            }
            var dynamicBlockOuter = root.parent.outerBlock;
            var outerSlotAboutToBeDeleted = dynamicBlockOuter.getSlot(pn, isInput);
            for( var conIdx in dynamicBlockOuter.connections ) {
                var con = dynamicBlockOuter.connections[conIdx];
                if(con.slot1 === outerSlotAboutToBeDeleted || con.slot2 === outerSlotAboutToBeDeleted) {
                    con.destroy();
                }
            }
            delete slotMap[ pn ];
            var index1 = slotArray.indexOf( pn );
            if (index1 > -1) {
                slotArray.splice(index1, 1);
            } else {
                console.log("Error while rmoving input. inconsistent input maps");
            }
            root.parent.outerBlock.redoLayout();
        }
    }

    function makeSafeName( innerSlot ) {
        var name = innerSlot.blockOuter.displayName + innerSlot.blockOuter.uniqueId + innerSlot.propName;
        return name.replace(/[^\w]/gi, '_');
    }

    function removeBlockInput( innerSlot ) {
        priv.removeBlockSlot( innerSlot, priv.inputMap, input, true);
    }

    function removeBlockOutput( innerSlot ) {
        priv.removeBlockSlot( innerSlot, priv.outputMap, output, false);
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

