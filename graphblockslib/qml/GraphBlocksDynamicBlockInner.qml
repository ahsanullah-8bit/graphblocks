import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import "qrc:/qml/theme/";

Item {
    id: root
    property var input: []
    property var output: []
    property bool isDynamic: true

    Item {
        id: priv
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

    function addBlockOutput( propname ) {
        var pn = makeSafeName( propname );
        if(priv.inputMap.hasOwnProperty( pn )) {
            return false;
        }
        priv.inputMap[ pn ] = null;
        if(-1 == input.indexOf( pn )) {
            console.log(" pushin " );
            input.push( pn );
        }
        parent.outerBlock.redoLayout();
    }

    function addBlockInput( propname ) {
        var pn = makeSafeName( propname );
        if(priv.outputMap.hasOwnProperty( pn )) {
            return false;
        }
        priv.outputMap[ pn ] = null;
        if(-1 == output.indexOf( pn )) {
            console.log(" pushin ");
            output.push( pn );
        }
        parent.outerBlock.redoLayout();
    }

    function setBlockInput( propname, value ) {
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

